//
//  TAMapViewVC.swift
//  Roome
//
//  Created by Tareq Safia on 4/20/18.
//  Copyright © 2018 Tareq Safia. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class TAMapViewVC: UIViewController , CLLocationManagerDelegate , GMSMapViewDelegate{

    @IBOutlet weak var mapView: GMSMapView!
    private var locationManag = CLLocationManager()
    private var latitude : Double = 0
    private var longitude : Double = 0
    private var array_rooms : [[String:Any]] = []
    private var myMarker: GMSMarker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hideBackWord()
        func_enableLocation()
        func_setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.func_getRooms()
    }
    
    //MARK: Location & Map Functions
    func func_setupMapView() {
        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.delegate = self
    }
    
    func func_enableLocation(){
        self.locationManag = CLLocationManager()
        self.locationManag.delegate = self
        self.locationManag.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            self.self.isLocationEnable("please enable location services to locatio your location for get apartment")
            break
        }
    }
    
    func isLocationEnable(_ message : String) {
        self.showCustomAlert(okFlag: false, title: "", message: message, okTitle: "OK", cancelTitle: "Cancel") { (action) in
            if action {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        let Location : CLLocationCoordinate2D = (location.coordinate)
        latitude = Location.latitude
        longitude = Location.longitude
        self.func_drawMarker()
        self.locationManag.stopUpdatingLocation()
    }

    func func_drawMarker(){
        let camera = GMSCameraPosition.camera(withLatitude:CLLocationDegrees(latitude) ,
                                              longitude:CLLocationDegrees(longitude) , zoom: 12)
        mapView.camera = camera
        mapView.animate(to: camera)
//
//        myMarker = GMSMarker()
//        myMarker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        myMarker.icon = UIImage(named: "marker-point")!
//        myMarker.map = self.mapView
//        myMarker.opacity = 1.0
    }
    
    
    //MARK: Get Rooms Function
    
    func func_getRooms(){
        self.showIndicator()
        MyApi.api.func_rooms { (items, status) in
            self.hideIndicator()
            self.array_rooms = items
            self.func_drawMarkers()
        }
    }
    
  
    ////
    
    func func_drawMarkers(){
        
        for room in array_rooms {
            let latitude = room["location_latitude"] as? Double ?? 0
            let longitude = room["location_longitude"] as? Double ?? 0

            let fullMarker = TACustomMarker()
            fullMarker.roomData = room
            fullMarker.position = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
            fullMarker.title = title
            fullMarker.icon = UIImage(named: "marker-point")!
            fullMarker.map = self.mapView
            fullMarker.opacity = 1.0
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if marker != myMarker {
            let customM = marker as! TACustomMarker
            let item = customM.roomData
            let title = item!["title"] as? String ?? ""
            let info  = item!["info"] as? String ?? ""
            
            let remain = item!["remain"] as? Int ?? 0
            
            let infoWindow2 = Bundle.main.loadNibNamed("UserInfoWindow", owner: self, options: nil)!.first as! TAUserInfoWindowView
            infoWindow2.title_str = title
            infoWindow2.desc_str = info
            infoWindow2.ava_count = remain

            return infoWindow2
            
        }
        
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if marker != myMarker
        {
            let selectedMarker = marker as! TACustomMarker
            let vc : TARoomDetailsVC = AppDelegate.Storyboard.instanceVC()
            vc.room_data = selectedMarker.roomData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Add Room Function
    @IBAction func func_addNewRoom(_ sender: UIButton) {
        let vc : TAAddRoomVC = AppDelegate.Storyboard.instanceVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: Logout Function
    @IBAction func func_logout(_ sender: UIBarButtonItem) {
        
        self.showCustomAlert(okFlag: false, title: "Logout 😟", message: "Do you want to logout?", okTitle: "OK", cancelTitle: "No") { (status) in
            if status {
                Auth_User.AccessToken = ""
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let vc : TALoginVC = AppDelegate.Storyboard.instanceVC()
                appdelegate.window?.rootViewController = vc
            }
        }
    }
    
}
