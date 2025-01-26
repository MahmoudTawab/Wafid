//
//  SignUp.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//


import SwiftUI

struct SignUp: View {
    @State private var phone = ""
    @State private var email = ""
    @State private var name = ""
    @State private var PhoneError: TextFieldError = .empty
    @State private var emailError: TextFieldError = .empty
    @State private var nameError: TextFieldError = .empty
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {


                VStack {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                        .padding(.bottom , 30)
                    
                    Text("Create an Account")
                        .font(Font.system(size: ControlWidth(20)).weight(.heavy))
                        .foregroundColor(.black)
                        .padding()
                        .padding(.bottom , 15)
                                        
                    TextFieldCustom(defaultText:.constant(""),title: "Full name", placeholder: "Enter your full name", isRequired: true, type: .text) { text, error in
                        name = text
                        nameError = error
                    }.padding(.bottom, 10)
                    
                    TextFieldCustom(defaultText:.constant(""),title: "E-mail", placeholder: "Enter your email", isRequired: true, type: .email) { text, error in
                        email = text
                        emailError = error
                    }.padding(.bottom, 10)
                    
                    TextFieldCustom(defaultText:.constant(""),title: "Phone", placeholder: "Enter your phone number", isRequired: true, type: .phone) { text, error in
                        phone = text
                        PhoneError = error
                    }.padding(.bottom, 10)
                    
                    Spacer()
      
                    Spacer()
                    
                    Button(action: {
                        validateLogin()
                        
                        if nameError == .none && emailError == .none && PhoneError == .none {
                            hideKeyboard()
                            navigationManager.navigate(to: .ProfileEmployeeScreen(phone: phone, email: email, name: name))
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: ControlWidth(16), weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(rgbToColor(red: 193, green: 140, blue: 70))
                            .cornerRadius(15)
                    }
                    .padding(.bottom,20)
                    .opacity(nameError == .none && emailError == .none && PhoneError == .none ? 1:0.6)
                    .disabled(nameError == .none && emailError == .none && PhoneError == .none ? false:true)
                    
                    HStack(spacing: 4) {
                        Text("You already have an account?")
                            .font(Font.system(size: ControlWidth(14)).weight(.regular))
                            .foregroundColor(rgbToColor(red: 163, green: 168, blue: 175))
                        
                        Text("Sign in")
                            .underline()
                            .font(Font.system(size: ControlWidth(14)).weight(.regular))
                            .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                    }
                    .padding(.bottom , 5)
                    .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
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
        
        .onTapGesture {
            hideKeyboard()
        }
        

    }
    
    // إخفاء لوحة المفاتيح
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    private func validateLogin() {
        // التحقق من البريد الإلكتروني
        if name.isEmpty {
            nameError = .empty
        } else {
            nameError = .none
        }
        
        if email.isEmpty {
            emailError = .empty
        } else if !isValidEmail(email) {
            emailError = .invalidEmail
        } else {
            emailError = .none
        }
        
        if phone.isEmpty {
            PhoneError = .empty
        } else {
            PhoneError = .none
        }
    }
}
