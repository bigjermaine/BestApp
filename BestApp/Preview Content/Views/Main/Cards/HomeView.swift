//
//  HomeView.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import SwiftUI
struct HomeView: View {
    @State private var selectedUser: UserModel? = nil
    @EnvironmentObject private var onboardingViewModel:OnboardingViewModel
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack{
                headerSection
                ScrollView(.vertical) {
                    if !isEmpty {
                        VStack{
                            userCardsSection
                            Spacer(minLength: 100)
                        }
                        .frame(maxWidth: .infinity,maxHeight: .infinity)
                    }else {
                        emptyStateView
                    }
                }
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
        .fullScreenCover(item: $selectedUser) { user in
            StoryDetailView(user: user){ updatedUser in
                if let index = onboardingViewModel.filteredUsers.firstIndex(where: { $0.id == updatedUser.id }) {
                    onboardingViewModel.filteredUsers[index] = updatedUser
                    print(onboardingViewModel.filteredUsers.map({$0.isRecorded}))
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
       
}

#Preview {
    HomeView()
        .environmentObject(previewData)
}

extension HomeView {
    private var headerSection: some View {
           VStack(alignment: .leading, spacing: 8) {
               HStack {
                   Text("Your Turn")
                       .font(.largeTitle)
                       .fontWeight(.bold)
                       .foregroundColor(.white)
                   
                   Spacer()
                   
                  
                   Button(action: {
                    
                   }) {
                       Image(systemName: "person.circle")
                           .font(.title2)
                           .foregroundColor(.white)
                   }
               }
               
               Text("Make your move, they are waiting 🎵")
                   .font(.subheadline)
                   .foregroundColor(.gray)
           }
           .padding(.horizontal)
       }
       
    private var isEmpty: Bool {
        onboardingViewModel.filteredUsers.isEmpty
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No users available")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("Check back later for new connections")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var userCardsSection: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(onboardingViewModel.filteredUsers) { user in
                        UserCardView(user: user, selectedUser: $selectedUser)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1.0 : 0.5)
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                            }
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 16)
        }
        
}
