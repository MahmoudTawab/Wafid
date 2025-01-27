//
//  ProfileCompanyScreen.swift
//  Wafid
//
//  Created by almedadsoft on 26/01/2025.
//


import SwiftUI

struct ProfileCompanyScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var viewModel = ProfileCompanyViewModel()
    @State var showingBottomSheet = false
    @State var showPhotoPicker = false
    @State var IsPassport = true
    
     // إضافة المتغيرات الجديدة
     @State private var showLoadingIndicator = false
     @State private var alertMessage = ""
     @State private var showingAlert = false
    
    var body: some View {
        ZStack(alignment: .top) {
        ScrollView(showsIndicators: false) {
        
                VStack {
                    
                    HStack(spacing: 10) {
                        Image("logo_labour")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45,height: 45)
                        
                        Text("Profile")
                            .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }.padding(.vertical,20)
                    
                    VStack {
                        Button(action: {
                            showPhotoPicker = true
                        }) {
                            VStack {
                                if let image = viewModel.selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .padding(.top,10)
                                } else {
                                    
                                    // أيقونة السحابة
                                    Image("PhotoPicker")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(Color.orange)
                                        .padding(.top,10)
                                }
                                
                                
                                Text("Upload Company Logo")
                                    .padding(.vertical)
                                    .foregroundColor(rgbToColor(red: 165, green: 171, blue: 179))
                                
                            }
                            .background(rgbToColor(red: 255, green: 255, blue: 255))
                        }
                        .background(rgbToColor(red: 255, green: 255, blue: 255))
                        .frame(width: UIScreen.main.bounds.width - 40,height: 160)
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $showPhotoPicker) {
                            // فتح مكتبة الصور
                            PhotoPicker(selectedImage: $viewModel.selectedImage)
                        }
                    }
                    
                    .background(rgbToColor(red: 255, green: 255, blue: 255))
                    .frame(width: UIScreen.main.bounds.width - 40,height: 160)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3)  , lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 3, y: 4)
      
                    TextFieldCustom(defaultText:.constant(""),IsShowImage: false,title: "Name of Company", placeholder: "Name of Company", isRequired: true, type: .text) { text, error in
                        viewModel.NameCompany = text
                        viewModel.NameCompanyError = error
                    }.padding(.bottom, 10)
                    
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Phone number", placeholder: "Phone number", isRequired: true, type: .phone) { text, error in
                        viewModel.PhoneNumber = text
                        viewModel.PhoneNumberError = error
                    }.padding(.bottom, 10)
                    
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Established date", placeholder: "Established date", isRequired: true, type: .date) { text, error in
                        viewModel.dateEstablished = text
                        viewModel.dateEstablishedError = error
                    }.padding(.bottom, 10)
                    
                    
                    PickerViewCountry(selectedCountry: $viewModel.selectedCountry)
                        .padding(.bottom, 10)
                    
                    
                    TextFieldCustom(defaultText:.constant(""),IsShowImage: false,title: "Company Address", placeholder: "Company Address", isRequired: true, type: .text) { text, error in
                        viewModel.CompanyAddress = text
                        viewModel.CompanyAddressError = error
                    }.padding(.bottom, 10)
                    
                    TextFieldCustom(defaultText:.constant(""),IsShowImage: false,title: "Activity", placeholder: "Activity", isRequired: true, type: .text) { text, error in
                        viewModel.Activity = text
                        viewModel.ActivityError = error
                    }.padding(.bottom, 10)

                    TextFieldCustom(defaultText:.constant(""),title: "Password", placeholder: "Enter password", isRequired: true, type: .password) { text, error in
                        viewModel.password = text
                        viewModel.passwordError = error
                    }.padding(.bottom, 10)
                    
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Confirm New Password", placeholder: "Enter Confirm password", isRequired: true, type: .Confirminvalid,
                                    passwordToMatch: viewModel.password) { text, error in
                        viewModel.ConfirmNew = text
                        viewModel.ConfirmpasswordError = error
                    }.padding(.bottom, 10)
                    
        
                    EmployeeNumberSurvey { NumberSurvey in
                    viewModel.EmployeeNumberSelected = NumberSurvey
                    }
                    .padding(.bottom, 10)
                    
                    Button(action: {
                        FuncSignUp()
                    }) {
                        Text("Confirm")
                            .font(.system(size: ControlWidth(16), weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(rgbToColor(red: 193, green: 140, blue: 70))
                            .cornerRadius(15)
                    }
                    .opacity(viewModel.validateAllFields() ? 1 : 0.6)
                    .disabled(!viewModel.validateAllFields())
                    .padding(.bottom,5)
                    
                    Spacer()
                }
                .padding(.top , 30)
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
            .padding(.top ,-40)
            
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
    
    func FuncSignUp() {
//         let isValid = viewModel.validateAllFields()
//         
//         if isValid {
//             hideKeyboard()
//             showLoadingIndicator = true // تفعيل المؤشر
//             Task {
//                 do {
//                let success = try await viewModel.performSignUp()
//                     
//                DispatchQueue.main.async {
//                showLoadingIndicator = false // إيقاف المؤشر
//                if success {
//                    navigationManager.navigate(to: .OTPVerificationView(email: viewModel.email, TransToken: "", user_id: viewModel.user_id, newPassword: viewModel.password, IsGomeInProfile: true))
//                }
//                }
//                } catch {
//                     DispatchQueue.main.async {
//                         showLoadingIndicator = false // إيقاف المؤشر
//                         alertMessage = error.localizedDescription
//                         showingAlert = true
//                     }
//                 }
//             }
//         }
     }
}


