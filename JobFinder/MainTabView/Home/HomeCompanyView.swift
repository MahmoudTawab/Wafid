//
//  HomeCompanyView.swift
//  Wafid
//
//  Created by almedadsoft on 28/01/2025.
//

import SwiftUI

struct HomeCompanyView: View {
    @AppStorage("fullName") var fullName : String = ""
    @StateObject private var viewModel = HomeViewCompanyViewModel()
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
                    

                    // Vacancies Section
                    VacanciesSection(jobs: viewModel.JobResponse?.jobs ?? [])
                               
                    // Recent Applications Section
                    RecentApplicationsSection(applications: viewModel.Applications ?? [])

                    
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
            }
            
            
            // Alert Message
            if let alertMessage = viewModel.alertMessage {
                AnimatedToastMessage(
                    showingErrorMessageisValid: $viewModel.showingAlert,
                    MassegeContent: .constant(alertMessage),
                    TypeToast: .error,
                    FrameHeight: .constant(65)
                )
                .padding(.top,50)
                .frame(width: UIScreen.main.bounds.width - 30)
            }
        }
        .preferredColorScheme(.light)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .task {
            await viewModel.fetchData1()
            await viewModel.fetchData2()
        }

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

struct VacanciesSection: View {
    let jobs: [Job]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center,spacing: 10) {
                Text("My Vacancies")
                    .foregroundColor(.black)
                    .font(.system(size: ControlWidth(16)))
                
                Spacer()
                
                Text("See all")
                    .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                    .font(.system(size: ControlWidth(14)))
            } .padding(.bottom, 8)
            
            ForEach(jobs, id: \.id) { job in
                VacancyCard(job: job)
                .padding(.top,10)
            }

        }
    }
}

struct VacancyCard: View {
    let job: Job
    @State private var isEnabled = true
    
    var body: some View {
        HStack {
            Image("linkedin")
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(job.jobTitle ?? "")
                    .font(.system(size: ControlWidth(15), weight: .semibold))
                Text(job.categoryName ?? "")
                    .font(.system(size: ControlWidth(14)))
                    .foregroundColor(.gray)
                Text("\(job.position ?? "") - \(job.typeName ?? "")")
                    .font(.system(size: ControlWidth(14)))
                    .foregroundColor(.gray)
            }.padding(.horizontal,4)

            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
    
                Toggle("", isOn: $isEnabled)
                
                if let salary = job.salary {
                    Text("$\(String(format: "%.2f", salary))")
                        .font(.system(size: ControlWidth(15), weight: .semibold))
                        .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: -2, y: 2)
    }
}

struct RecentApplicationsSection: View {
    let applications: [Application]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center,spacing: 10) {
                Text("Recent People Applied")
                    .foregroundColor(.black)
                    .font(.system(size: ControlWidth(16)))
                
                Spacer()
                
                Text("See all")
                    .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                    .font(.system(size: ControlWidth(14)))
            } .padding(.bottom, 8)
            
            ForEach(applications, id: \.id) { application in
                if let userInfo = application.userInfo?.first {
                    ApplicantCard(application: application, userInfo: userInfo)
                }
            }
        }
    }
}

struct ApplicantCard: View {
    let application: Application
    let userInfo: UserInfo
    @State var userImageProfile : UIImage?

