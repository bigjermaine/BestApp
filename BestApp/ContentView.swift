//
//  ContentView.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigationState:NavigationState
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.7)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.pink)

                    Text("Welcome to TrueConnect")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Find your perfect match")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(8)
                Spacer()

                Button(action: {
                    navigationState.push(to: .nameScreen)
                }) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            
        }
    }
}

#Preview {
    ContentView()
}
