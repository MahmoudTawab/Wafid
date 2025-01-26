//
//  Untitled.swift
//  JobFinder
//
//  Created by almedadsoft on 12/01/2025.
//

import SwiftUI

func rgbToColor(red: Double, green: Double, blue: Double, alpha: Double = 1.0) -> Color {
    return Color(
        red: red / 255.0,
        green: green / 255.0,
        blue: blue / 255.0,
        opacity: alpha
    )
}

struct CustomRoundedShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func isValidPassport(_ passport: String) -> Bool {
    let passportRegex = "^[A-Z0-9]{8,9}$"
    let passportTest = NSPredicate(format: "SELF MATCHES %@", passportRegex)
    return passportTest.evaluate(with: passport)
}

func ControlWidth(_ ControlW:CGFloat) -> CGFloat {
let Screen = UIDevice.current.userInterfaceIdiom != .phone ? UIScreen.main.bounds.height:UIScreen.main.bounds.width
let ControlH = UIDevice.current.userInterfaceIdiom != .phone ? CGFloat(667.0):CGFloat(375.0)
return ControlW * Screen / ControlH
}
