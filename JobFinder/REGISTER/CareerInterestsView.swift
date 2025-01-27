//
//  CareerInterestsView.swift
//  Wafid
//
//  Created by almedadsoft on 27/01/2025.
//


import SwiftUI

struct CareerInterestsView: View {
    @State private var selectedCareerLevel: String? = "Student"
    @State private var selectedJobTypes: Set<String> = ["Full Time", "Part Time", "Freelance"]
    @State private var selectedWorkplaceSettings: Set<String> = ["On-site","Part Time"]
    
    let careerLevels = ["Student","Manager","Entry Level", "Experienced", "Not Specified","Senior Management"]
    let jobTypes = ["Full Time", "Part Time", "Freelance", "Shift Based", "Volunteering", "Summer Job"]
    let workplaceSettings = ["On-site", "Remote", "Hybrid"]
    
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
                        
                        Text("What is your Career Interests?")
                            .font(Font.system(size: ControlWidth(18)).weight(.heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
            
            // Career Level Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What's your current Career level ?")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                ForEach(careerLevels, id: \.self) { level in
                                    SelectableButton(
                                        title: level,
                                        isSelected: selectedCareerLevel == level,
                                        selectionType: .single,
                                        action: { selectedCareerLevel = level }
                                    )
                                }
                            }
                            .frame(height: 100) // لضبط الارتفاع الإجمالي للشبكة
                        }
                    }
            
            // Job Types Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What type(s) of job are you open to ?")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                ForEach(jobTypes, id: \.self) { jobType in
                                    SelectableButton(
                                        title: jobType,
                                        isSelected: selectedJobTypes.contains(jobType),
                                        selectionType: .multi,
                                        action: {
                                            if selectedJobTypes.contains(jobType) {
                                                selectedJobTypes.remove(jobType)
                                            } else {
                                                selectedJobTypes.insert(jobType)
                                            }
                                        }
                                    )
                                }
                            }
                            .frame(height: 100)
                        }
                    }
            
            // Workplace Settings Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What is your preferred workplace settings?")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                ForEach(workplaceSettings, id: \.self) { setting in
                                    SelectableButton(
                                        title: setting,
                                        isSelected: selectedWorkplaceSettings.contains(setting),
                                        selectionType: .multi,
                                        action: {
                                            if selectedWorkplaceSettings.contains(setting) {
                                                selectedWorkplaceSettings.remove(setting)
                                            } else {
                                                selectedWorkplaceSettings.insert(setting)
                                            }
                                        }
                                    )
                                }
                            }
                            .frame(height: 100)
                        }
                    }
            
            Spacer()
            
            Button(action: {
            navigationManager.navigate(to: .FirstScreen)
            }) {
            Text("Next")
                .font(.system(size: ControlWidth(16), weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(rgbToColor(red: 193, green: 140, blue: 70))
                .cornerRadius(15)
            }
            .padding(.bottom, 10)
        }
        .padding(.top, 50)
        .frame(height: UIScreen.main.bounds.height - 50)
        }
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.light)
        .background(rgbToColor(red: 255, green: 255, blue: 255))
        .frame(width: UIScreen.main.bounds.width)
    }
}

struct SelectableButton: View {
    let title: String
    let isSelected: Bool
    let selectionType: SelectionType
    let action: () -> Void
    
    enum SelectionType {
        case single
        case multi
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if selectionType == .multi && isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }else if selectionType == .multi && !isSelected {
                    Image(systemName: "plus.circle")
                        .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                }
                
                LocalizedText(key:title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? 
                          rgbToColor(red: 193, green: 140, blue: 70) :
                          Color.white)
            )
            .overlay(
                Capsule()
                    .stroke(rgbToColor(red: 193, green: 140, blue: 70),
                           lineWidth: isSelected ? 0 : 1)
            )
            .foregroundColor(isSelected ? .white : rgbToColor(red: 193, green: 140, blue: 70))
        }
    }
    
}

struct CareerInterestsView_Previews: PreviewProvider {
    static var previews: some View {
        CareerInterestsView()
    }
}
