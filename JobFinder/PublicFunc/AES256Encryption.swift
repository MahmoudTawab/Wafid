//
//  AES256Encryption.swift
//  NewSwiftM
//
//  Created by Mahmoud on 05/01/2025.
//

import SwiftUI
import Foundation
import CommonCrypto


// Extension to handle preprocessing of JSON data
extension JSONSerialization {
    static func preprocessJsonData(_ data: [String: Any]) -> [String: Any] {
        var processedData = [String: Any]()
        
        for (key, value) in data {
            let processedValue: Any
            
            if let stringValue = value as? String {
                // معالجة القيم النصية الفارغة
                if stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || stringValue == "," {
                    processedValue = ""
                } else if stringValue == "True" || stringValue == "False" {
                    // معالجة القيم البولية التي تأتي كنصوص
                    processedValue = stringValue == "True"
                } else {
                    processedValue = stringValue
                }
            } else if value is NSNull || value as? String == "" {
                processedValue = NSNull()
            } else if let boolValue = value as? String, ["True", "False"].contains(boolValue) {
                // معالجة القيم البولية
                processedValue = boolValue == "True"
            } else {
                processedValue = value
            }
            
            processedData[key] = processedValue
        }
        
        return processedData
    }
}

struct ObjectTransform {
    static func transformOrderedKeys(data: [(String, Any)], pattern: String = "", mark: String = "#") -> String {
        let keys = data.map { $0.0 }
        return keys.joined(separator: mark) + pattern
    }
    
    static func transformOrderedValues(data: [(String, Any)], pattern: String = "", mark: String = "#") -> String {
        let values = data.map { "\($0.1)" }
        return values.joined(separator: mark) + pattern
    }
    
    static func transformValues(data: [String: Any], pattern: String = "", mark: String = "#") -> String {
        let values = data.map { "\($0.1)" }
        return values.joined(separator: mark) + pattern
    }
}

class AES256Encryption {
    // تعريف المفتاح كثابت في الكلاس
    private static let ENCRYPTION_KEY = "RH@P$%ss1966$@ss"
    
    static func encrypt(_ data: Any) -> Any {
        do {
            var jsonObject = data as? [String: Any] ?? [:]
            jsonObject = jsonObject.filter { $0.value is NSNull == false }
            
            let plaintext: String
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
            plaintext = String(data: jsonData, encoding: .utf8) ?? String(describing: data)
            
            // استخدام المفتاح المعرف مباشرة
            let asciiArr = asciiConverter(ENCRYPTION_KEY)
            let encKey = arrayResizer(asciiArr, newSize: 32, defaultValue: 0)
            let ivArr = arrayResizer(asciiArr, newSize: 16, defaultValue: 0)
            
            let encodedKeyHex = encKey.map { String(format: "%02x", $0) }.joined()
            let ivHex = ivArr.map { String(format: "%02x", $0) }.joined()
            
            let keyData = Data(hex: encodedKeyHex)
            let ivData = Data(hex: ivHex)
            
            guard let dataToEncrypt = plaintext.data(using: .utf8) else {
                return ["Encryption failed:": "Data conversion error"]
            }
            
            let bufferSize = dataToEncrypt.count + kCCBlockSizeAES128
            var encryptedData = Data(count: bufferSize)
            var numBytesEncrypted: size_t = 0
            
            let cryptStatus = encryptedData.withUnsafeMutableBytes { encryptedBytes in
                dataToEncrypt.withUnsafeBytes { dataToEncryptBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        ivData.withUnsafeBytes { ivBytes in
                            CCCrypt(
                                CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress,
                                keyData.count,
                                ivBytes.baseAddress,
                                dataToEncryptBytes.baseAddress,
                                dataToEncrypt.count,
                                encryptedBytes.baseAddress,
                                bufferSize,
                                &numBytesEncrypted
                            )
                        }
                    }
                }
            }
            
            guard cryptStatus == kCCSuccess else {
                return ["Encryption failed:": "Encryption error"]
            }
            
            encryptedData.count = numBytesEncrypted
            return encryptedData.base64EncodedString()
            
        } catch {
            return ["Encryption failed:": error.localizedDescription]
        }
    }
    
    static func decrypt(_ encryptedData: String) -> Any {
        // استخدام المفتاح المعرف مباشرة
        let asciiArr = asciiConverter(ENCRYPTION_KEY)
        let encKey = arrayResizer(asciiArr, newSize: 32, defaultValue: 0)
        let ivArr = arrayResizer(asciiArr, newSize: 16, defaultValue: 0)
        
        let encodedKeyHex = encKey.map { String(format: "%02x", $0) }.joined()
        let ivHex = ivArr.map { String(format: "%02x", $0) }.joined()
        
        let keyData = Data(hex: encodedKeyHex)
        let ivData = Data(hex: ivHex)
        
        let cleanEncryptedData = encryptedData.replacingOccurrences(of: "\r\n", with: "")
        
        guard let dataToDecrypt = Data(base64Encoded: cleanEncryptedData) else {
            return ["Decryption failed:": "Invalid base64 data"]
        }
        
        let bufferSize = dataToDecrypt.count + kCCBlockSizeAES128
        var decryptedData = Data(count: bufferSize)
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = decryptedData.withUnsafeMutableBytes { decryptedBytes in
            dataToDecrypt.withUnsafeBytes { encryptedBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            keyData.count,
                            ivBytes.baseAddress,
                            encryptedBytes.baseAddress,
                            dataToDecrypt.count,
                            decryptedBytes.baseAddress,
                            bufferSize,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            return ["Decryption failed:": "Decryption error"]
        }
        
        decryptedData.count = numBytesDecrypted
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            return ["Decryption failed:": "String conversion error"]
        }
        
        if let jsonData = decryptedString.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) {
            return jsonObject
        }
        
        return decryptedString
    }

}

// Extension to help with hex string conversion
extension Data {
    init(hex: String) {
        self.init(capacity: hex.count/2)
        var data: UInt8 = 0
        var state = true
        var i = hex.startIndex
        
        while i < hex.endIndex {
            let c = hex[i]
            switch c {
            case "0"..."9":
                data = data << 4 + UInt8(c.asciiValue! - ("0" as Character).asciiValue!)
            case "a"..."f":
                data = data << 4 + UInt8(c.asciiValue! - ("a" as Character).asciiValue! + 10)
            case "A"..."F":
                data = data << 4 + UInt8(c.asciiValue! - ("A" as Character).asciiValue! + 10)
            default:
                break
            }
            
            if !state {
                self.append(data)
                data = 0
            }
            
            state = !state
            i = hex.index(after: i)
        }
    }
}



func asciiConverter(_ key: String) -> [Int] {
    var keyASCIIArray: [Int] = []
    for char in key {
        let ascii = Int(char.asciiValue ?? 0)
        keyASCIIArray.append(ascii)
    }
    return keyASCIIArray
}

func arrayResizer(_ arr: [Int], newSize: Int, defaultValue: Int) -> [Int] {
    var newArr = arr
    if newArr.count > newSize {
        newArr = Array(newArr[0..<newSize])
    } else {
        while newSize > newArr.count {
            newArr.append(defaultValue)
        }
    }
    return newArr
}
