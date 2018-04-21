//
//  TAAddRoomVC.swift
//  Roome
//
//  Created by Tareq Safia on 4/20/18.
//  Copyright © 2018 Tareq Safia. All rights reserved.
//

import UIKit
import IBAnimatable
import ImagePicker
import GooglePlaces
import GooglePlacePicker

class TAAddRoomVC: UIViewController {
    
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_ownerName: UITextField!
    @IBOutlet weak var txt_price: UITextField!
    @IBOutlet weak var txt_maxTenants: UITextField!
    @IBOutlet weak var btn_address: UIButton!
    @IBOutlet weak var txt_info: AnimatableTextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collection_height: NSLayoutConstraint!
    private var selected_images : [UIImage] = []
    private var address = ""
    private var latitude : Double = 0
    private var longitude : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title  = "ADD NEW ROOM"
        collection_height.constant = 0
    }
    
    
    //MARK: Selec Room Images Function
    @IBAction func func_selecRoomImages(_ sender: UIButton) {
        let imagePicker = ImagePickerController()
        
        imagePicker.imageLimit = 4 - selected_images.count
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @IBAction func func_selectAddress(_ sender: UIButton) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.navigationController?.navigationBar.barTintColor = UIColor.white
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    
    //MARK: Add Room Function
    @IBAction func func_addRoom(_ sender: UIButton) {
        self.isInterntConnected()
        
        guard let title = txt_title.text , !title.isEmpty else {
            self.showOkAlert(title: "", message: "please enter room title")
            return
        }
        
        guard let owner = txt_ownerName.text , !owner.isEmpty else {
            self.showOkAlert(title: "", message: "please enter owner name")
            return
        }
        
        guard let info = txt_info.text , !info.isEmpty else {
            self.showOkAlert(title: "", message: "please enter room info")
            return
        }
        
        
        
        guard let price = txt_price.text , !price.isEmpty else {
            self.showOkAlert(title: "", message: "please enter price")
            return
        }
        
        
        guard let team_count = txt_maxTenants.text , !team_count.isEmpty else {
            self.showOkAlert(title: "", message: "please enter max tenants count")
            return
        }
        
        guard  address != "" else {
            self.showOkAlert(title: "", message: "please enter address")
            return
        }
        
        guard  selected_images.count > 0 else {
            self.showOkAlert(title: "", message: "please enter room pictuers")
            return
        }
        
        self.showIndicator()
        
        MyApi.api.func_uploadImages(selected_images) { (photos_ids, status) in
            if !status {
                self.hideIndicator()
                return
            }
            
            MyApi.api.func_addRoom(title, info, price, owner , team_count,
                                   self.address, self.latitude, self.longitude, photos_ids, completion: { (message, success) in
                self.hideIndicator()
                if !status {
                    self.showOkAlert(title: "", message: message)
                    return
                }
                
                let msg = "Room has been added successfully"
                self.showOkAlertWithComp(title: "", message: msg, completion: { (_) in
                    self.navigationController?.pop(animated: true)
                })
            })
        }
    }
    
    
    
}

extension TAAddRoomVC : UICollectionViewDelegate, UICollectionViewDataSource , ImagePickerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selected_images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : TAImageCVCell = collectionView.dequeueCVCell(indexPath: indexPath)
        cell.img_view.image = selected_images[indexPath.item]
        cell.img_view.setRounded(radius: 8)
        cell.btn_delete.tag = indexPath.item
        cell.btn_delete.addTarget(self, action: #selector(func_deleteImage(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func func_deleteImage(_ sender:UIButton)  {
        selected_images.remove(at: sender.tag)
        self.collectionView.reloadData()
        if selected_images.count == 0 {
            collection_height.constant  = 0
        }
    }
    
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) { }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        imagePicker.dismiss(animated: true) {
            self.selected_images = images
            self.collection_height.constant = 200
            self.collectionView.reloadData()
        }
    }
}

extension TAAddRoomVC : GMSPlacePickerViewControllerDelegate
{
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        
        viewController.dismiss(animated: true, completion: nil)
        
        self.latitude = Double(place.coordinate.latitude)
        self.longitude = Double(place.coordinate.longitude)
        
        if  place.formattedAddress != nil {
            let address = (place.formattedAddress?.components(separatedBy: ", ")
                .joined(separator: "\n"))!
            self.address = address
            self.btn_address.setTitle(address, for: .normal)
        }else {
            self.func_getAddress()
        }
    }
    
    func func_getAddress()
    {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        geoCoder.cancelGeocode()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            var addressString: String! = ""
            
            let placemark = placemarks?.last!
            if placemark?.subThoroughfare != nil
            {
                addressString = (placemark?.subThoroughfare!)! + " "
            }
            if placemark?.thoroughfare != nil
            {
                addressString = addressString + (placemark?.thoroughfare!)! + ", "
            }
            if placemark?.postalCode != nil
            {
                addressString = addressString + (placemark?.postalCode!)! + " "
            }
            if placemark?.locality != nil
            {
                addressString = addressString + (placemark?.locality!)! + ", "
            }
            if placemark?.administrativeArea != nil
            {
                addressString = addressString + (placemark?.administrativeArea!)! + " "
            }
            if placemark?.country != nil
            {
                addressString = addressString + (placemark?.country!)!
            }
            
            self.address = addressString
        })
    }
    
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

}

