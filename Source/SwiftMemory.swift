//
//  SwiftMemory.swift
//  Memory&Pointer-Swift
//
//  Created by 蔡杰 on 2019/10/22.
//  Copyright © 2019 蔡杰. All rights reserved.
//
/*
 
 学习 李明杰 Mems 开源代码
 
 */

import Foundation

public enum MemoryAlign : Int {
    case one = 1, two = 2, four = 4, eight = 8
}

private let EMPTY_POINTER = UnsafeRawPointer(bitPattern: 0x1)!


public struct SwiftMemory<T>{
    
    private static func _memoryStr(_ ptr: UnsafeRawPointer,
    _ size: Int,
    _ aligment: Int) ->String {
        
        if ptr == EMPTY_POINTER  { return ""}
        
        let rawPtr = ptr
        var string:String = ""
        
        //格式化模板
        let fmt = "0x%0\(aligment << 1)lx"
        let count = size / aligment
        for i in 0 ..< count {
            if i > 0 {
                string.append(" ")
            }
            let value: CVarArg
            switch aligment {
                       case MemoryAlign.eight.rawValue:
                           value = rawPtr.load(as: UInt64.self)
                       case MemoryAlign.four.rawValue:
                           value = rawPtr.load(as: UInt32.self)
                       case MemoryAlign.two.rawValue:
                           value = rawPtr.load(as: UInt16.self)
                       default:
                           value = rawPtr.load(as: UInt8.self)
                }
            string.append(String(format: fmt, value))
        }
        
        
        return string
    }
    
    //MARK:变量
    public static func size(ofValue v:T) -> Int {
        return MemoryLayout.size(ofValue:v)>0 ? MemoryLayout.stride(ofValue: v): 0
    }
    
    public static func pointer(ofValue v:inout T) -> UnsafeRawPointer {
        return MemoryLayout.size(ofValue: v) == 0 ? EMPTY_POINTER : withUnsafePointer(to: &v){ UnsafeRawPointer($0)}
    }
    
    
    public static func memoryStr(ofValue v:inout T ,alinment:MemoryAlign? = nil)-> String{
        
        let p = pointer(ofValue: &v)
        return _memoryStr(p, MemoryLayout.stride(ofValue: v), alinment != nil ? alinment!.rawValue : MemoryLayout.alignment(ofValue: v))
        
    }
    
    
}
