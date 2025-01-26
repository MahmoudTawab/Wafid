//
//  CreditCardFormView.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//


import SwiftUI

struct CreditCardFormView: View {
    
    // Properties to receive from previous view
    var cardIcon: String?
    var CardName: String?
    @State private var cardNumber: String = ""
    @State private var name: String = ""
    @State private var expirationDate: String = ""
    @State private var cvv: String = ""
    @State private var errors: [String: String] = [:]
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: NavigationManager
    @AppStorage("LanguageSelection") var LanguageSelection = "en"
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
            
            HStack(spacing: 10) {
                Image("Icon")
                    .resizable()
                    .frame(width: 30,height: 30)
                    .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                
                Text("Payment")
                    .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(CardName ?? "Card")
                    .font(.system(size: ControlWidth(20), weight: .bold))
            }
            .padding(.vertical,5)
            .frame(maxWidth: .infinity, alignment: .leading)
                
                // Credit Card View with binding
                CreditCardView(
                    cardNumber: cardNumber,
                    cardHolder: name,
                    expirationDate: expirationDate,
                    cvv: cvv,
                    cardIcon: cardIcon
                )
                .frame(height: 200)
                .padding(.vertical, 15)
                
                // Form Fields with validation
                VStack(alignment: .leading, spacing: 20) {
                    FormField(
                        title: "Card Number",
                        value: $cardNumber,
                        placeholder: "1234 5678 1234 5678",
                        required: true,
                        KeyboardType: .numberPad,
                        error: errors["cardNumber"]
                    )
                    .onChange(of: cardNumber) { newValue in
                           // Format card number with spaces every 4 digits
                           let filtered = newValue.filter { $0.isNumber }
                           let segments = stride(from: 0, to: filtered.count, by: 4).map {
                               let start = filtered.index(filtered.startIndex, offsetBy: $0)
                               let end = filtered.index(start, offsetBy: min(4, filtered.count - $0))
                               return String(filtered[start..<end])
                           }
                           cardNumber = segments.joined(separator: " ")
                           
                           // Limit to 16 digits plus spaces
                           if filtered.count > 16 {
                               cardNumber = String(filtered.prefix(16))
                               let segments = stride(from: 0, to: 16, by: 4).map {
                                   let start = filtered.index(filtered.startIndex, offsetBy: $0)
                                   let end = filtered.index(start, offsetBy: 4)
                                   return String(filtered[start..<end])
                               }
                               cardNumber = segments.joined(separator: " ")
                           }
                       }
                    
                    FormField(
                        title: "Name",
                        value: $name,
                        placeholder: "Name",
                        required: true,
                        KeyboardType: .default,
                        error: errors["name"]
                    )
                    .onChange(of: cvv) { newValue in
                              // Limit CVV to 3 digits
                              let filtered = newValue.filter { $0.isNumber }
                              cvv = String(filtered.prefix(50))
                    }
                    
                    HStack(spacing: 16) {
                        FormField(
                            title: "Expiration Date",
                            value: $expirationDate,
                            placeholder: "MM/YY",
                            required: true,
                            KeyboardType: .numberPad,
                            error: errors["expirationDate"]
                        )
                        .onChange(of: expirationDate) { newValue in
                            // السماح فقط بالأرقام وتنسيق المدخلات
                            let filtered = newValue.filter { $0.isNumber }
                            
                            // تحديد أقصى عدد للأرقام بـ 4
                            if filtered.count > 4 {
                                expirationDate = String(filtered.prefix(4))
                            } else {
                                var formatted = filtered
                                
                                // إضافة "/" بعد الشهر
                                if filtered.count > 2 {
                                    formatted.insert("/", at: filtered.index(filtered.startIndex, offsetBy: 2))
                                }
                                
                                expirationDate = formatted
                            }
                        }
                        
                        FormField(
                            title: "CVV",
                            value: $cvv,
                            placeholder: "123",
                            required: true,
                            KeyboardType: .numberPad,
                            error: errors["cvv"]
                        )
                        .onChange(of: cvv) { newValue in
                                  // Limit CVV to 3 digits
                                  let filtered = newValue.filter { $0.isNumber }
                                  cvv = String(filtered.prefix(3))
                        }
                    }
                }
                
                Spacer()
                
