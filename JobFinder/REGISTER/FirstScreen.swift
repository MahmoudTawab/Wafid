//
//  FirstScreen.swift
//  JobFinder
//
//  Created by almedadsoft on 12/01/2025.
//

import SwiftUI

struct FirstScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.width - 60)
                Spacer()
            }

            VStack(spacing: -3) {
                Text("The Best Portal job of this century")
                    .font(Font.system(size: ControlWidth(16)).weight(.regular))
                    .foregroundColor(.black)
                    .padding()

                Button(action: {
                    navigationManager.navigate(to: .LanguageSelectionView)
                }) {
                    Text("Language")
                        .font(.system(size: ControlWidth(16), weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(rgbToColor(red: 193, green: 140, blue: 70))
                        .cornerRadius(15)
                }
                .padding()

                Button(action: {
                    navigationManager.navigate(to: .LoginScreen)
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
            }
            .padding()
            .padding(.bottom,15)

        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
    }
}
