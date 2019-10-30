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
        
        var rawPtr = ptr
        var string:String = ""
        
        //格式化模板
        let fmt = "0x%0\(aligment << 1)lx"
        let count = size / aligment
        for i in 0 ..< count {
            if i > 0 {
                string.append(" ")
                rawPtr += aligment
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
    
    private static func _memoryBytes(_ ptr: UnsafeRawPointer,
                                     _ size: Int) -> [UInt8] {
           var arr: [UInt8] = []
           if ptr == EMPTY_POINTER { return arr }
           for i in 0..<size {
               arr.append((ptr + i).load(as: UInt8.self))
           }
           return arr
       }
    
    //MARK:变量
    public static func size(ofValue v:inout T) -> Int {
        return MemoryLayout.size(ofValue:v)>0 ? MemoryLayout.stride(ofValue: v): 0
    }
    
    public static func pointer(ofValue v:inout T) -> UnsafeRawPointer {
        return MemoryLayout.size(ofValue: v) == 0 ? EMPTY_POINTER : withUnsafePointer(to: &v){ UnsafeRawPointer($0)}
    }
    
    
    public static func memoryStr(ofValue v:inout T ,alinment:MemoryAlign? = nil)-> String{
        
        let p = pointer(ofValue: &v)
        return _memoryStr(p, MemoryLayout.stride(ofValue: v), alinment != nil ? alinment!.rawValue : MemoryLayout.alignment(ofValue: v))
    }
    
    public static func memoryBytes(ofValue v: inout T) -> [UInt8] {
        return _memoryBytes(pointer(ofValue: &v), MemoryLayout.stride(ofValue: v))
       }
    
    //堆变量-> 引用
    //MARK: 引用
    public static func pointer(ofRefValue v: T) -> UnsafeRawPointer {
       
        if v is Array<Any>
            || Swift.type(of: v) is AnyClass
            || v is AnyClass {
            
            return UnsafeRawPointer(bitPattern: unsafeBitCast(v, to: UInt.self))!
        } else if v is String {
            var mstr = v as! String
            if mstr.memorys.type() != .heap {
                return EMPTY_POINTER
            }
            return UnsafeRawPointer(bitPattern: unsafeBitCast(v, to: (UInt,UInt).self).1)!

        }
        
        return EMPTY_POINTER
    }
    
    public static func size(ofRefValue v: T) -> Int {
           return malloc_size(pointer(ofRefValue: v))
    }
    
    public static func memoryStr(ofRefValue v: T ,alinment:MemoryAlign? = nil)-> String{
           
           let p = pointer(ofRefValue: v)
           return _memoryStr(p, malloc_size(p), alinment != nil ? alinment!.rawValue : MemoryLayout.alignment(ofValue: v))
           
       }
    
    public static func memoryBytes(ofRefValue v: T) -> [UInt8] {
        let p = pointer(ofRefValue: v)
        return _memoryBytes(p, MemoryLayout.stride(ofValue: v))
    }
    
}

public enum StringMemoryType : UInt8 {
    /// TEXT段（常量区）
    case text = 0xd0
    /// taggerPointer
    case tagPtr = 0xe0
    /// 堆空间
    case heap = 0xf0
    /// 未知
    case unknow = 0xff
}

public struct MemoryWrapper<Base> {
    public private(set) var base: Base
    public init(_ base: Base) {
        self.base = base
        
        
    }
}

public protocol MemoryCompatible{}
public extension MemoryCompatible {
    
     static var memorys: MemoryWrapper<Self>.Type {
           get { MemoryWrapper<Self>.self }
           set {}
      }
    
     var memorys: MemoryWrapper<Self> {
        get { MemoryWrapper(self) }
        set {}
     }
    var memoryss: MemoryWrapper<Self> {
           get { MemoryWrapper(self) }
           set {}
        }
}

extension String:MemoryCompatible{}

public extension MemoryWrapper where Base == String {
    
    mutating func type() -> StringMemoryType {
        let ptr = SwiftMemory.pointer(ofValue: &base)
        return StringMemoryType(rawValue: (ptr + 15).load(as: UInt8.self) & 0xf0)
                   ?? StringMemoryType(rawValue: (ptr + 7).load(as: UInt8.self) & 0xf0)
                   ?? .unknow
    }
}

extension SwiftMemory {
    
   static func show<T>(val: inout T) {
        print("-------------- \(type(of: val)) --------------")
        print("变量的地址:", SwiftMemory<T>.pointer(ofValue: &val))
        print("变量的内存:", SwiftMemory<T>.memoryStr(ofValue: &val)  )
        print("变量的大小:", SwiftMemory<T>.size(ofValue: &val))
      //  print("变量的内存数据:", SwiftMemory<T>.memoryBytes(ofValue: &val))
        print("")
    }

   static func show<T>(ref:T) {
       print("-------------- \(type(of: ref)) --------------")
    
       var ss:String? = ref as?String
       if ss != nil {
          print("字符串存储空间:\(ss!.memorys.type())")
       }
    
    
       print("变量的地址:", SwiftMemory<T>.pointer(ofRefValue:ref))
       print("变量的内存:", SwiftMemory<T>.memoryStr(ofRefValue: ref)  )
       print("变量的大小:", SwiftMemory<T>.size(ofRefValue: ref))
      // print("变量的内存数据:", SwiftMemory<T>.memoryBytes(ofRefValue: ref))
       print("")
   }
    
    
}
