//
//  WeatherAPI.swift
//  SnapWeather
//
//  Created by Robert Crosby on 5/2/15.
//  Copyright (c) 2015 Robert Crosby. All rights reserved.
//

import Foundation



struct Weather: Printable {
    var city: String
    var currentTemp: Float
    var conditions: String
    
    var description: String {
        return "\(city): \(currentTemp)F and \(conditions)"
    }
}

protocol WeatherAPIDelegate {
    func weatherDidUpdate(weather: Weather)
}






class WeatherAPI {

    let BASE_URL = "http://api.openweathermap.org/data/2.5/weather?units=imperial&q="
    var someString = ""
    
    func fetchWeather(query: String) {
        
        let session = NSURLSession.sharedSession()
        let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let url = NSURL(string: BASE_URL + escapedQuery!)
        let task = session.dataTaskWithURL(url!) { data, response, error in
            let weather = weatherFromJSONData(data)
            let x = "\(weather)"
            println(x)
            let y = x.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let stringLength = count(y) // Since swift1.2 `countElements` became `count`
            let substringIndex = stringLength - 1
            let final = y.substringToIndex(advance(y.startIndex, substringIndex))
            NSUserDefaults.standardUserDefaults().setObject(final, forKey: "weather")
        }
             task.resume()
    }
    
    
}

func weatherFromJSONData(data: NSData) -> Weather? {
    var err: NSError?
    typealias JSONDict = [String:AnyObject]
    
    if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &err) as? JSONDict {
        var mainDict = json["main"] as! JSONDict
        var weatherList = json["weather"]as! [JSONDict]
        var weatherDict = weatherList[0]
        
        var weather = Weather(
            city: json["name"] as! String,
            currentTemp: mainDict["temp"] as! Float,
            conditions: weatherDict["main"] as! String
        )
        
        return weather
    }
    return nil
}