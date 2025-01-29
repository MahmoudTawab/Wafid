//
//  ChatView.swift
//  Wafid
//
//  Created by almedadsoft on 21/01/2025.
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

// ChatView.swift
struct ChatView: View {
    @State private var isEmoji: Bool = false
   
    @State private var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    let chatId: String
    let currentUserId: String
    let recipientId: String
    let currentImage: String
    let recipientImage: String
    let currentMail: String
    let recipientMail:String
    
    @State var image = Image("")
    @State var showImageViewer = false
    @State private var showImagePicker = false
    
    @State private var showVideoSourceMenu = false
    @State private var selectedVideo: URL?
    @State private var showVideoPicker = false
    
    @State private var showFilePicker = false
    @State private var selectedFile: URL?

    @State private var showLocationPicker = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var uploadProgress: Double = 0
    @State private var isUploading: Bool = false
    
    @StateObject private var callManager = CallManager.shared

    var body: some View {
        VStack {
                HStack(spacing: 10) {
                    Image("Icon")
                        .resizable()
                        .frame(width: 30,height: 30)
                        .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                    
                    VStack(alignment: .leading,spacing: 0) {
                        Text(recipientMail)
                            .font(Font.system(size: ControlWidth(15)).weight(.heavy))
                            .foregroundColor(.black)
                        
                        HStack {
                            Circle()
                                .fill(viewModel.userStatus == "Online" ? rgbToColor(red: 60, green: 177, blue: 106):.gray)
                                .frame(width: 7, height: 7)
                            
                            Text(viewModel.userStatus)
                                .font(Font.system(size: ControlWidth(10)))
                                .foregroundColor(viewModel.userStatus == "Online" ? rgbToColor(red: 60, green: 177, blue: 106):.gray)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 25) {
                        Button(action: {
                            callManager.startVideoCall(
                                currentUserId: currentUserId,
                                recipientUserId: recipientId,
                                callerName: currentMail,
                                receiverName: recipientMail
                            )
                        }) {
                            Image(systemName: "video")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                        }

//                        Button(action: {
//                            callManager.startAudioCall(
//                                currentUserId: currentUserId,
//                                recipientUserId: recipientId,
//                                callerName: currentMail,
//                                receiverName: recipientMail
//                            )
//                        }) {
//                            Image(systemName: "phone")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 22, height: 22)
//                                .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
//                        }
                    }
                    .background(Color.clear)
                }
                .offset(y:-30)
                .padding(.horizontal)
            
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message, isCurrentUser: message.sender == currentUserId, isOnline: viewModel.is_online, currentImage: currentImage, recipientImage: recipientImage) { image in
                                self.image = image
                                showImageViewer = true
                            }
                            .padding(.horizontal)
                            .id(message.id) // Add id for scrolling
                        }
                    }
                    .padding(.top, 5)
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        scrollProxy = proxy
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .offset(y:-25)
            
            if isUploading {
                HStack(spacing: 10) {
                ActivityIndicator(isAnimating: $isUploading) // اللودر
                    
                Text("Loading...") // النص المكتوب بجانب اللودر
                .font(.headline)
                .foregroundColor(.gray)
                Spacer()
                }
                .padding(.horizontal)
            }
            
