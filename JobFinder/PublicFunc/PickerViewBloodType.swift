//
//  PickerViewBloodType.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//

import SwiftUI

struct PickerViewBloodType: View {
    @Binding var selectedBloodType: String // تم تعديل هذا السطر
    @State private var searchText: String = ""
    @State private var isDropdownOpen: Bool = false
    
    let bloodTypes = ["O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"]

    var filteredBloodTypes: [String] {
        if searchText.isEmpty {
            return bloodTypes
        } else {
            return bloodTypes.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Blood Type")
                    .font(Font.system(size: ControlWidth(14)))
                    .foregroundColor(.black.opacity(0.8))

                Text("*")
                    .foregroundColor(.red)
                
                Spacer()
            }
            .padding(.bottom, 2)

            Button(action: {
                withAnimation {
                    isDropdownOpen.toggle()
                }
            }) {
                HStack {
                    Text(selectedBloodType.isEmpty ? "Select your blood type" : selectedBloodType)
                        .font(Font.system(size: ControlWidth(14)))
                        .foregroundColor(selectedBloodType.isEmpty ? .gray : .black)
                        .padding(.leading, 15)
                    Spacer()
                    Image(systemName: isDropdownOpen ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .padding(.trailing, 15)
                }
                .background(Color.clear)
                .frame(height: 50)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 3, y: 4)
            }
            
            // Dropdown Menu
            if isDropdownOpen {
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        TextField("Search", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .padding(.bottom, 4)
                    
                    // List of Filtered Blood Types
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredBloodTypes, id: \.self) { bloodType in
                                Button(action: {
                                    selectedBloodType = bloodType
                                    withAnimation {
                                        isDropdownOpen = false
                                    }
                                }) {
                                    HStack {
                                        Text(bloodType)
                                            .foregroundColor(.black)
                                            .padding(.vertical, 8)
                                            .padding(.leading, 8)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(Color.clear)
                                }
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: calculateHeight())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                            .background(Color.white)
                    )
                }
                .padding(.top, 4)
            }
        }
    }
    
    // Function to calculate height dynamically
    func calculateHeight() -> CGFloat {
        let itemHeight: CGFloat = 44 // Approximate height of each item
        let maxVisibleItems = 5      // Maximum visible items
        let totalHeight = CGFloat(filteredBloodTypes.count) * itemHeight
        return min(totalHeight, itemHeight * CGFloat(maxVisibleItems))
    }
}
