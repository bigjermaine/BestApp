//
//  UserCardView.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import SwiftUI

struct UserCardView: View {
    let user: UserModel
    @Binding var selectedUser: UserModel?
    
    var body: some View {
        ZStack {
            // Background image
            Image(user.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 250, height: 300)
                .clipped()
                .cornerRadius(20)
            
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(20)
            
            // Content overlay
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 8) {
                    // Name and age
                    Text("\(user.name), \(user.age)")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Question prompt
                    Text(user.question)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            
            // Border/frame effect
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.6),
                            Color.pink.opacity(0.4),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            
            if user.isRecorded {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(.purple)
                    .frame(width: 50,height: 50)
            }
        }
        .frame(width: 250, height: 300)
        .onTapGesture {
            selectedUser = user
        }
    }
}


#Preview {
    UserCardView(user: DummyUserDatabase.users.first!, selectedUser: .constant(DummyUserDatabase.users.first!))
}
