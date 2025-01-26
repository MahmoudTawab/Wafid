//
//  UIEmojiTextView.swift
//  Wafid
//
//  Created by almedadsoft on 26/01/2025.
//


import SwiftUI
import UIKit

class UIEmojiTextView: UITextView {
    var placeholder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isEmoji = false {
        didSet {
            setEmoji()
            if isEmoji {
                becomeFirstResponder()
            }
        }
    }
    
    let placeholderLabel = UILabel()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholderLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlaceholderLabel()
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textAlignment = .left
        placeholderLabel.font = UIFont.systemFont(ofSize: 15)
        placeholderLabel.textColor = .gray
        addSubview(placeholderLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePlaceholderLabel()
    }
    
    func updatePlaceholderLabel() {
        placeholderLabel.text = placeholder
        placeholderLabel.frame = CGRect(
            x: textContainerInset.left + 5,
            y: textContainerInset.top - 8,
            width: bounds.width - textContainerInset.left - textContainerInset.right - 10,
            height: bounds.height
        )
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    private func setEmoji() {
        reloadInputViews()
    }
    
    override var textInputContextIdentifier: String? {
        return ""
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" && isEmoji {
                keyboardType = .default
                return mode
            } else if !isEmoji {
                return mode
            }
        }
        return nil
    }
}

struct EmojiTextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    @Binding var isEmoji: Bool
    var minHeight: CGFloat = 30
    var maxHeight: CGFloat = 190
    
    func makeUIView(context: Context) -> UIEmojiTextView {
        let emojiTextView = UIEmojiTextView(frame: .zero, textContainer: nil)
        emojiTextView.placeholder = placeholder
        emojiTextView.text = text
        emojiTextView.delegate = context.coordinator
        emojiTextView.isEmoji = isEmoji
        emojiTextView.font = UIFont.systemFont(ofSize: 15)
        emojiTextView.backgroundColor = .clear
        emojiTextView.tintColor = UIColor(rgbToColor(red: 193, green: 140, blue: 70))
        emojiTextView.isScrollEnabled = true
        emojiTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return emojiTextView
    }
    
    func updateUIView(_ uiView: UIEmojiTextView, context: Context) {
        uiView.text = text
        uiView.isEmoji = isEmoji
        uiView.updatePlaceholderLabel()
        
        let fixedWidth = UIScreen.main.bounds.width - 140 // اجعل العرض ثابتًا
        let newSize = uiView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        // ضبط الارتفاع بين القيم الدنيا والقصوى
        let newHeight = min(max(newSize.height, minHeight), maxHeight)
        
        uiView.isScrollEnabled = newSize.height > maxHeight
        
        // تحديث قيود الإطار ديناميكيًا
        DispatchQueue.main.async {
            uiView.translatesAutoresizingMaskIntoConstraints = false
            uiView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
            uiView.widthAnchor.constraint(equalToConstant: fixedWidth).isActive = true
        }
    }

    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: EmojiTextView
        
        init(parent: EmojiTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text ?? ""
            
            // Notify SwiftUI to update the view
            DispatchQueue.main.async {
                textView.setNeedsLayout()
                textView.layoutIfNeeded()
            }
        }
    }
}
