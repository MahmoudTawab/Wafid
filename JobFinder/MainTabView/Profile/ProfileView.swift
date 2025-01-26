//
//  ProfileView.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//

import SwiftUI

// View للملف الشخصي
struct ProfileView: View {
    @AppStorage("user_id") var user_id: String = ""
    @StateObject private var viewModel = ProfileMainViewModel()
    @EnvironmentObject var navigationManager: NavigationManager
    // Form Fields State
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var birthDate: String = ""
    @State private var gender: String = ""
    @State private var address: String = ""
    @State private var occupation: String = ""
    @State private var nationality: String = ""
    @State private var nationalId: String = ""
    @State private var bloodType: String = ""
    @State private var qualification: String = ""
    @State private var birthPlace: String = ""
    
    // Error States
    @State private var fullNameError: TextFieldError = .none
    @State private var emailError: TextFieldError = .none
    @State private var phoneError: TextFieldError = .none
    @State private var birthDateError: TextFieldError = .none
    @State private var genderError: TextFieldError = .none
    @State private var addressError: TextFieldError = .none
    @State private var occupationError: TextFieldError = .none
    @State private var nationalityError: TextFieldError = .none
    @State private var nationalIdError: TextFieldError = .none
    @State private var bloodTypeError: TextFieldError = .none
    @State private var qualificationError: TextFieldError = .none
    @State private var birthPlaceError: TextFieldError = .none
    
    // Tab Selection
    @State private var selectedTab: ProfileTab = .general
    
    // Resume View State
    @State private var showPDFViewer: Bool = false
    
    enum ProfileTab: String {
        case general = "General"
        case uploadCV = "Upload CV"
        case education = "Education"
        case certificates = "Certificates"
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Profile Info Section
                        profileInfoSection
                        
                        // Social Links Section
                        socialLinksSection
                        
                        // Resume Section
                        resumeSection
                        
                        Rectangle()
                            .frame(height: 0.2)
                            .background(.gray.opacity(0.1))
                        
                        // Tab Selection Section
                        tabSelectionSection
                        
                        // Form Fields Section
                        if selectedTab == .general {
                            formFieldsSection
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 100)
                    .frame(width: UIScreen.main.bounds.width - 30)
                    .frame(minHeight: UIScreen.main.bounds.height - 100)
                }
                .padding()
                .keyboardSpace()
                .edgesIgnoringSafeArea(.all)
                .preferredColorScheme(.light)
                .background(rgbToColor(red: 255, green: 255, blue: 255))
                .frame(width: UIScreen.main.bounds.width)
                
