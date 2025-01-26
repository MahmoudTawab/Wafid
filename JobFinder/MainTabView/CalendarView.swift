//
//  CalendarView.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//


import SwiftUI

// View للتقويم
struct CalendarView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // الشعار والعنوان
                HStack(spacing: 12) {
                    Image("logo_labour")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    Text( "Calendar")
                        .font(.system(size: ControlWidth(22), weight: .bold))
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Spacer()
            }
            .padding(.top , 50)
            .frame(height: UIScreen.main.bounds.height - 50)
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.light)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .frame(width: UIScreen.main.bounds.width)
    }
}
