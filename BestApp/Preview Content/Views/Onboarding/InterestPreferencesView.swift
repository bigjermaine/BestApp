//
//  InterestPreferencesView.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import SwiftUI



struct InterestPreferencesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedGender: String = "Female"
    @State private var selectedAgeRange: AgeRange = .range18to25
    @EnvironmentObject var navigationState: NavigationState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Who are you interested in?")
                    .foregroundColor(.white)
                    .font(.title)

                Picker("Gender", selection: $selectedGender) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.blue.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack {
                    Text("Select Age Range")
                        .foregroundColor(.white)

                    Picker("Age Range", selection: $selectedAgeRange) {
                        ForEach(AgeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 8)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()

                Button("Finish") {
                    viewModel.interestedInGender = selectedGender
                    viewModel.interestedInAgeRange = selectedAgeRange
                    viewModel.saveUser()
                    navigationState.push(to: .tabbarScreen)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

#Preview {
    InterestPreferencesView(viewModel: previewData)
        .environmentObject(NavigationState())
}

#Preview {
    InterestPreferencesView(viewModel: previewData)
}