                // Continue Button with validation
                Button(action: {
                    if validateForm() {
                        navigationManager.navigate(to: .PaymentSuccessful)
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: ControlWidth(16), weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.76, green: 0.55, blue: 0.27))
                        .cornerRadius(12)
                }
                .padding(.top, 25)
                .padding(.bottom, 15)
            }
            
            .padding(.top,40)
            .frame(height: UIScreen.main.bounds.height - 40)
            }
            .keyboardSpace()
            .padding()
            .preferredColorScheme(.light)
            .edgesIgnoringSafeArea(.all)
            .background(rgbToColor(red: 255, green: 255, blue: 255))
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
            .onTapGesture {
            hideKeyboard()
            }
            }
    
    // إخفاء لوحة المفاتيح
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
    
    
    // Validation functions
    private func validateCardNumber(_ number: String) -> Bool {
        let filtered = number.filter { $0.isNumber }
        return filtered.count == 16
    }
    
    private func validateName(_ name: String) -> Bool {
        return name.count >= 3
    }
    
    private func validateExpirationDate(_ date: String) -> Bool {
        let filtered = date.filter { $0.isNumber }
        guard filtered.count == 4 else { return false }
        
        let month = Int(filtered.prefix(2)) ?? 0
        let year = Int("20" + filtered.suffix(2)) ?? 0
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        if year < currentYear {
            return false
        } else if year == currentYear && month < currentMonth {
            return false
        }
        
        return month >= 1 && month <= 12
    }
    
    private func validateCVV(_ cvv: String) -> Bool {
        let filtered = cvv.filter { $0.isNumber }
        return filtered.count == 3
    }
    
    private func validateForm() -> Bool {
        errors = [:]
        
        if !validateCardNumber(cardNumber) {
            errors["cardNumber"] = LanguageSelection == "ar" ? "يجب إدخال 16 رقم" : "You must enter 16 digits"
        }
        
        if !validateName(name) {
            errors["name"] = LanguageSelection == "ar" ?  "يجب إدخال اسم صحيح" : "You must enter a valid name"
        }
        
        if !validateExpirationDate(expirationDate) {
            errors["expirationDate"] = LanguageSelection == "ar" ? "تاريخ غير صالح" : "Invalid date"
        }
        
        if !validateCVV(cvv) {
            errors["cvv"] = LanguageSelection == "ar" ? "يجب إدخال 3 أرقام" : "You must enter 3 numbers"
        }
        
        return errors.isEmpty
    }
    
}

struct CreditCardView: View {
    let cardNumber: String
    let cardHolder: String
    let expirationDate: String
    let cvv: String
    var cardIcon: String?
    
    var body: some View {
        ZStack {
            Image("Frame 1")
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Credit")
                        .foregroundColor(.white)
                        .font(.system(size: ControlWidth(16)))
                    
                    Spacer()
                    
                    Image(cardIcon ?? "")
                        .foregroundColor(.white)
                }
                               
                               Text(cardNumber.isEmpty ? "1234 5678 1234 5678" : cardNumber)
                                   .foregroundColor(.white)
                                   .font(.system(size: ControlWidth(18), weight: .medium))
                                   .kerning(2)
                               
                               HStack {
                                   VStack(alignment: .leading, spacing: 4) {
                                       Text("Card Holder")
                                           .font(.system(size: ControlWidth(12)))
                                           .foregroundColor(.white.opacity(0.8))
                                       Text(cardHolder.isEmpty ? "Card Name" : cardHolder)
                                           .foregroundColor(.white)
                                   }
                                   
                                   Spacer()
                                   
                                   VStack(alignment: .leading, spacing: 4) {
                                       Text("Expires")
                                           .font(.system(size: ControlWidth(12)))
                                           .foregroundColor(.white.opacity(0.8))
                                       Text(expirationDate.isEmpty ? "07/29" : expirationDate)
                                           .foregroundColor(.white)
                                   }
                                   
                                   Spacer()
                                   
                                   VStack(alignment: .leading, spacing: 4) {
                                       Text("CVV")
                                           .font(.system(size: ControlWidth(12)))
                                           .foregroundColor(.white.opacity(0.8))
                                       Text(cvv.isEmpty ? "215" : cvv)
                                           .foregroundColor(.white)
                                   }
                               }
                           }
                           .padding(24)
                       }
                       .cornerRadius(16)
                       .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                   }
               }

// FormFieldViewModel للتحكم في حالة الحقل
class FormFieldViewModel: ObservableObject {
    @Published var shouldUpdate = false
    
    func updateView() {
        shouldUpdate.toggle()
    }
}

struct FormField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let required: Bool
    let KeyboardType: UIKeyboardType
    var error: String?
    @AppStorage("LanguageSelection") var LanguageSelection = "en"
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var viewModel = FormFieldViewModel()
    
    // إضافة computed properties للترجمة
    private var localizedTitle: String {
        LocalizationService.shared.localizedString(for: title, language: LanguageSelection)
    }
    
    private var localizedPlaceholder: String {
        LocalizationService.shared.localizedString(for: placeholder, language: LanguageSelection)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 4) {
                Text(localizedTitle)
                    .font(.system(size: ControlWidth(14)))
                    .foregroundColor(.black.opacity(0.8))
                if required {
                    Text("*")
                        .foregroundColor(.red)
                }
            }
            
            TextField(localizedPlaceholder, text: $value)
                .padding()
                .keyboardType(KeyboardType)
                .tint(rgbToColor(red: 193, green: 140, blue: 70))
                .background(rgbToColor(red: 255, green: 255, blue: 255))
                .frame(height: 50)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(error != nil ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 3, y: 4)
            
            if let error = error {
                Text(error)
                    .font(.system(size: ControlWidth(12)))
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            } else {
                Spacer()
            }
        }
        .id(viewModel.shouldUpdate) // إضافة معرف فريد يتغير عند تحديث اللغة
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            viewModel.updateView()
        }
    }
}
