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
import FirebaseFirestore
import SDWebImageSwiftUI

// ChatView.swift
struct ChatView: View {
    @State private var isEmoji: Bool = false
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
                }
                .offset(y:-30)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message, isCurrentUser: message.sender == currentUserId, isOnline: viewModel.is_online, currentImage: currentImage,recipientImage: recipientImage)
                            .padding(.horizontal)
                    }
                }.padding(.top,5)
            }.offset(y:-25)
            
            HStack {
                Button(action: {
                    isEmoji.toggle()
                }) {
                    Image("Frame")
                        .resizable()
                        .frame(width: 28,height: 28)
                }
                
                
                EmojiTextView(text: $messageText, placeholder: "write a message...", isEmoji: $isEmoji)
                    .frame(width: UIScreen.main.bounds.width - 140,height: 40)
                    .tint(rgbToColor(red: 193, green: 140, blue: 70))
                
                
                Button(action: {

                }) {
                    Image("Frame 2")
                        .resizable()
                        .frame(width: 25,height: 25)
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
                
            }
            .offset(y:-15)
            .frame(minHeight: 35)
            .padding(.horizontal)
        }
        .preferredColorScheme(.light)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        
        .onAppear {
            viewModel.fetchUserStatus(userId: recipientId)
            viewModel.listenToMessages(chatId: chatId, currentUserId: currentUserId,recipientId:recipientId)
        }
        
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
}

class UIEmojiTextView: UITextView {

    var placeholder: String? {
        didSet {
            setNeedsDisplay() // لإعادة رسم الـ placeholder عند تغييره
        }
    }
    
    var isEmoji = false {
        didSet {
            setEmoji()
            if isEmoji {self.becomeFirstResponder()}
        }
    }
    
    let placeholderLabel = UILabel()
        
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // إخفاء placeholder عندما يكون هناك نص
        placeholderLabel.numberOfLines = 1
        placeholderLabel.textAlignment = .left
        placeholderLabel.font = UIFont.systemFont(ofSize: ControlWidth(15))
        placeholderLabel.textColor = UIColor.gray
        placeholderLabel.text = placeholder
        addSubview(placeholderLabel)
        placeholderLabel.frame = CGRect(x: 5, y: 3, width: rect.width - 20, height: 30)
    }

    private func setEmoji() {
        self.reloadInputViews()
    }

    override var textInputContextIdentifier: String? {
        return ""
    }

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" && self.isEmoji {
                self.keyboardType = .default
                return mode
            } else if !self.isEmoji {
                return mode
            }
        }
        return nil
    }
}


struct EmojiTextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    @Binding var isEmoji: Bool
    
    func makeUIView(context: Context) -> UIEmojiTextView {
        let emojiTextView = UIEmojiTextView()
        emojiTextView.placeholder = placeholder
        emojiTextView.text = text
        emojiTextView.delegate = context.coordinator
        emojiTextView.isEmoji = self.isEmoji
        emojiTextView.isScrollEnabled = false // لتوسيع الحجم تلقائيًا بناءً على النص
        emojiTextView.font = UIFont.systemFont(ofSize: ControlWidth(15))
        emojiTextView.backgroundColor = .clear
        emojiTextView.tintColor = UIColor(rgbToColor(red: 193, green: 140, blue: 70))
        
        return emojiTextView
    }
    
    func updateUIView(_ uiView: UIEmojiTextView, context: Context) {
        uiView.text = text
        uiView.isEmoji = isEmoji
        uiView.placeholderLabel.isHidden = !text.isEmpty
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: EmojiTextView
        
        init(parent: EmojiTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text ?? ""
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            // تأكد من استخدام الكيبورد الافتراضي الذي يشمل الـ Emoji Picker
            textView.inputView = nil
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            // إغلاق الكيبورد بعد الانتهاء
            textView.resignFirstResponder()
        }
    }
}


