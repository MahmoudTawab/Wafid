//
//  JobRecommendationView.swift
//  Wafid
//
//  Created by almedadsoft on 28/01/2025.
//


import SwiftUI

struct JobRecommendationView: View {
    
    var jobs_id : String?
    @State var IfIsDescription:Bool = true
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = JobRecommendationViewModel()

    @AppStorage("user_id") var user_id: String = ""
    @AppStorage("company_id") var company_id: String = ""
    @AppStorage("user_mail") var user_mail: String = ""
    @AppStorage("fullName") var fullName : String = ""
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                ZStack {
                    Image("Company Job")
                    VStack(spacing: 20) {
                        // Navigation header
                        HStack(spacing: 10) {
                            Image("Icon")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 30,height: 30)
                                .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                            
                            Text("Job Recommendation")
                                .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.top,20)
                        .padding(.horizontal)
                        
                        // Social icons
                        ZStack(alignment: .trailing) {
                            HStack(spacing: 20) {
                                Spacer()
                                
                                Image("linkedin")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                
                                Spacer()
                            }
                            
                            Button {
                                navigateTapGesture()
                            } label: {
                                Image("Frame 1396")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .contentShape(Rectangle())
                            }
                            .padding(10)
                            .frame(width: 60, height: 60) 
                        }

                        // Job title and company
                        VStack(spacing: 8) {
                            Text(viewModel.jobData?.jobTitle ?? "")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if let companyInfo = viewModel.jobData?.parsedCompanyInfo?.first {
                                Text(companyInfo.company_email ?? companyInfo.companyName ?? "")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }

                        // Tags
                        HStack(spacing: 12) {
                            ForEach([viewModel.jobData?.categoryName ?? "", viewModel.jobData?.typeName ?? "", viewModel.jobData?.experienceLevel ?? ""], id: \.self) { tag in
                                Text(tag)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                                    .foregroundColor(.white)
                            }
                        }

                        // Salary and location
                        HStack(spacing: 40) {
                            Text("\(viewModel.jobData?.salary ?? "") /Month")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if let companyInfo = viewModel.jobData?.parsedCompanyInfo?.first {
                                Text(companyInfo.country ?? "")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 20)
                    .frame(width: UIScreen.main.bounds.width - 30)
                }
                
                // Content
                
                VStack(alignment: .leading, spacing: 20) {
                    // Description/Requirements tabs
                    HStack {
                        Text("Description")
                            .foregroundColor(IfIsDescription ? .black : .gray)
                            .font(.system(size: ControlWidth(14)))
                            .onTapGesture {withAnimation {IfIsDescription = true}}
                        
                        Spacer()
                        
                        Text("Requirement")
                            .foregroundColor(!IfIsDescription ? .black : .gray)
                            .font(.system(size: ControlWidth(14)))
                            .onTapGesture {withAnimation {IfIsDescription = false}}

                    }
                    .padding(.horizontal,10)

                    if IfIsDescription {
                        // Description text
                        Text(viewModel.jobData?.jobDescription ?? "")
                            .font(.system(size: ControlWidth(12)))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        // Responsibilities
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Responsibilities:")
                                .foregroundColor(.black.opacity(0.8))
                                .font(.system(size: ControlWidth(14)))
                                .padding(.bottom, 4)
                            if let companyInfo = viewModel.jobData?.parsedJobRequirements {
                                ForEach(companyInfo, id: \.id) { Info in
                                    BulletPoint(text: Info.title ?? "")
                                }
                            }
                        }
                        .padding(.horizontal)
                    }else{

                        if let companyInfo = viewModel.jobData?.parsedJobQuestions {
                            ForEach(companyInfo, id: \.id) { Info in
                                BulletPoint(text: Info.question ?? "")
                            }
                        }
                    }
                    
                    // Notification
                    HStack {
                        Image("directbox-notif")
                            .padding(.leading,15)
                        
                        Text("Financial Planner has viewed your profile and invited you to apply for this job 18 hours ago")
                            .padding(.vertical,10)
                            .padding(.horizontal,8)
                            .font(.footnote)
                            .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(rgbToColor(red: 255, green: 247, blue: 236))
                    )
                }
                .frame(width: UIScreen.main.bounds.width - 30)
                .padding(.vertical)
                
                Spacer()
                
                // Bottom buttons
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image("button")
                            .resizable()
                            .frame(width: 50,height: 50)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Apply Now")
                            .font(.system(size: ControlWidth(16),weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .frame(height: 50)
                            .background(rgbToColor(red: 193, green: 140, blue: 70))
                            .cornerRadius(12)
                    }
                }
                .background(Color.clear)
                .frame(width: UIScreen.main.bounds.width - 30)
            }
            .padding(.top,-30)
            .padding(.bottom, 20)
            .frame(height: UIScreen.main.bounds.height - 20)
            }
            .padding()
            .edgesIgnoringSafeArea(.all)
            .preferredColorScheme(.light)
            .background(rgbToColor(red: 255, green: 255, blue: 255))
            .frame(width: UIScreen.main.bounds.width)
            
//         Loading Indicator
        if viewModel.showLoadingIndicator {
            loadingOverlay
        }
        
        
