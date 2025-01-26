//
//  LanguageSelectionView.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//


import SwiftUI
import Foundation

// 1. LocalizationService للتحكم في الترجمة
class LocalizationService {
    static let shared = LocalizationService()
    private init() {}
    
    // تخزين الترجمات
    private var localizedStrings: [String: [String: String]] = [
        "en": [:],
        "ar": [:]
    ]
    
    // تحميل ملفات الترجمة
    func loadLocalizations() {
        if let enPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let arPath = Bundle.main.path(forResource: "ar", ofType: "lproj") {
            let enBundle = Bundle(path: enPath)
            let arBundle = Bundle(path: arPath)
            
            // قم بتحميل الترجمات من Localizable.strings
            if let enDict = NSDictionary(contentsOf: enBundle?.url(forResource: "Localizable", withExtension: "strings") ?? URL(fileURLWithPath: "")) as? [String: String] {
                localizedStrings["en"] = enDict
            }
            if let arDict = NSDictionary(contentsOf: arBundle?.url(forResource: "Localizable", withExtension: "strings") ?? URL(fileURLWithPath: "")) as? [String: String] {
                localizedStrings["ar"] = arDict
            }
        }
    }
    
    func localizedString(for key: String, language: String) -> String {
        return localizedStrings[language]?[key] ?? key
    }
}

// 2. LocalizationManager المحسن
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
            setupRootView()
        }
    }
    
    private init() {
        self.currentLanguage = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first ?? "en"
        LocalizationService.shared.loadLocalizations()
    }
    
    private func setupRootView() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let mainApp = MainApp()
                .environment(\.locale, Locale(identifier: self.currentLanguage))
                .environment(\.layoutDirection, self.currentLanguage == "ar" ? .rightToLeft : .leftToRight)
            
            window.rootViewController = UIHostingController(rootView: mainApp)
            window.makeKeyAndVisible()
            
            UIView.transition(with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: nil,
                            completion: nil)
        }
    }
}

// 3. LocalizedText View للنصوص المترجمة
struct LocalizedText: View {
    let key: String
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        Text(LocalizationService.shared.localizedString(for: key, language: localizationManager.currentLanguage))
    }
}

// 4. LanguageSelectionView المحدث
struct LanguageSelectionView: View {
    @AppStorage("LanguageSelection") var LanguageSelection = "en"
    @StateObject private var localizationManager = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State var ShowingToast = false
    @State var MassegeContent = ""
    @State var TypeToast: ToastType = .error
    
    let languages = [
        ("English", "en"),
        ("العربية", "ar")
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // المحتوى الحالي
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 10) {
                        Image("Icon")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                        
                        Text("Language")
                            .font(.system(size: ControlWidth(18), weight: .heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding()
                    
                    ForEach(languages, id: \.1) { language in
                        VStack(alignment: .leading) {
                            Button(action: {
                                if LanguageSelection == language.1 {
                                    // إذا كانت اللغة المحددة هي نفس اللغة الحالية
                                    ShowingToast = true
                                    MassegeContent = LanguageSelection == "ar" ? "اللغة المحددة هي نفسها بالفعل" : "The specified language is the same"
                                    TypeToast = .error
                                } else {
                                    // تغيير اللغة
                                    localizationManager.currentLanguage = language.1
                                    LanguageSelection = language.1
                                }
                            }) {
                                HStack {
                                    // تحديد الزر المحدد بناءً على اللغة الحالية
                                    Image(LanguageSelection == language.1 ? "selected" : "NoSelected")
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(LanguageSelection == language.1 ?
                                                         Color(red: 193/255, green: 140/255, blue: 70/255) : .black)
                                        .padding()
                                    
                                    Text(language.0)
                                        .foregroundColor(.black)
                                        .font(.body)
                                }
                            }
                            
                            Rectangle()
                                .frame(height: 0.8)
                                .foregroundColor(Color(red: 235/255, green: 238/255, blue: 242/255))
                                .padding(.leading, 20)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            
            // عرض Toast Message
            AnimatedToastMessage(showingErrorMessageisValid: $ShowingToast, MassegeContent: $MassegeContent, TypeToast: TypeToast, FrameHeight: .constant(65))
                .padding(.all, 0)
        }
        .padding()
        .padding(.top, 40)
        .edgesIgnoringSafeArea(.all)
        .background(Color.white)
    }
}
