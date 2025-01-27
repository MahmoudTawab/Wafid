//
//  LoadingView.swift
//  Wafid
//
//  Created by almedadsoft on 27/01/2025.
//


import SwiftUI

struct LoadingView: View {
    @State var isLoading: Bool = true // حالة للتحكم في اللودر

    var body: some View {
        HStack(spacing: 10) {
            if isLoading {
                ActivityIndicator(isAnimating: $isLoading) // اللودر
                    .frame(width: 20, height: 20)
            }
        }
        .padding()
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool // حالة التحكم

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        if isAnimating {
            activityIndicator.startAnimating() // بدء التحميل إذا كانت الحالة true
        }
        return activityIndicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        if isAnimating {
            uiView.startAnimating() // تشغيل اللودر
        } else {
            uiView.stopAnimating() // إيقاف اللودر
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