            HStack(alignment: .bottom) {
                Button(action: {
                    isEmoji.toggle()
                }) {
                    Image("Frame")
                        .resizable()
                        .frame(width: 28,height: 28)
                }
                
                
                EmojiTextView(text: $messageText, placeholder: "write a message...", isEmoji: $isEmoji)
                    .background(Color.clear)
                    .frame(minHeight: 30, maxHeight: 190)
                    .frame(width: UIScreen.main.bounds.width - 140,height: calculateTextViewHeight())
                    .tint(rgbToColor(red: 193, green: 140, blue: 70))
                
                
                Button(action: {
                    showVideoSourceMenu = true
                }) {
                    Image("Frame 2")
                        .resizable()
                        .frame(width: 25,height: 25)
                }
                .confirmationDialog("Send Media", isPresented: $showVideoSourceMenu, titleVisibility: .visible) {
                    Button("Photo") {
                        showImagePicker = true
                    }
                    Button("Video") {
                        showVideoPicker = true
                    }
                    Button("File") {
                    showFilePicker = true
                    }
                    Button("Location") {
                    showLocationPicker = true
                    }
                }
                
                Button(action: {
                    guard !messageText.isEmpty else { return }
                    
                    viewModel.createNewChat(currentImage: currentImage,recipientImage: recipientImage , currentUserId: currentUserId, currentMail: currentMail, recipientId: recipientId, recipientMail: recipientMail, initialMessage: messageText)
                    messageText = ""
                }) {
                    Image("Group")
                        .resizable()
                        .frame(width: 40,height: 40)
                }
                .offset(y:8)
                .opacity(!messageText.isEmpty ? 1:0.6)
                .disabled(!messageText.isEmpty ? false:true)
                
            }
            .offset(y:-15)
            .padding(.horizontal)
        }
        .preferredColorScheme(.light)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .onTapGesture {
            hideKeyboard()
        }
        
        .overlay(ImageViewer(image: $image, viewerShown: self.$showImageViewer, aspectRatio: .constant(1)))
        
        .onAppear {
            viewModel.fetchUserStatus(userId: recipientId)
            viewModel.listenToMessages(chatId: chatId, currentUserId: currentUserId,recipientId:recipientId)
        }
        
        ///
        .sheet(isPresented: $showImagePicker, onDismiss: uploadSelectedImage) {
        ImagePicker(image: $selectedImage)
        }
        
        ///
        .sheet(isPresented: $showVideoPicker) {
            VideoPicker(selectedVideoURL: $selectedVideo)
        }
        .onChange(of: selectedVideo) { videoURL in
            guard let url = videoURL else { return }
            uploadVideo(url)
        }
        
        ///
        .sheet(isPresented: $showFilePicker) {
        DocumentPicker(selectedFile: $selectedFile)
        }
        .onChange(of: selectedFile) { fileURL in
        guard let url = fileURL else { return }
        uploadFile(url)
        }

        // Add location picker sheet
        .sheet(isPresented: $showLocationPicker) {
            LocationPicker(selectedLocation: $selectedLocation)
        }
        
        .onChange(of: selectedLocation) { location in
            guard let location = location else { return }
            sendLocation(location)
        }

    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    private func calculateTextViewHeight() -> CGFloat {
        let fixedWidth = UIScreen.main.bounds.width - 140
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.text = messageText
        
        let size = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        return withAnimation { min(max(size.height, 30), 190) }
    }
    
    ///
    // Update the image upload function
    private func uploadSelectedImage() {
         guard let image = selectedImage else { return }
        withAnimation {
            isUploading = true
            uploadProgress = 0
        }
         
         viewModel.createNewChat(
             messageType: .image,
             currentImage: currentImage,
             recipientImage: recipientImage,
             currentUserId: currentUserId,
             currentMail: currentMail,
             recipientId: recipientId,
             recipientMail: recipientMail,
             image: image
         ) { progress in
             uploadProgress = progress
         } completion: {
             isUploading = false
             selectedImage = nil
         }
     }
    
    // Update video upload function
            private func uploadVideo(_ videoURL: URL) {
                guard let videoData = try? Data(contentsOf: videoURL) else { return }
                withAnimation {
                    isUploading = true
                    uploadProgress = 0
                }
                
                let storageRef = Storage.storage().reference()
                let videoName = "\(UUID().uuidString).mp4"
                let videoRef = storageRef.child("chat_videos/\(chatId)/\(videoName)")
                
                let uploadTask = videoRef.putData(videoData, metadata: nil) { metadata, error in
                    isUploading = false
                    
                    if let error = error {
                        print("Video upload error: \(error.localizedDescription)")
                        return
                    }
                    
                    videoRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            print("Could not get download URL")
                            return
                        }
                        
                        viewModel.createNewChat(
                            messageType: .video,
                            currentImage: currentImage,
                            recipientImage: recipientImage,
                            currentUserId: currentUserId,
                            currentMail: currentMail,
                            recipientId: recipientId,
                            recipientMail: recipientMail,
                            videoUrl: downloadURL.absoluteString
                        )
                    }
                }
                
                uploadTask.observe(.progress) { snapshot in
                    let percentComplete = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
                    uploadProgress = percentComplete
                }
            }
    
    
    // Update file upload function
        private func uploadFile(_ fileURL: URL) {
            guard let fileData = try? Data(contentsOf: fileURL) else { return }
            withAnimation {
                isUploading = true
                uploadProgress = 0
            }
            
            let storageRef = Storage.storage().reference()
            let fileName = fileURL.lastPathComponent
            let fileRef = storageRef.child("chat_files/\(chatId)/\(fileName)")
            
            let uploadTask = fileRef.putData(fileData, metadata: nil) { metadata, error in
                isUploading = false
                
                if let error = error {
                    print("File upload error: \(error.localizedDescription)")
                    return
                }
                
                fileRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Could not get download URL")
                        return
                    }
                    
                    viewModel.createNewChat(
                        messageType: .file,
                        currentImage: currentImage,
                        recipientImage: recipientImage,
                        currentUserId: currentUserId,
                        currentMail: currentMail,
                        recipientId: recipientId,
                        recipientMail: recipientMail,
                        fileURL: downloadURL.absoluteString
                    )
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                let percentComplete = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
                uploadProgress = percentComplete
            }
        }
        
    
    // New method to send location
     private func sendLocation(_ location: CLLocationCoordinate2D) {
         let locationString = "\(location.latitude),\(location.longitude)"
         
         viewModel.createNewChat(
             messageType: .location,
             currentImage: currentImage,
             recipientImage: recipientImage,
             currentUserId: currentUserId,
             currentMail: currentMail,
             recipientId: recipientId,
             recipientMail: recipientMail,
             initialMessage: locationString
         )
     }
}




