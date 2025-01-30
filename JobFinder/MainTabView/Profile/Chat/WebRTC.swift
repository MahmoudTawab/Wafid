//
//  WebRTC.swift
//  Wafid
//
//  Created by almedadsoft on 29/01/2025.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import AVFoundation
import StreamVideo
import StreamVideoSwiftUI

class CallManager: ObservableObject {
    static let shared = CallManager()
    private let db = Firestore.firestore()
    
    @Published var incomingCall: CallData?
    @Published var outgoingCall: CallData?
    @Published var isCallActive = false
    @Published var callType: String?
    @AppStorage("user_id") var user_id: String = ""
    @AppStorage("IsEmployee") var IsEmployee: Bool = true
    @AppStorage("company_id") var company_id: String = ""
    private var callListener: ListenerRegistration?
    
    struct CallData: Codable {
        let id: String // نفس callId
        let callId: String
        let callerId: String
        let receiverId: String
        let type: String
        let status: String
        let timestamp: Date
        let callerName: String
        let receiverName: String
    }
    
    init() {
          // بدء الاستماع للمكالمات الواردة عند تهيئة المدير
          setupCallListener()
      }
      
    func setupCallStatusListener(for callId: String) {
         // إلغاء أي listener سابق
         callListener?.remove()
         
         // إنشاء listener جديد
         callListener = db.collection("calls").document(callId)
             .addSnapshotListener { [weak self] snapshot, error in
                 guard let document = snapshot else { return }
                 guard let callData = try? document.data(as: CallData.self) else { return }
                 
                 DispatchQueue.main.async {
                     self?.handleCallStatusChange(callData)
                 }
             }
     }
     
     private func handleCallStatusChange(_ callData: CallData) {
         switch callData.status {
         case "rejected", "ended":
             // إنهاء المكالمة للطرفين
             self.incomingCall = nil
             self.outgoingCall = nil
             self.isCallActive = false
             callListener?.remove()
             
             RingtonePlayer.shared.stopRingtone()
         case "accepted":
             RingtonePlayer.shared.stopRingtone()

             self.isCallActive = true
             // يمكن هنا بدء إعداد المكالمة الفعلية
             
         default:
             break
         }
     }
      
      // دالة بدء مكالمة فيديو
    func startVideoCall(currentUserId: String, recipientUserId: String, callerName: String,receiverName: String) {
            let callId = UUID().uuidString
            let callData = CallData(
                id: callId,
                callId: callId,
                callerId: currentUserId,
                receiverId: recipientUserId,
                type: "video",
                status: "pending",
                timestamp: Date(),
                callerName: callerName,
                receiverName: receiverName
            )
            
            saveCallToFirestore(callData)
            self.outgoingCall = callData
            setupCallStatusListener(for: callId) // إضافة مراقبة حالة المكالمة
        }
        
        func startAudioCall(currentUserId: String, recipientUserId: String, callerName: String,receiverName: String) {
            let callId = UUID().uuidString
            let callData = CallData(
                id: callId,
                callId: callId,
                callerId: currentUserId,
                receiverId: recipientUserId,
                type: "audio",
                status: "pending",
                timestamp: Date(),
                callerName: callerName,
                receiverName: receiverName
            )
            
            saveCallToFirestore(callData)
            self.outgoingCall = callData
            setupCallStatusListener(for: callId) // إضافة مراقبة حالة المكالمة
        }
    
    // قبول المكالمة
    func acceptCall(callId: String) {
        db.collection("calls").document(callId).updateData([
            "status": "accepted"
        ]) { [weak self] error in
            if error == nil {
                self?.isCallActive = true
            }
        }
    }
    
    func endCall(callId: String) {
        db.collection("calls").document(callId).updateData([
            "status": "ended"
        ]) { [weak self] error in
            if error == nil {
                self?.incomingCall = nil
                self?.outgoingCall = nil
                self?.isCallActive = false
                self?.callListener?.remove()
            }
        }
    }
    
    
    func rejectCall(callId: String) {
        db.collection("calls").document(callId).updateData([
            "status": "rejected"
        ]) { [weak self] error in
            if error == nil {
                self?.incomingCall = nil
                self?.outgoingCall = nil
                self?.isCallActive = false
                self?.callListener?.remove()
            }
        }
    }
    

    
    deinit {
        callListener?.remove()
    }
    
    
    private func saveCallToFirestore(_ callData: CallData) {
            do {
                try db.collection("calls").document(callData.callId).setData(from: callData)
            } catch {
                print("Error saving call: \(error)")
            }
        }
        
