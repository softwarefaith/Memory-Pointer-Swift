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
        // Do any additional setup after 
         showClass()
    }
    
}


extension ViewController {
    
    class Person {
        var name: String
        var address: String
        var age:Double = 0

        init(name:String,address:String) {
            self.name = name
            self.address = address
        }
    }
    
    class Human {
        var age: Int?
        var name: String?
        var nicknames: [String] = [String]()

        //返回指向 Human 实例头部的指针
        func headPointerOfClass() -> UnsafeMutablePointer<Int8> {
            let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
            let mutableTypedPointer = opaquePointer.bindMemory(to: Int8.self, capacity: MemoryLayout<Human>.stride)
            return UnsafeMutablePointer<Int8>(mutableTypedPointer)
        }
    }

    
    
    func showClass(){
        
        
        let p0 = Person(name:"cc",address: "asd")
        
        let human = Human()
        human.age = 8
        human.name = "a"
        
        let human1 = human
        
        SwiftMemory<Human>.show(ref: human)
    }
    
    
}


extension ViewController {
    
    struct Point {
        var a: Double?
        var b: Double?
    }
    
    
    func showStruct(){
        
        
        var p0 = Point(a:12,b:30)
        
        SwiftMemory<Point>.show(val: &p0)
    }
    
    
}

extension ViewController {
    
    
    
    func showEnum(){
        var enum1 = Enum1.none
        
        SwiftMemory<Enum1>.show(val: &enum1)
        
        print("实际分配的大小：\( MemoryLayout.stride(ofValue: enum1))")
       
        
        var enmu2 = Enum2.none
        
        SwiftMemory<Enum2>.show(val: &enmu2)
        
        var enmu3 = Enum3.none
        SwiftMemory<Enum3>.show(val: &enmu3)
        
        var e = TestEnum.test1(1, 2, 3)
        SwiftMemory<TestEnum>.show(val: &e)
        e = .test2(4, 5)
         SwiftMemory<TestEnum>.show(val: &e)
        e = .test3(6)
        SwiftMemory<TestEnum>.show(val: &e)
        e = .test4(true)
        SwiftMemory<TestEnum>.show(val: &e)
        e = .test10
        SwiftMemory<TestEnum>.show(val: &e)
        e = .test9(6)
               SwiftMemory<TestEnum>.show(val: &e)
        
        e = .TestEnum1(.test111(8, 8, 8))
                      SwiftMemory<TestEnum>.show(val: &e)
       
    }
    
}



enum TestEnum {
    case test10
    case test3(Int)
    case test9(Int)
    case test2(Int, Int)
    case test4(Bool)
    case test1(Int, Int, Int)
    case TestEnum1(TestEnum1)
}



enum TestEnum1 {
       case test8
       case test9(Int,Int)
       case test5
       case test2(Int)
       case test11(Int, Int)
       case test14(Bool)
       case test111(Int, Int, Int)
       
}

/*
 
 1字节
 */
enum Enum1 {
   case none
}

enum Enum2 {
   case none,week
}

enum Enum3:String {
   case none,week,mouth
   case none1,week1,mouth1
   case none2,week2,mouth2
   case none3,week3,mouth3
}



