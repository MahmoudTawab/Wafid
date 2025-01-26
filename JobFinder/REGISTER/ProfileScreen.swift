//
//  ProfileScreen.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//

import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var viewModel: ProfileViewModel
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
                                
                                
                                Text("Upload Photo Profile")
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
                    
                    PickerViewCountry(selectedCountry: $viewModel.selectedCountry)
                        .padding(.vertical)
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Passport Number", placeholder: "Passport Number", isRequired: true, type: .passport) { text, error in
                        viewModel.Passport = text
                        viewModel.PassportError = error
                    }.padding(.bottom, 10)
                    
                    PassportPhotoView(selectedImage: $viewModel.PassportSelectedImage,Title: "Passport photo") {
                        IsPassport = true
                        withAnimation {showingBottomSheet = true}
                    }.padding(.vertical)
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Issuance Date", placeholder: "Issuance Date", isRequired: true, type: .date) { text, error in
                        viewModel.dateExpiry = text
                        viewModel.dateTextError = error
                    }.padding(.bottom, 10)
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Expiry Date", placeholder: "Expiry Date", isRequired: true, type: .date) { text, error in
                        viewModel.dateText = text
                        viewModel.ExpiryDateTextError = error
                    }.padding(.bottom, 10)
                    
                    PickerViewBloodType(selectedBloodType: $viewModel.selectedBloodType)
                        .padding(.vertical)
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Number of the nearest emergency boat", placeholder: "Number of the nearest emergency boat", isRequired: true, type: .phone) { text, error in
                        viewModel.NumberOfTheNearest = text
                        viewModel.NumberOfTheNearestError = error
                    }.padding(.bottom, 10)

                    
                    TextFieldCustom(defaultText:.constant(""),title: "Date of birth", placeholder: "Date of birth", isRequired: true, type: .date) { text, error in
                        viewModel.DateOfBirth = text
                        viewModel.DateOfBirthError = error
                    }.padding(.bottom, 10)
                    
                    //                    PickerViewGender()
                    //                        .padding(.vertical)
                    
                    TextFieldCustom(defaultText:.constant(""),IsShowImage:false,title: "Place of birth", placeholder: "Place of birth", isRequired: true, type: .text) { text, error in
                        viewModel.PlaceBirth = text
                        viewModel.PlaceBirthError = error
                    }.padding(.bottom, 10)

                    
                    TextFieldCustom(defaultText:.constant(""),IsShowImage:false,title: "Experience Years", placeholder: "Experience Years", isRequired: true, type: .text) { text, error in
                        viewModel.Experience = text
                        viewModel.ExperienceError = error
                    }.padding(.bottom, 10)

                    
                    TextFieldCustom(defaultText:.constant(""),IsShowImage:false,title: "Educational Qualification", placeholder: "Educational Qualification", isRequired: true, type: .text) { text, error in
                        viewModel.Educational = text
                        viewModel.EducationalError = error
                    }.padding(.bottom, 10)
                    
                    PassportPhotoView(selectedImage: $viewModel.EducationalSelectedImage,Title: "certificates or qualifications") {
                        IsPassport = false
                        withAnimation {showingBottomSheet = true}
                    }.padding(.vertical)
                                        
                    TextFieldCustom(defaultText:.constant(""),IsShowImage:false,title: "Occupation", placeholder: "Occupation", isRequired: true, type: .date) { text, error in
                        viewModel.Occupation = text
                        viewModel.OccupationError = error
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
                    
                    Button(action: {
                        FuncSignUp()
                    }) {
                        Text("Sign Up")
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
            
            NewBottomSheet(isOpen: $showingBottomSheet,IsShowIndicator: true, maxHeight: 250, minHeight: 0) {
                VStack() {
                    Text("Are You sure")
                        .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                        .foregroundColor(.black)
                        .padding(.vertical)
                    
                    HStack {
                        Text("You want to delete")
                            .font(Font.system(size: ControlWidth(16)))
                            .foregroundColor(.black)
                        
                        Text("Passport photo")
                            .font(Font.system(size: ControlWidth(16)))
                            .foregroundColor(rgbToColor(red: 218, green: 20, blue: 20))
                    }.padding(.vertical)
                    
                    Spacer()
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            withAnimation { showingBottomSheet = false }
                        }) {
                            Text("Cancel")
                                .font(.system(size: ControlWidth(16), weight: .bold))
                                .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(rgbToColor(red: 255, green: 255, blue: 255))
                                .cornerRadius(15)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 1)
                        )
                        
                        Button(action: {
                            if IsPassport {
                                viewModel.PassportSelectedImage = nil
                            }else{
                                viewModel.EducationalSelectedImage = nil
                            }
                            withAnimation { showingBottomSheet = false }
                        }) {
                            Text("Yes, Remove")
                                .font(.system(size: ControlWidth(16), weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(rgbToColor(red: 193, green: 140, blue: 70))
                                .cornerRadius(15)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 100)
                    .padding(.bottom,5)
                    
                }.padding(.horizontal).padding(.vertical).offset(y:-10)
                
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
    
    func FuncSignUp() {
         let isValid = viewModel.validateAllFields()
         
         if isValid {
             hideKeyboard()
             showLoadingIndicator = true // تفعيل المؤشر
             Task {
                 do {
                let success = try await viewModel.performSignUp()
                     
                DispatchQueue.main.async {
                showLoadingIndicator = false // إيقاف المؤشر
                if success {
                    navigationManager.navigate(to: .OTPVerificationView(email: viewModel.email, TransToken: "", user_id: viewModel.user_id, newPassword: viewModel.password, IsGomeInProfile: true))
                }
                }
                } catch {
                     DispatchQueue.main.async {
                         showLoadingIndicator = false // إيقاف المؤشر
                         alertMessage = error.localizedDescription
                         showingAlert = true
                     }
                 }
             }
         }
     }
}


// Add FileUploadData struct
struct FileUploadData {
    let actionType: String
    let mainId: Int
    let subId: Int
    let detailId: Int
    let fileType: String
    let fileId: String
    let description: String
    let name: String
    let dataToken: String
}


class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedImage: UIImage?
    @Published var PassportSelectedImage: UIImage?
    @Published var EducationalSelectedImage: UIImage?
    @Published var selectedCountry: String
    @Published var selectedBloodType: String
    
    @Published var Passport = ""
    @Published var dateText = ""
    @Published var dateExpiry = ""
    @Published var PlaceBirth = ""
    @Published var DateOfBirth = ""
    @Published var NumberOfTheNearest = ""
    @Published var Experience = ""
    @Published var Educational = ""
    @Published var Occupation = ""
    @Published var password = ""
    @Published var ConfirmNew = ""
    
    @Published var dateTextError: TextFieldError = .empty
    @Published var PassportError: TextFieldError = .empty
    @Published var ExpiryDateTextError: TextFieldError = .empty
    @Published var PlaceBirthError: TextFieldError = .empty
    @Published var DateOfBirthError: TextFieldError = .empty
    @Published var NumberOfTheNearestError: TextFieldError = .empty
    @Published var ExperienceError: TextFieldError = .empty
    @Published var EducationalError: TextFieldError = .empty
    @Published var OccupationError: TextFieldError = .empty
    @Published var passwordError: TextFieldError = .empty
    @Published var ConfirmpasswordError: TextFieldError = .empty
    
    var user_id: String = ""
    @AppStorage("user_mail") var user_mail: String = ""
    
    // MARK: - Properties
    var phone: String
    var email: String
    var name: String
    
    // Add new properties for image IDs
    private var profileImageId: String = ""
    private var passportImageId: String = ""
    private var educationalImageId: String = ""
    
    private let tableNames = ["ibVWvKYKYgVvqrBguXGjbw==", "/bxXtMQJKQ7HZcFnF7TcUg=="]
    
    // MARK: - Initialization
    init(phone: String, email: String, name: String) {
        self.phone = phone
        self.email = email
        self.name = name
        // ضع القيم الافتراضية هنا
        self.selectedCountry = "Libya"
        self.selectedBloodType = "O+"
    }
    
    // دالة لمسح كل البيانات
    func clearData() {
        selectedImage = nil
        selectedCountry = ""
        Passport = ""
        PassportError = .none
        PassportSelectedImage = nil
        dateExpiry = ""
        dateTextError = .none
        dateText = ""
        ExpiryDateTextError = .none
        selectedBloodType = ""
        NumberOfTheNearest = ""
        NumberOfTheNearestError = .none
        DateOfBirth = ""
        DateOfBirthError = .none
        PlaceBirth = ""
        PlaceBirthError = .none
        Experience = ""
        ExperienceError = .none
        Educational = ""
        EducationalError = .none
        EducationalSelectedImage = nil
        Occupation = ""
        OccupationError = .none
        password = ""
        passwordError = .none
        ConfirmNew = ""
        ConfirmpasswordError = .none
        email = ""
    }
    
    // MARK: - Validation Methods
    func validateAllFields() -> Bool {
//        selectedImage != nil &&

        let isImagesValid = PassportSelectedImage != nil &&
                           EducationalSelectedImage != nil
        
        let isFieldsValid = PassportError == .none &&
                           dateTextError == .none &&
                           ExpiryDateTextError == .none &&
                           DateOfBirthError == .none &&
                           NumberOfTheNearestError == .none &&
                           PlaceBirthError == .none &&
                           ExperienceError == .none &&
                           EducationalError == .none &&
                           OccupationError == .none &&
                           passwordError == .none &&
                           ConfirmpasswordError == .none
        
        return isFieldsValid && isImagesValid
    }
    

    
    // MARK: - API Methods
    // Update performSignUp to handle image uploads first
        func performSignUp() async throws -> Bool {
            // Upload images first and get their IDs
            if let profileImage = selectedImage {
                profileImageId = try await uploadImage(image: profileImage, type: "profile")
            }
            
            if let passportImage = PassportSelectedImage {
                passportImageId = try await uploadImage(image: passportImage, type: "passport")
            }
            
            if let educationalImage = EducationalSelectedImage {
                educationalImageId = try await uploadImage(image: educationalImage, type: "educational")
            }
            
            // Prepare user data with image IDs instead of base64
            let userData: [(String, Any)] = [
                ("id", "0"),
                ("fullName", name),
                ("email", email),
                ("password", password),
                ("phone", phone),
                ("role", "employee"),
                ("company_id", "0"),
                ("isValidate", "0"),
                ("active", "1"),
                ("method", "1"),
                ("read_date", "default"),
                ("nationality_name", selectedCountry),
                ("createdBy", "0"),
                ("updatedAt", "default"),
                ("updatedBy", "0"),
                ("personal_num",Passport),
                ("personal_attach", passportImageId), // Use image ID instead of base64
                ("status", "1"),
                ("Legal_status", "")
            ]
            
            // Prepare employee data with image IDs
            let employeeData: [(String, Any)] = [
                ("id", "0"),
                ("userss_id", "0"),
                ("birth_date",DateOfBirth),
                ("occupation",Occupation),
                ("country", selectedCountry),
                ("national_id", Passport),
                ("national_id_attach", educationalImageId), // Use image ID
                ("read_date", "default"),
                ("release_date", dateExpiry),
                ("expiry_date", dateText),
                ("blood_type", selectedBloodType),
                ("relatives_number", NumberOfTheNearest),
                ("birth_place", PlaceBirth),
                ("qualification", Educational),
                ("createdBy", "0"),
                ("updatedAt", "default"),
                ("updatedBy", "0"),
                ("profile_attach", profileImageId) // Use image ID
            ]
            
            let multiData = [userData, employeeData]
            
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

enum ProfileError: LocalizedError {
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return message
        }
    }
}
