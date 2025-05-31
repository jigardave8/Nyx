//
//  NyxWeatherService.swift
//  Nyx
//
//  Created by BitDegree on 31/05/25.
//
import Foundation

// Response models
struct WeatherResponse: Codable {
    let data: TimelineData
}

struct TimelineData: Codable {
    let timelines: [Timeline]
}

struct Timeline: Codable {
    let timestep: String
    let startTime: String
    let endTime: String
    let intervals: [Interval]
}

struct Interval: Codable {
    let startTime: String
    let values: WeatherValues
}

struct WeatherValues: Codable {
    let temperature: Double?
    let weatherCode: Int?
    let humidity: Int?
    let windSpeed: Double?
    let precipitationProbability: Int?
    let uvIndex: Int?
}

// Custom errors
enum NyxError: Error {
    case invalidParameters
    case invalidURL
    case invalidResponse
    case noData
    case invalidData
    case httpError(Int)
    
    var localizedDescription: String {
        switch self {
        case .invalidParameters:
            return "Invalid parameters provided"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response received"
        case .noData:
            return "No data received"
        case .invalidData:
            return "Invalid data received"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        }
    }
}

class NyxWeatherService {
    static let shared = NyxWeatherService()
    private let apiKey = "zpA3E41L5ZTe1yEpFpAyQ7jPsUL8MI2M"
    
    private init() {}
    
    func fetchWeather(completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let parameters = [
            "location": "42.3478, -71.0466",
            "fields": ["temperature", "weatherCode", "humidity", "windSpeed",
                      "precipitationProbability", "uvIndex"],
            "units": "metric",
            "timesteps": ["1h"],
            "startTime": "now",
            "endTime": "nowPlus6h"
        ] as [String : Any]
        
        guard let postData = try? JSONSerialization.data(withJSONObject: parameters) else {
            completion(.failure(NyxError.invalidParameters))
            return
        }
        
        guard let url = URL(string: "https://api.tomorrow.io/v4/timelines") else {
            completion(.failure(NyxError.invalidURL))
            return
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems = [URLQueryItem(name: "apikey", value: apiKey)]
        components.queryItems = queryItems
        
        guard let finalURL = components.url else {
            completion(.failure(NyxError.invalidURL))
            return
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Accept-Encoding": "deflate, gzip, br",
            "content-type": "application/json"
        ]
        request.httpBody = postData
        
        #if DEBUG
        print("📡 API Request URL: \(finalURL)")
        if let bodyString = String(data: postData, encoding: .utf8) {
            print("📦 Request Body: \(bodyString)")
        }
        #endif
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                #if DEBUG
                print("❌ Network Error: \(error.localizedDescription)")
                #endif
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NyxError.invalidResponse))
                return
            }
            
            #if DEBUG
            print("📥 API Response Status Code: \(httpResponse.statusCode)")
            #endif
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NyxError.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NyxError.noData))
                return
            }
            
            #if DEBUG
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Response Data: \(responseString)")
            }
            #endif
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WeatherResponse.self, from: data)
                
                guard let timeline = response.data.timelines.first,
                      let interval = timeline.intervals.first else {
                    completion(.failure(NyxError.invalidData))
                    return
                }
                
                let weatherData = WeatherData(
                    id: UUID(),
                    temperature: interval.values.temperature ?? 0,
                    condition: self.getWeatherCondition(from: interval.values.weatherCode ?? 0),
                    humidity: interval.values.humidity ?? 0,
                    windSpeed: interval.values.windSpeed ?? 0,
                    precipitationProbability: interval.values.precipitationProbability ?? 0,
                    uvIndex: interval.values.uvIndex ?? 0,
                    hourlyForecasts: timeline.intervals.map { interval in
                        WeatherData.HourlyForecast(
                            id: UUID(),
                            time: interval.startTime,
                            temperature: interval.values.temperature ?? 0,
                            condition: self.getWeatherCondition(from: interval.values.weatherCode ?? 0)
                        )
                    }
                )
                
                #if DEBUG
                print("✅ Successfully parsed weather data")
                #endif
                
                completion(.success(weatherData))
            } catch {
                #if DEBUG
                print("❌ Decoding Error: \(error)")
                #endif
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func getWeatherCondition(from code: Int) -> String {
        switch code {
        case 1000: return "Clear"
        case 1100, 1101, 1102: return "Partly Cloudy"
        case 1001: return "Cloudy"
        case 4000, 4001, 4200: return "Rain"
        case 4201: return "Heavy Rain"
        case 5000, 5001, 5100: return "Snow"
        case 5101: return "Heavy Snow"
        case 6000, 6001, 6200, 6201: return "Freezing Rain"
        case 7000, 7101, 7102: return "Ice"
        case 8000: return "Thunderstorm"
        default: return "Unknown"
        }
    }
}