// MessageBubble.swift
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    let isOnline:Bool
    let currentImage: String
    let recipientImage: String
    @State var timestamp = String()

    var body: some View {
        HStack(spacing: 2) {
            
            if !isCurrentUser {
                VStack() {
                
                    ZStack(alignment: .bottomTrailing) {
                        WebImage(url: URL(string: recipientImage)) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.black.opacity(0.8))
                        }
                        
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(width: 35, height: 35, alignment: .center)
                        .clipShape(Circle())
                        .overlay(RoundedRectangle(cornerRadius: 25)
                            .stroke(isOnline ? rgbToColor(red: 60, green: 177, blue: 106):rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 1))
                        .shadow(color: isOnline ? rgbToColor(red: 60, green: 177, blue: 106):rgbToColor(red: 193, green: 140, blue: 70), radius: 2, x: 0.5, y: 0.5)
                        .padding(.leading,2)
                        .padding(.trailing,8)
                        
                        // مؤشر الاتصال
                        if isOnline == true {
                            Circle()
                                .fill(rgbToColor(red: 60, green: 177, blue: 106))
                                .frame(width: 9, height: 9)
                                .overlay(RoundedRectangle(cornerRadius: 25)
                                    .stroke(.white, lineWidth: 1.5))
                                .offset(x: -5, y: -2)
                        }
                        
                    }.padding(.trailing, 3)
                    
                    Spacer()
                }
            }
            
            if isCurrentUser { Spacer() }
            
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .trailing,spacing: 2) {
                    Text(message.content)
                        .background(.clear)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(isCurrentUser ?  .white : rgbToColor(red: 27, green: 26, blue: 87))
                }.padding(.bottom,20)
                Spacer()

                Text(timestamp)
                    .offset(x:3, y:3)
                    .background(.clear)
                    .font(Font.system(size: ControlWidth(11)))
                    .foregroundColor(isCurrentUser ?  .white : rgbToColor(red: 161, green: 161, blue: 188))
            }
            .padding()
            .background(isCurrentUser ? rgbToColor(red: 193, green: 140, blue: 70) : rgbToColor(red: 247, green: 247, blue: 247))
            .cornerRadius(isCurrentUser ? 0:10)
            .clipShape(CustomRoundedShape(corners: [.topLeft, .topRight, .bottomLeft], radius: isCurrentUser ? 10:0))
            .clipped()
            

            if !isCurrentUser { Spacer() }
            
            if isCurrentUser {
                VStack() {
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
                        .frame(width: 35, height: 35, alignment: .center)
                        .clipShape(Circle())
                        .overlay(RoundedRectangle(cornerRadius: 25)
                            .stroke(rgbToColor(red: 60, green: 177, blue: 106) , lineWidth: 1))
                        .shadow(color:rgbToColor(red: 60, green: 177, blue: 106), radius: 2, x: 0.5, y: 0.5)
                        .padding(.leading,2)
                        .padding(.trailing,8)
                        
                        // مؤشر الاتصال
                            Circle()
                                .fill(rgbToColor(red: 60, green: 177, blue: 106))
                                .frame(width: 9, height: 9)
                                .overlay(RoundedRectangle(cornerRadius: 25)
                                    .stroke(.white, lineWidth: 1.5))
                                .offset(x: -5, y: -2)
                        
                    }.padding(.leading, 5)
                }
            }
        }.padding(.bottom,8)
        
        .onAppear {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        self.timestamp = formatter.string(from:  message.timestamp)
        }
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case sender
        case recipientId = "recipient_id"
        case content
        case timestamp
        case isRead = "is_read"
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
    
    func createNewChat(currentImage: String, recipientImage: String, currentUserId: String, currentMail: String, recipientId: String, recipientMail: String, initialMessage: String) {
        let chatId = ChatService.createChatId(userId1: currentUserId, userId2: recipientId)

        let chatData = ChatListItem(
            id: chatId,
            lastMessage: initialMessage,
            ProfileImage: [currentImage, recipientImage],
            lastMessageDate: Date(),
            participantIds: [currentUserId, recipientId],
            participantNames: [recipientMail, currentMail],
            recipientUnreadCounts: [recipientId: recipientUnreadCounts]
        )

        
        try? db.collection("chats").document(chatId).setData(from: chatData)

        sendMessage(
            content: initialMessage,
            sender: currentUserId,
            recipientId: recipientId,
            chatId: chatId
        )
    }

    func sendMessage(content: String, sender: String, recipientId: String, chatId: String) {
        let message = Message(
            id: UUID().uuidString,
            sender: sender,
            recipientId: recipientId,
            content: content,
            timestamp: Date(),
            isRead: false
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

                self?.db.collection("chats").document(chatId).updateData([
                    "last_message": content,
                    "last_message_date": Date(),
                    "recipientUnreadCounts": recipientUnreadCounts
                ])
            }
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    func fetchUserStatus(userId: String) {
            let db = Firestore.firestore()
            let docRef = db.collection("user_status").document(userId)
            
            docRef.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot, document.exists else {
                    self.userStatus = "User not found"
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

