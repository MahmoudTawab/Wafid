import SwiftUI

struct JobCategory: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var isSelected: Bool = false
}

struct JobSelectionView: View {
    @State private var jobCategories = [
        JobCategory(title: "Content Writer", icon: "pencil"),
        JobCategory(title: "Art & Design", icon: "paintbrush"),
        JobCategory(title: "Human Resources", icon: "person.2"),
        JobCategory(title: "Programmer", icon: "chevron.left.forwardslash.chevron.right"),
        JobCategory(title: "Finance", icon: "briefcase"),
        JobCategory(title: "Customer Service", icon: "headphones"),
        JobCategory(title: "Food & Restaurant", icon: "fork.knife"),
        JobCategory(title: "Music Producer", icon: "music.note")
    ]
    
    @State private var selectedCount = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    // Handle back action
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                
                Text("What job you want?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Subtitle
            Text("Choose 3-5 job categories and we'll optimize the job vacancy for you.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .multilineTextAlignment(.leading)
            
            // Grid of job categories
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(jobCategories.indices, id: \.self) { index in
                    JobCategoryCard(
                        category: $jobCategories[index],
                        selectedCount: $selectedCount
                    )
                }
            }
            .padding()
            
            Spacer()
            
            // Next button
            Button(action: {
                // Handle next action
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)))
                    )
            }
            .padding()
        }
    }
}

struct JobCategoryCard: View {
    @Binding var category: JobCategory
    @Binding var selectedCount: Int
    
    var body: some View {
        Button(action: {
            if !category.isSelected && selectedCount < 5 {
                category.isSelected.toggle()
                selectedCount += 1
            } else if category.isSelected {
                category.isSelected.toggle()
                selectedCount -= 1
            }
        }) {
            VStack(spacing: 12) {
                Circle()
                    .fill(Color(UIColor(red: 0.98, green: 0.95, blue: 0.92, alpha: 1)))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: category.icon)
                            .foregroundColor(Color(UIColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)))
                    )
                
                Text(category.title)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.isSelected ? 
                           Color(UIColor(red: 0.76, green: 0.6, blue: 0.42, alpha: 1)) : 
                           Color.gray.opacity(0.2))
            )
        }
    }
}

struct JobSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        JobSelectionView()
    }
}