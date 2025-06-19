//
//  BestAppApp.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import SwiftUI



@main
struct BestAppApp: App {
    @StateObject var navigationState = NavigationState()
    @StateObject var onboardingViewModel = OnboardingViewModel()
    @StateObject var recordingViewModel = RecordingViewModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationState.path) {
                ContentView()
                    .environmentObject(onboardingViewModel)
                    .environmentObject(navigationState)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .genderScreen:
                            GenderSelectionView(viewModel: onboardingViewModel)
                                .environmentObject(navigationState)

                        case .interestsScreen:
                            InterestPreferencesView(viewModel: onboardingViewModel)
                                .environmentObject(recordingViewModel)
                                .environmentObject(navigationState)

                        case .nameScreen:
                            NameEntryView(viewModel: onboardingViewModel)
                                .environmentObject(navigationState)
                                .environmentObject(recordingViewModel)
                            

                        case .tabbarScreen:
                            Tabbar()
                                .environmentObject(navigationState)
                                .environmentObject(recordingViewModel)
                                .environmentObject(onboardingViewModel)
                        }
                    }
                    .environmentObject(navigationState)
                    .environmentObject(recordingViewModel)
                    .environmentObject(onboardingViewModel)
            }
            
        }
    }
}
