//
//  TAPeopleTVCell.swift
//  Roome
//
//  Created by Tareq Safia on 4/20/18.
//  Copyright © 2018 Tareq Safia. All rights reserved.
//

import UIKit
import IBAnimatable

class TAPeopleTVCell: UITableViewCell {

    @IBOutlet weak var img_view: AnimatableImageView!
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var lbl_country: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
