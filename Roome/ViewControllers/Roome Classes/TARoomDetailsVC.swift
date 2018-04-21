//
//  TARoomDetailsVC.swift
//  Roome
//
//  Created by Tareq Safia on 4/20/18.
//  Copyright © 2018 Tareq Safia. All rights reserved.
//

import UIKit
import IBAnimatable
import ImageSlideshow
import SwiftyPickerPopover
import SDWebImage
class TARoomDetailsVC: UIViewController {

    @IBOutlet weak var slideShow: ImageSlideshow!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var lbl_avaCount: UILabel!
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_peopleCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_booking: AnimatableButton!
    
    var room_data : [String:Any] = [:]
    private var tenants_data : [[String:Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Room Details"
        self.navigationItem.hideBackWord()
        self.tableView.tableFooterView = UIView()
        self.func_setUpImageSlider()
        self.func_setData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.func_setStyle()
    }

    //MARK: Set Style
    func func_setStyle() {
        btn_booking.setRounded(radius: 10)
        btn_booking.applyGradient(colours: ["17EAD9".color,"6078EA".color], gradientOrientation: .horizontal)
    }
    
    
    //MARK: Show Data
    func func_setData(){
        let title = room_data["title"] as? String ?? ""
        let info  = room_data["info"] as? String ?? ""
        let price = room_data["price"] as? String ?? ""
        let priceInt = Int(Double(price) ?? 0)

        let max_tenants = room_data["max_tenants"] as? Int ?? 0
        let remain = room_data["remain"] as? Int ?? 0
        
        lbl_peopleCount.text =  "\(max_tenants - remain)"
        lbl_avaCount.text = "\(remain)"
        
        self.tenants_data = room_data["tenants"] as? [[String:Any]] ?? []
        self.tableView.reloadData()
        
        lbl_title.text = title
        lbl_subTitle.text = info
        lbl_price.text = "\(priceInt) $"
        self.func_showImageForSlider()
    }
    
    
    //MARK: Show Romm Pictuers
    func func_showImageForSlider(){
        let media = room_data["media"] as? [[String:Any]] ?? []
        var img_array : [String] = []
        for item in media {
            let url = item["url"] as? String ?? ""
           img_array.append(url)
        }
        
        if img_array.count > 0 {
        self.ImagesSlider(img_array)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        slideShow.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func func_setUpImageSlider() {
        slideShow.backgroundColor = UIColor.gray
        slideShow.slideshowInterval = 5.0
        slideShow.pageControlPosition = PageControlPosition.insideScrollView
        slideShow.pageControl.currentPageIndicatorTintColor = "6078EA".color
        slideShow.pageControl.pageIndicatorTintColor = "515151".color
        slideShow.contentScaleMode = .scaleAspectFill
        slideShow.circular = false
        slideShow.activityIndicator = DefaultActivityIndicator()
    }
    
    func ImagesSlider(_ urlImages : [String]) {
        let arr =  urlImages.map { KingfisherSource(urlString: $0 )!}
        slideShow.setImageInputs(arr)
    }
    
    @objc func didTap() {
        slideShow.presentFullScreenController(from: self)
    }
    
    //MARK: Booking Function

    @IBAction func func_booking(_ sender: UIButton) {
        isInterntConnected()
        DatePickerPopover(title: "Booking Date")
            .setDateMode(.date)
            .setMinimumDate(Date().nextDay)
            .setDoneButton(title: "Select", color: UIColor.white, action: { (popover, selectedDate) in
                let date = MyTools.tool.getDateOnly(date: selectedDate)
                self.func_book(date)
            })
            .setCancelButton(title: "Cancel", color: UIColor.white, action: nil)
            .appear(originView: sender, baseViewController: self)
    }
    
    func func_book(_ dateStr:String) {
        self.showIndicator()
        let room_id = room_data["id"] as? Int ?? 0
        MyApi.api.func_Book(room_id, dateStr) { (message, status) in
            self.hideIndicator()
            if !status {
                self.showOkAlert(title: "", message: message)
                self.hideIndicator()
                return
            }
            
            self.showOkAlert(title: "", message: "Your booking request has been sent")

           // self.func_getSingleRoomData()
        }
    }
    
    func func_getSingleRoomData(){
        let room_id = room_data["id"] as? Int ?? 0
        MyApi.api.func_getSingleRoom(room_id) { (item, status) in
            self.hideIndicator()
            if status {
                self.func_setData()
            }
        }
    }
    
}


//MARK: Table View  Delegate & DataSource
extension TARoomDetailsVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tenants_data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : TAPeopleTVCell = tableView.dequeueTVCell()
        let user  = self.tenants_data[indexPath.row]
        let name = user["name"] as? String ?? ""
        let nationality = user["nationality"] as? String ?? "N/A"
        let urlimage = user["urlimage"] as? String ?? ""
        
        cell.lbl_username.text = name
        cell.lbl_country.text = nationality
        let url = URL.init(string: urlimage)
        cell.img_view.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "avatar"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
