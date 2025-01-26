//
//  PassportPhotoView.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//

import SwiftUI

struct PassportPhotoView: View {
    @Binding var selectedImage: UIImage?
    @State var Title = "photo"
    @State private var showPhotoPicker = false
    @State private var showPreview = false
    var Remove: (() -> Void)

    var body: some View {

            VStack {
                HStack(spacing: 15) {
                    Image("document-text")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            showPhotoPicker = true
                        }
                    
                    // عنوان وأزرار التحكم
                    HStack(spacing: 4) {
                        Text(Title)
                            .foregroundColor(.black)
                            .font(Font.system(size: ControlWidth(16)))
                            .onTapGesture {
                                showPhotoPicker = true
                            }
                        
                        Spacer()
                        Spacer()

                        if selectedImage != nil {
                            HStack(spacing: 15) {
                                Button(action: {
                                    showPreview = true
                                }) {
                                    Text("Preview")
                                        .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                                        .font(Font.system(size: ControlWidth(14)).bold())
                                }
                                
                                Button(action: {
                                    Remove()
                                }) {
                                    Text("Delete")
                                        .foregroundColor(rgbToColor(red: 218, green: 20, blue: 20))
                                        .font(Font.system(size: ControlWidth(14)).bold())
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .background(rgbToColor(red: 255, green: 255, blue: 255))
            }
        
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showPreview) {
            if let image = selectedImage {
                PassportPhotoPreview(image: image)
            }
        }
    }
}

// شاشة معاينة الصورة
struct PassportPhotoPreview: View {
    @Environment(\.presentationMode) var presentationMode
    let image: UIImage
    
    var body: some View {
        NavigationView {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .navigationBarTitle("Passport Photo", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

