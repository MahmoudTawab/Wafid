//
//  HomeView.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//

import SwiftUI

// View للصفحة الرئيسية

struct HomeView: View {
    @StateObject private var viewModel = HomeViewViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                HStack(spacing: 12) {
                    Image("logo_labour")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    Text("Home")
                        .font(.system(size: 22, weight: .bold))
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                // Categories ScrollView
                if let favouriteCategories = viewModel.favouriteCategories {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryButton(title: "All Job", isSelected: true)
                            ForEach(favouriteCategories, id: \.id) { category in
                                CategoryButton(
                                    title: category.categoryName ?? "",
                                    isSelected: false
                                )
                            }
                        }
                    }
                }
                
                // Job Listings
                if let jobs = viewModel.jobs {
                    VStack(spacing: 16) {
                        ForEach(jobs, id: \.id) { job in
                            JobCard(job: job)
                        }
                    }
                } else if viewModel.showLoadingIndicator {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("No jobs available")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.top, 50)
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.light)
        .background(Color.white)
        .frame(maxWidth: .infinity)
        .task {
            await viewModel.fetchData()
        }
        .alert("Error", isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage ?? "Unknown error")
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color(red: 0.83, green: 0.65, blue: 0.41) : .white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

struct JobCard: View {
    let job: JobsData
    @State private var isSaved: Bool
    
    init(job: JobsData) {
        self.job = job
        _isSaved = State(initialValue: job.isSaved == 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image("twitter_logo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.jobTitle ?? "Unknown Position")
                        .font(.system(size: 16, weight: .semibold))
                    
                    if let companyInfo = job.companyInfo?.first {
                        Text(companyInfo.companyName ?? "Unknown Company")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("\(companyInfo.country ?? "Unknown Location") - \(job.typeName ?? "Unknown Type")")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    isSaved.toggle()
                }) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundColor(Color(red: 0.83, green: 0.65, blue: 0.41))
                }
            }
            
            if let salary = job.salary {
                Text("$\(String(format: "%.2f", salary))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.83, green: 0.65, blue: 0.41))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ResponseUserData: Codable {
    var fieldNames: String?
    var fieldTypes: String?
    var fieldsCount: String?
    var outParameters: String?
    var result: [JobResult]?
    var totalRowsCount: String?
    
    enum CodingKeys: String, CodingKey {
        case fieldNames = "FieldNames"
        case fieldTypes = "FieldTypes"
        case fieldsCount = "FieldsCount"
        case outParameters = "OutParameters"
        case result = "Result"
        case totalRowsCount = "TotalRowsCount"
    }
}

struct JobResult: Codable {
    var favouriteCategories: String?
    var jobs: String?
    
    enum CodingKeys: String, CodingKey {
        case favouriteCategories = "favourite_categories"
        case jobs
    }
}

struct FavouriteCategory: Codable {
    var categoryName: String?
    var id: Int?
    
    enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case id
    }
}

struct JobsData: Codable {
    var id: Int
    var jobTitle: String?
    var position: String?
    var salary: Double?
    var available: Bool?
    var experienceLevel: String?
    var jobDescription: String?
    var categoryId: Int?
    var categoryName: String?
    var active: Bool?
    var readDate: String?
    var expired: Bool?
    var isSaved: Int?
    var savedId: Int?
    var Subscribed: Int?
    var isApplied: Int?
    var companyInfo: [CompanyInfo]?
    var typeName: String?
    var jobRequirements: [JobRequirement]?
    var jobQuestions: [JobQuestion]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case jobTitle = "job_title"
        case position
        case salary
        case available
        case experienceLevel = "experience_level"
        case jobDescription = "job_description"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case active
        case readDate = "read_date"
        case expired
        case isSaved
        case savedId = "saved_id"
        case Subscribed
        case isApplied
        case companyInfo = "company_info"
        case typeName = "type_name"
        case jobRequirements = "job_requirements"
        case jobQuestions = "job_questions"
    }
}

