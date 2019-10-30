//
//  main.swift
//  Test
//
//  Created by 蔡杰 on 2019/10/29.
//  Copyright © 2019 蔡杰. All rights reserved.
//

import Foundation

print("Hello, World!")

enum Enum1 {
   case none
}

enum Enum2 {
   case none,week
}

enum Enum3 {
   case none,week,mouth
}


func showEnum(){
      var enum1 = Enum1.none
      
      SwiftMemory<Enum1>.show(val: &enum1)
      
      var enmu2 = Enum2.none
      
      SwiftMemory<Enum2>.show(val: &enmu2)
      
       var enmu3 = Enum3.none
      SwiftMemory<Enum3>.show(val: &enmu3)
  }

showEnum()
