//
//  ContentView.swift
//  Nyx
//
//  Created by BitDegree on 31/05/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoading = true
    @State private var weatherData: WeatherData?
    @State private var currentTime = Date()
    @State private var rotationDegree: Double = 0
    @State private var selectedTimeIndex = 0
    
    private let nyxColors = NyxColors()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Mystical Nyx-themed background
            NyxBackground()
            
            VStack {
                // Nyx branding
                Text("NYX")
                    .font(.custom("Futura", size: 28))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                if isLoading {
                    NyxLoadingView()
                } else {
                    NyxWeatherCircle(weatherData: weatherData)
                        .rotation3DEffect(Angle(degrees: rotationDegree), axis: (x: 0, y: 1, z: 0))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    rotationDegree = value.translation.width
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                        rotationDegree = 0
                                    }
                                }
                        )
                }
                
                // Time display
                Text(formatDate(currentTime))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(nyxColors.textSecondary)
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            fetchWeatherData()
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }
    
    private func fetchWeatherData() {
        NyxWeatherService.shared.fetchWeather { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.weatherData = data
                    self.isLoading = false
                case .failure(let error):
                    print("Error fetching weather data: \(error.localizedDescription)")
                    // Handle error appropriately
                    self.isLoading = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
