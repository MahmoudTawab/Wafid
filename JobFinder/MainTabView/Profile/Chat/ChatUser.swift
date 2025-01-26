//
//  ChatUser.swift
//  JobFinder
//
//  Created by almedadsoft on 21/01/2025.
//


import SwiftUI
import Firebase
import Foundation
import SDWebImage
import SDWebImageSwiftUI
import FirebaseFirestore

struct ChatUser: View {
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showLoadingIndicator = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = ChatListViewModel()
    
    @AppStorage("user_id") var user_id: String = ""
    @AppStorage("user_mail") var user_mail: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack(spacing: 10) {
                        Image("Icon")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                        
                        Text("Chat")
                            .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button {
                            navigationManager.navigate(to: .NewMessageView)
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 22,height: 22)
                                .foregroundColor(.black)
                        }.frame(width: 50,height: 50)
    
                    }.padding(.bottom,5)
                    

                    ForEach(viewModel.chats) { chat in
                        ChatListRow(chat: chat, userStatus: viewModel.userStatuses[chat.participantIds.first { $0 != FirebaseManager.shared.auth.currentUser?.uid } ?? ""],currentUserId: chat.participantIds.first { $0 == FirebaseManager.shared.auth.currentUser?.uid } ?? "")
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 30,height: 80)
                    .background(chat.unreadCountForUser(chat.participantIds.first { $0 == FirebaseManager.shared.auth.currentUser?.uid } ?? "") != 0 ? rgbToColor(red: 255, green: 247, blue: 236) : .white)
                    .cornerRadius(10)
                    .clipped()
                        
                    .onTapGesture {
                    if let uid = FirebaseManager.shared.auth.currentUser?.uid {
                    navigationManager.navigate(to: .ChatView(chatId: chat.id, currentImage: chat.ProfileImage[0],recipientImage: chat.ProfileImage[1], currentUserId: uid, currentMail: user_mail, recipientId: chat.participantIds.first { $0 != uid } ?? "", recipientMail: chat.participantNames.first { $0 != user_mail } ?? ""))
                    }
                    }
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
                .frame(height: UIScreen.main.bounds.height - 30)
            }
            .padding()
            .keyboardSpace()
            .edgesIgnoringSafeArea(.all)
            .preferredColorScheme(.light)
            .background(rgbToColor(red: 255, green: 255, blue: 255))
            .frame(width: UIScreen.main.bounds.width)
            
            
            // إضافة LoadingIndicator
            if showLoadingIndicator {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                VStack {
                    ActivityIndicatorView(isVisible: $showLoadingIndicator, type: .flickeringDots())
                        .frame(width: 60, height: 60)
                        .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                }
                .frame(width: 120, height: 120)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            
            // إضافة AnimatedToastMessage
            AnimatedToastMessage(
                showingErrorMessageisValid: $showingAlert,
                MassegeContent: $alertMessage,
                TypeToast: .error,
                FrameHeight: .constant(65)
            )
            .padding(.all, 0)
        }
        
        .onAppear {
            if let uid = FirebaseManager.shared.auth.currentUser?.uid {
            viewModel.fetchChats(for: uid)
            }
        }
    }
    
    
}



// ChatListRow.swift
struct ChatListRow: View {
    let chat: ChatListItem
    let userStatus: UserStatus?
    let currentUserId: String

