//
//  NyxWeatherCircle.swift
//  Nyx
//
//  Created by BitDegree on 31/05/25.
//

import SwiftUI

struct NyxWeatherCircle: View {
    let weatherData: WeatherData?
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    let nyxColors = NyxColors()
    
    var body: some View {
        ZStack {
            // Outer rotating ring
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
                    lineWidth: 8
                )
                .rotationEffect(Angle(degrees: rotation))
                .frame(width: 300, height: 300)
                .onAppear {
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            // Weather info cards
            ForEach(0..<6) { index in
                WeatherInfoCard(
                    index: index,
                    total: 6,
                    weatherData: weatherData,
                    nyxColors: nyxColors
                )
            }
            
            // Center temperature display
            VStack {
                Text("\(Int(weatherData?.temperature ?? 0))°")
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                
                Text(weatherData?.condition ?? "Loading...")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    scale = 1.05
                }
            }
        }
    }
}

struct WeatherInfoCard: View {
    let index: Int
    let total: Int
    let weatherData: WeatherData?
    let nyxColors: NyxColors
    
    var body: some View {
        let angle = Double(index) * 360.0 / Double(total)
        let radius: CGFloat = 150
        
        VStack {
            Image(systemName: getWeatherIcon())
                .font(.system(size: 24))
            Text(getWeatherValue())
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(nyxColors.secondary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(nyxColors.accent1.opacity(0.3), lineWidth: 1)
                )
        )
        .offset(
            x: cos(angle * .pi / 180) * radius,
            y: sin(angle * .pi / 180) * radius
        )
    }
    
    private func getWeatherIcon() -> String {
        switch index {
        case 0: return "thermometer"
        case 1: return "humidity"
        case 2: return "wind"
        case 3: return "cloud.rain.fill"
        case 4: return "sun.max.fill"
        case 5: return "clock"
        default: return "questionmark"
        }
    }
    
    private func getWeatherValue() -> String {
        guard let data = weatherData else { return "..." }
        
        switch index {
        case 0: return "\(Int(data.temperature))°"
        case 1: return "\(data.humidity)%"
        case 2: return "\(Int(data.windSpeed))m/s"
        case 3: return "\(data.precipitationProbability)%"
        case 4: return "UV \(data.uvIndex)"
        case 5: return "Now"
        default: return "..."
        }
    }
}
