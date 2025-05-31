//
//  NyxFogEffect.swift
//  Nyx
//
//  Created by BitDegree on 31/05/25.
//

import SwiftUI

struct NyxFogEffect: View {
    @State private var phase: CGFloat = 0
    let nyxColors = NyxColors()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timeScale: CGFloat = 1
                let color = nyxColors.backgroundMid.opacity(0.3)
                
                context.addFilter(.blur(radius: 30))
                
                for i in stride(from: 0, through: size.width, by: size.width/6) {
                    let xOffset = (phase + i).truncatingRemainder(dividingBy: size.width)
                    let circle = Path(ellipseIn: CGRect(x: xOffset - 50,
                                                      y: 0,
                                                      width: 100,
                                                      height: size.height))
                    context.fill(circle, with: .color(color))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                phase = UIScreen.main.bounds.width
            }
        }
    }
}