    var body: some View {
        VStack {
            HStack {
                Image(uiImage: (userImageProfile ?? UIImage(systemName: "person.circle")) ?? UIImage() )
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(userInfo.fullName)
                        .font(.headline)
                    Text(userInfo.occupation)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if let experience = userInfo.workExperience?.first {
                        Text("Experience: \(experience.jobTitle)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }else{
                        Text(userInfo.email)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
    
                Spacer()

                Button(action: {
                    // Bookmark action
                }) {
                    Image("button")
                        .resizable()
                        .frame(width: 40,height: 40)
                }
            }
            
            Divider()
            .foregroundColor(rgbToColor(red: 255, green: 247, blue: 236))
            
            HStack(spacing: 20) {
                Button("Job Details") {
                    // Action
                }
                .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 1)
                )
                
                Button("See Details") {
                    // Action
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(rgbToColor(red: 193, green: 140, blue: 70))
                .cornerRadius(20)
            }
            .padding(.top, 10)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: -2, y: 2)
        
        .onAppear {
            CollApiDownloadFile(fileId: "\(userInfo.profileAttachID)")
        }
    }
    
    func CollApiDownloadFile(fileId:String) {
        Task {
            do {
                let result = try await makeRequestDownloadFile(
                    ApiToken: ApiToken,
                    fileId: fileId,
                    dateToken: dateToken
                )
                                
                // التعامل مع النتيجة
                if let resultDict = result as? [String: Any] {
                    if let fileData = resultDict["FileData"] as? String {
                        // تحويل البيانات من Base64 إلى Data
                        if let decodedData = Data(base64Encoded: fileData.replacingOccurrences(of: "\r\n", with: "")) {
                            // يمكنك الآن استخدام decodedData لإنشاء صورة أو حفظ الملف
                            if let image = UIImage(data: decodedData) {
                                // تم تحميل الصورة بنجاح
                                self.userImageProfile = image
                            }
                        }
                    }
                }
            } catch {
                print("Error downloading file:", error)
            }
        }
    }
}


struct ApplicationsResponse: Codable {
    var applications: String?
    var isSaved: Int?
    var isInvited: Int?
    var isInterview: Int?
    var jobs: String?
    
    enum CodingKeys: String, CodingKey {
        case applications
        case isSaved = "issaved"
        case isInvited = "isinvited"
        case isInterview = "isinterview"
        case jobs
    }
    
    var parsedJob: [Job]? {
        guard let data = jobs?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([Job].self, from: data)
    }
    
    var parsedApplications: [Application]? {
        guard let data = applications?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([Application].self, from: data)
    }
}

struct Application: Codable {
    var id: Int?
    var jobsID: Int?
    var usersID: Int?
    var status: String?
    var applicationDate: String?
    var userInfo: [UserInfo]?
    var jobs: [Job]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case jobsID = "jobs_id"
        case usersID = "userss_id"
        case status
        case applicationDate = "application_date"
        case userInfo = "user_info"
        case jobs
    }

}

struct UserInfo: Codable {
    var id: Int
    var fullName: String
    var phone: String
    var email: String
    var occupation: String
    var profileAttach: String
    var profileAttachID: Int
    var releaseDate: String
    var country: String
    var expiryDate: String
    var nationalID: String
    var nationalIDAttachID: Int
    var nationalIDAttach: String
    var bloodType: String
    var birthDate: String
    var relativesNumber: String
    var qualification: String
    var birthPlace: String
    var types: [String]
    var links: [UserLink]?
    var education: [Education]?
    var certifications: [Certification]?
    var trainings: [Training]?
    var workExperience: [WorkExperience]?

    enum CodingKeys: String, CodingKey {
        case id, fullName, phone, email, occupation
        case profileAttach = "profile_attach"
        case profileAttachID = "profile_attach_id"
        case releaseDate = "release_date"
        case country
        case expiryDate = "expiry_date"
        case nationalID = "national_id"
        case nationalIDAttachID = "national_id_attach_id"
        case nationalIDAttach = "national_id_attach"
        case bloodType = "blood_type"
        case birthDate = "birth_date"
        case relativesNumber = "relatives_number"
        case qualification
        case birthPlace = "birth_place"
        case links, types, education, certifications, trainings, workExperience
    }
    
}

struct UserLink: Codable {
    var id: Int
    var name: String
    var link: String
}

struct Education: Codable {
    var id: Int
    var educationLevel: String
    var bachelorsDegree: [BachelorsDegree]
    var highSchool: [HighSchool]

