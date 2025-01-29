//
//  OnlineStatusService.swift
//  Wafid
//
//  Created by almedadsoft on 26/01/2025.
//

import SwiftUI
import Combine
import Firebase
import FirebaseAuth


// OnlineStatusService.swift
class OnlineStatusService {
    private var db = Firestore.firestore()
    private var statusRef: DocumentReference?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var userId: String?
    
    func setupPresence(userId: String) {
        if userId != "" {
            guard statusRef == nil else { return }
            self.userId = userId
            statusRef = db.collection("user_status").document(userId)
            
            // التحقق من وجود الوثيقة أولاً
            statusRef?.getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("Error checking document: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot, !snapshot.exists {
                    // إنشاء الوثيقة إذا لم تكن موجودة
                    self?.createInitialUserStatus(userId: userId) { success in
                        if success {
                            // بعد إنشاء الوثيقة بنجاح، قم بتحديث الحالة
                            self?.updateOnlineStatus(isOnline: true, updateLastSeen: false)
                            self?.setupNotifications()
                        }
                    }
                } else {
                    // الوثيقة موجودة بالفعل، قم بتحديث الحالة مباشرة
                    self?.updateOnlineStatus(isOnline: true, updateLastSeen: false)
                    self?.setupNotifications()
                }
            }
        }
    }
    
    private func createInitialUserStatus(userId: String, completion: @escaping (Bool) -> Void) {
        let initialData: [String: Any] = [
            "user_id": userId,
            "is_online": true,
            "last_seen": Timestamp(date: Date())
        ]
        
        statusRef?.setData(initialData) { error in
            if let error = error {
                print("Error creating user status document: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User status document created successfully")
                completion(true)
            }
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        updateOnlineStatus(isOnline: true, updateLastSeen: false)
    }
    
    @objc private func appWillResignActive() {
        handleAppBackground()
    }
    
    @objc private func appWillTerminate() {
        handleAppTermination()
    }
    
    private func handleAppBackground() {
        guard userId != nil else { return }
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        updateOnlineStatus(isOnline: false, updateLastSeen: true) { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func handleAppTermination() {
        guard userId != nil else { return }
        
        let group = DispatchGroup()
        group.enter()
        
        updateOnlineStatus(isOnline: false, updateLastSeen: true) {
            group.leave()
        }
        
        group.notify(queue: .main) {
            print("Termination updates completed.")
        }
    }
    
    private func updateOnlineStatus(isOnline: Bool, updateLastSeen: Bool, completion: (() -> Void)? = nil) {
        guard let statusRef = statusRef else { return }
        
        var data: [String: Any] = ["is_online": isOnline]
        if updateLastSeen {
            data["last_seen"] = Timestamp(date: Date())
        }
        
        statusRef.updateData(data) { error in
            if let error = error {
                print("Error updating online status: \(error.localizedDescription)")
            } else {
                print("Online status updated successfully")
            }
            completion?()
        }
    }
    
    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// OnlineStatusManager.swift - Singleton لضمان وجود نسخة واحدة فقط
class OnlineStatusManager {
    static let shared = OnlineStatusManager()
    private var onlineStatusService = OnlineStatusService()
    
    private init() {}
    
    func setupPresence(userId: String) {
        onlineStatusService.setupPresence(userId: userId)
    }
}

