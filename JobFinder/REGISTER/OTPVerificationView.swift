//
//  OTPVerificationView.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//


import SwiftUI
import FirebaseStorage

struct OTPVerificationView: View {
    @State var TransToken = ""
    @State var newPassword = ""
    @State var UserId: String = ""
    @State var IsGomeInProfile = false
    @State var UserImage: UIImage?
    @State private var remainingTime: Int = 120
    @State var email = "Ahmed*****@example.com"
    @State private var timer: Timer?
    @FocusState private var focusedField: Int?
    @Environment(\.presentationMode) var presentationMode
    @State private var isError = false
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showResendButton = false
    @State private var showLoadingIndicator: Bool = false
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @State private var otpCode: [String] = Array(repeating: "", count: 6)
    @EnvironmentObject var navigationManager: NavigationManager
    @AppStorage("user_id") var user_id: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Back button and title
                    HStack(spacing: 10) {
                        Image("Icon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture { self.presentationMode.wrappedValue.dismiss() }
                        
                        Text("Forgot Password")
                            .font(.system(size: ControlWidth(18), weight: .heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    // Email info text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Please enter the 4-digit code sent to you on E-mail")
                            .font(.system(size: ControlWidth(13), weight: .regular))
                            .foregroundColor(rgbToColor(red: 163, green: 168, blue: 175))
                        Text(email)
                            .font(.system(size: ControlWidth(13), weight: .regular))
                            .foregroundColor(rgbToColor(red: 163, green: 168, blue: 175))
                    }.padding(.vertical, 10)
                    
                    Spacer()
                    
                    // OTP input fields container with fixed height
                    VStack(spacing: 10) {
                        HStack(spacing: 15) {
                            ForEach(0..<6, id: \.self) { index in
                                TextField("", text: $otpCode[index])
                                    .frame(width: (UIScreen.main.bounds.width / 5) - 33, height: (UIScreen.main.bounds.width / 5) - 33)
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad)
                                    .tint(rgbToColor(red: 193, green: 140, blue: 70))
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(isError ? rgbToColor(red: 207, green: 45, blue: 72) : rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 2)
                                            .shadow(color: Color.black.opacity(0.5), radius: 15, x: 3, y: 4)
                                    )
                                    .focused($focusedField, equals: index)
                                    .onChange(of: otpCode[index]) { newValue in
                                        handleOTPInput(index: index, newValue: newValue)
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        if isError {
                            HStack {
                                Image("Alert-circle")
                                    .resizable()
                                    .frame(width: 15,height: 15)
                                Text("Invalid OTP code")
                                    .foregroundColor(rgbToColor(red: 207, green: 45, blue: 72))
                                    .font(.system(size: ControlWidth(12)))
                                    .padding(.top, 5)
                                Spacer()
                            }.padding(.horizontal, 15)
                        }
                    }
                    .frame(height: 100)  // Fixed height for OTP container
                    
                    // Timer/Resend button
                    HStack {
                        Spacer()
                        if showResendButton {
                            Button(action: {
                                resendCode()
                            }) {
                                Text("Resend Code")
                                    .font(.system(size: ControlWidth(14)))
                                    .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                            }
                        } else {
                            HStack(spacing: 2) {
                                Text("Resend code in")
                                    .font(.system(size: ControlWidth(14)))
                                    .foregroundColor(.black)
                                Text("\(remainingTime / 60):\(String(format: "%02d", remainingTime % 60))") // عرض الوقت كـ "دقائق:ثواني"
                                    .font(.system(size: ControlWidth(14)))
                                    .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    
                    Spacer()
                    
                    // Verify button
                    Button(action: {
                        verifyOTP()
                    }) {
                        Text("Verify")
                            .font(.system(size: ControlWidth(16), weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(rgbToColor(red: 193, green: 140, blue: 70))
                            .cornerRadius(15)
                    }
                }
                .padding(.top, 60)
                .frame(height: UIScreen.main.bounds.height - 60)
            }
            .padding()
            .keyboardSpace()
            .preferredColorScheme(.light)
            .edgesIgnoringSafeArea(.all)
            .background(rgbToColor(red: 255, green: 255, blue: 255))
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
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
        .onAppear {
            startTimer()
            if IsGomeInProfile {resetPassword()}
        }
        
    }
    
    // إخفاء لوحة المفاتيح
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    // Handle OTP input
    private func handleOTPInput(index: Int, newValue: String) {
        if newValue.count > 1 {
            otpCode[index] = String(newValue.prefix(1))
        }
        if !newValue.isEmpty && index < 5 {
            focusedField = index + 1
        }
        // Handle backspace
        if newValue.isEmpty && index > 0 {
            focusedField = index - 1
        }
        isError = false
    }
    
    private func startTimer() {
        showResendButton = false
        remainingTime = 120 // تغيير القيمة إلى 120 ثانية (دقيقتين)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
                showResendButton = true
            }
        }
    }
    
    private func resendCode() {
        startTimer()
        resetPassword()
    }
    
    private func verifyOTP() {
        let enteredOTP = otpCode.joined()
        Task {
            do {
                if enteredOTP.count == 6 {
                    showLoadingIndicator = true
                    let verified = await viewModel.verifyAndResetPassword(transToken: TransToken, otp: enteredOTP)
                    
                    await MainActor.run {
                        if verified {
                            isError = false
                            showingAlert = false
                            showLoadingIndicator = false

                            if IsGomeInProfile {
                            user_id = UserId
                            navigationManager.navigate(to: .PricingPlanView)
//                            CreateAccount()
                            }else{
                            setupRootView()
                            }
                        } else {
                            showLoadingIndicator = false
                            alertMessage = viewModel.errorMessage
                            showingAlert = true
                            isError = true
                        }
                    }
                }
            }
        }
    }
    
    private func setupRootView() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let mainApp = MainApp()
            window.rootViewController = UIHostingController(rootView: mainApp)
            window.makeKeyAndVisible()
            
            UIView.transition(with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: nil,
                            completion: nil)
        }
    }
    
}

// MARK: - ForgotPassword View Extension
extension OTPVerificationView {
    func resetPassword() {
        // Show loading indicator
        showLoadingIndicator = true
        
        // Start the reset password process
        Task {
            do {
                // First step: Send reset request
                let requestSent = await viewModel.sendResetRequest(
                    IsReset: "0",
                    email: email,
                    password: newPassword
                )
                
                await MainActor.run {
                    if requestSent.success {
                        self.TransToken = requestSent.transToken ?? ""
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
