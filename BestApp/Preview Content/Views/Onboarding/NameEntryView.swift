//
//  NameEntryView.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//


import SwiftUI

struct NameEntryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var name: String = ""
    @EnvironmentObject var navigationState:NavigationState
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {
                Text("What's your name?")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                TextField("Enter your name", text: $name)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: {
                    viewModel.name = name
                    navigationState.push(to: .genderScreen)
                   
                }) {
                    Text("Continue")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.isEmpty ? Color.gray : Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(name.isEmpty)
            }
            .padding()
        }
    }
}

#Preview {
    NameEntryView(viewModel: previewData)
}
