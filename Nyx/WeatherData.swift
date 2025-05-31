//
//  WeatherData.swift
//  Nyx
//
//  Created by BitDegree on 31/05/25.
//

import Foundation

struct WeatherData: Codable, Identifiable {
    let id: UUID
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let precipitationProbability: Int
    let uvIndex: Int
    let hourlyForecasts: [HourlyForecast]
    
    struct HourlyForecast: Codable, Identifiable {
        let id: UUID
        let time: String
        let temperature: Double
        let condition: String
    }
}
