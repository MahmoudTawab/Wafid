//
//  NewBottomSheet.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//


import SwiftUI

struct NewBottomSheet<Content: View>: View {
    @Binding var isOpen: Bool
    @State var IsShowIndicator = true
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: () -> Content
    
    @GestureState private var translation: CGFloat = 0
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    private var indicator: some View {
        Image("Line 186")
            .resizable()
            .frame(width: 60, height: 4)
            .foregroundColor(.secondary)
            .padding(5)
            .rotationEffect(Angle(degrees: isOpen ? 180 : 0))
            .scaleEffect(max(0.6, translation > -80.0 ? 1.0 - Double(translation / maxHeight) : 1.0))
            .animation(.interactiveSpring(), value: translation)
    }
    
    private var backgroundOpacity: Double {
        let maxOpacity: Double = 0.5
        let minOpacity: Double = 0.0
        let dragProgress = Double(translation / maxHeight)
        return max(min(maxOpacity - (maxOpacity * dragProgress), maxOpacity), minOpacity)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black
                .opacity(isOpen ? backgroundOpacity : 0)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: translation)
                .onTapGesture {
                        self.isOpen.toggle()
                }
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if IsShowIndicator {
                        self.indicator
                            .padding(.top, 10)
                    }
                    
                    self.content()
                }
                .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
                .background(Color.white)
                .cornerRadius(20)
                .frame(height: geometry.size.height, alignment: .bottom)
                .offset(y: max(self.offset + self.translation, 0))
                .animation(.interactiveSpring(), value: translation)
                .gesture(
                    DragGesture().updating(self.$translation) { value, state, _ in
                        state = value.translation.height
                    }.onEnded { value in
                        let snapDistance = self.maxHeight * 0.25
                        guard abs(value.translation.height) > snapDistance else {
                            return
                        }
                        self.isOpen = value.translation.height < 0
                    }
                )
            }
        }
        
        .edgesIgnoringSafeArea(.all)
    }
}
