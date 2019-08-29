//
//  ViewController.swift
//  Memory&Pointer-Swift
//
//  Created by 蔡杰 on 2019/8/29.
//  Copyright © 2019 蔡杰. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var age = 10
        
        UnsafeMutableBufferPointer
        
        withUnsafeBytes(of: &age) { (ageBytes) in
        
            print(ageBytes.count)
            print(ageBytes.first ?? 9999)
            print( ageBytes[0])
        }
        

    }
    
  

}


