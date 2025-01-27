//
//  NavigationManager.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//

import SwiftUI

enum AppViews: Hashable {
    case FirstScreen
    case JobSelectionView
    case CareerInterestsView
    case LanguageSelectionView
    case LoginScreen
    case SignUp
    case ProfileEmployeeScreen(phone:String, email:String, name :String)
    case ProfileCompanyScreen
    case PricingPlanView
    case PaymentMethodView
    case CreditCardFormView(Icon: String,Card:String)
    case PaymentSuccessful
    case PaymentError
    case ForgotPassword
    case OTPVerificationView(email: String,TransToken:String, user_id:String,newPassword:String,IsGomeInProfile:Bool)
    case CongratsScreen
    case MainTabView
    case SettingsView
    case ChatUser
    case NewMessageView
    case ChatView(chatId: String,currentImage: String,recipientImage: String,
                  currentUserId: String,currentMail: String,recipientId: String,recipientMail: String)
}

class NavigationManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    func navigate(to view: AppViews) {
        navigationPath.append(view)
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}

