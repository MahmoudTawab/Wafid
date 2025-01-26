//
//  Plan.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//

import SwiftUI

struct PricingPlanView: View {
    @State private var selectedPlan: Int = 0
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = PricingPlanViewViewModel()

    let plans = [
        Plan(name: "Exclusive Plan",
             price: 12,
             period: "Month",
             features: [
                "Create 10 Jobs",
                "2 Invitation",
                "20 Resume / CV",
                "20 User"
             ],
             backgroundColor: Color(red: 0.76, green: 0.55, blue: 0.27),
             textColor:  rgbToColor(red: 193, green: 140, blue: 70),
             isSelected: true),
        
        Plan(name: "Business Plan",
             price: 32,
             period: "Month",
             features: [
                "Create 20 Jobs",
                "5 Invitation",
                "40 Resume / CV",
                "40 User"
             ],
             backgroundColor:  rgbToColor(red: 193, green: 140, blue: 70),
             textColor: Color(red: 0.76, green: 0.55, blue: 0.27),
             isSelected: false),
        
        Plan(name: "Vip Plan",
             price: 42,
             period: "Month",
             features: [
                "Create 30 Jobs",
                "10 Invitation",
                "60 Resume / CV",
                "60 User"
             ],
             backgroundColor:  rgbToColor(red: 193, green: 140, blue: 70),
             textColor: Color(red: 0.76, green: 0.55, blue: 0.27),
             isSelected: false)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // الشعار والعنوان
                HStack(spacing: 12) {
                    Image("logo_labour")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    Text( "Pricing Plan")
                        .font(.system(size: ControlWidth(24), weight: .bold))
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                // العنوان الفرعي
                VStack(alignment: .leading, spacing: 8) {
                    Text( "Choose your subscription plan")
                        .font(.system(size: ControlWidth(24), weight: .bold))
                    
                    Text( "And get a free 7-day trial")
                        .font(.system(size: ControlWidth(16)))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // عرض الخطط
                ForEach(plans.indices, id: \.self) { index in
                    PlanCard(
                        plan: plans[index],
                        isSelected: index == selectedPlan
                    ) {
                        withAnimation {
                            selectedPlan = index
                        }
                    } actionSubscribe: {
                        navigationManager.navigate(to: .PaymentMethodView)
                    }
                }
                
                Spacer()
            }
            .padding(.top , 50)
            .frame(height: UIScreen.main.bounds.height - 50)
        }
       .padding()
       .edgesIgnoringSafeArea(.all)
       .preferredColorScheme(.light)
       .background(rgbToColor(red: 255, green: 255, blue: 255))
       .frame(width: UIScreen.main.bounds.width)
        
       .task {
       await viewModel.fetchPlans()
       }
        
    }
}

struct PlanCard: View {
    let plan: Plan
    let isSelected: Bool
    let action: () -> Void
    let actionSubscribe: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // عنوان الخطة

            if isSelected {
                Text( plan.name)
                    .font(.system(size: ControlWidth(24), weight: .bold))
                    .foregroundColor(isSelected ? .white : plan.textColor)
                
                HStack(spacing: 10) {
                    // عرض الميزات
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(plan.features, id: \.self) { feature in
                            FeatureRow(text: feature, textColor: isSelected ? .white : plan.textColor)
                        }
                    }
                    
                    Spacer()
                    
                    // السعر
                    VStack(alignment: .trailing) {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text( "$")
                                .offset(y: -20)
                                .font(.system(size: ControlWidth(20), weight: .bold))
                            Text( "\(plan.price)")
                                .font(.system(size: ControlWidth(32), weight: .bold))
                            Text( "/ \(plan.period)")
                                .font(.system(size: ControlWidth(16), weight: .bold))
                        }
                        .foregroundColor(isSelected ? .white : plan.textColor)
                    }
                }
            } else {
                HStack(spacing: 10) {
                    Text( plan.name)
                        .font(.system(size: ControlWidth(24), weight: .bold))
                        .gradientText(
                           Gradient(colors: [
                            rgbToColor(red: 193, green: 140, blue: 70),
                            rgbToColor(red: 89, green: 51, blue: 0)
                            ])
                        )
                        .foregroundColor(isSelected ? .white : plan.textColor)
                    
                    Spacer()
                    
                    // السعر
                    VStack(alignment: .trailing) {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text( "$")
                                .font(.system(size: ControlWidth(20), weight: .bold))
                                .gradientText(
                                   Gradient(colors: [
                                    rgbToColor(red: 193, green: 140, blue: 70),
                                    rgbToColor(red: 89, green: 51, blue: 0)
                                    ])
                                )
                            
                            Text( "\(plan.price)")
                                .font(.system(size: ControlWidth(32), weight: .bold))
                                .gradientText(
                                   Gradient(colors: [
                                    rgbToColor(red: 193, green: 140, blue: 70),
                                    rgbToColor(red: 89, green: 51, blue: 0)
                                    ])
                                )
                            
                            Text( "/ \(plan.period)")
                                .font(.system(size: ControlWidth(16), weight: .bold))
                                .gradientText(
                                   Gradient(colors: [
                                    rgbToColor(red: 193, green: 140, blue: 70),
                                    rgbToColor(red: 89, green: 51, blue: 0)
                                    ])
                                )
                        }
                        .foregroundColor(isSelected ? .white : plan.textColor)
                    }
                }
            }
            
            // زر الاشتراك
            if isSelected {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Spacer()
                    Button(action: actionSubscribe) {
                        Text( "Subscribe now")
                            .font(.system(size: ControlWidth(16), weight: .semibold))
                            .gradientText(
                               Gradient(colors: [
                                rgbToColor(red: 193, green: 140, blue: 70),
                                rgbToColor(red: 89, green: 51, blue: 0)
                                ])
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(UIScreen.main.bounds.width / 4)
                    }
                    .frame(width: UIScreen.main.bounds.width / 2, height: 40)
                    Spacer()
                }
            }
        }
        .padding(24)
        .frame(width: UIScreen.main.bounds.width - 40)
        
        .background(
            Group {
                if isSelected {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            rgbToColor(red: 193, green: 140, blue: 70),
                            rgbToColor(red: 89, green: 51, blue: 0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomLeading
                    )
                } else {
                    Color.white
                }
            }
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .onTapGesture {
            action()
        }
        .animation(.easeInOut, value: isSelected)
    }
}

struct FeatureRow: View {
    let text: String
    let textColor: Color
    
    var body: some View {
        HStack {
            Text( text)
                .font(.system(size: ControlWidth(16)))
                .foregroundColor(textColor)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct Plan: Identifiable {
    let id = UUID()
    let name: String
    let price: Int
    let period: String
    let features: [String]
    let backgroundColor: Color
    let textColor: Color
    let isSelected: Bool
}

struct GradientTextModifier: ViewModifier {
    var gradient: Gradient
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.clear) // اجعل النص شفافًا
            .overlay(
                LinearGradient(
                    gradient: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomLeading
                )
                .mask(content) // استخدم النص كقناع
            )
    }
}

extension View {
    func gradientText(_ gradient: Gradient) -> some View {
        self.modifier(GradientTextModifier(gradient: gradient))
    }
}


@MainActor
class PricingPlanViewViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let procedureName = "hfC35zzAABZQcYeWZo6+cQ=="
    
    func fetchPlans() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await makeRequestGet(
                ProcedureName: procedureName,
                ApiToken: ApiToken,
                dateToken: dateToken,
                parametersValues: [:],
                orderedKeys: []
            )
            
            print(response)

        } catch {
            errorMessage = "Failed to fetch plans: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
}