    var body: some View {
        HStack {
            ZStack(alignment: .bottomTrailing) {
                // يمكنك إضافة صورة المستخدم هنا
                WebImage(url: URL(string: chat.participantIds.first == FirebaseManager.shared.auth.currentUser?.uid ? chat.ProfileImage[1] : chat.ProfileImage[0])) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.black.opacity(0.8))
                }
                
                .indicator(.activity)
                .scaledToFill()
                .frame(width: 50, height: 50, alignment: .center)
                .clipShape(Circle())
                .overlay(RoundedRectangle(cornerRadius: 25)
                    .stroke(rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 1))
                .shadow(color: rgbToColor(red: 193, green: 140, blue: 70), radius: 2, x: 0.5, y: 0.5)
                .padding(.leading,2)
                .padding(.trailing,8)

                // مؤشر الاتصال
                if userStatus?.isOnline == true {
                Circle()
                .fill(rgbToColor(red: 242, green: 201, blue: 76))
                .frame(width: 12, height: 12)
                .overlay(RoundedRectangle(cornerRadius: 25)
                    .stroke(.white, lineWidth: 2))
                .offset(x: -5, y: -5)
                }
            }
            .padding(.leading, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(chat.otherParticipantName)
                    .font(Font.system(size: ControlWidth(16)))
                    .offset(y: 4)

                Spacer()
                
                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .offset(y: -4)

            }.padding(.trailing,3)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {

                Text(formatDate(chat.lastMessageDate))
                    .offset(y: 6)
                    .font(.caption)
                    .font(Font.system(size: ControlWidth(12)))
                    .foregroundColor(rgbToColor(red: 51, green: 51, blue: 51))
                

                let unreadCount = chat.unreadCountForUser(currentUserId)
                if unreadCount > 0 {
                    Text("\(unreadCount)")
                        .font(Font.system(size: ControlWidth(12)))
                        .foregroundColor(.white)
                        .frame(width: 26,height: 30)
                        .background(rgbToColor(red: 193, green: 140, blue: 70))
                        .cornerRadius(15)
                        .clipped()
                        .padding(6)
                }
            }
            .padding(.trailing, 10)
        }
        .padding(.vertical, 10)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatLastSeen(_ date: Date?) -> String {
        guard let date = date else { return "" }
        // تنسيق وقت آخر ظهور
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// ChatService.swift
class ChatService {
    static func createChatId(userId1: String, userId2: String) -> String {
        let sortedIds = [userId1, userId2].sorted()
        return sortedIds.joined(separator: "_")
    }
}


// ChatListModel.swift
struct ChatListItem: Identifiable, Codable {
    let id: String
    let lastMessage: String
    let ProfileImage: [String]
    let lastMessageDate: Date
    let participantIds: [String]
    let participantNames: [String]
    let recipientUnreadCounts: [String: Int]

    var otherParticipantName: String {
        participantIds.first == FirebaseManager.shared.auth.currentUser?.uid ? participantNames[0] : participantNames[1]
    }
    
    func unreadCountForUser(_ userId: String) -> Int {
        return recipientUnreadCounts[userId] ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case lastMessage = "last_message"
        case ProfileImage
        case lastMessageDate = "last_message_date"
        case participantIds = "participant_ids"
        case participantNames = "participant_names"
        case recipientUnreadCounts = "recipientUnreadCounts"
    }
}

// ChatListViewModel.swift
class ChatListViewModel: ObservableObject {
    @Published var chats: [ChatListItem] = []
    @Published var userStatuses: [String: UserStatus] = [:]
    private var db = Firestore.firestore()
    var onlineStatusService = OnlineStatusService()
    private var chatListeners: [String: ListenerRegistration] = [:]
    
    func fetchChats(for userId: String) {
        chatListeners.values.forEach { $0.remove() }
        chatListeners.removeAll()
        
        let listener = db.collection("chats")
            .whereField("participant_ids", arrayContains: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self,
                      let changes = querySnapshot?.documentChanges else { return }
                
                // Only process changes, not the entire collection
                for change in changes {
                    switch change.type {
                    case .added, .modified:
                        if let chatItem = try? change.document.data(as: ChatListItem.self) {
                            if let index = self.chats.firstIndex(where: { $0.id == chatItem.id }) {
                                self.chats[index] = chatItem
                            } else {
                                self.chats.append(chatItem)
                            }
                        }
                    case .removed:
                        self.chats.removeAll { $0.id == change.document.documentID }
                    }
                }
                
                self.chats.sort { $0.lastMessageDate > $1.lastMessageDate }
                self.updateUserStatusListeners(userId: userId)
            }
        
        chatListeners["main"] = listener
    }
        
    private func updateUserStatusListeners(userId: String) {
        // إلغاء المراقبين السابقين للحالة
        for (id, listener) in chatListeners where id != "main" {
            listener.remove()
            chatListeners.removeValue(forKey: id)
        }
        
        // إضافة مراقبين جدد
        for chat in chats {
            let otherUserId = chat.participantIds.first { $0 != userId } ?? ""
            if !otherUserId.isEmpty {
                listenToUserStatus(userId: otherUserId)
            }
        }
    }
    
    private func listenToUserStatus(userId: String) {
        let listener = db.collection("user_status")
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let data = snapshot?.data(),
                      let status = try? Firestore.Decoder().decode(UserStatus.self, from: data)
                else { return }
                
                DispatchQueue.main.async {
                    self?.userStatuses[userId] = status
                }
            }
        
        chatListeners[userId] = listener
    }
    
}


