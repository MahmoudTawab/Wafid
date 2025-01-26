//
//  FirebaseManager.swift
//  Wafid
//
//  Created by almedadsoft on 21/01/2025.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager : NSObject {
    
    let auth:Auth
    let storage:Storage
    let firestore:Firestore
    static let shared = FirebaseManager()
    
   override init() {
       self.auth = Auth.auth()
       self.storage = Storage.storage()
       self.firestore = Firestore.firestore()
    }
}
