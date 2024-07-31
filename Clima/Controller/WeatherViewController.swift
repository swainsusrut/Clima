//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @IBAction func updateCurrentLocation(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}


//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField.text != "") {
            textField.placeholder = "Search a city name"
            return true
        } else {
            textField.placeholder = "Type something..."
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        weatherManager.fetchWeather(cityName: searchTextField.text!)
        searchTextField.text = ""
    }
}


//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        //Updating UI in a Completion Handler must be performed in MAIN THREAD
        //COMPLETION HANDLER RUNS ON BACKGROUND THREAD
        
        DispatchQueue.main.async { [self] in
            temperatureLabel.text = weather.temperatureString
            conditionImageView.image = UIImage(systemName: weather.conditionName)
            cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}


//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
