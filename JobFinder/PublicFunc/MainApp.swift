//
//  MainApp.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//

import SwiftUI

struct MainApp: View {
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            StartScreen()
                .environmentObject(navigationManager)
                .environmentObject(localizationManager)
                .navigationDestination(for: AppViews.self) { view in
                    switch view {
                    case .FirstScreen:
                        FirstScreen()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .LanguageSelectionView:
                        LanguageSelectionView()
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .LoginScreen:
                        LoginScreen()
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .SignUp:
                        SignUp()
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager

                    case .ProfileEmployeeScreen(let phone, let email,let name):
                        ProfileEmployeeScreen(viewModel: ProfileEmployeeViewModel(phone: phone, email: email, name: name))
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .ProfileCompanyScreen:
                        ProfileCompanyScreen()
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager)
                        
                    case .PricingPlanView:
                        PricingPlanView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .PaymentMethodView:
                        PaymentMethodView()
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .CreditCardFormView(let cardIcon, let card):
                        CreditCardFormView(cardIcon: cardIcon, CardName: card)
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .PaymentSuccessful:
                        PaymentSuccessful()
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .PaymentError:
                        PaymentError()
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .ForgotPassword:
                        ForgotPassword()
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .OTPVerificationView(let email,let TransToken,let user_id , let newPassword,let IsGomeInProfile):
                        OTPVerificationView(TransToken:TransToken,newPassword:newPassword,UserId:user_id,IsGomeInProfile: IsGomeInProfile, email: email)
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .CongratsScreen:
                        CongratsScreen()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .MainTabView:
                        MainTabView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .SettingsView:
                        SettingsView()
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .ChatUser:
                        ChatUser()
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager
                        
                    case .NewMessageView:
                        NewMessageView()
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager) // تمرير localizationManager

                    case .ChatView(let chatId,let currentImage,let recipientImage,let currentUserId,let currentMail,let recipientId,let recipientMail):
                        ChatView(chatId: chatId,currentUserId: currentUserId, recipientId: recipientId, currentImage:currentImage, recipientImage:recipientImage, currentMail: currentMail, recipientMail: recipientMail)
                            .addKeyboardToolbar() // إضافة شريط لوحة المفاتيح هنا
                            .navigationBarTitle("", displayMode: .inline)
                            .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
                            .environmentObject(localizationManager)
                    }
                }
        }
        .tint(.clear)
        .toolbarBackground(.clear, for: .navigationBar) // جعل شريط التنقل شفافًا
        .environmentObject(navigationManager)
        .environmentObject(localizationManager) // تمرير localizationManager هنا أيضًا
    }
}
