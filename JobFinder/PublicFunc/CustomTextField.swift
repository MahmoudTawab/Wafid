//
//  CustomTextField.swift
//  JobFinder
//
//  Created by almedadsoft on 12/01/2025.
//

import SwiftUI

enum TextFieldType {
    case email
    case password
    case Confirminvalid
    case phone
    case text
    case passport
    case date
}

// إضافة نوع الخطأ الجديد
enum TextFieldError {
    case empty
    case invalidEmail
    case invalidPassword
    case ConfirminvalidPassword
    case invalidPhone
    case invalidPassport
    case invalidDate
    case none
    
    var message: String {
        @AppStorage("LanguageSelection") var LanguageSelection = "en"

        switch self {
        case .empty:
            return LanguageSelection == "ar" ? "الرجاء إدخال قيمة" : "Please enter a value"
        case .invalidEmail:
            return LanguageSelection == "ar" ? "البريد الإلكتروني غير صحيح" : "Invalid email"
        case .invalidPassword:
            return LanguageSelection == "ar" ? "كلمة المرور يجب أن تكون ٦ أحرف على الأقل" : "Password must be at least 6 characters"
        case .ConfirminvalidPassword:
            return LanguageSelection == "ar" ? "كلمة المرور غير متطابقة": "Password does not match"
        case .invalidPhone:
            return LanguageSelection == "ar" ? "رقم الهاتف غير صحيح" : "Invalid phone number"
        case .invalidPassport:
            return LanguageSelection == "ar" ? "رقم الجواز غير صحيح" : "Invalid passport number"
        case .invalidDate:
            return LanguageSelection == "ar" ? "التاريخ غير صحيح" : "Invalid date"
        case .none:
            return ""
        }
    }
}


class CustomTextFieldViewModel: ObservableObject {
    @Published var shouldUpdate = false
    
    func updateView() {
        shouldUpdate.toggle()
    }
}

struct TextFieldCustom: View, Equatable {
    static func == (lhs: TextFieldCustom, rhs: TextFieldCustom) -> Bool {
        return lhs.state.text == rhs.state.text && lhs.state.error == rhs.state.error
    }
    
    // MARK: - Properties
    @StateObject var state = TextFieldState()
    @Binding var defaultText : String 
    var IsShowImage: Bool = true
    var title: String
    var placeholder: String
    let isRequired: Bool
    let type: TextFieldType
    var IsShowCountry: Bool = true
    var passwordToMatch: String? = nil  // نضيف هذه الخاصية
    @FocusState private var isFocused: Bool
    
    var TextFieldPost: (_ text: String, _ error: TextFieldError) -> Void
    
    // MARK: - Localization
    @AppStorage("LanguageSelection") var LanguageSelection = "en"
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var viewModel = CustomTextFieldViewModel()
    
    // MARK: - Phone Number
    private let phoneNumberKit = PhoneNumberUtility()
    @State private var isShowingCountryPicker = false
    @State private var selectedCountry: Country = Country(name: "Libya", code: "LY", phoneCode: "+218")
    
    // MARK: - Date Picker
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    // MARK: - Debouncing
    @State private var debouncedTask: DispatchWorkItem?
    
    // MARK: - Computed Properties
    private var localizedTitle: String {
        LocalizationService.shared.localizedString(for: title, language: LanguageSelection)
    }
    
    private var localizedPlaceholder: String {
        LocalizationService.shared.localizedString(for: placeholder, language: LanguageSelection)
    }
    
    private var leadingIcon: String {
        switch type {
        case .email: return "sms"
        case .password: return "lock"
        case .Confirminvalid: return "lock"
        case .phone: return "call-calling"
        case .text: return "user"
        case .passport: return "passport"
        case .date: return "calendar"
        }
    }
    
    private var trailingIcon: String {
        return state.showPassword ? "eye" : "eye.slash"
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title with required indicator
            HStack {
                Text(localizedTitle)
                    .font(Font.system(size: ControlWidth(12)))
                    .foregroundColor(.black.opacity(0.8))
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
            }
            
            // Main TextField Container
            HStack {
                buildTextField()
                buildTrailingIcon()
            }
            .padding()
            .background(rgbToColor(red: 255, green: 255, blue: 255))
            .frame(height: 50)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(state.text == "" ? Color.gray.opacity(0.3) :
                           state.error != .none ? Color.red :
                           rgbToColor(red: 193, green: 140, blue: 70),
                           lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 15, x: 3, y: 4)
            
            // Error message
            if state.error != .none {
                HStack {
                    Image("Alert-circle")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text(LocalizationService.shared.localizedString(for: state.error.message, language: LanguageSelection))
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 40)
        .id(viewModel.shouldUpdate)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            viewModel.updateView()
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate, text: $state.text, dateFormatter: dateFormatter)
        }
        .sheet(isPresented: $isShowingCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
        
        .onChange(of: state.text) { newValue in
             debouncedTask?.cancel()
             let task = DispatchWorkItem {
                 if type == .Confirminvalid {
                     // نتحقق فقط عندما يتوقف المستخدم عن الكتابة
                     validateAndUpdate(newValue)
                 } else {
                     // للحقول الأخرى، نتحقق مباشرة
                     if IsShowCountry {
                         validateAndUpdate(newValue)
                     }
                 }
             }
             debouncedTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: task)
         }
        
