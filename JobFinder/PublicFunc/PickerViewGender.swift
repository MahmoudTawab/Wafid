//
//  PickerViewGender.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//


import SwiftUI

struct PickerViewGender: View {
    @State private var isDropdownOpen: Bool = false
    @State private var selectedGender: String = "Male"

    let genders = ["Male", "Female"]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Gender")
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
                    Text(selectedGender.isEmpty ? "Select your gender" : selectedGender)
                        .font(Font.system(size: ControlWidth(14)))
                        .foregroundColor(selectedGender.isEmpty ? .gray : .black)
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
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(genders, id: \.self) { gender in
                                Button(action: {
                                    selectedGender = gender
                                    withAnimation {
                                        isDropdownOpen = false
                                    }
                                }) {
                                    HStack {
                                        Text(gender)
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
}

