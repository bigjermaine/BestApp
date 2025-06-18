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
    @State private var ageRange: ClosedRange<Double> = 18...30
    @State private var selectedAgeRangeIndex: Int = 0
    @EnvironmentObject var navigationState:NavigationState
    let ageRanges: [ClosedRange<Int>] = [
           18...25,
           25...50,
           50...60
       ]
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Who are you interested in?")
                    .foregroundColor(.white)
                    .font(.title)

                Picker("Gender", selection: $selectedGender) {
                    Text("Male")
                        .tag("Male")
                    Text("Female")
                        .tag("Female")
                }
                .pickerStyle(.segmented)
                .background(Color.blue)
              
                .padding()
                
                VStack {
                    Text("Select Age Range")
                    .foregroundColor(.white)
                    Picker("Age Range", selection: $selectedAgeRangeIndex) {
                        Text("18–25").tag(0)
                        Text("25–50").tag(1)
                        Text("50+").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .background(Color.blue)
                }
                .padding()
                Button("Finish") {
                    viewModel.interestedInGender = selectedGender
                    viewModel.interestedInAgeRange = ageRanges[selectedAgeRangeIndex]
                    viewModel.saveUser()
                    navigationState.push(to: .tabbarScreen)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

#Preview {
    InterestPreferencesView(viewModel: previewData)
}
