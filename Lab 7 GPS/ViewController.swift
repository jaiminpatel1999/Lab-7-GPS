//
//  ViewController.swift
//  Lab 7 GPS
//
//  Created by user237118 on 3/18/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationLogo: UIImageView!
    
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet weak var maxSpeed: UILabel!
    @IBOutlet weak var averageSpeed: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var maxAcceleration: UILabel!
    @IBOutlet weak var myLocation: MKMapView!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var greenView: UIView!
    
    
    
    var locationManager: CLLocationManager! // Manages location-related operations
    var startLocation: CLLocation? // The starting location of the trip
    var lastLocation: CLLocation? // The last recorded location
    var maxspeed: CLLocationSpeed = 0.0 // Maximum speed during the trip
    var Distance: CLLocationDistance = 0.0 // Total distance covered
    var acceleration: CLLocationSpeed = 0.0 // Current acceleration
    var tripStartTime: Date? // Start time of the trip
    var tripEndTime: Date? // End time of the trip
    var totalSpeed: CLLocationSpeed = 0.0 // Accumulated speed during the trip
    var speedReadings: Int = 0 // Number of speed readings taken
    var isUpdatingLocation: Bool = false // Flag to track whether location updates are in progress
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupUI()
        requestLocationPermission()
    }
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    func setupUI() {
        locationLogo.image = UIImage(named: "Location logo")
    }

    
    @IBAction func startTrip(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        tripStartTime = Date()
//        redView.backgroundColor = .red
        greenView.backgroundColor = .green
        myLocation.showsUserLocation = true
        myLocation.setUserTrackingMode(.follow, animated: true)
        isUpdatingLocation = true

    }
    
    
    @IBAction func stopTrip(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        tripEndTime = Date()
        redView.backgroundColor = .white
        greenView.backgroundColor = .gray
        currentSpeed.text = "0.00 km/h"
        maxSpeed.text = "0.00 km/h"
        averageSpeed.text = "0.00 km/h"
        distance.text = "0.00 km"
        maxAcceleration.text = "0.00 m/s²"
        myLocation.showsUserLocation = false
        myLocation.setUserTrackingMode(.none, animated: true)
        isUpdatingLocation = false
        
    // Calculate and display distance to exceed speed limit
        let distanceToExceedLimit = calculateDistanceToExceedSpeedLimit()
        print("Distance to exceed speed limit: \(distanceToExceedLimit) meters")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isUpdatingLocation, let liveLocation = locations.last else { return }
        
        // Update current speed label
        let currentspeed = liveLocation.speed
        if currentspeed * 3.6 > 115{
            redView.backgroundColor = .red
            redView.isHidden = false
        } else{
            redView.backgroundColor = .gray
            redView.isHidden = true
        currentSpeed.text = String(format: "%.1f km/h", abs(currentspeed) * 3.6)
        
        // Update max speed label if the current speed exceeds the recorded max speed
        if currentspeed > maxspeed {
            maxspeed = currentspeed
            maxSpeed.text = String(format: "%.1f km/h", abs(maxspeed) * 3.6)
            
            
            
            
        }
        
        }
        
        // Update average speed label based on the accumulated speed readings
        totalSpeed += currentspeed
        speedReadings += 1
        let averagespeed = totalSpeed / Double(speedReadings)
        averageSpeed.text = String(format: "%.1f km/h", abs(averagespeed) * 3.6)
        
        // Calculate distance, acceleration, and update corresponding labels
        if let lastLocation = lastLocation {
            let distanceIncrement = liveLocation.distance(from: lastLocation)
            Distance += distanceIncrement
            distance.text = String(format: "%.2f km", Distance / 1000)
            
            let timeIncrement = liveLocation.timestamp.timeIntervalSince(lastLocation.timestamp)
            acceleration = (currentspeed - lastLocation.speed) / timeIncrement
            maxAcceleration.text = String(format: "%.1f m/s²", abs(acceleration))
        }
        
        // Update the last recorded location
        lastLocation = liveLocation
        
        // Center and animate the map to the current location
        myLocation.setCenter(liveLocation.coordinate, animated: true)
        let region = MKCoordinateRegion(center: liveLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        myLocation.setRegion(region, animated: true)
    }
    
    // Calculates the distance needed to exceed a specified speed limit
    func calculateDistanceToExceedSpeedLimit() -> CLLocationDistance {
        let speedLimit = 125.0
        let averageSpeed = totalSpeed / Double(speedReadings)
        let timeToExceedLimit = (speedLimit / (averageSpeed * 3.6))
        let distanceToExceedLimit = timeToExceedLimit * maxspeed * 3.6 * 1000
        return distanceToExceedLimit
    }

}