        .onChange(of: defaultText) { newValue in
            state.text = newValue
        }
    }
    
    // MARK: - Helper Views
    @ViewBuilder
    private func buildTextField() -> some View {
        Group {
            switch type {
            case .password, .Confirminvalid:
                buildSecureField()
            case .date:
                buildDateField()
            case .phone:
                buildPhoneField()
            default:
                buildDefaultField()
            }
        }
    }
    
    @ViewBuilder
    private func buildSecureField() -> some View {
        Group {
            if state.showPassword {
                TextField(localizedPlaceholder, text: $state.text)
                    .applyTextFieldStyle(isFocused: $isFocused)
            } else {
                SecureField(localizedPlaceholder, text: $state.text)
                    .applyTextFieldStyle(isFocused: $isFocused)
            }
        }
    }
    
    @ViewBuilder
    private func buildDateField() -> some View {
        ZStack {
            TextField(localizedPlaceholder, text: $state.text)
                .applyTextFieldStyle(isFocused: $isFocused)
                .disabled(true)
            
            Rectangle()
                .foregroundColor(rgbToColor(red: 255, green: 255, blue: 255).opacity(0.1))
                .frame(width: UIScreen.main.bounds.width - 100, height: 30)
                .onTapGesture {
                    showDatePicker = true
                }
        }
    }
    
    @ViewBuilder
    private func buildPhoneField() -> some View {
        HStack {
            if IsShowCountry {
                Button(action: { isShowingCountryPicker = true }) {
                    HStack {
                        Text(selectedCountry.flag)
                            .foregroundColor(.black)
                            .font(Font.system(size: ControlWidth(10)))
                        Text(selectedCountry.phoneCode)
                            .foregroundColor(.black)
                            .font(Font.system(size: ControlWidth(10)))
                        Image(systemName: "chevron.down")
                            .foregroundColor(.black)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                    .background(Color.clear)
                    .cornerRadius(8)
                }
            }
            
            TextField(localizedPlaceholder, text: $state.text)
                .applyTextFieldStyle(isFocused: $isFocused)
                .keyboardType(.phonePad)
        }
    }
    
    @ViewBuilder
    private func buildDefaultField() -> some View {
        TextField(localizedPlaceholder, text: $state.text)
            .applyTextFieldStyle(isFocused: $isFocused)
            .keyboardType(getKeyboardType())
    }
    
    @ViewBuilder
    private func buildTrailingIcon() -> some View {
        if type == .password || type == .Confirminvalid {
            Button(action: {
                let focused = isFocused
                state.showPassword.toggle()
                DispatchQueue.main.async {
                    isFocused = focused
                }
            }) {
                Image(systemName: trailingIcon)
                    .foregroundColor(.black.opacity(0.8))
                    .frame(width: 20)
            }
            .simultaneousGesture(TapGesture().onEnded {
                isFocused = true
            })
        } else if IsShowImage {
            Image(leadingIcon)
                .foregroundColor(.gray)
                .frame(width: 18)
        }
    }
    
    // MARK: - Helper Methods
    private func validateAndUpdate(_ value: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let newError = validateInput(value)
            DispatchQueue.main.async {
                withAnimation {state.error = newError}
                if IsShowCountry {
                    TextFieldPost(value, newError)
                }
            }
        }
    }
    
    private func validateInput(_ value: String) -> TextFieldError {
        if value.isEmpty && isRequired {
            return .empty
        }
        
        switch type {
        case .email:
            return isValidEmail(value) ? .none : .invalidEmail
        case .password:
            return value.count >= 6 ? .none : .invalidPassword
        case .Confirminvalid:
            if let password = passwordToMatch {
                return value == password ? .none : .ConfirminvalidPassword
            }
            return .none
        case .phone:
            let fullNumber = selectedCountry.phoneCode + value
            do {
                _ = try phoneNumberKit.parse(fullNumber)
                return .none
            } catch {
                return .invalidPhone
            }
        case .passport:
            return isValidPassport(value) ? .none : .invalidPassport
        case .date:
            return dateFormatter.date(from: value) != nil ? .none : .invalidDate
        case .text:
            return .none
        }
    }
    
    private func getKeyboardType() -> UIKeyboardType {
        switch type {
        case .email: return .emailAddress
        case .phone: return .phonePad
        case .passport: return .phonePad
        case .date: return .asciiCapable
        case .Confirminvalid, .password, .text: return .default
        }
    }
    
}

// MARK: - TextFieldState
class TextFieldState: ObservableObject {
    @Published var text: String = ""
    @Published var error: TextFieldError = .none
    @Published var showPassword: Bool = false
}

// MARK: - TextField Style
extension View {
    func applyTextFieldStyle(isFocused: FocusState<Bool>.Binding) -> some View {
        self
            .font(Font.system(size: ControlWidth(14)))
            .foregroundColor(.gray)
            .focused(isFocused)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.none)
            .tint(rgbToColor(red: 193, green: 140, blue: 70))
    }
}



// مكون منفصل لعرض التقويم
struct DatePickerSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedDate: Date
    @Binding var text: String
    let dateFormatter: DateFormatter
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(rgbToColor(red: 193, green: 140, blue: 70))
                .padding()
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarItems(
                trailing : Button("Done") {
                    text = dateFormatter.string(from: selectedDate)
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
            )
            
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
            )
        }
    }
}