//       Alert Message
        if let alertMessage = viewModel.alertMessage {
            AnimatedToastMessage(
                showingErrorMessageisValid: $viewModel.showingAlert,
                MassegeContent: .constant(alertMessage),
                TypeToast: .error,
                FrameHeight: .constant(65)
            )
            .padding(.top,50)
            .frame(width: UIScreen.main.bounds.width - 30)
        }
    }
        
    .task {
    if let jobsId = jobs_id {
    await viewModel.fetchData(jobs_id: jobsId)
    }
    }
    }
    
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                ActivityIndicatorView(isVisible: $viewModel.showLoadingIndicator, type: .flickeringDots())
                    .frame(width: 60, height: 60)
                    .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
            }
            .frame(width: 120, height: 120)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
        }
    }
    
    private func navigateTapGesture() {
        if let companyInfo = viewModel.jobData?.parsedCompanyInfo?.first {
            checkExistingChat(currentUserId: user_id , recipientId: "\(companyInfo.id)") { existingChatId in
                
            if let chatId = existingChatId {
            // Existing chat found - navigate to it
            navigationManager.navigate(to: .ChatView(chatId: chatId,
                                currentImage: "",
                                recipientImage: "",
                                currentUserId: user_id ,
                                currentMail: user_mail,
                                recipientId: "\(companyInfo.id)",
                                recipientMail: companyInfo.company_email ?? companyInfo.companyName  ?? "Unknown User"
                                ))
                } else {
                    // No existing chat - create new one
                    let newChatId = ChatService.createChatId(userId1: user_id, userId2: "\(companyInfo.id)")
                    navigationManager.navigate(to: .ChatView(
                        chatId: newChatId,
                        currentImage: "",
                        recipientImage: "",
                        currentUserId: user_id ,
                        currentMail: user_mail ,
                        recipientId: "\(companyInfo.id)",
                        recipientMail:  companyInfo.company_email ?? companyInfo.companyName ?? "Unknown User"
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

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.gray)
                .frame(width: 6, height: 6)
                .padding(.top, 8)
            Text(text)
                .foregroundColor(.gray)
                .font(.system(size: ControlWidth(12)))
        }
    }
}

// Data models for the response
struct JobData: Codable {
    let id: String            // تغيير من Int
    let jobTitle: String
    let position: String
    let salary: String        // تغيير من Int
    let available: String     // تغيير من Bool
    let experienceLevel: String
    let jobDescription: String
    let categoryId: String    // تغيير من Int
    let categoryName: String
    let active: String        // تغيير من Bool
    let readDate: String
    let expired: String       // تغيير من Bool
    let isSaved: String       // تغيير من Int
    let savedId: String       // تغيير من Int
    let subscribed: String    // تغيير من Int
    let isApplied: String     // تغيير من Int
    let companyInfo: String
    let typeName: String
    let jobRequirements: String
    let jobQuestions: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case jobTitle = "job_title"
        case position
        case salary
        case available
        case experienceLevel = "experience_level"
        case jobDescription = "job_description"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case active
        case readDate = "read_date"
        case expired
        case isSaved
        case savedId = "saved_id"
        case subscribed = "Subscribed"
        case isApplied
        case companyInfo = "company_info"
        case typeName = "type_name"
        case jobRequirements = "job_requirements"
        case jobQuestions = "job_questions"
    }
    
    // إضافة computed properties للحصول على القيم المحولة
    var idInt: Int? { Int(id) }
    var salaryInt: Int? { Int(salary) }
    var categoryIdInt: Int? { Int(categoryId) }
    var isSavedInt: Int? { Int(isSaved) }
    var savedIdInt: Int? { Int(savedId) }
    var subscribedInt: Int? { Int(subscribed) }
    var isAppliedInt: Int? { Int(isApplied) }
    var availableBool: Bool { available.lowercased() == "true" }
    var activeBool: Bool { active.lowercased() == "true" }
    var expiredBool: Bool { expired.lowercased() == "true" }
    
    // دوال مساعدة لتحويل JSON strings إلى objects
    var parsedCompanyInfo: [CompanyInfo]? {
        guard let data = companyInfo.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([CompanyInfo].self, from: data)
    }
    
    var parsedJobRequirements: [JobRequirement]? {
        guard let data = jobRequirements.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([JobRequirement].self, from: data)
    }
    
    var parsedJobQuestions: [JobQuestion]? {
        guard let data = jobQuestions.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([JobQuestion].self, from: data)
    }
}
@MainActor
class JobRecommendationViewModel: ObservableObject {
    @Published var alertMessage: String?
    @Published var showingAlert = false
    @Published var showLoadingIndicator = false
    @Published var jobData: JobData?
    @AppStorage("user_id") var userId: String = ""
    private var procedureName = "dzUq/PJhryxiecJR9/vEdg=="
    
    func fetchData(jobs_id: String) async {
        
        if let jobs = jobData {
            return
        }
        
        showLoadingIndicator = true
        alertMessage = nil
        
        let orderedParameters: [(String, Any)] = [
            ("user_id", userId),
            ("jobs_id", jobs_id)
        ]
        
        let parameters = Dictionary(uniqueKeysWithValues: orderedParameters)
        
        do {
            let response = try await makeRequestGet(
                ProcedureName: procedureName,
                ApiToken: ApiToken,
                dateToken: dateToken,
                parametersValues: parameters,
                orderedKeys: orderedParameters
            )
        
            
            if let encrypted = response as? [String: Any],
               let dataString = encrypted["Data"] as? String {
                if let decryptedData = AES256Encryption.decrypt(dataString) as? [String: Any],
                   let resultArray = decryptedData["Result"] as? [[String: Any]],
                   let firstResult = resultArray.first {
                    // تحويل القاموس إلى Data
                                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: firstResult)

                        let decoder = JSONDecoder()
                        let jobData = try decoder.decode(JobData.self, from: jsonData)
                        self.jobData = jobData
                    } catch {
                        print("Decoding error: \(error)")
                    }
                }
            }
            
            showLoadingIndicator = false
        } catch {
            showingAlert = true
            showLoadingIndicator = false
            alertMessage = "Failed to fetch Data: \(error.localizedDescription)"
        }
    }
}


