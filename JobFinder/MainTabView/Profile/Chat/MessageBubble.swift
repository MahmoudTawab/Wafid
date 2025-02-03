//
//  MessageBubble.swift
//  Wafid
//
//  Created by almedadsoft on 26/01/2025.
//

import SwiftUI
import Firebase
import Foundation
import SDWebImage
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI
import AVFoundation
import MapKit
import CoreLocation

// MessageBubble.swift
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    let isOnline:Bool
    let currentImage: String
    let recipientImage: String
    @State var timestamp = String()
    
    @State var image = Image("")
    @State var imageVideo = Image("")
    var ShowImage: (_ image:Image) -> Void
    
    @State private var showVideoPlayer = false

    @State private var showMap = false
    
    var body: some View {
        HStack(spacing: 2) {
            if !isCurrentUser {
                VStack {
                    ZStack(alignment: .bottomTrailing) {
                        WebImage(url: URL(string: recipientImage)) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.black.opacity(0.8))
                        }
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(isOnline ? rgbToColor(red: 60, green: 177, blue: 106) : rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 1)
                        )
                        .shadow(color: isOnline ? rgbToColor(red: 60, green: 177, blue: 106) : rgbToColor(red: 193, green: 140, blue: 70), radius: 2, x: 0.5, y: 0.5)
                        .padding(.leading, 2)
                        .padding(.trailing, 8)
                        
                        if isOnline {
                            Circle()
                                .fill(rgbToColor(red: 60, green: 177, blue: 106))
                                .frame(width: 9, height: 9)
                                .overlay(RoundedRectangle(cornerRadius: 25)
                                    .stroke(.white, lineWidth: 1.5))
                                .offset(x: -5, y: -2)
                        }
                    }
                    .padding(.trailing, 3)
                    
                    Spacer()
                }
            }
            
            if isCurrentUser { Spacer() }
            
            if message.messageType == .video || message.messageType == .image {
                ZStack(alignment: .bottomTrailing) {
                    if message.messageType == .video {
                        imageVideo
                            .resizable()
                            .frame(maxHeight: 300)
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            )
                    } else if message.messageType == .image {
                        WebImage(url: URL(string: message.content)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .onSuccess { image, cacheType,arg  in
                        self.image = Image(uiImage: image)
                        }
                        .frame(maxHeight: 300)
                    }
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text(timestamp)
                            .padding(6)
                            .foregroundColor(.white)
                            .font(Font.system(size: 11))

                        if isCurrentUser {
                            Image(message.isRead ? "Read" : "NotRead")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.3)) // الخلفية
                    .clipShape(RoundedRectangle(cornerRadius: 8)) // تطبيق الكورنر راديوس
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 1, y: 1)
                    .frame(height: 26)

                }
                .background(isCurrentUser ? rgbToColor(red: 193, green: 140, blue: 70) : rgbToColor(red: 247, green: 247, blue: 247))
                .cornerRadius(10)
                .onTapGesture {
                    if message.messageType == .video {
                        showVideoPlayer = true
                    } else {
                        ShowImage(image)
                    }
                }
                .sheet(isPresented: $showVideoPlayer) {
                    if message.messageType == .video {
                        VideoPlayerView(videoURL: message.content)
                    }
                }
            }else if message.messageType == .file {
                HStack(alignment: .bottom) {
                HStack(alignment: .top) {
                        Image(systemName: "doc.fill")
                            .padding(.leading)
                            .foregroundColor(isCurrentUser ?  .white : rgbToColor(red: 27, green: 26, blue: 87))
                        
                        Text(getFileName(from: message.content) ?? "File")
                            .foregroundColor(isCurrentUser ?  .white : rgbToColor(red: 27, green: 26, blue: 87))
                        
                        Spacer(minLength: 5)
                }
                    
                    HStack(alignment: .center, spacing: 5) {
                        Text(timestamp)
                            .offset(x: isCurrentUser ? 1 : 0,y:3)
                            .background(.clear)
                            .font(Font.system(size: ControlWidth(11)))
                            .shadow(color: .black.opacity(0.6), radius: 10, x: 2, y: 4)
                            .foregroundColor(isCurrentUser ?  .white : rgbToColor(red: 27, green: 26, blue: 87))
                        
                        if isCurrentUser {
                            Image(message.isRead ? "Read" : "NotRead")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .offset(y: 3)
                                .frame(width: 12,height:12)
                                .foregroundColor(.white)
                        }
                    }.padding(.trailing,6)
    
                }
                .padding(.vertical)
                .background(isCurrentUser ? rgbToColor(red: 193, green: 140, blue: 70) : rgbToColor(red: 247, green: 247, blue: 247))
                .cornerRadius(isCurrentUser ? 0:10)
                .clipShape(CustomRoundedShape(corners: [.topLeft, .topRight, .bottomLeft], radius: isCurrentUser ? 10:0))
                .clipped()
    
                .onTapGesture {
                openFile(urlString: message.content)
                }
                
                }else if message.messageType == .location {
                let locationComponents = message.content.split(separator: ",")
                let latitude = Double(locationComponents[0]) ?? 0.0
                let longitude = Double(locationComponents[1]) ?? 0.0
                    
                ZStack(alignment: .bottomTrailing) {
                    MapSnapshotView(latitude: latitude, longitude: longitude)
                
                    HStack(alignment: .center, spacing: 0) {
                        Text(timestamp)
                            .padding(6)
                            .foregroundColor(.white)
                            .font(Font.system(size: ControlWidth(11)))

                        if isCurrentUser {
                            Image(message.isRead ? "Read" : "NotRead")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.3)) // الخلفية
                    .clipShape(RoundedRectangle(cornerRadius: 8)) // تطبيق الكورنر راديوس
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 1, y: 1)
                    .frame(height: 26)
                }
                .onTapGesture {
                    showMap = true
                }
                .sheet(isPresented: $showMap) {
                    LocationMapView(
                        latitude: latitude,
                        longitude: longitude,
                        isPresented: $showMap
                    )
                }
                .background(isCurrentUser ? rgbToColor(red: 193, green: 140, blue: 70) : rgbToColor(red: 247, green: 247, blue: 247))
                .cornerRadius(10)
                }else if message.messageType == .text {
                ZStack(alignment: .bottomTrailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(message.content)
                            .background(.clear)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(isCurrentUser ? .white : rgbToColor(red: 27, green: 26, blue: 87))
                    }
                    .padding(.bottom, 20)
                    Spacer()
                    
                    Text(timestamp)
                        .padding(.trailing, isCurrentUser ? 10:0)
                        .offset(x: isCurrentUser ? 1 : 3, y: 3)
                        .background(.clear)
                        .font(Font.system(size: ControlWidth(11)))
                        .foregroundColor(isCurrentUser ? .white : rgbToColor(red: 161, green: 161, blue: 188))
                    
                    if isCurrentUser {
                        Image(message.isRead ? "Read" : "NotRead")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .offset(x: 6, y: 3)
                            .padding(.trailing, 0)
                            .frame(width: 12,height:12)
                            .foregroundColor(.white)
                    }
                    
                }
                .padding()
                .background(isCurrentUser ? rgbToColor(red: 193, green: 140, blue: 70) : rgbToColor(red: 247, green: 247, blue: 247))
                .cornerRadius(10)
            }

            if !isCurrentUser { Spacer() }
            
            if isCurrentUser {
                VStack {
                    Spacer()
                    
                    ZStack(alignment: .bottomTrailing) {
                        WebImage(url: URL(string: currentImage)) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.black.opacity(0.8))
                        }
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(rgbToColor(red: 60, green: 177, blue: 106), lineWidth: 1)
                        )
                        .shadow(color: rgbToColor(red: 60, green: 177, blue: 106), radius: 2, x: 0.5, y: 0.5)
                        .padding(.leading, 2)
                        .padding(.trailing, 8)
                        
                        Circle()
                            .fill(rgbToColor(red: 60, green: 177, blue: 106))
                            .frame(width: 9, height: 9)
                            .overlay(RoundedRectangle(cornerRadius: 25)
                                .stroke(.white, lineWidth: 1.5))
                            .offset(x: -5, y: -2)
                    }
                    .padding(.leading, 5)
                }
            }
        }
        .padding(.bottom, 8)
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            self.timestamp = formatter.string(from: message.timestamp)
            
            if message.messageType == .video {
                getThumbnailURL(videoURL: message.content)
            }
        }
        
    }


    private func getThumbnailURL(videoURL: String) {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: videoURL) else {
                semaphore.signal()
                return
            }
            
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            do {
                // Generate thumbnail at 1 second mark
                let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                self.imageVideo = Image(uiImage: thumbnail)
            } catch {
                print("Thumbnail generation error: \(error.localizedDescription)")
                semaphore.signal()
            }
        }
    }
    
    
    private func openFile(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Implement file opening logic
        // This might involve downloading the file or using UIDocumentInteractionController
        let documentInteractionController = UIDocumentInteractionController(url: url)
        documentInteractionController.presentOptionsMenu(from: .zero, in: UIApplication.shared.windows.first!.rootViewController!.view, animated: true)
    }
    
    func getFileName(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url) else {
            print("Invalid URL")
            return nil
        }
        
        // استخراج مسار الملف
        guard let path = urlComponents.path.removingPercentEncoding else {
            print("Unable to decode URL path")
            return nil
        }
        
        // تقسيم المسار واستخراج آخر جزء (اسم الملف)
        let components = path.split(separator: "/")
        if let fileName = components.last {
            return String(fileName)
        }
        
        return nil
    }

}