struct CompanyInfo: Codable {
    var id: Int
    var companyName: String?
    var companyPhone: String?
    var companyAddress: String
    var companyCapital: String?
    var activity: String?
    var country: String?
    var taxAttachId: Int?
    var recordAttach: String?
    var isMultinational: Bool?
    var taxAttach: String
    var createdBy: Int?
    var readDate: String?
    var updatedAt: String?
    var updatedBy: Int?
    var nationality: String?
    var nearestPoint: String?
    var recordAttachId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case companyPhone = "company_phone"
        case companyAddress = "company_address"
        case companyCapital = "company_capital"
        case activity
        case country
        case taxAttachId = "tax_attach_id"
        case recordAttach = "record_attach"
        case isMultinational
        case taxAttach = "tax_attach"
        case createdBy
        case readDate = "read_date"
        case updatedAt
        case updatedBy
        case nationality
        case nearestPoint = "nearest_point"
        case recordAttachId = "record_attach_id"
    }
}

struct JobRequirement: Codable {
    var id: Int?
    var title: String?
}

struct JobQuestion: Codable {
    var id: Int?
    var question: String?
    var required: Bool?
}

@MainActor
class HomeViewViewModel: ObservableObject {
    @Published var userData: ResponseUserData?
    @Published var favouriteCategories: [FavouriteCategory]?
    @Published var jobs: [JobsData]?
    @Published var alertMessage: String?
    @Published var showingAlert = false
    @Published var showLoadingIndicator = false
    @AppStorage("user_id") var userId: String = ""
    private var procedureName = "rEAEGTXWvqyvcPKVZcfTSQ=="
    
    func fetchData() async {
        showLoadingIndicator = true
        alertMessage = nil
        
        let orderedParameters: [(String, Any)] = [
            ("user_id", userId)
        ]
                
        let parameters = Dictionary(uniqueKeysWithValues: orderedParameters)
        
        do {
            let response = try await makeRequestGet(
                ProcedureName: procedureName,
                ApiToken: ApiToken,
                dateToken: dateToken,
                parametersValues: parameters,
                orderedKeys: orderedParameters
            )
            
            if let encrypted = response as? [String: Any], let dataString = encrypted["Data"] as? String {
                let decryptedData = AES256Encryption.decrypt(dataString)
                                
                if let jsonData = try? JSONSerialization.data(withJSONObject: decryptedData),
                   let userDataResponse = try? JSONDecoder().decode(ResponseUserData.self, from: jsonData) {
                    
                    if let result = userDataResponse.result?.first {
                        
                   

                        
                        if var jobsString = result.jobs {
                            jobsString = jobsString.replacingOccurrences(of: "\\\"", with: "\"")
                            print("Jobs String: \(jobsString)") // طباعة سلسلة الوظائف

                            if let jobsData = jobsString.data(using: .utf8) , let jobs = try? JSONDecoder().decode([JobsData].self, from: jobsData) {
                                    self.jobs = jobs
                                    print("Jobs: \(jobs)") // طباعة الوظائف المحولة
                            }
                            
                        }
                        
                        if var categoriesString = result.favouriteCategories {
                            categoriesString = categoriesString.replacingOccurrences(of: "\\\"", with: "\"")
                            if let categoriesData = categoriesString.data(using: .utf8),
                               let categories = try? JSONDecoder().decode([FavouriteCategory].self, from: categoriesData) {
                                self.favouriteCategories = categories
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.showLoadingIndicator = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showingAlert = true
                            self.showLoadingIndicator = false
                            self.alertMessage = "No data available"
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showingAlert = true
                        self.showLoadingIndicator = false
                        self.alertMessage = "Failed to decode User Data"
                    }
                }
            }
        } catch {
            showingAlert = true
            showLoadingIndicator = false
            alertMessage = "Failed to fetch profile: \(error.localizedDescription)"
        }
    }
}