    enum CodingKeys: String, CodingKey {
        case id
        case educationLevel = "education_level"
        case bachelorsDegree = "bachelors_degree"
        case highSchool = "high_school"
    }
}

struct BachelorsDegree: Codable {
    var university: String
    var faculty: String
    var universityGradeYear: Int
    var universityGrade: String
    var qualificationAttach: String

    enum CodingKeys: String, CodingKey {
        case university, faculty
        case universityGradeYear = "university_grade_year"
        case universityGrade = "university_grade"
        case qualificationAttach = "qualification_attach"
    }
}

struct HighSchool: Codable {
    var schoolName: String
    var schoolCertificateName: String
    var schoolGradeYear: Int
    var schoolGrade: String

    enum CodingKeys: String, CodingKey {
        case schoolName = "school_name"
        case schoolCertificateName = "school_certificate_name"
        case schoolGradeYear = "school_grade_year"
        case schoolGrade = "school_grade"
    }
}

struct Certification: Codable {
    var id: Int
    var usersID: Int
    var name: String
    var date: String
    var organization: String
    var attachmentID: Int
    var type: String
    var readDate: String
    var empID: Int
    var updatedAt: String
    var updatedBy: Int
    var attachment: String

    enum CodingKeys: String, CodingKey {
        case id
        case usersID = "userss_id"
        case name, date, organization
        case attachmentID = "attachment_id"
        case type
        case readDate = "read_date"
        case empID = "emp_id"
        case updatedAt, updatedBy, attachment
    }
}

struct Training: Codable {
    var id: Int
    var usersID: Int
    var name: String
    var date: String
    var organization: String
    var attachmentID: Int
    var type: String
    var readDate: String
    var empID: Int
    var updatedAt: String
    var updatedBy: Int
    var attachment: String

    enum CodingKeys: String, CodingKey {
        case id
        case usersID = "userss_id"
        case name, date, organization
        case attachmentID = "attachment_id"
        case type
        case readDate = "read_date"
        case empID = "emp_id"
        case updatedAt, updatedBy, attachment
    }
}

struct WorkExperience: Codable {
    var id: Int
    var jobTitle: String
    var jobDetails: String
    var startDate: String
    var endDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case jobTitle = "job_title"
        case jobDetails = "job_details"
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct Job: Codable {
    var id: Int?
    var jobTitle: String?
    var position: String?
    var salary: Double?
    var available: Bool?
    var experienceLevel: String?
    var jobDescription: String?
    var categoryID: Int?
    var categoryName: String?
    var companyID: Int?
    var active: Bool?
    var expired: Bool?
    var readDate: String?
    var typeName: String?
    var jobType: Int?
    var jobRequirements: [JobRequirement]?
    var jobQuestions: [JobQuestion]?
    var questionsResponse: [QuestionResponse]?  // اختياري لأنه قد لا يكون موجوداً في كل الحالات
    
    enum CodingKeys: String, CodingKey {
        case id
        case jobTitle = "job_title"
        case position
        case salary
        case available
        case experienceLevel = "experience_level"
        case jobDescription = "job_description"
        case categoryID = "category_id"
        case categoryName = "category_name"
        case companyID = "company_id"
        case active
        case expired
        case readDate = "read_date"
        case typeName = "type_name"
        case jobType = "job_type"
        case jobRequirements = "job_requirements"
        case jobQuestions = "job_questions"
        case questionsResponse = "questions_response"
    }
}

struct QuestionResponse: Codable {
    var id: Int?
    var questionsID: Int?
    var response: String?

    enum CodingKeys: String, CodingKey {
        case id
        case questionsID = "questions_id"
        case response
    }
}

// First level response structure
struct JobsWrapper: Codable {
    var jobs: String  // Note: This is a string containing JSON
}

// Your existing structures remain the same
struct JobsResponse: Codable {
    var jobs: [Job]
}


@MainActor
class HomeViewCompanyViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var alertMessage: String?
    @Published var showingAlert = false
    @Published var showLoadingIndicator = false
    @Published var JobResponse : JobsResponse?
    @Published var Applications:[Application]?
    @AppStorage("company_id") var company_id: String = ""
    
