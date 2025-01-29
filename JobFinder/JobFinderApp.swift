//
//  JobFinderApp.swift
//  JobFinder
//
//  Created by almedadsoft on 12/01/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseMessaging

import StreamVideo
import StreamVideoSwiftUI

class AppDelegate: NSObject, UIApplicationDelegate ,UNUserNotificationCenterDelegate , MessagingDelegate {
    
    @AppStorage("user_id") var user_id: String = ""
    @AppStorage("IsEmployee") var IsEmployee: Bool = true
    @AppStorage("company_id") var company_id: String = ""
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        // إعداد إشعارات Push
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // التعامل مع إشعارات المكالمات
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                              didReceive response: UNNotificationResponse,
//                              withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        
//        if let callId = userInfo["callId"] as? String,
//           let callerId = userInfo["callerId"] as? String,
//           let type = userInfo["type"] as? String {
//            
//            // معالجة المكالمة الواردة
//            let callData = CallManager.CallData(
//                id: callId,
//                callId: callId,
//                callerId: callerId,
//                receiverId: IsEmployee ? user_id : company_id,
//                type: type,
//                status: "pending",
//                timestamp: Date(),
//                callerName: userInfo["callerName"] as? String ?? ""
//            )
//            
//            CallManager.shared.incomingCall = callData
//        }
//        
//        completionHandler()
//    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
}

@main
struct JobFinderApp: App {
    @StateObject private var callManager = CallManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
 
                MainApp()
                
                // عرض المكالمة الواردة إذا وجدت
                 if let incomingCall = callManager.incomingCall {
                     if !callManager.isCallActive {
                         IncomingCallView(call: incomingCall)
                     }
                 }
                 
                 // عرض المكالمة الصادرة إذا وجدت
                 if let outgoingCall = callManager.outgoingCall {
                     if !callManager.isCallActive {
                         OutgoingCallView(call: outgoingCall)
                     }
                 }
                
                
                if callManager.isCallActive {
                    VideoCallApp(name: callManager.outgoingCall?.callerName ?? "Mahmoud")
                }
                
            }
        }
        
    }
}
        



            

