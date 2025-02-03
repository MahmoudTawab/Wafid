//
//  HomeEmployeeView.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//

import SwiftUI

// View للصفحة الرئيسية
struct HomeEmployeeView: View {
    @AppStorage("fullName") var fullName : String = ""
    @StateObject private var viewModel = HomeViewEmployeeViewModel()
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack(spacing: 12) {
                        Image("logo_labour")
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        Text(fullName == "" ? "Home" : fullName)
                            .foregroundColor(.black)
                            .font(.system(size: ControlWidth(20), weight: .bold))
                        
                        Spacer()
                        
                        Image("Frame 1394")
                            .resizable()
                            .frame(width: 44, height: 44)
                    }
                    .padding(.bottom, 8)
                
                    
                    HStack(alignment: .center,spacing: 10) {
                        HStack {
                        TextField("Search", text: $viewModel.searchText)
                            .padding(10)
                            .tint(.gray)
                            .frame(height: 44)
                            .onChange(of: viewModel.searchText) { _ in
                                viewModel.handleSearchTextChange()
                            }
                            
                            Spacer()
                            Image("search-normal")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                         }
                        .background(rgbToColor(red: 255, green: 247, blue: 236))
                        .cornerRadius(20)
                        
                        Button(action: {}) {
                            Image("Frame 1395")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44,height: 44)
                        }
                    } .padding(.bottom, 8)
                    
                    HStack(alignment: .center,spacing: 10) {
                        Text("Job Recommendation")
                            .foregroundColor(.black)
                            .font(.system(size: ControlWidth(16)))
                        
                        Spacer()
                        
                        Text("See all")
                            .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                            .font(.system(size: ControlWidth(14)))
                    } .padding(.bottom, 8)
                    
                    // Categories ScrollView
                    if let favouriteCategories = viewModel.favouriteCategories {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                CategoryButton(
                                title: "All Job",
                                isSelected: viewModel.selectedCategory == "All Job",
                                onTap: {
                                viewModel.selectCategory("All Job")
                                }
                                )
                                                  
                                ForEach(favouriteCategories, id: \.id) { category in
                                CategoryButton(
                                title: category.categoryName ?? "",
                                isSelected: viewModel.selectedCategory == category.categoryName,
                                onTap: {
                                viewModel.selectCategory(category.categoryName ?? "")
                                }
                                )
                                }
                                .padding(.vertical, 4)
                        }
                        }
                        }
                    
                    // Job Listings
                    if let jobs = viewModel.jobs {
                        VStack(spacing: 16) {
                            ForEach(jobs, id: \.id) { job in
                                JobCard(job: job)
                                .onTapGesture {
                                navigationManager.navigate(to: .JobRecommendationView(jobs_id: "\(job.id)"))
                                }
                            }
                        }
                    } else {
                        Text("No jobs available")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
            .padding()
            .padding(.bottom, 70)
            .edgesIgnoringSafeArea(.all)
            
            // Loading Indicator
            if viewModel.showLoadingIndicator {
                loadingOverlay
                .padding(.bottom)
            }
            
            
            // Alert Message
            if let alertMessage = viewModel.alertMessage {
                AnimatedToastMessage(
                    showingErrorMessageisValid: $viewModel.showingAlert,
                    MassegeContent: .constant(alertMessage),
                    TypeToast: .error,
                    FrameHeight: .constant(65)
                )
                .padding(.top)
            }
        }
        .preferredColorScheme(.light)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .task {
            await viewModel.fetchData()
        }
        
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // إخفاء لوحة المفاتيح
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                ActivityIndicatorView(isVisible: $viewModel.showLoadingIndicator, type: .flickeringDots())
                    .frame(width: 60, height: 60)
                    .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
            }
            .frame(width: 120, height: 120)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
        }
    }
    
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: ControlWidth(14)))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? rgbToColor(red: 193, green: 140, blue: 70) : .white)
                .foregroundColor(isSelected ? .white : rgbToColor(red: 193, green: 140, blue: 70))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 1)
                )
        }
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
            HStack(spacing: 12) {
                Image("linkedin")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.jobTitle ?? "")
                        .font(.system(size: ControlWidth(15), weight: .semibold))
                    
                    if let companyInfo = job.companyInfo?.first {
                        Text(companyInfo.companyName ?? "")
                            .font(.system(size: ControlWidth(14)))
                            .foregroundColor(.gray)
                        
                        Text("\(companyInfo.country ?? "") - \(job.typeName ?? "")")
                            .font(.system(size: ControlWidth(12)))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing,spacing: 12) {
                    Button(action: {
                        isSaved.toggle()
                    }) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70) )
                    }
                    
                    if let salary = job.salary {
                        Text("$\(String(format: "%.2f", salary))")
                            .font(.system(size: ControlWidth(15), weight: .semibold))
                            .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70) )
                    }
                }
            }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: -2, y: 2)
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
    var Subscribed: Int
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
    var isMultinational: Int?
    var taxAttach: String
    var createdBy: Int?
    var readDate: String?
    var updatedAt: String?
    var updatedBy: Int?
    var nationality: String?
    var nearestPoint: String?
    var recordAttachId: Int?
    var company_email: String?
    
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
        case company_email
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
class HomeViewEmployeeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: String = "All Job"
    @Published var favouriteCategories: [FavouriteCategory]?
    @Published var jobs: [JobsData]?
    @Published var alertMessage: String?
    @Published var showingAlert = false
    @Published var showLoadingIndicator = false
    @AppStorage("user_id") var userId: String = ""
    
    private var procedureName = "rEAEGTXWvqyvcPKVZcfTSQ=="
    private var searchProcedureName = "yKw6hiR4EUW+qtEMZ5mLzQ=="
    private var searchTask: Task<Void, Never>?
    private var isSelectingCategory = false
    
    func selectCategory(_ category: String) {
        selectedCategory = category
        isSelectingCategory = true
        searchText = category == "All Job" ? "" : category
        isSelectingCategory = false
        // Directly call search without the debounce since it's a direct user action
        Task {
            await searchJobs()
        }
    }
    
    func handleSearchTextChange() {
        // Don't trigger search if the change came from category selection
        if isSelectingCategory { return }
        
        // Reset category to "All Job" if user is typing manually
        if searchText.isEmpty {
            selectedCategory = "All Job"
        }
        
        // Cancel any existing search task
        searchTask?.cancel()
        
        // Create a new search task with debounce
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds delay
            
            // Check if the task was cancelled
            if !Task.isCancelled {
                await searchJobs()
            }
        }
    }
    
    func searchJobs() async {
        guard !Task.isCancelled else { return }
        
        alertMessage = nil
        
        let orderedParameters: [(String, Any)] = [
            ("user_id", userId),
            ("value", searchText)
        ]
        
        let parameters = Dictionary(uniqueKeysWithValues: orderedParameters)
        
        do {
            let response = try await makeRequestGet(
                ProcedureName: searchProcedureName,
                ApiToken: ApiToken,
                dateToken: dateToken,
                parametersValues: parameters,
                orderedKeys: orderedParameters
            )
            
            if !Task.isCancelled {
                if let encrypted = response as? [String: Any], let dataString = encrypted["Data"] as? String {
                    let decryptedData = AES256Encryption.decrypt(dataString)
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: decryptedData),
                       let userDataResponse = try? JSONDecoder().decode(ResponseUserData.self, from: jsonData) {
                        
                        if let result = userDataResponse.result?.first {
                            if let jobsString = result.jobs {
                                do {
                                    if let jobsData = jobsString.data(using: .utf8) {
                                        let jobs = try JSONDecoder().decode([JobsData].self, from: jobsData)
                                        self.jobs = jobs
                                    }
                                } catch {
                                    self.alertMessage = "Failed to decode search results"
                                    self.showingAlert = true
                                }
                            }
                        } else {
                            self.jobs = []
                        }
                    }
                }
                
            }
            
        } catch {
            if !Task.isCancelled {
                alertMessage = "Search failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
        
    }
    
    func fetchData() async {

        if let jobs = jobs, !jobs.isEmpty,
           let categories = favouriteCategories, !categories.isEmpty {
            return
        }
        
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
                        
                        if let jobsString = result.jobs {
                            do {
                                if let jobsData = jobsString.data(using: .utf8) {
                                    let jobs = try JSONDecoder().decode([JobsData].self, from: jobsData)
                                    self.jobs = jobs
                                }
                            } catch {
                                print("Decoding error: \(error)") // سيطبع تفاصيل الخطأ بالضبط
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
            alertMessage = "Failed to fetch Data: \(error.localizedDescription)"
        }
    }
}



