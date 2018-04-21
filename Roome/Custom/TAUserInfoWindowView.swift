//
//  TAUserInfoWindowView.swift
//  Heat Map
//
//  Created by Tareq Safia on 10/3/17.
//  Copyright © 2017 Tareq Safia. All rights reserved.
//

import UIKit

class TAUserInfoWindowView: UIView {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_count: UILabel!
    @IBOutlet weak var lbl_desc: UILabel!
    
    
    var userId = ""
    var title_str = ""
    var desc_str = ""
    var ava_count = 0

    override func draw(_ rect: CGRect) {
        
        lbl_title.text = title_str
        lbl_desc.text = desc_str
        lbl_count.text = "\(ava_count)"

    }

}
