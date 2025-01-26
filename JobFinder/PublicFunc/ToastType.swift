//
//  ToastType.swift
//  JobFinder
//
//  Created by almedadsoft on 16/01/2025.
//

import SwiftUI

// 1. أولاً نحدد نوع التنبيه
enum ToastType {
    case success
    case error
}

struct AnimatedToastMessage: View {
    @Binding var showingErrorMessageisValid: Bool
    @Binding var MassegeContent: String
    @State var TypeToast: ToastType = .error
    @Binding var FrameHeight : CGFloat
    @State private var isCircle = true
    @State private var showContent = false
    @State private var hideTimer: Timer?

    var body: some View {
        VStack {
            if showingErrorMessageisValid {
                VStack {
                    HStack(alignment: .center, spacing: -10) {
                        ZStack(alignment: .top) {
                            HStack {
                                Spacer()
                                Button(action: {
                                    hideErrorMessageWithAnimation()
                                }) {
                                    Image(systemName: "xmark")
                                        .padding()
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .frame(height: 20)
                            
                            if showContent {
                                Text(MassegeContent)
                                    .font(Font.system(size: ControlWidth(13)).weight(.heavy))
                                    .lineLimit(2)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(EdgeInsets(top: 18, leading: 10, bottom: 0, trailing: 10))
                                    .frame(height: 40)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    .frame(height: FrameHeight, alignment: .center)
                    .background(TypeToast == .error ? .red : .green)
                    .cornerRadius(isCircle ? FrameHeight / 2 : 10)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: isCircle)
                }
                .frame(width: isCircle ? FrameHeight : nil)
                .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: isCircle)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: showingErrorMessageisValid ? 20 : 0, trailing: 10))
                .onAppear {

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            isCircle = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation {
                                showContent = true
                            }
                        }
                        
                        hideTimer?.invalidate()
                        hideTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                            hideErrorMessageWithAnimation()
                        }
                    }
                }
            }
        }
    }

    private func hideErrorMessageWithAnimation() {
        withAnimation {
            showContent = false
            isCircle = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingErrorMessageisValid = false
                hideTimer?.invalidate()
            }
        }
    }
}