                HStack {
                    Spacer()
                    
                    Button {
//                        navigationManager.navigate(to: .ChatUser)
                    } label: {
                        Image("Frame 2087324728")
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90,height: 90)
                            .padding(.bottom, 15)
                    }
                }
            }
            
            // Loading Indicator
            if viewModel.showLoadingIndicator {
                loadingOverlay
            }
            
            // Alert Message
            if let alertMessage = viewModel.alertMessage {
                AnimatedToastMessage(
                    showingErrorMessageisValid: $viewModel.showingAlert,
                    MassegeContent: .constant(alertMessage),
                    TypeToast: .error,
                    FrameHeight: .constant(65)
                )
                .padding(.top, -40)
            }
        }
        .task {
            if viewModel.userProfile == nil {
                await viewModel.fetchUser()
                if let profile = viewModel.userProfile {
                    updateFieldsWithProfile(profile)
                }
            }
        }
        
        .onTapGesture {
        hideKeyboard()
        }

    }
    
    // إخفاء لوحة المفاتيح
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            Image("logo_labour")
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("Profile")
                .font(.system(size: ControlWidth(22), weight: .bold))
            
            Spacer()
            
            Button(action: {
                // Add settings action
                navigationManager.navigate(to: .SettingsView)
            }) {
                Image("Frame 1388")
                    .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                    .frame(width: 28, height: 28)
            }
            .offset(y:-2)
            .padding()
        }
        .padding(.bottom, 8)
    }
    
    private var profileInfoSection: some View {
        HStack(alignment: .top,spacing: 16) {
            // Profile Image and Edit Button
            ZStack(alignment: .bottomTrailing) {
                if let profileAttach = viewModel.userImageProfile {
                    Image(uiImage: profileAttach)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.black.opacity(0.8))
                                .clipShape(Circle())
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .foregroundColor(.black.opacity(0.8))
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    // Add edit profile picture action
                }) {
                    Image("edit-2")
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 25, height: 25)
                        .padding()
                }
                .frame(width: 30, height: 30)
                .background(rgbToColor(red: 193, green: 140, blue: 70))
                .clipShape(Circle())

            }

            // Profile Text Info
            VStack(alignment: .leading ,spacing: 4) {
                Text(viewModel.userProfile?.fullName ?? "")
                    .font(.system(size: ControlWidth(20), weight: .bold))
                
                Text(viewModel.userProfile?.country ?? "")
                    .font(.system(size: ControlWidth(14)))
                    .foregroundColor(.gray)
                
                Text(viewModel.userProfile?.occupation ?? "")
                    .font(.system(size: ControlWidth(14)))
                    .foregroundColor(.gray)
                
                Text("Experience : 2 Years ( Junior )")
                    .font(.system(size: ControlWidth(14)))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Profile Text Info
            HStack(spacing: 5) {
                Image("edit_svgrepo.com")
                Spacer(minLength: 5)
                Image("trash")
            }.frame(width: 60)
            
        }
    }
    
    private var socialLinksSection: some View {
        HStack(spacing: 20) {
            Spacer()
            SocialLinkButton(imageName: "facebook", url: "")
            Spacer()
            SocialLinkButton(imageName: "github", url: "")
            Spacer()
            SocialLinkButton(imageName: "linkedin", url: "")
            Spacer()
            SocialLinkButton(imageName: "behance", url: "")
            Spacer()
            Spacer()
        }
    }
    
    private var resumeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resume")
                .foregroundColor(.black)
                .font(.system(size: ControlWidth(16)))
            
            HStack(spacing: 10) {
                Text("Your Resume")
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    showPDFViewer = true
                }) {
                    Text("View")
                        .font(.system(size: ControlWidth(14)))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(rgbToColor(red: 193, green: 140, blue: 70))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    // Add PDF download action
                }) {
                    
                    Text("PDF")
                        .font(.system(size: ControlWidth(14)))
                        .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(rgbToColor(red: 255, green: 247, blue: 236))
                        .cornerRadius(12)
                       
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .frame(width: UIScreen.main.bounds.width - 40)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    private var tabSelectionSection: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                ForEach([ProfileTab.general, .uploadCV, .education, .certificates], id: \.self) { tab in
                    Button(action: {
                        withAnimation {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(tab.rawValue)
                                .foregroundColor(selectedTab == tab ? rgbToColor(red: 193, green: 140, blue: 70) : .gray)
                                .font(.system(size: ControlWidth(14),weight: selectedTab == tab ? .black:.regular))
                            
                            Spacer(minLength: 0)
                            
                            Rectangle()
                                .fill(selectedTab == tab ? rgbToColor(red: 193, green: 140, blue: 70) : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            Rectangle()
                .frame(height: 0.2)
                .background(.gray.opacity(0.1))
        }.frame(height: 40)
    }
    
    private var formFieldsSection: some View {
        VStack(spacing: 16) {
            
            TextFieldCustom(defaultText: $fullName,title: "Full name", placeholder: "Enter your full name", isRequired: true, type: .text) { text, error in
                fullName = text
                fullNameError = error
            }

            
            TextFieldCustom(defaultText: $email,title: "E-mail", placeholder: "Enter your email", isRequired: true, type: .email) { text, error in
                email = text
                emailError = error
            }
            
            
            TextFieldCustom(defaultText: $phone,title: "Phone number", placeholder: "Enter your phone number", isRequired: true, type: .phone,IsShowCountry : false) { text, error in
                phone = text
                phoneError = error
            }
                        
            TextFieldCustom(defaultText: $birthDate,title: "Date of birth", placeholder: "Select your birth date", isRequired: true, type: .date) { text, error in
                birthDate = text
                birthDateError = error
            }
            
            TextFieldCustom(defaultText: $birthPlace,IsShowImage:false,title: "Place of birth", placeholder: "Place of birth", isRequired: true, type: .text) { text, error in
                birthPlace = text
                addressError = error
            }
            
            TextFieldCustom(defaultText: $occupation,IsShowImage:false,title: "Occupation", placeholder: "Enter your occupation", isRequired: true, type: .text) { text, error in
                occupation = text
                occupationError = error
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
    
    // MARK: - Helper Functions
    
    private func updateFieldsWithProfile(_ profile: UserProfile) {
        fullName = profile.fullName
        email = profile.email
        phone = profile.phone
        birthDate = profile.birthDate
        occupation = profile.occupation
        nationality = profile.nationalityName
        nationalId = profile.nationalId
        bloodType = profile.bloodType
        qualification = profile.qualification
        birthPlace = profile.birthPlace
    }
}

// MARK: - Supporting Views

struct SocialLinkButton: View {
    let imageName: String
    let url: String
    
    var body: some View {
        Button(action: {
            // Add social link action
            guard let url = URL(string: url) else { return }
            UIApplication.shared.open(url)
        }) {
            Image(imageName)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
        }
    }
}

// Profile Data Models
struct ProfileResponse: Codable {
    let totalRowsCount: String
    let fieldsCount: String
    let fieldNames: String
    let fieldTypes: String
    let outParameters: String
    let result: [UserProfile]
    
    enum CodingKeys: String, CodingKey {
        case totalRowsCount = "TotalRowsCount"
        case fieldsCount = "FieldsCount"
        case fieldNames = "FieldNames"
        case fieldTypes = "FieldTypes"
        case outParameters = "OutParameters"
        case result = "Result"
    }
}

struct UserProfile: Codable, Identifiable {
    let id: String
    let fullName: String
    let email: String
    let phone: String
    let nationalityName: String
    let birthDate: String
    let employeeId: String
    let occupation: String
    let releaseDate: String
    let country: String
    let expiryDate: String
    let nationalId: String
    let nationalIdAttachId: String
    let nationalIdAttach: String
    let personalAttach: String
    let bloodType: String
    let relativesNumber: String
    let birthPlace: String
    let qualification: String
    let profileAttachId: String
    let profileAttach: String
    let subscribed: String
    let educationId: String
    let links: String
    let types: String
    let education: String
    let certifications: String
    let trainings: String
    let workExperience: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case email
        case phone
        case nationalityName = "nationality_name"
        case birthDate = "birth_date"
        case employeeId = "employee_id"
        case occupation
        case releaseDate = "release_date"
        case country
        case expiryDate = "expiry_date"
        case nationalId = "national_id"
        case nationalIdAttachId = "national_id_attach_id"
        case nationalIdAttach = "national_id_attach"
        case personalAttach = "personal_attach"
        case bloodType = "blood_type"
        case relativesNumber = "relatives_number"
        case birthPlace = "birth_place"
        case qualification
        case profileAttachId = "profile_attach_id"
        case profileAttach = "profile_attach"
        case subscribed = "Subscribed"
        case educationId = "education_id"
        case links
        case types
        case education
        case certifications
        case trainings
        case workExperience = "work_experience"
    }
}

@MainActor
class ProfileMainViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var alertMessage: String?
    @Published var showingAlert = false
    @Published var showLoadingIndicator = false
    @AppStorage("user_id") var userId: String = ""
    @Published var userImageProfile : UIImage?
    
    private let procedureName = "vmwj6g067SaW8AVo535JJw=="
    
    func fetchUser() async {
        showLoadingIndicator = true
        alertMessage = nil
        
        let orderedParameters: [(String, Any)] = [
            ("user_id", userId)
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
            
            if let encrypted = response as? [String: Any] , let dataString = encrypted["Data"] as? String {
                let decryptedData = AES256Encryption.decrypt(dataString)
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: decryptedData),
                   let profileResponse = try? JSONDecoder().decode(ProfileResponse.self, from: jsonData) {
                    if let firstProfile = profileResponse.result.first {
                        userProfile = firstProfile
                        if let profileAttach = userProfile?.profileAttachId { CollApiDownloadFile(fileId: profileAttach) }
                        showLoadingIndicator = false
                    }
                } else {
                    showingAlert = true
                    showLoadingIndicator = false
                    alertMessage = "Failed to decode profile data"
                }
            }
        } catch {
            showingAlert = true
            showLoadingIndicator = false
            alertMessage = "Failed to fetch profile: \(error.localizedDescription)"
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
                                print("Image downloaded successfully")
                            }
                        }
                    }
                    
                    // فك تشفير امتداد الملف واسمه
                    if let fileExt = resultDict["FileExt"] as? String {
                        let decryptedFileExt = AES256Encryption.decrypt(fileExt)
                        print("File Extension:", decryptedFileExt)
                    }
                    
                    if let savedFileName = resultDict["SavedFileName"] as? String {
                        let decryptedFileName = AES256Encryption.decrypt(savedFileName)
                        print("Saved File Name:", decryptedFileName)
                    }
                }
            } catch {
                print("Error downloading file:", error)
            }
        }
    }
}