    private var procedureName1 = "IMfO9Vv+kGb3kJP2+Q/+2WLmSr2EulkjyPDfPgaa/xo="
    private var procedureName2 = "8etOwuUVGWXcbyLWnYnmNQy0dveJKEiD+wonV8PgGbM="

    
    func fetchData1() async {
        showLoadingIndicator = true
        alertMessage = nil
        
        let orderedParameters: [(String, Any)] = [
            ("company_id", company_id)
        ]
                
        let parameters = Dictionary(uniqueKeysWithValues: orderedParameters)
        
        do {
            let response = try await makeRequestGet(
                ProcedureName: procedureName1,
                ApiToken: ApiToken,
                dateToken: dateToken,
                parametersValues: parameters,
                orderedKeys: orderedParameters
            )
            
            if let encrypted = response as? [String: Any],
               let dataString = encrypted["Data"] as? String {
                if let decryptedData = AES256Encryption.decrypt(dataString) as? [String: Any],
                   let resultArray = decryptedData["Result"] as? [[String: Any]],
                   let firstResult = resultArray.first {

                    // تحويل البيانات إلى Data
                    let jsonData = try JSONSerialization.data(withJSONObject: firstResult)
                    let decoder = JSONDecoder()
                    
                    // فك تشفير ApplicationWrapper
                    let wrapper = try decoder.decode(ApplicationsResponse.self, from: jsonData)
                    
                    if let applications = wrapper.applications?.replacingOccurrences(of: "\\", with: "") {
                        // إزالة علامات الاقتباس في البداية والنهاية إذا وجدت
                        let cleanedString = applications.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                        
                        if let applicationData = cleanedString.data(using: .utf8) {
                            do {
                                let decodedApplications = try decoder.decode([Application].self, from: applicationData)
                                self.Applications = decodedApplications
                            } catch {
                                showingAlert = true
                                alertMessage = "Failed to fetch Data"
                            }
                        }
                    }
                }
            }
            showLoadingIndicator = false
            
        } catch {
            showingAlert = true
            showLoadingIndicator = false
            alertMessage = "Failed to fetch Data"
        }
    }
    
    func fetchData2() async {
        showLoadingIndicator = true
        alertMessage = nil
        
        let orderedParameters: [(String, Any)] = [
            ("company_id", company_id)
        ]
                
        let parameters = Dictionary(uniqueKeysWithValues: orderedParameters)
        
        do {
            let response = try await makeRequestGet(
                ProcedureName: procedureName2,
                ApiToken: ApiToken,
                dateToken: dateToken,
                parametersValues: parameters,
                orderedKeys: orderedParameters
            )
            
            if let encrypted = response as? [String: Any],
               let dataString = encrypted["Data"] as? String {
                if let decryptedData = AES256Encryption.decrypt(dataString) as? [String: Any],
                   let resultArray = decryptedData["Result"] as? [[String: Any]],
                   let firstResult = resultArray.first {
                    
                    do {
                        // First decode to get the wrapper with the JSON string
                        let jsonData = try JSONSerialization.data(withJSONObject: firstResult)
                        let decoder = JSONDecoder()
                        let wrapper = try decoder.decode(JobsWrapper.self, from: jsonData)
                        
                        // Then decode the inner JSON string to get the actual jobs array
                        if let jobsData = wrapper.jobs.data(using: .utf8) {
                            let jobsResponse = try decoder.decode([Job].self, from: jobsData)
                            self.JobResponse = JobsResponse(jobs: jobsResponse)
                            showLoadingIndicator = false
                        }
                        
                    } catch {
                        print("Decoding error:", error)
                        showLoadingIndicator = false
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


