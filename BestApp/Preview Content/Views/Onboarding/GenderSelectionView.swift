//
//  GenderSelectionView.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import SwiftUI

struct GenderSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selected: String? = nil
    @EnvironmentObject var navigationState:NavigationState
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 40) {
                Text("Select Your Gender")
                    .foregroundColor(.white)
                    .font(.title)

                VStack(spacing: 30) {
                    GenderCard(title: "Male", isSelected: selected == "Male")
                        .onTapGesture {
                            selected = "Male"
                            viewModel.gender = "Male"
                        }
                    GenderCard(title: "Female", isSelected: selected == "Female")
                        .onTapGesture {
                            selected = "Female"
                            viewModel.gender = "Female"
                        }
                    
                    GenderCard(title: "Others", isSelected: selected == "Others")
                        .onTapGesture {
                            selected = "Others"
                            viewModel.gender = "Others"
                        }
                }

                Button("Next") {
                    navigationState.push(to: .interestsScreen)
                }
                .disabled(selected == nil)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
        }
    }
}

struct GenderCard: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(isSelected ? .black : .white)
            .padding()
            .frame(width: 120)
            .background(isSelected ? Color.white : Color.gray.opacity(0.3))
            .cornerRadius(12)
    }
}


    
#Preview {
    GenderSelectionView(viewModel: previewData)
}
