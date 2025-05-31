//
//  NyxLoadingView.swift
//  Nyx
//
//  Created by BitDegree on 31/05/25.
//

import SwiftUI

struct NyxLoadingView: View {
    @State private var rotation: Double = 0
    let nyxColors = NyxColors()
    
    var body: some View {
        ZStack {
            // Cosmic loading ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            nyxColors.accent1,
                            nyxColors.accent2,
                            nyxColors.accent1.opacity(0.5),
                            nyxColors.accent1
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: rotation))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            Text("Consulting the Stars...")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(nyxColors.textSecondary)
                .offset(y: 50)
        }
    }
}
