//
//  CongratsScreen.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//


import SwiftUI

struct CongratsScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                
                Text("Congrats!")
                    .font(Font.system(size: ControlWidth(18)).weight(.bold))
                    .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                    .padding()
                
                Text("Your account is ready to use")
                    .font(Font.system(size: ControlWidth(16)).weight(.regular))
                    .foregroundColor(.black)
                    .padding()
                
                Spacer()
            }

            
            Button(action: {
            navigationManager.navigate(to: .MainTabView)
            }) {
                Text("Go to homepage")
                    .font(.system(size: ControlWidth(16), weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(rgbToColor(red: 193, green: 140, blue: 70))
                    .cornerRadius(15)
            }
            .padding()
            .padding(.bottom,25)

        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
    }
}
