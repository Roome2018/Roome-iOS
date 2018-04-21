//
//  MyTools.swift
//  Roome
//
//  Created by Tareq Safia on 4/20/18.
//  Copyright © 2018 Tareq Safia. All rights reserved.
//

import UIKit

class MyTools: NSObject {

    static var tool = MyTools()
    let formatter = DateFormatter()

    func getDateOnly(date:Date) -> String
    {
        //format style :  31-10-2017
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en") as Locale?
        let today = formatter.string(from: date)
        return today
    }
    
}
