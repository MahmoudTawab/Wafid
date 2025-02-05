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

    @State private var showScrollButton = false
    @State private var scrollViewProxy: ScrollViewProxy?
    @State private var lastMessageId: String?
    
    @State private var showAlert = false
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
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
                            if !NetworkMonitor.shared.isConnected {
                                hideKeyboard()
                                callManager.startVideoCall(
                                    currentUserId: currentUserId,
                                    recipientUserId: recipientId,
                                    callerName: currentMail,
                                    receiverName: recipientMail
                                )
                            } else {
                                showAlert = true
                            }
                        }) {
                            Image(systemName: "video")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                        }.padding()
                        
                        Button(action: {
                            if !NetworkMonitor.shared.isConnected {
                                hideKeyboard()
                                callManager.startAudioCall(
                                    currentUserId: currentUserId,
                                    recipientUserId: recipientId,
                                    callerName: currentMail,
                                    receiverName: recipientMail
                                )
                            } else {
                                showAlert = true
                            }
                        }) {
                            Image(systemName: "phone")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                        }
                    }
                    .background(Color.clear)
                }
                .offset(y:-30)
                .padding(.horizontal)
                
                GeometryReader { outerGeometry in
                    ScrollView {
                        ScrollViewReader { proxy in
                            VStack {
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self,
                                                    value: geometry.frame(in: .named("scroll")).minY)
                                }
                                .frame(height: 0)
                                
                                LazyVStack {
                                    ForEach(viewModel.messages) { message in
                                        MessageBubble(message: message, isCurrentUser: message.sender == currentUserId, isOnline: viewModel.is_online, currentImage: currentImage, recipientImage: recipientImage) { image in
                                            
                                            self.image = image
                                            showImageViewer = true
                                            hideKeyboard()
                                        }
                                        .padding(.horizontal)
                                        .id(message.id)
                                    }
                                }
                                .background(
                                    GeometryReader { contentGeometry in
                                        Color.clear
                                            .preference(key: ContentHeightPreferenceKey.self,
                                                        value: contentGeometry.size.height)
                                    }
                                )
                            }
                            .padding(.top, 5)
                            .onChange(of: viewModel.messages.count) { _ in
                                withAnimation {
                                    if let lastId = viewModel.messages.last?.id {
                                        proxy.scrollTo(lastId, anchor: .bottom)
                                        lastMessageId = lastId
                                    }
                                }
                            }
                            .onAppear {
                                DispatchQueue.main.async {
                                    scrollViewProxy = proxy
                                    if let lastId = viewModel.messages.last?.id {
                                        proxy.scrollTo(lastId, anchor: .bottom)
                                        lastMessageId = lastId
                                    }
                                }
                            }
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                        checkScrollButtonVisibility(offset: offset)
                    }
                    .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
                        contentHeight = height
                    }
                    .onChange(of: outerGeometry.size.height) { newHeight in
                        withAnimation {
                            if let lastId = viewModel.messages.last?.id {
                                scrollViewProxy?.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
                .overlay(
                    VStack {
                        Spacer()
                        if showScrollButton {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        if let lastId = lastMessageId {
                                            scrollViewProxy?.scrollTo(lastId, anchor: .bottom)
                                        }
                                    }
                                }) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 35))
                                        .foregroundColor(Color.orange)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(.leading, 16)
                                .padding(.bottom, 10)
                                
                                Spacer()
                            }
                        }
                    }
                )
                .offset(y:-25)
                
                if isUploading {
                    HStack(spacing: 10) {
                        ActivityIndicator(isAnimating: $isUploading)
                        
                        Text("Loading...")
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
                    
                    
                    
                    Menu {
                        Button(action: { showImagePicker = true }) {
                            Label("Photo", systemImage: "photo")
                                .foregroundColor(.black)
                        }
                        
                        Button(action: { showVideoPicker = true }) {
                            Label("Video", systemImage: "video.fill")
                                .foregroundColor(.black)
                        }
                        
                        Button(action: { showFilePicker = true }) {
                            Label("File", systemImage: "doc.fill")
                                .foregroundColor(.black)
                        }
                        
                        Button(action: { showLocationPicker = true }) {
                            Label("Location", systemImage: "location.fill")
                                .foregroundColor(.black)
                        }
                    } label: {
                        Image("Frame 2")
                            .resizable()
                            .frame(width: 25, height: 25)
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
            
            
            // Alert Message
            if showAlert {
                AnimatedToastMessage(
                    showingErrorMessageisValid: $showAlert,
                    MassegeContent: .constant("برجاء التحقق من الاتصال بالإنترنت"),
                    TypeToast: .error,
                    FrameHeight: .constant(65)
                )
                .padding(.top,0)
            }
        }
        .preferredColorScheme(.light)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .onTapGesture {
            hideKeyboard()
        }
        
        .overlay(ImageViewer(image: $image, viewerShown: self.$showImageViewer, aspectRatio: .constant(1)))
        
        .onAppear {
            viewModel.isViewActive = true
            viewModel.loadLocalMessages(chatId: chatId)
            viewModel.fetchUserStatus(userId: recipientId)
            viewModel.listenToMessages(chatId: chatId, currentUserId: currentUserId,recipientId:recipientId)
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    if let lastId = viewModel.messages.last?.id {
                        scrollViewProxy?.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
        
        .onDisappear {
            viewModel.isViewActive = false
            
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    private func checkScrollButtonVisibility(offset: CGFloat) {
        let screenHeight = UIScreen.main.bounds.height
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                showScrollButton = offset > 60 && contentHeight > screenHeight
            }
        }
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
    var callInfo: CallInfo? // Optional call information

    enum MessageType: String, Codable {
        case text
        case image
        case video
        case file
        case location
        case call
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case sender
        case recipientId = "recipient_id"
        case content
        case timestamp
        case isRead = "is_read"
        case messageType = "message_type"
        case callInfo
    }
    
    struct CallInfo: Codable {
        let callType: String // "audio" or "video"
        let status: String // "missed", "ended", etc.
        let duration: TimeInterval?
    }
    
    init(id: String, sender: String, recipientId: String, content: String, timestamp: Date, isRead: Bool, messageType: MessageType, callInfo: CallInfo? = nil) {
        self.id = id
        self.sender = sender
        self.recipientId = recipientId
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
        self.messageType = messageType
        self.callInfo = callInfo
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
    @Published var isViewActive = false

    
    init() {}
    
    // 4. تحديث وظيفة تحديث حالة القراءة
    func markMessagesAsRead(chatId: String, currentUserId: String) {
        let batch = db.batch()
        let chatRef = db.collection("chats").document(chatId)
        
        // أولاً، نتحقق من recipientUnreadCounts
        chatRef.getDocument { document, error in
            guard let document = document,
                  let recipientUnreadCounts = document.data()?["recipientUnreadCounts"] as? [String: Int] else {
                print("Error fetching recipientUnreadCounts")
                return
            }
            
            // نتحقق مما إذا كان المفتاح موجود وقيمته تساوي currentUserId
            for (key, _) in recipientUnreadCounts {
                if key == currentUserId {
                    // إذا وجدنا التطابق، نقوم بتحديث الرسائل غير المقروءة
                    self.db.collection("chats")
                        .document(chatId)
                        .collection("messages")
                        .whereField("recipient_id", isEqualTo: currentUserId)
                        .whereField("is_read", isEqualTo: false)
                        .getDocuments { querySnapshot, error in
                            guard let documents = querySnapshot?.documents else { return }
                            
                            // تحديث كل رسالة غير مقروءة
                            for document in documents {
                                batch.updateData(["is_read": true], forDocument: document.reference)
                            }
                            
                            // تصفير عداد الرسائل غير المقروءة للمستخدم الحالي
                            if !documents.isEmpty {
                                batch.updateData([
                                    "recipientUnreadCounts.\(currentUserId)": 0
                                ], forDocument: chatRef)
                            }
                            
                            // تنفيذ التحديثات دفعة واحدة
                            batch.commit { error in
                                if let error = error {
                                    print("Error updating read status: \(error)")
                                }
                            }
                        }
                    break  // نخرج من الحلقة بمجرد أن نجد التطابق
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
        let chatId = ChatService.createChatId(userId1: currentUserId, userId2: recipientId)

        let chatData = ChatListItem(
            id: chatId,
            lastMessage: getLastMessageText(messageType: messageType, initialMessage: initialMessage),
            ProfileImage: [currentImage, recipientImage],
            lastMessageDate: Date(),
            participantIds: [currentUserId, recipientId],
            participantNames: [recipientMail, currentMail],
            recipientUnreadCounts: [recipientId: recipientUnreadCounts]
        )

        do {
            try db.collection("chats").document(chatId).setData(from: chatData)
            
            if messageType == .image, let image = image {
                // Upload image to Firebase Storage first
                guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                    completion?()
                    return
                }
                
                let storageRef = Storage.storage().reference()
                let imageName = "\(UUID().uuidString).jpg"
                let imageRef = storageRef.child("chat_images/\(chatId)/\(imageName)")
                
                let uploadTask = imageRef.putData(imageData) { metadata, error in
                    if let error = error {
                        print("Image upload error: \(error.localizedDescription)")
                        completion?()
                        return
                    }
                    
                    imageRef.downloadURL { [weak self] (url, error) in
                        guard let self = self,
                              let downloadURL = url else {
                            print("Could not get download URL")
                            completion?()
                            return
                        }
                        
                        self.sendMessage(
                            content: downloadURL.absoluteString,
                            sender: currentUserId,
                            recipientId: recipientId,
                            chatId: chatId,
                            messageType: .image
                        )
                        completion?()
                    }
                }
                
                uploadTask.observe(.progress) { snapshot in
                    let percentComplete = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
                    progressCallback?(percentComplete)
                }
            } else {
                // Handle all other message types
                sendMessage(
                    content: messageType == .text ? initialMessage :
                            messageType == .video ? videoUrl :
                            messageType == .file ? fileURL :
                            initialMessage,
                    sender: currentUserId,
                    recipientId: recipientId,
                    chatId: chatId,
                    messageType: messageType
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
                let currentCount = recipientUnreadCounts[recipientId] ?? 0
                recipientUnreadCounts[recipientId] = currentCount + 1
                self?.recipientUnreadCounts = (recipientUnreadCounts[recipientId] ?? 0)
                
                let lastType = messageType == .text ? content :
                              messageType == .image ? "Sent an image" :
                              messageType == .video ? "Sent a video" :
                              messageType == .file ? "Sent a file" : 
                              messageType == .location ? "Sent a location" : "Missed call"
                
                let updateData: [String: Any] = [
                    "last_message": lastType,
                    "last_message_date": Timestamp(date: Date()),
                    "recipientUnreadCounts": recipientUnreadCounts
                ]
                
                self?.db.collection("chats").document(chatId).updateData(updateData) { error in
                    if let error = error {
                        print("Error updating chat: \(error.localizedDescription)")
                    }
                }
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
        case .call:
            return "Missed call"
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






extension ChatViewModel {
    // حفظ الرسائل محليًا
    func saveMessagesLocally(chatId: String) {
        let encoder = JSONEncoder()
        do {
            let encodedMessages = try encoder.encode(messages)
            UserDefaults.standard.set(encodedMessages, forKey: "chat_messages_\(chatId)")
            UserDefaults.standard.synchronize()
        } catch {
            print("Failed to save messages locally: \(error)")
        }
    }
    
    // استرجاع الرسائل محليًا
    func loadLocalMessages(chatId: String) {
        guard let data = UserDefaults.standard.data(forKey: "chat_messages_\(chatId)") else {
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let localMessages = try decoder.decode([Message].self, from: data)
            
            // التحقق من وجود اتصال بالإنترنت
            if NetworkMonitor.shared.isConnected {
                updateMessagesWithFirestore(localMessages: localMessages, chatId: chatId)
            } else {
                // في حالة عدم وجود اتصال بالإنترنت، استخدم الرسائل المخزنة محليًا
                self.messages = localMessages
            }
        } catch {
            print("Failed to load local messages: \(error)")
        }
    }
    
    // تحديث الرسائل مع Firestore
    private func updateMessagesWithFirestore(localMessages: [Message], chatId: String) {
        let chatRef = db.collection("chats").document(chatId).collection("messages")
        
        chatRef
            .order(by: "timestamp", descending: false)
            .getDocuments { [weak self] querySnapshot, error in
                guard let self = self,
                      let documents = querySnapshot?.documents else { return }
                
                // استخراج رسائل Firestore
                let firestoreMessages = documents.compactMap { document -> Message? in
                    try? document.data(as: Message.self)
                }
                
                // دمج الرسائل المحلية مع رسائل Firestore
                var mergedMessages = localMessages
                
                for firestoreMessage in firestoreMessages {
                    if !localMessages.contains(where: { $0.id == firestoreMessage.id }) {
                        mergedMessages.append(firestoreMessage)
                    }
                }
                
                // فرز الرسائل حسب التاريخ
                self.messages = mergedMessages.sorted { $0.timestamp < $1.timestamp }
                
                // حفظ الرسائل المحدثة محليًا
                self.saveMessagesLocally(chatId: chatId)
            }
    }
    
    // تعديل وظيفة الاستماع للرسائل
    func listenToMessages(chatId: String, currentUserId: String, recipientId: String) {
        // استرجاع الرسائل المحلية أولاً
        loadLocalMessages(chatId: chatId)
        
        let chatRef = db.collection("chats").document(chatId)
        
        listenerRegistration = chatRef
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self,
                      let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.messages = documents.compactMap { document -> Message? in
                    try? document.data(as: Message.self)
                }
                
                // حفظ الرسائل محليًا
                self.saveMessagesLocally(chatId: chatId)
                
                // تحديث حالة القراءة للرسائل
                if isViewActive {
                    self.markMessagesAsRead(chatId: chatId, currentUserId: currentUserId)
                }
            }
    }
}


struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

