//
//  ForgotPassword.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//

import SwiftUI

struct ForgotPassword: View {
    @State private var email = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showLoadingIndicator = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @State private var emailError: TextFieldError = .empty
    @State private var passwordError: TextFieldError = .empty
    @State private var confirmPasswordError: TextFieldError = .empty
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack(spacing: 10) {
                        Image("Icon")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                        
                        Text("Forgot Password")
                            .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    Text("If you need help resetting your password We can help by sending you a link to reset it.")
                        .font(Font.system(size: ControlWidth(13)).weight(.regular))
                        .foregroundColor(rgbToColor(red: 163, green: 168, blue: 175))
                        .padding(.vertical,10)
                    
                    TextFieldCustom(defaultText:.constant(""),title: "E-mail", placeholder: "Enter your email", isRequired: true, type: .email) { text, error in
                        email = text
                        emailError = error
                    }.padding(.bottom, 10)
                    
                    TextFieldCustom(defaultText:.constant(""),title: "New Password", placeholder: "Enter new password", isRequired: true, type: .password) { text, error in
                        newPassword = text
                        passwordError = error
                    }.padding(.bottom, 10)
                    
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Confirm Password", placeholder: "Confirm new password", isRequired: true, type: .Confirminvalid,
                                    passwordToMatch: newPassword) { text, error in
                        confirmPassword = text
                        confirmPasswordError = error
                    }.padding(.bottom, 40)
                    
