//
//  makeRequest.swift
//  JobFinder
//
//  Created by almedadsoft on 18/01/2025.
//


import SwiftUI

 let dateToken = "Rwafed"
 let ApiToken = "TTRreifoi&kah@hd$ghrd24"


struct TransactionDataGet {
    let FunctionName: String?
    let ProcedureName: String
    let ParametersValues: String
    let DataToken: String
    let Offset: String
    let Fetch: String
}

func makeRequestGet(
    functionName: String = "",
    ProcedureName: String,
    ApiToken: String,
    dateToken: String,
    parametersValues: [String: Any],
    orderedKeys: [(String, Any)]
) async throws -> Any {
    let url = URL(string: "https://framework.md-license.com:8093/emsserver.dll/ERPDatabaseWorkFunctions/ExecuteProcedure")!
    
    // Use ordered parameters for transformation
    let allValues = ObjectTransform.transformOrderedValues(data: orderedKeys)
    
    let transactionData = TransactionDataGet(
        FunctionName: functionName.isEmpty ? nil : functionName,
        ProcedureName: ProcedureName,
        ParametersValues: allValues,
        DataToken: dateToken,
        Offset: "",
        Fetch: ""
    )
    
    // Build jsonData dynamically, removing "FunctionName" if it's nil
    var jsonData: [String: Any] = [
        "ProcedureName": transactionData.ProcedureName,
        "ParametersValues": transactionData.ParametersValues,
        "DataToken": transactionData.DataToken,
        "Offset": transactionData.Offset,
        "Fetch": transactionData.Fetch
    ]
    
    if let functionName = transactionData.FunctionName {
        jsonData["FunctionName"] = functionName
    }
    
    // Encrypt the jsonData
    let encryptedData = AES256Encryption.encrypt(jsonData)
    
    let requestBody: [String: Any] = [
        "ApiToken": ApiToken,
        "Data": encryptedData
    ]
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONSerialization.jsonObject(with: data)
    
    return response
}


func makeRequestMultiPost(ApiToken: String, dateToken: String, tableNames: [String], multiData: [[(String, Any)]]) async throws -> Any {
    let url = URL(string: "https://framework.md-license.com:8093/emsserver.dll/ERPDatabaseWorkFunctions/DoMultiTransaction")!
    
    // Transform data for each table
    let allValues = multiData.map { ObjectTransform.transformOrderedValues(data: $0) }
    let combinedValues = allValues.joined(separator: "^")
    let combinedTableNames = tableNames.joined(separator: "^")
    
    // Create the data object
    let transactionData = [
        "MultiTableName": combinedTableNames,
        "MultiColumnsValues": combinedValues,
        "WantedAction": "0",
        "PointId": "1",
        "DataToken": dateToken
    ] as [String : Any]
    
    // Encrypt the data using the provided AES256 encryption
    let encryptedData = AES256Encryption.encrypt(transactionData)
    
    // Create the final request body
    let requestBody = [
        "ApiToken": ApiToken,
        "Data": encryptedData
    ]
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONSerialization.jsonObject(with: data)
    return response
}


// Add FileUploadData struct
struct FileUploadData {
    let actionType: String
    let mainId: Int
    let subId: Int
    let detailId: Int
    let fileType: String
    let fileId: String
    let description: String
    let name: String
    let dataToken: String
}

// Add image upload function
     func uploadImage(image: UIImage?, type: String) async throws -> String {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let uploadData = FileUploadData(
            actionType: "Add",
            mainId: 1,
            subId: 0,
            detailId: 0,
            fileType: ".jpg",
            fileId: "",
            description: "\(type) photo",
            name: "\(type)_image",
            dataToken: dateToken
        )
        
        let result = try await makeRequestUploadFile(
            ApiToken: ApiToken,
            fileData: imageData,
            uploadData: uploadData
        )
        
        // Parse the response to get the file ID
        if let resultDict = result as? [String: Any],
           let fileId = resultDict["FileId"] as? String, let encryptedData = AES256Encryption.decrypt(fileId) as? String {
            
            return encryptedData
        }
        
        throw NSError(domain: "", code: -1,
                     userInfo: [NSLocalizedDescriptionKey: "Failed to get file ID"])
    }
    
    // Add makeRequestUploadFile function
    func makeRequestUploadFile(
        ApiToken: String,
        fileData: Data,
        uploadData: FileUploadData
    ) async throws -> Any {
        let url = URL(string: "https://framework.md-license.com:8093/emsserver.dll/ERPDatabaseWorkFunctions/UploadFileNew")!
        
        let base64FileString = fileData.base64EncodedString()
        
        let jsonData = [
            "ActionType": uploadData.actionType,
            "MainId": uploadData.mainId,
            "SubId": uploadData.subId,
            "DetailId": uploadData.detailId,
            "FileType": uploadData.fileType,
            "FileId": uploadData.fileId,
            "Description": uploadData.description,
            "Name": uploadData.name,
            "DataToken": uploadData.dataToken
        ] as [String: Any]
        
        let encryptedData = AES256Encryption.encrypt(jsonData)
        
        let requestBody = [
            "ApiToken": ApiToken,
            "Data": encryptedData,
            "encode_plc1": base64FileString
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONSerialization.jsonObject(with: data)
        
        return response
    }



func makeRequestDownloadFile(ApiToken: String, fileId: String, dateToken: String) async throws -> Any {
    // استخدام URL الصحيح من المستندات
    let url = URL(string: "https://framework.md-license.com:8093/emsserver.dll/ERPDatabaseWorkFunctions/DownloadFileNew")!
    
    // Create the data object
    let jsonData = [
        "FileId": fileId,
        "DataToken": dateToken
    ] as [String : Any]
    
    // Encrypt the data using the provided AES256 encryption
    let encryptedData = AES256Encryption.encrypt(jsonData)
    
    // Create the final request body
    let requestBody = [
        "ApiToken": ApiToken,
        "Data": encryptedData
    ]
    
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONSerialization.jsonObject(with: data)
    return response
}
