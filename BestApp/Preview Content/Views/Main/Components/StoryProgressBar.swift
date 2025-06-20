//
//  StoryProgressBar.swift
//  BestApp
//
//  Created by Daniel Jermaine on 19/06/2025.
//

import SwiftUI
struct StoryProgressBar: View {
    var progress: CGFloat 

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 4)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .cornerRadius(2)

                Rectangle()
                    .frame(width: geometry.size.width * progress, height: 4)
                    .foregroundColor(.white)
                    .cornerRadius(2)
                    .animation(.linear, value: progress)
            }
        }
    }
}
