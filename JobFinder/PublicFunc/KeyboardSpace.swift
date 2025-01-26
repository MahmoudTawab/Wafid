//
//  KeyboardSpace.swift
//  JobFinder
//
//  Created by almedadsoft on 13/01/2025.
//

import SwiftUI
import Combine

let keyboardSpaceD = KeyboardSpace()

extension View {
    func keyboardSpace(isActive: Bool = true, extraPadding: CGFloat = 20) -> some View {
        modifier(KeyboardSpace.Space(data: keyboardSpaceD, isActive: isActive, extraPadding: extraPadding))
    }
}

class KeyboardSpace: ObservableObject {
    var sub: AnyCancellable?
    @Published var currentHeight: CGFloat = 0
    
    var heightIn: CGFloat = 0 {
        didSet {
            withAnimation {
                if UIWindow.keyWindow != nil {
                    self.currentHeight = heightIn
                }
            }
        }
    }
    
    init() {
        subscribeToKeyboardEvents()
    }
    
    private let keyboardWillOpen = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
        .map { $0.height - (UIWindow.keyWindow?.safeAreaInsets.bottom ?? 0) }
    
    private let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat.zero }
    
    private func subscribeToKeyboardEvents() {
        sub?.cancel()
        sub = Publishers.Merge(keyboardWillOpen, keyboardWillHide)
            .subscribe(on: RunLoop.main)
            .assign(to: \.self.heightIn, on: self)
    }
    
    deinit {
        sub?.cancel()
    }
    
    struct Space: ViewModifier {
        @ObservedObject var data: KeyboardSpace
        var isActive = true
        var extraPadding: CGFloat
        
        func body(content: Content) -> some View {
            VStack(spacing: 0) {
                content
                if isActive {
                    Rectangle()
                        .foregroundColor(Color(.clear))
                        .frame(height: data.currentHeight + extraPadding)
                        .frame(maxWidth: .greatestFiniteMagnitude)
                }
            }
        }
    }
}

extension UIWindow {
    static var keyWindow: UIWindow? {
        let keyWindow = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive }
            .flatMap { $0 as? UIWindowScene }?.windows
            .first { $0.isKeyWindow }
        return keyWindow
    }
}



struct KeyboardToolbar: ViewModifier {
    @AppStorage("LanguageSelection") var LanguageSelection = "en"
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(LanguageSelection == "ar" ? "إغلاق":"Close") {
                        hideKeyboard()
                    }
                    .foregroundColor(rgbToColor(red: 193, green: 140, blue: 70))
                }
            }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func addKeyboardToolbar() -> some View {
        self.modifier(KeyboardToolbar())
    }
}