// OnlineStatusService.swift
class OnlineStatusService {
    private var db = Firestore.firestore()
    private var statusRef: DocumentReference?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var userId: String?
    
    func setupPresence(userId: String) {
        guard statusRef == nil else { return }
        self.userId = userId
        statusRef = db.collection("user_status").document(userId)
        
        // التحقق من وجود الوثيقة أولاً
        statusRef?.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error checking document: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.exists {
                // إنشاء الوثيقة إذا لم تكن موجودة
                self?.createInitialUserStatus(userId: userId) { success in
                    if success {
                        // بعد إنشاء الوثيقة بنجاح، قم بتحديث الحالة
                        self?.updateOnlineStatus(isOnline: true, updateLastSeen: false)
                        self?.setupNotifications()
                    }
                }
            } else {
                // الوثيقة موجودة بالفعل، قم بتحديث الحالة مباشرة
                self?.updateOnlineStatus(isOnline: true, updateLastSeen: false)
                self?.setupNotifications()
            }
        }
    }
    
    private func createInitialUserStatus(userId: String, completion: @escaping (Bool) -> Void) {
        let initialData: [String: Any] = [
            "user_id": userId,
            "is_online": true,
            "last_seen": Timestamp(date: Date())
        ]
        
        statusRef?.setData(initialData) { error in
            if let error = error {
                print("Error creating user status document: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User status document created successfully")
                completion(true)
            }
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        updateOnlineStatus(isOnline: true, updateLastSeen: false)
    }
    
    @objc private func appWillResignActive() {
        handleAppBackground()
    }
    
    @objc private func appWillTerminate() {
        handleAppTermination()
    }
    
    private func handleAppBackground() {
        guard userId != nil else { return }
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        updateOnlineStatus(isOnline: false, updateLastSeen: true) { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func handleAppTermination() {
        guard userId != nil else { return }
        
        let group = DispatchGroup()
        group.enter()
        
        updateOnlineStatus(isOnline: false, updateLastSeen: true) {
            group.leave()
        }
        
        group.notify(queue: .main) {
            print("Termination updates completed.")
        }
    }
    
    private func updateOnlineStatus(isOnline: Bool, updateLastSeen: Bool, completion: (() -> Void)? = nil) {
        guard let statusRef = statusRef else { return }
        
        var data: [String: Any] = ["is_online": isOnline]
        if updateLastSeen {
            data["last_seen"] = Timestamp(date: Date())
        }
        
        statusRef.updateData(data) { error in
            if let error = error {
                print("Error updating online status: \(error.localizedDescription)")
            } else {
                print("Online status updated successfully")
            }
            completion?()
        }
    }
    
    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// OnlineStatusManager.swift - Singleton لضمان وجود نسخة واحدة فقط
class OnlineStatusManager {
    static let shared = OnlineStatusManager()
    private var onlineStatusService = OnlineStatusService()
    
    private init() {}
    
    func setupPresence(userId: String) {
        onlineStatusService.setupPresence(userId: userId)
    }
}

