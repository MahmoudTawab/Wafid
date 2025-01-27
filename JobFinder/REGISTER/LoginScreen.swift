//
//  LoginScreen.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//

import SwiftUI
import FirebaseStorage

struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showLoadingIndicator = false
    @AppStorage("user_id") var user_id: String = ""
    @AppStorage("user_mail") var user_mail: String = ""

    @StateObject private var viewModel = LoginViewModel()
    @State private var emailError: TextFieldError = .empty
    @State private var passwordError: TextFieldError = .empty
    @EnvironmentObject var navigationManager: NavigationManager

    @AppStorage("IsEmployee") var IsEmployee: Bool = false
    @AppStorage("rememberMe") private var selectedRemember = false
    @AppStorage("userCredentials") private var savedCredentials: Data?
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                
                VStack {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                        .padding(.bottom , 30)
                    
                    Text("Sign in to your account")
                        .font(Font.system(size: ControlWidth(20)).weight(.heavy))
                        .foregroundColor(.black)
                        .padding()
                        .padding(.bottom , 15)
                                        
                    TextFieldCustom(defaultText:.constant(""),title: "E-mail", placeholder: "Enter your email", isRequired: true, type: .email) { text, error in
                        email = text
                        emailError = error
                    }.padding(.bottom, 10)
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Password", placeholder: "Enter password", isRequired: true, type: .password) { text, error in
                        password = text
                        passwordError = error
                    }.padding(.bottom, 10)
                    
                    HStack(spacing: 4) {
                        Image(selectedRemember ?  "selectedRemember" : "Remember")
                            .frame(width: 30, height: 30)
                            .foregroundColor(selectedRemember ? .black:rgbToColor(red: 193, green: 140, blue: 70))
                        
                        Text("Remember me")
                            .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                            .font(.body)
                        
                        Spacer()
                    }.padding(.bottom , 10)
                        .onTapGesture {
                            withAnimation {
                                if email != "" && password != "" {selectedRemember.toggle()}
                                if !selectedRemember {
                                    // مسح البيانات المحفوظة عند إلغاء التحديد
                                    savedCredentials = nil
                                }
                            }
                        }
                    
                    Button(action: {
                        FuncLogin()
                    }) {
                        Text("Login")
                            .font(.system(size: ControlWidth(16), weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(rgbToColor(red: 193, green: 140, blue: 70))
                            .cornerRadius(15)
                    }
                    .opacity(emailError == .none && passwordError == .none ? 1:0.6)
                    .disabled(emailError == .none && passwordError == .none ? false:true)
                    
                    
                    Text("Forgot the password?")
                        .font(Font.system(size: ControlWidth(16)))
                        .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                        .padding()
                        .onTapGesture {
                            navigationManager.navigate(to: .ForgotPassword)
                        }
                    
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Don’t have an account?")
                            .font(Font.system(size: ControlWidth(14)).weight(.regular))
                            .foregroundColor(rgbToColor(red: 163, green: 168, blue: 175))
                        
                        Text("Sign up")
                            .underline()
                            .font(Font.system(size: ControlWidth(14)).weight(.regular))
                            .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                    }
                    .padding(.bottom , 5)
                    .onTapGesture {
                        if IsEmployee {
                            navigationManager.navigate(to: .SignUp)
                        }else{
                            navigationManager.navigate(to: .ProfileCompanyScreen)
                        }
                    }
                    
                }
                .padding(.top , 50)
                .frame(height: UIScreen.main.bounds.height - 50)
            }
            .padding()
            .keyboardSpace()
            .edgesIgnoringSafeArea(.all)
            .preferredColorScheme(.light)
            .background(rgbToColor(red: 255, green: 255, blue: 255))
            .frame(width: UIScreen.main.bounds.width)
            
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
            
            AnimatedToastMessage(showingErrorMessageisValid: $showingAlert, MassegeContent: $alertMessage, TypeToast : .error, FrameHeight: .constant(65))
            .padding(.top ,-50)
        }
        .onTapGesture {
            hideKeyboard()
        }
        
        .onAppear {
            loadSavedCredentials()
        }
    }
    
    // 2. دالة لحفظ بيانات المستخدم
    private func saveUserCredentials() {
        let credentials = UserCredentials(email: email, password: password)
        if let encoded = try? JSONEncoder().encode(credentials) {
            savedCredentials = encoded
        }
    }
    
    // 3. دالة لاسترجاع بيانات المستخدم المحفوظة
    private func loadSavedCredentials() {
        if selectedRemember,
           let savedData = savedCredentials,
           let credentials = try? JSONDecoder().decode(UserCredentials.self, from: savedData) {
            email = credentials.email
            password = credentials.password
        }
    }
    
    // إخفاء لوحة المفاتيح
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    private func validateLogin() {
        // التحقق من البريد الإلكتروني
        if email.isEmpty {
            emailError = .empty
        } else if !isValidEmail(email) {
            emailError = .invalidEmail
        } else {
            emailError = .none
        }
        
        // التحقق من كلمة المرور
        if password.isEmpty {
            passwordError = .empty
        } else if password.count < 6 {
            passwordError = .invalidPassword
        } else {
            passwordError = .none
        }
    }
    
    func FuncLogin() {
        validateLogin()

        if emailError == .none && passwordError == .none {
            if selectedRemember { saveUserCredentials() }
            showLoadingIndicator = true
            hideKeyboard()
            
              // Perform login
              Task {
                  do {
                      let success = try await viewModel.login(
                          email: email,
                          password: password,
                          serial_no: UIDevice.current.identifierForVendor?.uuidString ?? ""
                      )
                                        
                      if success && viewModel.userResult?.isValidate == true {
                          DispatchQueue.main.async {
                              if let id = viewModel.userResult?.id ,let email = viewModel.userResult?.email ,let role = viewModel.userResult?.role {
                                  user_id = id
                                  user_mail = email
                                  IsEmployee = role == "employee" ? true:false
                                  navigationManager.navigate(to: .MainTabView)
                              }
                          }
                      }else if success && viewModel.userResult?.isValidate == false {
                          DispatchQueue.main.async {
                            showLoadingIndicator = false
                              navigationManager.navigate(to: .OTPVerificationView(email: email, TransToken: "", user_id: "", newPassword: password, IsGomeInProfile: true))
                          }
                      }
                  } catch {
                      DispatchQueue.main.async {
                          showLoadingIndicator = false
                          alertMessage = error.localizedDescription
                          showingAlert = true
                      }
                  }
              }
          }
    }
    
}


