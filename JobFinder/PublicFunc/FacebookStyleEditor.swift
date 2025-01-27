//
//  FacebookStyleEditor.swift
//  Wafid
//
//  Created by almedadsoft on 27/01/2025.
//


import SwiftUI

struct FacebookStyleEditor: View {
    @State var placeholder: String = ""
    @Binding var Editor:String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .font(Font.system(size: ControlWidth(12)))
                .foregroundColor(.black.opacity(0.8))
            
            TextEditor(text: $Editor)
                .frame(height: 200)
                .disabled(true)
                .background(rgbToColor(red: 255, green: 255, blue: 255))
                .overlay(
                    Text(Editor.isEmpty ? text : "")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 25)
                        .allowsHitTesting(false),
                    alignment: .topLeading
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3),lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 3, y: 4)
                .frame(width: UIScreen.main.bounds.width - 40)
                .cornerRadius(20)
        }
        .background(Color(.white))
    }
}