// UserStatus.swift
struct UserStatus: Codable {
    let isOnline: Bool
    let lastSeen: Date
    
    enum CodingKeys: String, CodingKey {
        case isOnline = "is_online"
        case lastSeen = "last_seen"
    }
}

// Message.swift
struct Message: Identifiable, Codable {
    var id: String
    var sender: String
    var recipientId: String
    var content: String
    var timestamp: Date
    var isRead: Bool
    var messageType: MessageType

    enum MessageType: String, Codable {
        case text
        case image
        case video
        case file
        case location
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case sender
        case recipientId = "recipient_id"
        case content
        case timestamp
        case isRead = "is_read"
        case messageType = "message_type"
    }
}


class ChatViewModel: ObservableObject {
    @Published var recipientUnreadCounts:Int = 0
    @Published var messages: [Message] = []
    var db = Firestore.firestore()
    @Published var is_online: Bool = false
    var listenerRegistration: ListenerRegistration?
    @StateObject var viewModel = ChatListViewModel()
    @Published var userStatus: String = "Loading..."

    init() {}
    
    func listenToMessages(chatId: String, currentUserId: String,recipientId:String) {
        listenerRegistration = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.messages = documents.compactMap { document -> Message? in
                    try? document.data(as: Message.self)
                }
                
                
                // جلب قيمة recipientUnreadCounts من Firebase
                let chatRef = Firestore.firestore().collection("chats").document(chatId)
                
                chatRef.getDocument { document, error in
                    guard let document = document, document.exists else {
                        print("Document does not exist or error occurred: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    // جلب بيانات unread counts للمستلم
                    if let recipientUnreadCounts = document.data()?["recipientUnreadCounts"] as? [String: Int] {
                        if recipientUnreadCounts.first?.key == currentUserId {
                            self?.markMessagesAsRead(chatId: chatId, currentUserId: currentUserId)
                        }
                    }
                }
            }
    }

    
    func markMessagesAsRead(chatId: String, currentUserId: String) {
        let batch = db.batch()
        
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .whereField("recipient_id", isEqualTo: currentUserId)
            .whereField("is_read", isEqualTo: false)
            .getDocuments { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }

                // Update read status for each message
                for document in documents {
                    batch.updateData(["is_read": true], forDocument: document.reference)
                }

                // Reset unread count to zero for the current user
                let chatRef = self?.db.collection("chats").document(chatId)
                if let chatRef = chatRef {
                    batch.updateData(["recipientUnreadCounts.\(currentUserId)": 0], forDocument: chatRef)
                }

                batch.commit { error in
                    if let error = error {
                        print("Error updating read status: \(error)")
                    }
                }
            }
    }
    
