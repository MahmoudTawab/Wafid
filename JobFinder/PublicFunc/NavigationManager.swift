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
    case ProfileEmployeeScreen(phone: String, email: String, name: String)
    case UserDetailsView(user: UserInfo)
    case ProfileCompanyScreen
    case PricingPlanView
    case PaymentMethodView
    case CreditCardFormView(Icon: String, Card: String)
    case PaymentSuccessful
    case PaymentError
    case ForgotPassword
    case OTPVerificationView(email: String, TransToken: String, user_id: String, newPassword: String, IsGomeInProfile: Bool)
    case CongratsScreen
    case MainTabView
    case JobRecommendationView(jobs_id: String)
    case SettingsView
    case ChatUser
    case NewMessageView
    case ChatView(chatId: String, currentImage: String, recipientImage: String,
                  currentUserId: String, currentMail: String, recipientId: String, recipientMail: String)

    static func == (lhs: AppViews, rhs: AppViews) -> Bool {
        switch (lhs, rhs) {
        case (.FirstScreen, .FirstScreen),
             (.JobSelectionView, .JobSelectionView),
             (.CareerInterestsView, .CareerInterestsView),
             (.LanguageSelectionView, .LanguageSelectionView),
             (.LoginScreen, .LoginScreen),
             (.SignUp, .SignUp),
             (.ProfileCompanyScreen, .ProfileCompanyScreen),
             (.PricingPlanView, .PricingPlanView),
             (.PaymentMethodView, .PaymentMethodView),
             (.PaymentSuccessful, .PaymentSuccessful),
             (.PaymentError, .PaymentError),
             (.ForgotPassword, .ForgotPassword),
             (.CongratsScreen, .CongratsScreen),
             (.MainTabView, .MainTabView),
             (.SettingsView, .SettingsView),
             (.ChatUser, .ChatUser),
             (.NewMessageView, .NewMessageView):
            return true

        case let (.ProfileEmployeeScreen(phone1, email1, name1), .ProfileEmployeeScreen(phone2, email2, name2)):
            return phone1 == phone2 && email1 == email2 && name1 == name2

        case let (.UserDetailsView(user1), .UserDetailsView(user2)):
            return user1.id == user2.id  // مقارنة عبر `id` فقط

        case let (.CreditCardFormView(Icon1, Card1), .CreditCardFormView(Icon2, Card2)):
            return Icon1 == Icon2 && Card1 == Card2

        case let (.OTPVerificationView(email1, token1, user1, pass1, profile1),
                  .OTPVerificationView(email2, token2, user2, pass2, profile2)):
            return email1 == email2 && token1 == token2 && user1 == user2 && pass1 == pass2 && profile1 == profile2

        case let (.JobRecommendationView(jobsID1), .JobRecommendationView(jobsID2)):
            return jobsID1 == jobsID2

        case let (.ChatView(id1, img1, rimg1, uid1, mail1, rid1, rmail1),
                  .ChatView(id2, img2, rimg2, uid2, mail2, rid2, rmail2)):
            return id1 == id2 && img1 == img2 && rimg1 == rimg2 &&
                   uid1 == uid2 && mail1 == mail2 && rid1 == rid2 && rmail1 == rmail2

        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .FirstScreen:
            hasher.combine("FirstScreen")
        case .JobSelectionView:
            hasher.combine("JobSelectionView")
        case .CareerInterestsView:
            hasher.combine("CareerInterestsView")
        case .LanguageSelectionView:
            hasher.combine("LanguageSelectionView")
        case .LoginScreen:
            hasher.combine("LoginScreen")
        case .SignUp:
            hasher.combine("SignUp")
        case .ProfileCompanyScreen:
            hasher.combine("ProfileCompanyScreen")
        case .PricingPlanView:
            hasher.combine("PricingPlanView")
        case .PaymentMethodView:
            hasher.combine("PaymentMethodView")
        case .PaymentSuccessful:
            hasher.combine("PaymentSuccessful")
        case .PaymentError:
            hasher.combine("PaymentError")
        case .ForgotPassword:
            hasher.combine("ForgotPassword")
        case .CongratsScreen:
            hasher.combine("CongratsScreen")
        case .MainTabView:
            hasher.combine("MainTabView")
        case .SettingsView:
            hasher.combine("SettingsView")
        case .ChatUser:
            hasher.combine("ChatUser")
        case .NewMessageView:
            hasher.combine("NewMessageView")
        case let .ProfileEmployeeScreen(phone, email, name):
            hasher.combine("ProfileEmployeeScreen")
            hasher.combine(phone)
            hasher.combine(email)
            hasher.combine(name)
        case let .UserDetailsView(user):
            hasher.combine("UserDetailsView")
            hasher.combine(user.id)
        case let .CreditCardFormView(Icon, Card):
            hasher.combine("CreditCardFormView")
            hasher.combine(Icon)
            hasher.combine(Card)
        case let .OTPVerificationView(email, token, user, pass, profile):
            hasher.combine("OTPVerificationView")
            hasher.combine(email)
            hasher.combine(token)
            hasher.combine(user)
            hasher.combine(pass)
            hasher.combine(profile)
        case let .JobRecommendationView(jobsID):
            hasher.combine("JobRecommendationView")
            hasher.combine(jobsID)
        case let .ChatView(chatId, currentImage, recipientImage, currentUserId, currentMail, recipientId, recipientMail):
            hasher.combine("ChatView")
            hasher.combine(chatId)
            hasher.combine(currentImage)
            hasher.combine(recipientImage)
            hasher.combine(currentUserId)
            hasher.combine(currentMail)
            hasher.combine(recipientId)
            hasher.combine(recipientMail)
        }
    }
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

