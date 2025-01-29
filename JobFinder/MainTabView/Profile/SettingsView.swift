//
//  SettingsView.swift
//  JobFinder
//
//  Created by almedadsoft on 20/01/2025.
//


import SwiftUI

struct SettingsView: View {
    @State var showingBottomSheet = false
    @AppStorage("user_id") var userId: String = ""
    @AppStorage("company_id") var company_id: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(spacing: 10) {
                        Image("Icon")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                        
                        Text("Settings")
                            .font(Font.system(size: ControlWidth(20)).weight(.heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }.padding(.bottom,20)
                    
                    Spacer(minLength: 30)
                    // Notification
                    SettingsRow(
                        icon: "Frame 1389",
                        title: "Notification"
                    ).frame(height: 60)
                    
                    Spacer(minLength: 30)
                    // Security
                    SettingsRow(
                        icon: "Frame 1390",
                        title: "Security"
                    ).frame(height: 60)
                    
                    Spacer(minLength: 30)
                    // Language
                    SettingsRow(
                        icon: "Frame 1391",
                        title: "Language"
                    ).frame(height: 60)
                    
                    Spacer(minLength: 30)
                    // Help
                    SettingsRow(
                        icon: "Frame 1392",
                        title: "Help"
                    ).frame(height: 60)
                    
                    Spacer(minLength: 30)
                    // Logout
                    Button(action: {
                        withAnimation {showingBottomSheet = true}
                    }) {
                        SettingsRow(
                            icon: "Frame 1393",
                            title: "Logout",
                            showArrow: false
                        ).frame(height: 60)
                    }
                    
                    
                    Spacer()
                }
                .background(Color.clear)
            }
            .padding(.top, 60)
            .edgesIgnoringSafeArea(.all)
            .frame(width: UIScreen.main.bounds.width - 40)
            
            NewBottomSheet(isOpen: $showingBottomSheet,IsShowIndicator: true, maxHeight: 300, minHeight: 0) {
                VStack() {
                    Image("Frame 1393")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80,height: 80)
                        .padding(.vertical)
                    
                    Text("Are you sure want to logout?")
                    .font(Font.system(size: ControlWidth(15)))
                    .foregroundColor(.black)
                    .padding(.vertical)
                    
                    Spacer()
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            withAnimation { showingBottomSheet = false }
                        }) {
                            Text("Cancel")
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
                        
                        Button(action: {
                            userId = ""
                            company_id = ""
                            setupRootView()
                            withAnimation { showingBottomSheet = false }
                        }) {
                            Text("Yes, Logout")
                                .font(.system(size: ControlWidth(16), weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(rgbToColor(red: 193, green: 140, blue: 70))
                                .cornerRadius(15)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 100)
                    .padding(.bottom,15)
                    
                }.padding(.horizontal).padding(.vertical).offset(y:-15)
                
            }

        }
        .preferredColorScheme(.light)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .frame(width: UIScreen.main.bounds.width)
    }
    
    private func setupRootView() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let mainApp = MainApp()
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

struct SettingsRow: View {
    let icon: String
    let title: String
    var showArrow: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    Image(icon)
                        .font(.system(size: ControlWidth(20)))
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                    
                    Text(title)
                        .foregroundColor(.black.opacity(0.8))
                        .font(.system(size: ControlWidth(16),weight: .regular))
                    
                    Spacer()
                    
                    if showArrow {
                        Image(systemName: "chevron.right")
                            .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                            .font(.system(size: ControlWidth(16)))
                    }
                }.offset(y:-10)
                
                
                if showArrow {
                    Rectangle()
                        .frame(height: 0.2)
                        .background(.gray.opacity(0.1))
                }
            }
        }
        .padding(.vertical)
        .background(Color.white)
        .cornerRadius(12)

    }
}
