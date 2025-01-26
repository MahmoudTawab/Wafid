//
//  PaymentMethod.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//

import SwiftUI

// نموذج بيانات طريقة الدفع
struct PaymentMethod: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct PaymentMethodView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedMethod: String = "PayPal"
    @State private var selectedImage: String = "paypal_logo"
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: NavigationManager

    let paymentMethods = [
        PaymentMethod(name: "PayPal", imageName: "paypal_logo"),
        PaymentMethod(name: "Master Card", imageName: "mastercard_logo"),
        PaymentMethod(name: "Visa Card", imageName: "visa_logo"),
        PaymentMethod(name: "ApplePay", imageName: "applepay_logo")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
            
            HStack(spacing: 10) {
                Image("Icon")
                    .resizable()
                    .frame(width: 30,height: 30)
                    .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                
                Text("subscription")
                    .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your Payment Method")
                    .font(.system(size: ControlWidth(20), weight: .bold))
            }
            .padding(.vertical,20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Payment Methods List
            VStack(spacing: 25) {
                ForEach(paymentMethods) { method in
                    PaymentMethodRow(
                        name: method.name,
                        imageName: method.imageName,
                        isSelected: selectedMethod == method.name
                    ) {
                        withAnimation {
                            selectedMethod = method.name
                            selectedImage = method.imageName
                        }
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                navigationManager.navigate(to: .CreditCardFormView(Icon: selectedImage, Card: selectedMethod))
            }) {
                Text("Continue")
                    .font(.system(size: ControlWidth(16), weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(rgbToColor(red: 193, green: 140, blue: 70))
                    .cornerRadius(15)
            }
                
        }
        
        .padding(.top,60)
        .frame(height: UIScreen.main.bounds.height - 60)
        }
        .padding()
        .preferredColorScheme(.light)
        .edgesIgnoringSafeArea(.all)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

struct PaymentMethodRow: View {
    let name: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.76, green: 0.55, blue: 0.27) : Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.76, green: 0.55, blue: 0.27))
                            .frame(width: 16, height: 16)
                    }
                }
                
                Text(name)
                    .font(.system(size: ControlWidth(16)))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Payment Method Logo
                Image(imageName)
                    .scaledToFit()
                    .frame(height: 10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
    }
}
