//
//  ViewController.swift
//  openWeather
//
//  Created by 840west on 9/5/16.
//  Copyright © 2016 840west. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tempLogo: UIImageView!
    @IBOutlet weak var tempDisplay: UILabel!
    
    var currentTemp = 0
    
    var manager = CLLocationManager()
    var lat: String = ""
    var lon: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        manager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
            
        }
        
        
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = kCLDistanceFilterNone
        
        manager.delegate = self
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get most recent coordinate
        let myCoor = locations[locations.count - 1]
        
        // get lat and longit
        lat = "\(myCoor.coordinate.latitude)"
        lon = "\(myCoor.coordinate.longitude)"

        
        
    }
    
    func pullRequest() {
        
        let requestURL: NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=imperial&appid=05d30aadebf9cfe66f2ef8d47e04027e")!
        print(requestURL)
        let urlRequest: NSURLRequest = NSURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let codeStatus = httpResponse.statusCode
            
            if (codeStatus == 200) {
                print("Everyone is fine, file downloaded successfully")
                
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    
                    if let main = json["main"] as? [String: AnyObject] {
                        
                        if let temp = main["temp"] as? Int {
                            self.currentTemp = temp
                            
                            // TODO: Figure out weather icon path
                        }
                    }
                    
                }
                catch {
                    print("Error with Json: \(error)")
                }
            }
            
        }
        
        task.resume()
        
    }
    
    func loadImageFromURL(url: String, view: UIImageView) {
        
        // Thanks to Juan Carlos Sanchez's blog for this simple code
        // https://softwarejuancarlos.com/2015/11/27/swift-2-examples-loading-an-image-from-a-url/
        
        // Create Url from string
        let url = NSURL(string: url)!
        
        // Download task
        // - sharedSession = global URLCache, HttpcookieStorage, credentialStorage objects
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
            // if responseData is not null...
            if let data = responseData{
                
                // execute in UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    view.image = UIImage(data: data)
                })
            }
            
        }
        
        // Run task
        task.resume()
            
    }

    func checkForBackground(currentTemp: Int) {
        
        switch currentTemp {
        case let currentTemp where currentTemp > 90:
            backgroundImage.image = UIImage(named: "Hot")
        case let currentTemp where currentTemp < 60:
            backgroundImage.image = UIImage(named: "Cold")
        default:
            backgroundImage.image = UIImage(named: "Great")
        }
        
    }
    
    @IBAction func getCurrentWeather(sender: UIButton) {
        
        while (currentTemp == 0) {
            pullRequest()
            sleep(4)
        }
        checkForBackground(currentTemp)
        tempDisplay.textColor = UIColor.whiteColor()
        tempDisplay.text = "\(currentTemp)° Fahrenheit"
        
    }
    

}