struct EmployeeNumberSurvey: View {
    let actionSelected: (_ Selected : String) -> Void
    @State private var selectedOption: String? = nil // لتتبع الخيار المحدد

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Number of Employee")
                    .font(Font.system(size: ControlWidth(12)))
                    .foregroundColor(.black.opacity(0.8))
                
                    Text("*")
                        .foregroundColor(.red)
            }
            
            HStack(spacing: 16) {
                            RadioButtonOption(
                                label: "10 - 50",
                                isSelected: selectedOption == "10 - 50",
                                action: {
                                    selectedOption = "10 - 50"
                                    actionSelected(selectedOption ?? "10 - 50")
                                }
                            )
                            RadioButtonOption(
                                label: "51 - 100",
                                isSelected: selectedOption == "51 - 100",
                                action: {
                                    selectedOption = "51 - 100"
                                    actionSelected(selectedOption ?? "10 - 50")
                                }
                            )
                            RadioButtonOption(
                                label: "101 - 200",
                                isSelected: selectedOption == "101 - 200",
                                action: {
                                    selectedOption = "101 - 200"
                                    actionSelected(selectedOption ?? "10 - 50")
                                }
                            )
                            RadioButtonOption(
                                label: "Over 200",
                                isSelected: selectedOption == "Over 200",
                                action: {
                                    selectedOption = "Over 200"
                                    actionSelected(selectedOption ?? "10 - 50")
                                }
                            )
                        }
                    }
        }
}


struct RadioButtonOption: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.76, green: 0.55, blue: 0.27) : Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.76, green: 0.55, blue: 0.27))
                            .frame(width: 14, height: 14)
                    }
                }
                
                Text(label)
                    .font(Font.system(size: ControlWidth(12)))
                    .foregroundColor(.black.opacity(0.8))
            }
        }
    }
}

class ProfileCompanyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedImage: UIImage?
    @Published var selectedCountry: String = "Libya"
    @Published var EmployeeNumberSelected : String = "10 - 50"
    
    @Published var NameCompany = ""
    @Published var PhoneNumber = ""
    @Published var dateEstablished = ""
    @Published var CompanyAddress = ""
    @Published var Activity = ""
    
    @Published var password = ""
    @Published var ConfirmNew = ""
    
    @Published var NameCompanyError: TextFieldError = .empty
    @Published var PhoneNumberError: TextFieldError = .empty
    @Published var dateEstablishedError: TextFieldError = .empty
    @Published var CompanyAddressError: TextFieldError = .empty
    @Published var ActivityError: TextFieldError = .empty

    @Published var passwordError: TextFieldError = .empty
    @Published var ConfirmpasswordError: TextFieldError = .empty
    
    var user_id: String = ""
    @AppStorage("user_mail") var user_mail: String = ""
    
    // Add new properties for image IDs
    private var profileImageId: String = ""
    private var passportImageId: String = ""
    private var educationalImageId: String = ""
    
    private let tableNames = ["ibVWvKYKYgVvqrBguXGjbw==", "mj67HwxQ/R4DQp/ZsCtgmw=="]
    
    // دالة لمسح كل البيانات
    func clearData() {
        selectedImage = nil
        NameCompany = ""
        NameCompanyError = .none
        dateEstablished = ""
        dateEstablishedError = .none
        CompanyAddress = ""
        CompanyAddressError = .none
        PhoneNumber = ""
        PhoneNumberError = .none
        Activity = ""
        ActivityError = .none
        
        password = ""
        passwordError = .none
        ConfirmNew = ""
        ConfirmpasswordError = .none
    }
    
    // MARK: - Validation Methods
    func validateAllFields() -> Bool {
        
        let isFieldsValid = NameCompanyError == .none &&
                           dateEstablishedError == .none &&
                           CompanyAddressError == .none &&
                           PhoneNumberError == .none &&
                           ActivityError == .none &&
                           passwordError == .none &&
                           ConfirmpasswordError == .none
        
        return isFieldsValid
    }
    

    
    // MARK: - API Methods
    // Update performSignUp to handle image uploads first
        func performSignUp() async throws -> Bool {
            // Upload images first and get their IDs
            if let profileImage = selectedImage {
                profileImageId = try await uploadImage(image: profileImage, type: "profile")
            }
            
            // Prepare user data with image IDs instead of base64
            let userData: [(String, Any)] = [
                ("id", "0"),
                ("fullName", NameCompany),
                ("email", CompanyAddress),
                ("password", password),
                ("phone", PhoneNumber),
                ("role", "company"),
                ("company_id", "0"),
                ("isValidate", "0"),
                ("active", "1"),
                ("method", "1"),
                ("read_date", "default"),
                ("nationality_name", selectedCountry),
                ("createdBy", "0"),
                ("updatedAt", "default"),
                ("updatedBy", "0"),
                ("personal_num",""),
                ("personal_attach", ""), // Use image ID instead of base64
                ("status", "0"),
                ("Legal_status", "")
            ]
            
            // Prepare company data with image IDs
            let companyData: [(String, Any)] = [
                ("id", "0"),
                ("company_name", "0"),
                ("company_address",CompanyAddress),
                ("activity",Activity),
                ("country", selectedCountry),
                ("users_id", "0"),
                ("read_date", "default"),
                ("package_id", "0"),
                ("company_phone", PhoneNumber),
                ("company_capital", EmployeeNumberSelected),
                ("country", selectedCountry),
                
                
                ("nationality", ""),
                ("createdBy", "default"),
                ("updatedAt", "default"),
                ("updatedBy", "default"),
                
                ("nearest_point", ""),
                ("record_attach", ""),
                
                ("tax_attach", ""),
                ("isMultinational", ""),
                ("isMultinational", "")
            ]
            
            let multiData = [userData, companyData]
            
            let result = try await makeRequestMultiPost(
                ApiToken: ApiToken,
                dateToken: dateToken,
                tableNames: tableNames,
                multiData: multiData
            )
            

            if let resultDict = result as? [String: Any],
               let status = resultDict["Result"] as? String,
               let error = resultDict["Error"] as? String,
               let decryptedResult = AES256Encryption.decrypt(status) as? String,
               let decryptedError = AES256Encryption.decrypt(error) as? String {
                
                if !decryptedError.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    // إذا كان هناك خطأ، قم برميه
                    throw ProfileError.apiError(decryptedError)
                } else if decryptedResult == "200" {
                    
                    guard let resultDict = result as? [String: Any],
                          let dataString = resultDict["Data"] as? String else {
                        throw LoginError.invalidResponse
                    }
                    
                    let decryptedData = AES256Encryption.decrypt(dataString)
                    
                    guard let responseDict = decryptedData as? [String: Any],
                          let resultArray = responseDict["Result"] as? [[String: Any]],
                          let firstResult = resultArray.first else {
                        throw LoginError.invalidResponse
                    }
                    
                    if let error = firstResult["Status"] as? String {
                        throw LoginError.apiError(error)
                    }
                    
                    // معالجة البيانات قبل التحويل
                    let processedResult = JSONSerialization.preprocessJsonData(firstResult)
                    let jsonData = try JSONSerialization.data(withJSONObject: processedResult)
                    
                    do {
                        let decoder = JSONDecoder()
                        let userResult = try decoder.decode(UserResult.self, from: jsonData)
                        
                        DispatchQueue.main.async {
                        if let email = userResult.email ,let id = userResult.id {
                        self.user_mail = email
                        self.user_id = id
                        }
                        }
                        return true
                    } catch {
                        if String(data: jsonData, encoding: .utf8) != nil {}
                        throw LoginError.decodingError(error)
                    }
                    
                }
            }
            
            return false
        }
}

