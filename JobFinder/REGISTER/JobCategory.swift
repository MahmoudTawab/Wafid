//
//  JobCategory.swift
//  Wafid
//
//  Created by almedadsoft on 27/01/2025.
//


import SwiftUI

struct JobCategory: Identifiable {
    let id = UUID()
    let titleKey: String  // مفتاح الترجمة بدلاً من النص المباشر
    let icon: String
    var isSelected: Bool = false
}

struct JobSelectionView: View {
    @State private var jobCategories = [
        JobCategory(titleKey: "Content Writer", icon: "Group 1387"),
        JobCategory(titleKey: "Art & Design", icon: "Group 1380"),
        JobCategory(titleKey: "Human Resources", icon: "Group 1381"),
        JobCategory(titleKey: "Programmer", icon: "Group 1382"),
        JobCategory(titleKey: "Finance", icon: "Group 1383"),
        JobCategory(titleKey: "Customer Service", icon: "Group 1384"),
        JobCategory(titleKey: "Food & Restaurant", icon: "Group 1385"),
        JobCategory(titleKey: "Music Producer", icon: "Group 1386")
    ]
    
    @State private var selectedCount = 0
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack(spacing: 10) {
                        Image("Icon")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .onTapGesture {self.presentationMode.wrappedValue.dismiss()}
                        
                        Text("What job you want?")
                            .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    Text("Choose 3-5 job categories and we’ll optimize the jop vacancy for you.")
                        .font(Font.system(size: ControlWidth(13)).weight(.regular))
                        .frame(height: 60)
                        .foregroundColor(.black.opacity(0.8))
                    
                    // Grid of job categories
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(jobCategories.indices, id: \.self) { index in
                            JobCategoryCard(
                                category: $jobCategories[index],
                                selectedCount: $selectedCount
                            )
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        navigationManager.navigate(to: .CareerInterestsView)
                    }) {
                        Text("Next")
                            .font(.system(size: ControlWidth(16), weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(rgbToColor(red: 193, green: 140, blue: 70))
                            .cornerRadius(15)
                    }
                    .opacity(selectedCount > 0 ? 1 : 0.6)
                    .disabled(selectedCount < 0)
                    .padding(.bottom, 30)
                }
                .padding(.top, 50)
                .frame(height: UIScreen.main.bounds.height - 30)
            }
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.light)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .frame(width: UIScreen.main.bounds.width)
    }
}

struct JobCategoryCard: View {
    @Binding var category: JobCategory
    @Binding var selectedCount: Int
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        Button(action: {
            if !category.isSelected && selectedCount < 5 {
                category.isSelected.toggle()
                selectedCount += 1
            } else if category.isSelected {
                category.isSelected.toggle()
                selectedCount -= 1
            }
        }) {
            VStack(spacing: 12) {
                Circle()
                    .fill(Color(UIColor(red: 0.98, green: 0.95, blue: 0.92, alpha: 1)))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(category.icon)
                            .foregroundColor(Color(UIColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)))
                    )
                
                LocalizedText(key: category.titleKey)
                    .lineLimit(1)
                    .font(Font.system(size: ControlWidth(12)))
                    .foregroundColor(.black)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.isSelected ?
                           Color(UIColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)) :
                           Color.gray.opacity(0.2))
            )
        }
    }
}

struct JobSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        JobSelectionView()
    }
}
