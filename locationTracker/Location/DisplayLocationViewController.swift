//
//  DisplayLocationViewController.swift
//  locationTracker
//
//  Created by Rutwik Shinde on 05/03/22.
//

import UIKit
import CoreLocation
import MapKit

class DisplayLocationViewController: UIViewController {
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var allowPermissionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let updateInterval = 5.0
    var isFirstUpdate = true
    var latestLocation: CLLocation = CLLocation()
    
    private var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isHidden = true
        setupLocationManager()
        handleLocationAuthorizationStatus()
    }
    
    func handleLocationAuthorizationStatus() {
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            allowPermissionLabel.isHidden = true
        case .denied, .restricted:
            handlePermissionDeniedCase()
        default:
            break
        }
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.allowsBackgroundLocationUpdates = true
    }
    
    @objc func handleUpdates(timer: Timer!) {
        switch locationManager?.authorizationStatus {
        case .denied, .restricted, .notDetermined:
            break
        default:
            locationManager?.requestLocation()
            fileHandlingForLocation()
        }
    }
    
    func handlePermissionDeniedCase() {
        allowPermissionLabel.isHidden = false
    }
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
        // resetting all user data and moving back to login screen
        UserDefaults.standard.resetKeys()
        
        let userDetailsVC = UserDetailsViewController()
        userDetailsVC.modalPresentationStyle = .fullScreen
        userDetailsVC.modalTransitionStyle = .crossDissolve
        present(userDetailsVC, animated: true)
    }
    
    // TODO
    func fileHandlingForLocation() {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let str = "\(latestLocation) logged at \(formatter.string(from: Date()))\n"
        let header = "Location Data\n"
        let fileName = "locations.txt"
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
                
        // create file if doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            fileManager.createFile(atPath: url.path, contents: header.data(using: .utf8), attributes: nil)
        }
        
        // append location data to file
        if let fileUpdater = try? FileHandle(forUpdating: url) {
            fileUpdater.seekToEndOfFile()
            fileUpdater.write(str.data(using: .utf8)!)
            fileUpdater.closeFile()
        }
    }
}


extension DisplayLocationViewController: CLLocationManagerDelegate {
    func addTimerForFileUpdates(time: TimeInterval) {
        let _ = Timer.scheduledTimer(timeInterval: time,
                                     target: self,
                                     selector: #selector(handleUpdates(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func handleUiOnLocationUpdate(_ location: CLLocation) {
        mapView.isHidden = false
        allowPermissionLabel.isHidden = true
        latitudeLabel.text = "Latitude: \(location.coordinate.latitude)"
        longitudeLabel.text = "Longitude: \(location.coordinate.longitude)"
        
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.removeAnnotations(self.mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latestLocation = location
            
            if isFirstUpdate {
                isFirstUpdate = false
                fileHandlingForLocation()
                addTimerForFileUpdates(time: updateInterval)
            }
            handleUiOnLocationUpdate(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied,.restricted:
            handlePermissionDeniedCase()
        default:
            break
        }
    }
}
