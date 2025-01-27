//
//  ProfileCompanyView.swift
//  Wafid
//
//  Created by almedadsoft on 27/01/2025.
//


import SwiftUI

// View للملف الشخصي
struct ProfileCompanyView: View {
    @AppStorage("user_id") var user_id: String = ""
    @StateObject private var viewModel = ProfileMainCompanyViewModel()
    @EnvironmentObject var navigationManager: NavigationManager
    
    // Form Fields State
    @State private var Description: String = ""
    @State private var NameOfCompany: String = ""
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var EstablishedDate: String = ""
    @State private var Country: String = ""
    @State private var CompanyAddress: String = ""
    @State private var Activity: String = ""
    @State private var Branches: String = ""
    
    // Error States
    @State private var fullNameError: TextFieldError = .none
    @State private var emailError: TextFieldError = .none
    @State private var phoneError: TextFieldError = .none
    @State private var NameOfCompanyError: TextFieldError = .none
    @State private var EstablishedDateError: TextFieldError = .none
    @State private var CountryError: TextFieldError = .none
    @State private var CompanyAddressError: TextFieldError = .none
    @State private var ActivityError: TextFieldError = .none
    @State private var BranchesError: TextFieldError = .none

    
    // Tab Selection
    @State private var selectedTab: ProfileTab = .general
    
    // Resume View State
    @State private var showPDFViewer: Bool = false
    
    enum ProfileTab: String {
        case general = "General"
        case uploadCV = "Add User"
        case education = "Pricing Plann"
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
                        navigationManager.navigate(to: .ChatUser)
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
                .padding(.top,0)
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
                
                Text(viewModel.userProfile?.email ?? "")
                    .font(.system(size: ControlWidth(14)))
                    .foregroundColor(.gray)
                
                Text("\(viewModel.userProfile?.country ?? "")  \(viewModel.userProfile?.companyAddress1 ?? "")")
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
    