// 1. نموذج لتخزين بيانات المستخدم
struct UserCredentials: Codable {
    var email: String
    var password: String
}

// 2. نموذج لتخزين بيانات الـ Result
struct UserResult: Codable {
    var personal_attach: String?
    var phone: String?
    var Subscribed: String?
    var id: String?
    var role: String?
    var nationality_name: String?
    var personal_attach_id: String?
    var emp_id: String?
    var personal_num: String?
    var email: String?
    var company_id: String?
    var fullName: String?
    var isValidate: Bool?
    

    
    enum CodingKeys: String, CodingKey {
        case personal_attach
        case phone
        case Subscribed
        case id
        case role
        case nationality_name
        case personal_attach_id
        case emp_id
        case personal_num
        case email
        case company_id
        case fullName
        case isValidate
    }
    
    init(personal_attach: String? = "", phone: String? = "", Subscribed: String? = "", id: String? = "", role: String? = "", nationality_name: String? = "", personal_attach_id: String? = "", emp_id: String? = "", personal_num: String? = "", email: String? = "", company_id: String? = "", fullName: String? = "", isValidate: Bool? = true) {
        self.personal_attach = personal_attach
        self.phone = phone
        self.Subscribed = Subscribed
        self.id = id
        self.role = role
        self.nationality_name = nationality_name
        self.personal_attach_id = personal_attach_id
        self.emp_id = emp_id
        self.personal_num = personal_num
        self.email = email
        self.company_id = company_id
        self.fullName = fullName
        self.isValidate = isValidate
    }
}


class LoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userResult: UserResult?
    
    func login(email: String, password: String, serial_no: String, firebase_Token: String = "1", firebase_Deviceid: String = "1") async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        let orderedParameters: [(String, Any)] = [
            ("Email", email),
            ("Pass", password),
            ("Encrypt", "$????"),
            ("serial_no", serial_no),
            ("firebase_Token", firebase_Token),
            ("firebase_Deviceid", firebase_Deviceid)
        ]
        
        let parameters = Dictionary(uniqueKeysWithValues: orderedParameters)
        
        do {
            let result = try await makeRequestGet(
                ProcedureName: "7lgMl3DLGpYu7xln2ZexiA==",
                ApiToken: ApiToken,
                dateToken: dateToken,
                parametersValues: parameters,
                orderedKeys: orderedParameters
            )
            
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
                    self.userResult = userResult
                }
                return true
            } catch {
                if String(data: jsonData, encoding: .utf8) != nil {}
                throw LoginError.decodingError(error)
            }
        } catch {
            throw error
        }
    }
}

enum LoginError: LocalizedError {
    case invalidResponse
    case apiError(String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return message
        case .decodingError(let error):
            return "Failed to process response: \(error.localizedDescription)"
        }
    }
}
