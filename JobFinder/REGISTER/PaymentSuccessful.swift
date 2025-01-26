//
//  Payment Successful.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//


import SwiftUI

struct PaymentSuccessful: View {
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
                
                Spacer()
                Image("Successful")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                
                Text("Payment Successful")
                    .font(Font.system(size: ControlWidth(18)).weight(.bold))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.top,10)
                    .padding()
                
                Text("Thank you for your purchase.")
                    .font(Font.system(size: ControlWidth(12)).weight(.regular))
                    .foregroundColor(rgbToColor(red: 154, green: 154, blue: 154))
                    .padding()
                
                Spacer()
            }

            
            Button(action: {
            navigationManager.navigate(to: .MainTabView)
            }) {
                Text("Continue")
                    .font(.system(size: ControlWidth(16), weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(rgbToColor(red: 193, green: 140, blue: 70))
                    .cornerRadius(15)
            }
            .padding()
            .padding(.bottom,40)

        }
        .padding(.top,60)
        .edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
    }
}
