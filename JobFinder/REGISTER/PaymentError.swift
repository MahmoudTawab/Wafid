//
//  PaymentError.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//


import SwiftUI

struct PaymentError: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .center, spacing: 20) {
                
                HStack(spacing: 10) {
                    Image("Icon")
                        .resizable()
                        .frame(width: 30,height: 30)
                        .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                    
                    Text("Payment")
                        .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                        .foregroundColor(.black)
                    
                    Spacer()
                }.padding()
                
                VStack {
                    Spacer()
                    Image("Error")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                        .padding(.bottom,20)
                    
                    Text("We couldn't proceed your payment")
                        .font(Font.system(size: ControlWidth(18)).weight(.bold))
                        .foregroundColor(.black.opacity(0.8))
                    
                    Text("your payment")
                        .font(Font.system(size: ControlWidth(18)).weight(.bold))
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.bottom,10)
                    
                    Text("Please, change your payment method or try again")
                        .font(Font.system(size: ControlWidth(12)).weight(.regular))
                        .foregroundColor(rgbToColor(red: 154, green: 154, blue: 154))
                        .padding()
                    
                    Spacer()
                }
                
                
                VStack(spacing: 20) {
                    
                    Button(action: {
                        // Action for Try Again
                    }) {
                        Text("Try Again")
                            .font(.system(size: ControlWidth(16), weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(rgbToColor(red: 193, green: 140, blue: 70))
                            .cornerRadius(15)
                    }
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Change")
                            .font(.system(size: ControlWidth(16), weight: .bold))
                            .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(rgbToColor(red: 255, green: 255, blue: 255))
                            .cornerRadius(15)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 1)
                    )
                }
                .padding()
                .padding(.bottom,40)
            }
        }
        .padding(.top,60)
        .edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
    }
}