        func setupCallListener() {
            let currentUserId = IsEmployee ? user_id : company_id

            db.collection("calls")
                .whereField("receiverId", isEqualTo: currentUserId)
                .whereField("status", isEqualTo: "pending")
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    
                    if let latestCall = documents.compactMap({ try? $0.data(as: CallData.self) }).first {
                        DispatchQueue.main.async {
                            self?.incomingCall = latestCall
                            self?.setupCallStatusListener(for: latestCall.callId) // إضافة مراقبة حالة المكالمة
                            self?.showIncomingCallUI()
                        }
                    }
                }
        }

    
    // عرض واجهة المكالمة الواردة
    private func showIncomingCallUI() {
        // يمكنك هنا تشغيل صوت الرنين
        RingtonePlayer.shared.playRingtone()
    }
    
    // إرسال إشعار للمستخدم
    private func sendPushNotification(to userId: String, callData: CallData) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let fcmToken = document?.data()?["fcmToken"] as? String {
                self?.sendFCMNotification(to: fcmToken, callData: callData)
            }
        }
    }
    
    // إرسال إشعار FCM
    private func sendFCMNotification(to token: String, callData: CallData) {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=YOUR_SERVER_KEY", forHTTPHeaderField: "Authorization")
        
        let notification: [String: Any] = [
            "to": token,
            "notification": [
                "title": "\(callData.type == "video" ? "مكالمة فيديو" : "مكالمة صوتية")",
                "body": "مكالمة واردة من \(callData.callerName)",
                "sound": "default"
            ],
            "data": [
                "callId": callData.callId,
                "callerId": callData.callerId,
                "type": callData.type
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: notification)
        
        URLSession.shared.dataTask(with: request).resume()
    }

    
}




// IncomingCallView.swift
struct IncomingCallView: View {
    @ObservedObject var callManager = CallManager.shared
    let call: CallManager.CallData
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("مكالمة واردة")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(call.callerName)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(call.type == "video" ? "مكالمة فيديو" : "مكالمة صوتية")
                    .foregroundColor(.white)
                
                HStack(spacing: 50) {
                    // زر رفض المكالمة
                    Button(action: {
                        callManager.rejectCall(callId: call.callId)
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                    
                    // زر قبول المكالمة
                    Button(action: {
                        callManager.acceptCall(callId: call.callId)
                    }) {
                        Image(systemName: call.type == "video" ? "video.fill" : "phone.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// IncomingCallView.swift
struct OutgoingCallView: View {
    let call: CallManager.CallData
    @ObservedObject private var callManager = CallManager.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("جاري الاتصال...")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(call.receiverName)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Image(systemName: call.type == "video" ? "video.fill" : "phone.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .padding()
                
                // زر إنهاء المكالمة
                Button(action: {
                    callManager.endCall(callId: call.callId)
                }) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .padding(.top, 30)
            }
        }
    }
}

class RingtonePlayer {
    static let shared = RingtonePlayer() // Singleton لاستخدامه في أي مكان

    private var player: AVPlayer?
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?

    // تشغيل النغمة مع التكرار
    func playRingtone() {
        guard let url = Bundle.main.url(forResource: "WhatsApp", withExtension: "mp3") else {
            print("❌ ملف الصوت غير موجود!")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem)

        queuePlayer?.play()
        print("✅ تشغيل النغمة...")
    }

    // إيقاف النغمة
    func stopRingtone() {
        queuePlayer?.pause()
        queuePlayer?.removeAllItems()
        print("⏹️ تم إيقاف النغمة.")
    }
}




struct VideoCallApp: View {
    @StateObject private var callManager = CallManager.shared
    @ObservedObject var viewModel: CallViewModel
    private var client: StreamVideo

    private let apiKey: String = "mmhfdzb5evj2"
    private let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0RhcnRoX1ZhZGVyIiwidXNlcl9pZCI6IkRhcnRoX1ZhZGVyIiwidmFsaWRpdHlfaW5fc2Vjb25kcyI6NjA0ODAwLCJpYXQiOjE3MzgxNzExNzgsImV4cCI6MTczODc3NTk3OH0.0HqiDxWbLhxEsD8cak5HhTrvbn7eGz1LJ1b4bT4cgGM"
    private let userId: String = "Darth_Vader"
    private let callId: String = "BKTcmRHlJx83"

    init(name:String) {
        let user = User(
            id: userId,
            name: name , // name and imageURL are used in the UI
            imageURL: .init(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/a3911/martin-mitrevski.webp")
        )

        // Initialize Stream Video client
        self.client = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(stringLiteral: token)
        )

        self.viewModel = .init()
    }

        var body: some View {
            VStack {
                if viewModel.call != nil {
                    CallContainer(viewFactory: DefaultViewFactory.shared, viewModel: viewModel)
                }
            }.onAppear {
                Task {
                    guard viewModel.call == nil else { return }
                    viewModel.joinCall(callType: .default, callId: callId)
                }
            }
            
            .onChange(of: viewModel.callingState, perform: { State in
                if State == CallingState.idle {
                    callManager.incomingCall = nil
                    callManager.outgoingCall = nil
                    callManager.isCallActive = false
                }
            })
            
        }

}
            

