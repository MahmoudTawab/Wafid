//
//  StartScreen.swift
//  JobFinder
//
//  Created by almedadsoft on 12/01/2025.
//

import SwiftUI

struct StartScreen: View {
    @State private var isLogoVisible = false
    @AppStorage("user_id") var user_id: String = ""
    @StateObject var viewModel = ChatListViewModel()
    @State private var showingBottomSheet: Bool = false
    @AppStorage("IsEmployee") var IsEmployee: Bool = true
    @AppStorage("company_id") var company_id: String = ""
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.width - 60)
                    .opacity(isLogoVisible ? 1 : 0) // ظهور تدريجي
                Spacer()
            }
            
            VStack(spacing: -5) {
        
                Text("صندوق تنمية الموارد البشرية")
                    .font(Font.system(size: ControlWidth(12)).weight(.heavy))
                    .foregroundColor(.black)
                
                Text("© 2024 All Rights Reserved Powered by @ Almedad soft")
                    .font(Font.system(size: ControlWidth(10)).weight(.heavy))
                    .foregroundColor(.black)
                    .padding()
                    .padding(.bottom, 10)
            }

            if user_id == "" {
                NewBottomSheet(isOpen: $showingBottomSheet,IsShowIndicator: true, maxHeight: 330, minHeight: 330) {
                    VStack() {
                        Image("user-tag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50,height: 50)
                            .padding(.top , 20)
                        
                        Text("What are you looking for?")
                        .font(Font.system(size: ControlWidth(13)))
                        .foregroundColor(.black)
                        .padding(.vertical)
                        .padding(.bottom , 25)
                        
                        HStack(spacing: 30) {
                            Button(action: {
                                IsEmployee = true
                                navigationManager.navigate(to: user_id == "" ? .JobSelectionView : .MainTabView)
                                withAnimation { showingBottomSheet = false }
                            }) {
                                VStack(spacing: -10) {
                                    Image("Group 1379")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50,height: 50)
                                        .padding(.vertical)
                                    
                                    Text("I want a job")
                                        .font(.system(size: ControlWidth(12)))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(rgbToColor(red: 255, green: 255, blue: 255))
                                        .cornerRadius(15)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(!IsEmployee ? rgbToColor(red: 233, green: 233, blue: 233) : rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 1)
                            )
                            
                            Button(action: {
                                IsEmployee = false
                                navigationManager.navigate(to: user_id == "" ? .FirstScreen : .MainTabView)
                                withAnimation { showingBottomSheet = false }
                            }) {
                                VStack(spacing: -10) {
                                    Image("Group 1378")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50,height: 50)
                                        .padding(.vertical)
                                    
                                    Text("I want an employee")
                                        .font(.system(size: ControlWidth(12)))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(rgbToColor(red: 255, green: 255, blue: 255))
                                        .cornerRadius(20)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(IsEmployee ? rgbToColor(red: 233, green: 233, blue: 233) : rgbToColor(red: 193, green: 140, blue: 70), lineWidth: 1)
                            )
                        }
                        .frame(width: UIScreen.main.bounds.width - 40,height: 80)
                        .padding(.bottom,20)
                        
                    }.padding(.horizontal).padding(.vertical).offset(y:-10)
                    
                }
            }
        }
        .preferredColorScheme(.light)
        .edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .onAppear {
            
            viewModel.onlineStatusService.setupPresence(userId: IsEmployee ? user_id : company_id)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {isLogoVisible = true}
            }
            
            if user_id != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigationManager.navigate(to: .MainTabView)
            }
            }else{
            withAnimation {showingBottomSheet = true}
            }
            
        }
    }
    
    
    
}


#Preview {
    StartScreen()
}
