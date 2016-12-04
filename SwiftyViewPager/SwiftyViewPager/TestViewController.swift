//
//  TestViewController.swift
//  SwiftyViewPager
//
//  Created by lip on 16/12/4.
//  Copyright © 2016年 lip. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        var array = [UIImage]()
        for i in 1...5{
            let v = UIImage(named: "pkq\(i)")
            array.append(v!)
            
        }
        
        let vp = SwiftyViewPager(viewpagerHeight: 180, imageArray: array, timeInterval: 2.5)
        view.addSubview(vp)
        
    }

}

