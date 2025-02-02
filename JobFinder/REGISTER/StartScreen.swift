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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigationManager.navigate(to: user_id != "" ? .MainTabView : .FirstScreen)
            }
            
        }
    }
    
    
    
}


#Preview {
    StartScreen()
}
