import SwiftUI

struct CareerInterestsView: View {
    @State private var selectedCareerLevel: String?
    @State private var selectedJobTypes: Set<String> = ["Full Time", "Part Time", "Shift Based"]
    @State private var selectedWorkplaceSettings: Set<String> = []
    
    let careerLevels = ["Student", "Entry Level", "Experienced", "Manager", "Senior Management", "Not Specified"]
    let jobTypes = ["Full Time", "Part Time", "Freelance", "Shift Based", "Volunteering", "Summer Job"]
    let workplaceSettings = ["On-site", "Remote", "Hybrid"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Button(action: {
                    // Handle back action
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                Text("What is your Career Interests?")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            // Career Level Section
            VStack(alignment: .leading, spacing: 16) {
                Text("What's your current Career level ?")
                    .font(.headline)
                
                FlowLayout(spacing: 8) {
                    ForEach(careerLevels, id: \.self) { level in
                        SelectableButton(
                            title: level,
                            isSelected: selectedCareerLevel == level,
                            selectionType: .single,
                            action: { selectedCareerLevel = level }
                        )
                    }
                }
            }
            
            // Job Types Section
            VStack(alignment: .leading, spacing: 16) {
                Text("What type(s) of job are you open to ?")
                    .font(.headline)
                
                FlowLayout(spacing: 8) {
                    ForEach(jobTypes, id: \.self) { jobType in
                        SelectableButton(
                            title: jobType,
                            isSelected: selectedJobTypes.contains(jobType),
                            selectionType: .multi,
                            action: {
                                if selectedJobTypes.contains(jobType) {
                                    selectedJobTypes.remove(jobType)
                                } else {
                                    selectedJobTypes.insert(jobType)
                                }
                            }
                        )
                    }
                }
            }
            
            // Workplace Settings Section
            VStack(alignment: .leading, spacing: 16) {
                Text("What is your preferred workplace settings?")
                    .font(.headline)
                
                FlowLayout(spacing: 8) {
                    ForEach(workplaceSettings, id: \.self) { setting in
                        SelectableButton(
                            title: setting,
                            isSelected: selectedWorkplaceSettings.contains(setting),
                            selectionType: .multi,
                            action: {
                                if selectedWorkplaceSettings.contains(setting) {
                                    selectedWorkplaceSettings.remove(setting)
                                } else {
                                    selectedWorkplaceSettings.insert(setting)
                                }
                            }
                        )
                    }
                }
            }
            
            Spacer()
            
            // Next Button
            Button(action: {
                // Handle next action
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(UIColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)))
                    )
            }
            .padding(.bottom)
        }
        .padding()
    }
}

struct SelectableButton: View {
    let title: String
    let isSelected: Bool
    let selectionType: SelectionType
    let action: () -> Void
    
    enum SelectionType {
        case single
        case multi
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if selectionType == .multi && isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? 
                          Color(UIColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)) :
                          Color.white)
            )
            .overlay(
                Capsule()
                    .stroke(Color(UIColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)),
                           lineWidth: isSelected ? 0 : 1)
            )
            .foregroundColor(isSelected ? .white : Color(UIColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)))
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for index in subviews.indices {
            let point = result.origins[index]
            subviews[index].place(
                at: CGPoint(x: point.x + bounds.minX, y: point.y + bounds.minY),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }
    
    struct FlowResult {
        var origins: [CGPoint]
        var sizes: [CGSize]
        var size: CGSize
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var origins: [CGPoint] = []
            var sizes: [CGSize] = []
            
            var currentPosition: CGPoint = .zero
            var currentRow: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentPosition.x + size.width > maxWidth && !origins.isEmpty {
                    currentPosition.x = 0
                    currentPosition.y += currentRow + spacing
                    currentRow = 0
                }
                
                origins.append(currentPosition)
                sizes.append(size)
                
                currentRow = max(currentRow, size.height)
                maxHeight = max(maxHeight, currentPosition.y + size.height)
                
                currentPosition.x += size.width + spacing
            }
            
            self.origins = origins
            self.sizes = sizes
            self.size = CGSize(width: maxWidth, height: maxHeight)
        }
    }
}

struct CareerInterestsView_Previews: PreviewProvider {
    static var previews: some View {
        CareerInterestsView()
    }
}