                    Button(action: {
                        resetPassword()
                    }) {
                        Text("Reset Password")
                            .font(.system(size: ControlWidth(16), weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(rgbToColor(red: 193, green: 140, blue: 70))
                            .cornerRadius(15)
                    }
                    .opacity(isFormValid ? 1 : 0.6)
                    .disabled(!isFormValid)
                    
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
        
        .onTapGesture {
            hideKeyboard()
        }
    
    }
    
    private var isFormValid: Bool {
        emailError == .none &&
        passwordError == .none &&
        confirmPasswordError == .none &&
        !email.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    private func validateForm() {
        if email.isEmpty {
            emailError = .empty
        } else if !isValidEmail(email) {
            emailError = .invalidEmail
        } else {
            emailError = .none
        }
        
        if newPassword.isEmpty {
            passwordError = .empty
        } else if newPassword.count < 6 {
            passwordError = .invalidPassword
        } else {
            passwordError = .none
        }
        
        if confirmPassword.isEmpty {
            confirmPasswordError = .empty
        } else if confirmPassword != newPassword {
            confirmPasswordError = .ConfirminvalidPassword
        } else {
            confirmPasswordError = .none
        }
    }
}



// MARK: - ForgotPassword View Extension
extension ForgotPassword {
    func resetPassword() {
        // Validate form first
        validateForm()
        
//      Check if form is valid
        guard isFormValid else {
            alertMessage = "Please correct the errors in the form"
            showingAlert = true
            return
        }
        
        // Show loading indicator
        showLoadingIndicator = true
        hideKeyboard()
        
        // Start the reset password process
        Task {
            do {
                // First step: Send reset request
                let requestSent = await viewModel.sendResetRequest(
                    IsReset:"1",
                    email: email,
                    password: newPassword
                )
                
                await MainActor.run {
                    if requestSent.success {
                        navigationManager.navigate(to: .OTPVerificationView(email: email, TransToken: requestSent.transToken ?? "", user_id: "", newPassword: newPassword, IsGomeInProfile: false))
                    } else {
                        alertMessage = viewModel.errorMessage
                        showingAlert = true
                    }
                    showLoadingIndicator = false
                }
            }
        }
    }
}

// MARK: - Response Models
struct AuthenticationResponse: Codable {
    let Result: String
    let Error: String?
    let Data: String?
    let TransToken: String?
}

struct AuthenticationError: Error {
    let message: String
}

class AuthenticationService {
    static let shared = AuthenticationService()
    private let baseURL = "https://framework.md-license.com:8093/emsserver.dll/ERPDatabaseWorkFunctions"
    
    // MARK: - RequireAuthentication
    func requireAuthentication(
        functionName: String,
        procedureName: String,
        parametersValue: String,
        authType: String,
        sendTo: String,
        dataToken: String,
        apiToken: String
    ) async throws -> (status: String, transToken: String?, error: String?) {
        let url = URL(string: "\(baseURL)/RequireAuthentication")!

        // Prepare the inner data dictionary
        let innerData: [String: Any] = [
            "FunctionName": functionName,
            "ProcedureName": procedureName,
            "ParametersValue": parametersValue,
            "AuthType": authType,
            "SendTo": sendTo,
            "DataToken": dataToken
        ]
        
        // Encrypt the inner data
        let encryptedData = AES256Encryption.encrypt(innerData)
        
        // Prepare the request body
        let requestData: [String: Any] = [
            "ApiToken": apiToken,
            "Data": encryptedData
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
                
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
        
  
        // Decrypt the response
        let status = AES256Encryption.decrypt(response.Result) as? String ?? ""
        let error = response.Error != nil ? AES256Encryption.decrypt(response.Error!) as? String : nil
        
        return (status: status, transToken: response.TransToken, error: error)
    }
    
    // MARK: - ExecuteAuthentication
    func executeAuthentication(
        transToken: String,
        verCode: String,
        dataToken: String,
        apiToken: String
    ) async throws -> (status: String, data: Any?, error: String?) {
        let url = URL(string: "\(baseURL)/ExecuteAuthentication")!
        
        // Prepare the inner data dictionary
        let innerData: [String: Any] = [
            "TransToken": transToken,
            "VerCode": verCode,
            "DataToken": dataToken
        ]
        
        // Encrypt the inner data
        let encryptedData = AES256Encryption.encrypt(innerData)
        
        // Prepare the request body
        let requestData: [String: Any] = [
            "ApiToken": apiToken,
            "Data": encryptedData
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
        
        print("requestData :\(response)")

        // Decrypt the response
        let status = AES256Encryption.decrypt(response.Result) as? String ?? ""
        let responseData = response.Data != nil ? AES256Encryption.decrypt(response.Data!) : nil
        let error = response.Error != nil ? AES256Encryption.decrypt(response.Error!) as? String : nil
        
        return (status: status, data: responseData, error: error)
    }
}

class ForgotPasswordViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    private let authService = AuthenticationService.shared
    
    func sendResetRequest(IsReset: String,email: String, password: String) async -> (transToken: String?, success: Bool) {
        
        do {
            // First step: RequireAuthentication
            let requireResult = try await authService.requireAuthentication(
                functionName: "8d8VWC1xFIjp4ztA3Mny/g==", // Replace with your actual encrypted function name
                procedureName: "+DQV2pYTqILS8W/zi6PtNA==", // Replace with your actual encrypted procedure name
                parametersValue: "\(IsReset)#\(email)#\(password)#$????", // Parameters separated by #
                authType: "Email",
                sendTo: email,
                dataToken: dateToken, // Replace with your actual data token
                apiToken: ApiToken // Replace with your actual API token
            )
            
            if requireResult.status == "200" {
                return (requireResult.transToken, true)
            } else {
                self.errorMessage = requireResult.error ?? "Failed to send verification code"
                return (nil, false)
            }
        } catch {
            self.errorMessage = error.localizedDescription
            return (nil, false)
        }
    }
    
    func verifyAndResetPassword(transToken: String, otp: String) async -> Bool {
        do {
            let executeResult = try await authService.executeAuthentication(
                transToken: transToken,
                verCode: otp,
                dataToken: dateToken, // Replace with your actual data token
                apiToken: ApiToken // Replace with your actual API token
            )
            
                        
            if executeResult.status == "200" {
                return true
            } else {
                self.errorMessage = executeResult.error ?? "Failed to verify code"
                return false
            }
        } catch {
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}

