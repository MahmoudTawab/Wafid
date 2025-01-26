//
//  NewMessageView.swift
//  Wafid
//
//  Created by almedadsoft on 21/01/2025.
//

import SwiftUI
import Combine
import Firebase
import SDWebImage
import FirebaseAuth
import SDWebImageSwiftUI

struct NewMessageView: View {
    
    @AppStorage("user_mail") var user_mail: String = ""
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var vm = CreateNewMessageView()
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header stays the same
                    HStack(spacing: 10) {
                        Image("Icon")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                        
                        Text("New Message")
                            .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {vm.ShowSearch = true}
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 22,height: 22)
                                .foregroundColor(.black)
                        }.frame(width: 50,height: 50)
                    }.padding(.bottom,5)
                    
                    // Search field stays the same
                    if vm.ShowSearch {
                        HStack(alignment: .center) {
                            TextField("Search", text: $vm.searchText)
                                .padding(10)
                                .tint(.gray)
                                .background(rgbToColor(red: 255, green: 247, blue: 236))
                                .cornerRadius(20)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Image(systemName: "magnifyingglass")
                                            .padding(.trailing, 10)
                                            .foregroundColor(.gray)
                                    }
                                )
                                .frame(height: 44)
                            
                            Button(action: {withAnimation {vm.ShowSearch = false}}) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .frame(width: 18,height: 18)
                            }
                        } .padding(.bottom, 15)
                    }
                    
                    if vm.filteredUsers.isEmpty {
                        Spacer()
                        Text("Search by email")
                            .foregroundColor(.gray)
                            .font(.system(size: ControlWidth(16)))
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(vm.filteredUsers) { user in
                            Button {
                                if let currentUserId = FirebaseManager.shared.auth.currentUser?.uid {
                                    // Check for existing chat
                                    checkExistingChat(currentUserId: currentUserId, recipientId: user.uid) { existingChatId in
                                        if let chatId = existingChatId {
                                            
                                            // Existing chat found - navigate to it
                                            navigationManager.navigate(to: .ChatView(chatId: chatId,
                                                currentImage: vm.currentImage,
                                                recipientImage: user.ProfileImage,
                                                currentUserId: currentUserId,
                                                currentMail: user_mail,
                                                recipientId: user.uid,
                                                recipientMail: user.email
                                            ))
                                        } else {
                                            // No existing chat - create new one
                                            let newChatId = ChatService.createChatId(userId1: currentUserId, userId2: user.uid)
                                            navigationManager.navigate(to: .ChatView(
                                                chatId: newChatId,
                                                currentImage: vm.currentImage,
                                                recipientImage: user.ProfileImage,
                                                currentUserId: currentUserId,
                                                currentMail: user_mail,
                                                recipientId: user.uid,
                                                recipientMail: user.email
                                            ))
                                        }
                                    }
                                }
                            } label: {
                                // User row UI stays the same
                                HStack(spacing: 16) {
                                    WebImage(url: URL(string: user.ProfileImage)) { image in
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
                                    
                                    Text(user.email)
                                        .font(.system(size: ControlWidth(16), weight: .bold))
                                        .foregroundColor(.black.opacity(0.8))
                                    Spacer()
                                }
                            }
                            
                            Divider()
                                .padding([.bottom,.top,.vertical], 2)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
                .frame(height: UIScreen.main.bounds.height - 50)
            }
            .padding()
            .keyboardSpace()
            .edgesIgnoringSafeArea(.all)
            .preferredColorScheme(.light)
            .background(rgbToColor(red: 255, green: 255, blue: 255))
            .frame(width: UIScreen.main.bounds.width - 10)
            
            // Loading indicator and toast message stay the same
            if vm.showLoadingIndicator {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                VStack {
                    ActivityIndicatorView(isVisible: $vm.showLoadingIndicator, type: .flickeringDots())
                        .frame(width: 60, height: 60)
                        .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                }
                .frame(width: 120, height: 120)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            
            AnimatedToastMessage(
                showingErrorMessageisValid: $vm.showingAlert,
                MassegeContent: $vm.alertMessage,
                TypeToast: .error,
                FrameHeight: .constant(65)
            )
            .padding(.all, 0)
        }
        
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    // Function to check for existing chat
    private func checkExistingChat(currentUserId: String, recipientId: String, completion: @escaping (String?) -> Void) {
        let chatId = ChatService.createChatId(userId1: currentUserId, userId2: recipientId)
        
        FirebaseManager.shared.firestore.collection("chats").document(chatId).getDocument { snapshot, error in
            if let error = error {
                print("Error checking for existing chat: \(error)")
                completion(nil)
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                completion(chatId)
            } else {
                completion(nil)
            }
        }
    }
}

class CreateNewMessageView: ObservableObject {
    @Published var searchText = ""
    @Published var ShowSearch = false
    @Published var alertMessage = ""
    @Published var showingAlert = false
    @Published var users = [DataChatUser]()
    @Published var showLoadingIndicator = false
    @Published var currentImage = ""
    
    // Add debouncer for search
    private var searchDebounceTimer: Timer?
    
    var filteredUsers: [DataChatUser] {
        users
    }
    
    init() {
        // Add searchText listener
        $searchText
            .sink { [weak self] text in
                self?.searchDebounceTimer?.invalidate()
                
                if text.isEmpty {
                    self?.users = []
                    return
                }
                
                // Debounce search to avoid too many Firebase queries
                self?.searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    self?.performSearch(with: text)
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func performSearch(with searchText: String) {
        guard !searchText.isEmpty else {
            self.users = []
            return
        }
        
        if !ShowSearch {showLoadingIndicator = true}
        
        // Create the query
        let query = FirebaseManager.shared.firestore.collection("UsersChat")
            .whereField("email", isGreaterThanOrEqualTo: searchText.lowercased())
            .whereField("email", isLessThanOrEqualTo: searchText.lowercased() + "\u{f8ff}")
            .limit(to: 10) // Limit results for better performance
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.showLoadingIndicator = false
                
                if let error = error {
                    self.showingAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                }
                
                self.users = []
                
                snapshot?.documents.forEach { document in
                    let user = DataChatUser(data: document.data())
                    
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(user)
                    }
                    
                    if user.uid == FirebaseManager.shared.auth.currentUser?.uid {
                        self.currentImage = user.ProfileImage
                    }
                }
            }
        }
    }
}

// تعديل نموذج DataChatUser لإضافة الفهرس
struct DataChatUser: Identifiable {
    var id: String { uid }
    let uid, email, ProfileImage: String
    let IsUser: Bool
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.IsUser = data["IsUser"] as? Bool ?? true
        self.email = data["email"] as? String ?? ""
        self.ProfileImage = data["ProfileImage"] as? String ?? ""
    }
    
    init(uid: String, IsUser: Bool, email: String, ProfileImage: String) {
        self.uid = uid
        self.IsUser = IsUser
        self.email = email
        self.ProfileImage = ProfileImage
    }
}
