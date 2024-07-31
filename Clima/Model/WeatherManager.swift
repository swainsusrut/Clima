//
//  WeatherManager.swift
//  Clima
//
//  Created by Swain, Susrut (Cognizant) on 24/10/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    
    let openWeatherApiKey: String = "f71a24ed065b9aaa8dd85cefe4a1201a"
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=f71a24ed065b9aaa8dd85cefe4a1201a&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlstring: String) {
        
        //1. Create a url
        if let url = URL(string: urlstring) {
            
            //2. Create a URL Session
            let urlSession = URLSession(configuration: .default)
            
            //3.Give the session a task
            let task = urlSession.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        //IMPORTANT CONCEPT - PROTOCOLS & DELEGATES Use Case
                        
                        //let weatherVC = WeatherViewController()
                        //weatherVC.didUpdateWeather(waether: weather)
                        /*
                            This would work BUT BY DOING THIS THE WEATER MANAGER WILL BE LIMITED TO SINGLE USE
                            TO RESUE THIS WEATHER MANAGER THAT SHOULD WORK WITH OTHER VIEW CONTROLLERS AS WELL, DONT TIE THIS CLASS TO ANY SPECIFIC CONTROLLER
                            INSTEAD USE THE CONCEPT OF PROTOCOLS AND DELEGAETS
                         */
                        
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temperature = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temperature)
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
