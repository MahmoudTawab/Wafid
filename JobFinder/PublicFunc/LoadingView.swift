import SwiftUI

struct LoadingView: View {
    var loadingText: String = "Loading..." // النص المكتوب
    @State var isLoading: Bool = true // حالة للتحكم في اللودر

    var body: some View {
        HStack(spacing: 10) {
            if isLoading {
                ActivityIndicator(isAnimating: $isLoading) // اللودر
                    .frame(width: 20, height: 20)
            }

            Text(loadingText) // النص المكتوب بجانب اللودر
                .font(.headline)
                .foregroundColor(isLoading ? .gray : .green) // تغيير اللون حسب الحالة
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
