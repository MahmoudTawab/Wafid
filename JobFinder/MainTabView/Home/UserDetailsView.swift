//
//  UserDetailsView.swift
//  Wafid
//
//  Created by almedadsoft on 29/01/2025.
//


import SwiftUI

struct UserDetailsView: View {
    let user: UserInfo
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HeaderView(user: user)
                    
                    // Resume Section
                    ResumeButtonView()
                    
                    // Tab Bar
                    UserDetailsCustomTabBar(selectedTab: $selectedTab)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        EducationView(user: user)
                            .tag(0)
                        WorkExperienceView(user: user)
                            .tag(1)
                        AnswersView(user: user)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                .padding(.top)
                .frame(width: UIScreen.main.bounds.width -  20,height: UIScreen.main.bounds.height)
            }
            .padding()
            .edgesIgnoringSafeArea(.all)
            .preferredColorScheme(.light)
            .background(rgbToColor(red: 255, green: 255, blue: 255))
            .frame(width: UIScreen.main.bounds.width)
        }
    }
}

struct HeaderView: View {
    let user: UserInfo
    @State var userImageProfile : UIImage?
    @AppStorage("company_id") var company_id: String = ""
    @AppStorage("user_mail") var user_mail: String = ""
    @AppStorage("fullName") var fullName : String = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image("Icon")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                
                Text("Applications")
                    .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                    .foregroundColor(.black)
                
                Spacer()
                
               
                Button {
                    navigateTapGesture()
                } label: {
                    Image("Frame 1396")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            navigateTapGesture()
                        }
                }
                .padding()
                .frame(width: 40, height: 40)
                
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            HStack(alignment: .top, spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: (userImageProfile ?? UIImage(systemName: "person.circle")) ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(user.fullName ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("♂")
                    }
                    
                    Text(user.email ?? "")
                        .foregroundColor(.gray)
                    
                    Text(user.occupation ?? "")
                        .foregroundColor(.gray)
                    
                    Text("\(user.country ?? "")")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.white)
        .onAppear {
            if let profile = user.profileAttachID {
                CollApiDownloadFile(fileId: "\(profile)")
            }
        }
    }
    
    func CollApiDownloadFile(fileId:String) {
        Task {
            do {
                let result = try await makeRequestDownloadFile(
                    ApiToken: ApiToken,
                    fileId: fileId,
                    dateToken: dateToken
                )
                                
                // التعامل مع النتيجة
                if let resultDict = result as? [String: Any] {
                    if let fileData = resultDict["FileData"] as? String {
                        // تحويل البيانات من Base64 إلى Data
                        if let decodedData = Data(base64Encoded: fileData.replacingOccurrences(of: "\r\n", with: "")) {
                            // يمكنك الآن استخدام decodedData لإنشاء صورة أو حفظ الملف
                            if let image = UIImage(data: decodedData) {
                                // تم تحميل الصورة بنجاح
                                self.userImageProfile = image
                            }
                        }
                    }
                }
            } catch {
                print("Error downloading file:", error)
            }
        }
    }
    
    private func navigateTapGesture() {
        if let recipientUserId = user.id {
            // Check for existing chat
            checkExistingChat(currentUserId: company_id , recipientId: "\(recipientUserId)") { existingChatId in
                
                if let chatId = existingChatId {
                    
                    // Existing chat found - navigate to it
                    navigationManager.navigate(to: .ChatView(chatId: chatId,
                        currentImage: "\(user.profileAttachID ?? 0)",
                        recipientImage: "",
                        currentUserId: company_id ,
                        currentMail: user_mail,
                        recipientId: "\(recipientUserId)",
                        recipientMail: user.fullName ?? user.email ?? ""
                    ))
                } else {
                    // No existing chat - create new one
                    let newChatId = ChatService.createChatId(userId1: company_id, userId2: "\(recipientUserId)")
                    navigationManager.navigate(to: .ChatView(
                        chatId: newChatId,
                        currentImage: "\(user.profileAttachID ?? 0)",
                        recipientImage: "",
                        currentUserId: company_id ,
                        currentMail: user_mail ,
                        recipientId: "\(recipientUserId)",
                        recipientMail: user.fullName ?? user.email ?? "Unknown User"
                    ))
                }
            }
        }
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

struct ResumeButtonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Resume")
                .font(Font.system(size: ControlWidth(15)).weight(.heavy))
                .padding(.horizontal)
            
            HStack {
                Text("Unlock to see Resume")
                    .foregroundColor(.black.opacity(0.8))
                    .font(Font.system(size: ControlWidth(13), weight: .regular))
                
                Spacer()
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Unlock")
                            .font(Font.system(size: ControlWidth(13)).weight(.heavy))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(rgbToColor(red: 220, green: 200, blue: 16))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding()
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

struct UserDetailsCustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs = ["Education", "Work experience", "Answers to questions"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    VStack {
                        Text(tabs[index])
                            .foregroundColor(selectedTab == index ? rgbToColor(red: 193, green: 140, blue: 70) : .gray)
                            .fontWeight(selectedTab == index ? .medium : .regular)
                            .font(Font.system(size: ControlWidth(14)))
                        
                        Rectangle()
                            .fill(selectedTab == index ? rgbToColor(red: 193, green: 140, blue: 70) : Color.clear)
                            .frame(height: 2)
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedTab = index
                        }
                    }
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
        }
        .frame(height: 50)
        .padding(.vertical)
    }
}

