//
//  MainTabView.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @AppStorage("IsEmployee") var IsEmployee: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                BriefcaseView()
                    .tag(1)
                
                CalendarView()
                    .tag(2)
                
                RequestsView()
                    .tag(3)
                
                if IsEmployee {
                    ProfileEmployeeView()
                        .tag(4)
                }else{
                    ProfileCompanyView()
                        .tag(4)
                }
            }
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.light)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs: [(image: String, title: String)] = [
        ("Home", "Home"),
        ("Work", "Work"),
        ("Calendar", "Calendar"),
        ("Wallet", "Wallet"),
        ("Profile", "Profile")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                VStack(spacing: 4) {
                    Image(tabs[index].image)
                        .renderingMode(.template)
                        .foregroundColor(selectedTab == index ?
                            rgbToColor(red: 193, green: 140, blue: 70) :
                            rgbToColor(red: 202, green: 203, blue: 206))
                    
                    Circle()
                        .fill(rgbToColor(red: 193, green: 140, blue: 70))
                        .frame(width: 6, height: 6)
                        .opacity(selectedTab == index ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        )
    }
}