    func createNewChat(
        messageType: Message.MessageType = .text,
        currentImage: String,
        recipientImage: String,
        currentUserId: String,
        currentMail: String,
        recipientId: String,
        recipientMail: String,
        initialMessage: String = "",
        image: UIImage? = nil,
        videoUrl: String = "",
        fileURL: String = "",
        progressCallback: ((Double) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        // إنشاء معرف فريد للمحادثة باستخدام معرفات المستخدمين
        let chatId = ChatService.createChatId(userId1: currentUserId, userId2: recipientId)

        // إنشاء بيانات المحادثة
        let chatData = ChatListItem(
            id: chatId,
            lastMessage: getLastMessageText(messageType: messageType, initialMessage: initialMessage),
            ProfileImage: [currentImage, recipientImage],
            lastMessageDate: Date(),
            participantIds: [currentUserId, recipientId],
            participantNames: [recipientMail, currentMail],
            recipientUnreadCounts: [recipientId: recipientUnreadCounts]
        )

        // حفظ بيانات المحادثة في Firestore
        do {
            try db.collection("chats").document(chatId).setData(from: chatData)
            
            // معالجة أنواع الرسائل المختلفة
            switch messageType {
            case .text:
                sendMessage(
                    content: initialMessage,
                    sender: currentUserId,
                    recipientId: recipientId,
                    chatId: chatId,
                    messageType: .text
                )
                completion?()
                
            case .image:
                if let image = image {
                    uploadImage(
                        image,
                        sender: currentUserId,
                        recipientId: recipientId,
                        chatId: chatId,
                        progressCallback: progressCallback,
                        completion: completion
                    )
                }
                
            case .video:
                sendMessage(
                    content: videoUrl,
                    sender: currentUserId,
                    recipientId: recipientId,
                    chatId: chatId,
                    messageType: .video
                )
                completion?()
                
            case .file:
                sendMessage(
                    content: fileURL,
                    sender: currentUserId,
                    recipientId: recipientId,
                    chatId: chatId,
                    messageType: .file
                )
                completion?()
                
            case .location:
                sendMessage(
                    content: initialMessage,
                    sender: currentUserId,
                    recipientId: recipientId,
                    chatId: chatId,
                    messageType: .location
                )
                completion?()
            }
            
        } catch {
            print("Error creating chat: \(error.localizedDescription)")
            completion?()
        }
    }

    func sendMessage(content: String, sender: String, recipientId: String, chatId: String, messageType: Message.MessageType = .text) {
        
        viewModel.onlineStatusService.setupPresence(userId: sender)
        let message = Message(
            id: UUID().uuidString,
            sender: sender,
            recipientId: recipientId,
            content: content,
            timestamp: Date(),
            isRead: false,
            messageType: messageType
        )

        do {
            try db.collection("chats")
                .document(chatId)
                .collection("messages")
                .document(message.id)
                .setData(from: message)

            db.collection("chats").document(chatId).getDocument { [weak self] snapshot, error in
                guard let document = snapshot, document.exists else { return }
                
                var recipientUnreadCounts = document.data()?["recipientUnreadCounts"] as? [String: Int] ?? [:]
                recipientUnreadCounts[recipientId] = (recipientUnreadCounts[recipientId] ?? 0) + 1
                self?.recipientUnreadCounts = (recipientUnreadCounts[recipientId] ?? 0)

                let lastType = messageType == .text ? content : messageType == .image ? "Sent an image": messageType == .video ? "Sent an video" : messageType == .file ? "ent an file" : "Sent an location"
                self?.db.collection("chats").document(chatId).updateData([
                    "last_message": lastType,
                    "last_message_date": Date(),
                    "recipientUnreadCounts": recipientUnreadCounts
                ])
            }
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    private func getLastMessageText(messageType: Message.MessageType, initialMessage: String) -> String {
        switch messageType {
        case .text:
            return initialMessage
        case .image:
            return "Sent an image"
        case .video:
            return "Sent a video"
        case .file:
            return "Sent a file"
        case .location:
            return "Sent a location"
        }
    }

    
    func uploadImage(_ image: UIImage,
                        sender: String,
                        recipientId: String,
                        chatId: String,
                        progressCallback: ((Double) -> Void)? = nil,
                        completion: (() -> Void)? = nil) {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
            
            let storageRef = Storage.storage().reference()
            let imageName = "\(UUID().uuidString).jpg"
            let imageRef = storageRef.child("chat_images/\(chatId)/\(imageName)")
            
            let uploadTask = imageRef.putData(imageData) { [weak self] metadata, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Image upload error: \(error.localizedDescription)")
                    completion?()
                    return
                }
                
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Could not get download URL")
                        completion?()
                        return
                    }
                    
                    let message = Message(
                        id: UUID().uuidString,
                        sender: sender,
                        recipientId: recipientId,
                        content: downloadURL.absoluteString,
                        timestamp: Date(),
                        isRead: false,
                        messageType: .image
                    )
                    
                    do {
                        try self.db.collection("chats")
                            .document(chatId)
                            .collection("messages")
                            .document(message.id)
                            .setData(from: message)
                    } catch {
                        print("Error sending image message: \(error.localizedDescription)")
                    }
                    completion?()
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                let percentComplete = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
                progressCallback?(percentComplete)
            }
        }
    
    func fetchUserStatus(userId: String) {
            let db = Firestore.firestore()
            let docRef = db.collection("user_status").document(userId)
            
            docRef.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot, document.exists else {
                    self.userStatus = "Last seen a long time ago"
                    return
                }
                
                if let data = document.data() {
                    let isOnline = data["is_online"] as? Bool ?? false
                    self.is_online = isOnline
                    if isOnline {
                        self.userStatus = "Online"
                    } else if let lastSeen = data["last_seen"] as? Timestamp {
                        let date = lastSeen.dateValue()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMM d, h:mm a"
                        self.userStatus = "Last seen \(formatter.string(from: date))"
                    } else {
                        self.userStatus = ""
                        
                    }
                } else {
                    self.userStatus = "Error fetching data"
                    
                }
            }
        
        }
}