    private var tabSelectionSection: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                ForEach([ProfileTab.general, .uploadCV, .education], id: \.self) { tab in
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
            
            FacebookStyleEditor(placeholder: "Description", Editor: .constant(""),text: $Description)
            
            TextFieldCustom(defaultText: $NameOfCompany,IsShowImage: false,title: "Name of Company", placeholder: "Name of Company", isRequired: true, type: .text) { text, error in
            NameOfCompany = text
            NameOfCompanyError = error
            }
            
            TextFieldCustom(defaultText: $email,title: "Company E-mail", placeholder: "Enter your email", isRequired: true, type: .email) { text, error in
                email = text
                emailError = error
            }

            TextFieldCustom(defaultText: $phone,title: "Phone number", placeholder: "Enter your phone number", isRequired: true, type: .phone,IsShowCountry : false) { text, error in
                phone = text
                phoneError = error
            }
                        
            TextFieldCustom(defaultText: $EstablishedDate,title: "Established date", placeholder: "Established date", isRequired: true, type: .date,IsShowCountry : false) { text, error in
                EstablishedDate = text
                EstablishedDateError = error
            }
            
 
            TextFieldCustom(defaultText: $Country,IsShowImage:false,title: "Country", placeholder: "Country", isRequired: true, type: .text) { text, error in
                Country = text
                CountryError = error
            }
         
            TextFieldCustom(defaultText: $CompanyAddress,IsShowImage:false,title: "Company Address", placeholder: "Company Address", isRequired: true, type: .text) { text, error in
                CompanyAddress = text
                CompanyAddressError = error
            }
            
            TextFieldCustom(defaultText: $Activity,IsShowImage:false,title: "Activity", placeholder: "Activity", isRequired: true, type: .text) { text, error in
                Activity = text
                ActivityError = error
            }
           
            TextFieldCustom(defaultText: $Branches,IsShowImage:false,title: "Branches", placeholder: "Branches", isRequired: true, type: .text) { text, error in
                Branches = text
                BranchesError = error
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
    
    private func updateFieldsWithProfile(_ profile: CompanyProfile) {
        fullName = profile.fullName ?? ""
        email = profile.email ?? ""
        phone = profile.phone ?? ""
        Description = profile.activity ?? ""
        NameOfCompany = profile.companyName ?? ""
        EstablishedDate = profile.readDate ?? ""
        Country = profile.country ?? ""
        CompanyAddress = profile.companyAddress ?? ""
        Activity = profile.activity ?? ""
        Branches = profile.companyAddress1 ?? ""
    }
}


struct ProfileCompanyResponse: Codable {
    var fieldNames: String?
    var fieldTypes: String?
    var fieldsCount: String?
    var outParameters: String?
    var result: [CompanyProfile]?
    var totalRowsCount: String?
    
    enum CodingKeys: String, CodingKey {
        case fieldNames = "FieldNames"
        case fieldTypes = "FieldTypes"
        case fieldsCount = "FieldsCount"
        case outParameters = "OutParameters"
        case result = "Result"
        case totalRowsCount = "TotalRowsCount"
    }
    
    init(fieldNames: String? = nil, fieldTypes: String? = nil, fieldsCount: String? = nil, outParameters: String? = nil, result: [CompanyProfile]? = nil, totalRowsCount: String? = nil) {
        self.fieldNames = fieldNames
        self.fieldTypes = fieldTypes
        self.fieldsCount = fieldsCount
        self.outParameters = outParameters
        self.result = result
        self.totalRowsCount = totalRowsCount
    }
}

struct CompanyProfile: Codable {
    var id: String
    var fullName: String?
    var email: String?
    var role: String?
    var phone: String?
    var companyId: String?
    var companyName: String?
    var companyAddress: String?
    var activity: String?
    var companyAddress1: String?
    var companyType: String?
    var adminId: String?
    var companyPhone: String?
    var companyCapital: String?
    var country: String?
    var taxAttachId: String?
    var personalNum: String?
    var personalAttachId: String?
    var personalAttach: String?
    var isMultinational: String?
    var recordAttach: String?
    var taxAttach: String?
    var createdBy: String?
    var readDate: String?
    var updatedAt: String?
    var updatedBy: String?
    var nationality: String?
    var nearestPoint: String?
    var recordAttachId: String?
    var companyUsers: String?
    var CompanyData : [CompanyUser]?
    
    enum CodingKeys: String, CodingKey {
        case id, fullName, email, role, phone
        case companyId = "company_id"
        case companyName = "company_name"
        case companyAddress = "company_address"
        case activity
        case companyAddress1 = "company_address_1"
        case companyType = "company_type"
        case adminId = "admin_id"
        case companyPhone = "company_phone"
        case companyCapital = "company_capital"
        case country
        case taxAttachId = "tax_attach_id"
        case personalNum = "personal_num"
        case personalAttachId = "personal_attach_id"
        case personalAttach = "personal_attach"
        case isMultinational
        case recordAttach = "record_attach"
        case taxAttach = "tax_attach"
        case readDate = "read_date"
        case createdBy , updatedAt, updatedBy, nationality, nearestPoint
        case recordAttachId = "record_attach_id"
        case companyUsers = "company_users"
    }
    
    init(id: String, fullName: String? = nil, email: String? = nil, role: String? = nil, phone: String? = nil, companyId: String? = nil, companyName: String? = nil, companyAddress: String? = nil, activity: String? = nil, companyAddress1: String? = nil, companyType: String? = nil, adminId: String? = nil, companyPhone: String? = nil, companyCapital: String? = nil, country: String? = nil, taxAttachId: String? = nil, personalNum: String? = nil, personalAttachId: String? = nil, personalAttach: String? = nil, isMultinational: String? = nil, recordAttach: String? = nil, taxAttach: String? = nil, createdBy: String? = nil, readDate: String? = nil, updatedAt: String? = nil, updatedBy: String? = nil, nationality: String? = nil, nearestPoint: String? = nil, recordAttachId: String? = nil, companyUsers: String? = nil, CompanyData: [CompanyUser]? = nil) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.role = role
        self.phone = phone
        self.companyId = companyId
        self.companyName = companyName
        self.companyAddress = companyAddress
        self.activity = activity
        self.companyAddress1 = companyAddress1
        self.companyType = companyType
        self.adminId = adminId
        self.companyPhone = companyPhone
        self.companyCapital = companyCapital
        self.country = country
        self.taxAttachId = taxAttachId
        self.personalNum = personalNum
        self.personalAttachId = personalAttachId
        self.personalAttach = personalAttach
        self.isMultinational = isMultinational
        self.recordAttach = recordAttach
        self.taxAttach = taxAttach
        self.createdBy = createdBy
        self.readDate = readDate
        self.updatedAt = updatedAt
        self.updatedBy = updatedBy
        self.nationality = nationality
        self.nearestPoint = nearestPoint
        self.recordAttachId = recordAttachId
        self.companyUsers = companyUsers
        self.CompanyData = CompanyData
    }
    
}

struct CompanyUser: Codable {
    var userId: Int?
    var userName: String?
    var email: String?
    var userPhone: String?
    var role: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case email
        case userPhone = "user_phone"
        case role
    }
    
    init(userId: Int? = nil, userName: String? = nil, email: String? = nil, userPhone: String? = nil, role: String? = nil) {
        self.userId = userId
        self.userName = userName
        self.email = email
        self.userPhone = userPhone
        self.role = role
    }
}


@MainActor
class ProfileMainCompanyViewModel: ObservableObject {
    @Published var userProfile: CompanyProfile?
    @Published var alertMessage: String?
    @Published var showingAlert = false
    @Published var showLoadingIndicator = false
    @AppStorage("user_id") var userId: String = ""
    @Published var userImageProfile : UIImage?
    
    private let procedureName = "WGhhBCgyZ+aO3D1gfDjRow=="

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
            
            if let encrypted = response as? [String: Any], let dataString = encrypted["Data"] as? String {
                let decryptedData = AES256Encryption.decrypt(dataString)
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: decryptedData),
                   let profileResponse = try? JSONDecoder().decode(ProfileCompanyResponse.self, from: jsonData) {
                    if var firstProfile = profileResponse.result?.first {
                        // فك التشفير للمستخدمين داخل company_users
                        if var companyUsersString = firstProfile.companyUsers {
                            companyUsersString = companyUsersString.replacingOccurrences(of: "\\\"", with: "\"")

                            if  let companyUsersData = companyUsersString.data(using: .utf8) {
                            let decoder = JSONDecoder()
                            if let companyUsers = try? decoder.decode([CompanyUser].self, from: companyUsersData) {
                                firstProfile.CompanyData = companyUsers
                                self.userProfile = firstProfile
                                if let personalAttachId = self.userProfile?.personalAttachId {self.CollApiDownloadFile(fileId:personalAttachId)}
                                self.showLoadingIndicator = false
                            }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showingAlert = true
                        self.showLoadingIndicator = false
                        self.alertMessage = "Failed to decode profile data"
                    }
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