struct EducationView: View {
    let user: UserInfo
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Bachelor's Degree
                EducationSection(
                    title: "Bachelor's Degree",
                    items: user.education?.flatMap { education in
                        education.bachelorsDegree.map { degree in
                            EducationItem(
                                date: "December",
                                year: "\(degree.universityGradeYear)",
                                title: "Bachelor's Degree",
                                subtitle: "\(degree.university) - \(degree.faculty)"
                            )
                        }
                    } ?? []
                )
                
                // High School
                EducationSection(
                    title: "High School",
                    items: user.education?.flatMap { education in
                        education.highSchool.map { school in
                            EducationItem(
                                date: "December",
                                year: "\(school.schoolGradeYear)",
                                title: "High School",
                                subtitle: school.schoolName
                            )
                        }
                    } ?? []
                )
                
                // Certifications
                if let certifications = user.certifications {
                    EducationSection(
                        title: "Certifications",
                        items: certifications.map { cert in
                            EducationItem(
                                date: "December",
                                year: cert.date.prefix(4).description,
                                title: "Certifications",
                                subtitle: "\(cert.name) - \(cert.organization)"
                            )
                        }
                    )
                }
                
                // Training & Courses
                if let trainings = user.trainings {
                    EducationSection(
                        title: "Training & Courses",
                        items: trainings.map { training in
                            EducationItem(
                                date: "December",
                                year: training.date.prefix(4).description,
                                title: "Training & Courses",
                                subtitle: "\(training.name) - \(training.organization)"
                            )
                        }
                    )
                }
            }
            .padding(.horizontal)
        }.padding(.bottom , 20)

    }
}

struct EducationSection: View {
    let title: String
    let items: [EducationItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(Font.system(size: ControlWidth(15)))
            
            ForEach(items, id: \.subtitle) { item in
                EducationItemView(
                    date: item.date,
                    year: item.year,
                    title: item.title,
                    subtitle: item.subtitle
                )
            }
        }
    }
}

struct EducationItem {
    let date: String
    let year: String
    let title: String
    let subtitle: String
}

struct EducationItemView: View {
    let date: String
    let year: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Text(date)
                    .foregroundColor(.gray)
                    .font(Font.system(size: ControlWidth(13)))
                
                Text(year)
                    .foregroundColor(.gray)
                    .font(Font.system(size: ControlWidth(13)))
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(rgbToColor(red: 193, green: 140, blue: 70).opacity(0.2))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                Text(subtitle)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

struct WorkExperienceView: View {
    let user: UserInfo
    
    let dummyWorkExperience = [
        WorkExperience(id: 1, jobTitle: "iOS Developer", jobDetails: "Developed and maintained iOS applications using Swift and SwiftUI.", startDate: "2020-01-01", endDate: "2022-12-31"),
        WorkExperience(id: 2, jobTitle: "Software Engineer", jobDetails: "Worked on backend systems and APIs using Node.js and Python.", startDate: "2023-01-01", endDate: "Present"),
        WorkExperience(id: 3, jobTitle: "Junior Developer", jobDetails: "Assisted in developing web applications using HTML, CSS, and JavaScript.", startDate: "2018-06-01", endDate: "2019-12-31")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(user.workExperience ?? dummyWorkExperience, id: \.id) { experience in
                    HStack {
                        Image("Group 1171279909")
                            .resizable()
                            .frame(width: 45, height: 45)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(experience.jobTitle)
                                .fontWeight(.medium)
                            Text("\(experience.startDate) - \(experience.endDate)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AnswersView: View {
    let user: UserInfo
    
    let dummyWorkExperience = [
        WorkExperience(id: 1, jobTitle: "iOS Developer", jobDetails: "Developed and maintained iOS applications using Swift and SwiftUI.", startDate: "2020-01-01", endDate: "2022-12-31"),
        WorkExperience(id: 2, jobTitle: "Software Engineer", jobDetails: "Worked on backend systems and APIs using Node.js and Python.", startDate: "2023-01-01", endDate: "Present"),
        WorkExperience(id: 3, jobTitle: "Junior Developer", jobDetails: "Assisted in developing web applications using HTML, CSS, and JavaScript.", startDate: "2018-06-01", endDate: "2019-12-31")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(user.workExperience ?? dummyWorkExperience, id: \.id) { experience in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How many experience do you have?")
                            .fontWeight(.medium)

                        Text("\(experience.startDate) - \(experience.endDate) Years")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

