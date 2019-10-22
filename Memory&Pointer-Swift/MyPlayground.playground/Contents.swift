import UIKit

 let fmt = "0x%0\(4 << 1)lx"

var str = "Hello, playground"


let a = MemoryLayout<UnsafeBufferPointer<Int>>.stride

let count = 4
let stride = MemoryLayout<Int>.stride
let alignment = MemoryLayout<Int>.alignment
let bytecount = stride * count

//MARK:Using Raw Pointers
do {
    //开辟了 16个字节的内存空间
    let pointer = UnsafeMutableRawPointer.allocate(byteCount: bytecount, alignment: alignment)

    defer {
        pointer.deallocate()
    }
    //内存空间写
    pointer.storeBytes(of: 42, as: Int.self)//前8个字节存42
    
    //偏移8个字节,储存 6
    pointer.advanced(by: stride).storeBytes(of: 6, as: Int.self)//后8个字节存
    //偏移两次，存储 10
    (pointer + 2).storeBytes(of: 10, as: Int.self)
    //pointer.advanced(by: stride).advanced(by: stride).storeBytes(of: 10, as: Int.self)
    //与上一句等价
   // pointer.storeBytes(of: 8, toByteOffset: stride*3, as: Int.self)
    
//    let a = pointer.move()
//    print(a)
    
    //内存空间读
    pointer.load(as: Int.self)
    pointer.advanced(by: stride).load(as: Int.self)
    pointer.advanced(by: stride).advanced(by: stride).load(as: Int.self)
    //与上一句等价，唯一不同的是从开头偏移多少字节直接读取，advanced  返回一个偏移量的指针
    pointer.load(fromByteOffset: stride*3, as: Int.self)
    
    //一字节一字节访问
    let bufferPointer = UnsafeMutableRawBufferPointer(start: pointer, count: bytecount)
    for (index,byte) in bufferPointer.enumerated(){
       // print("byte\(index):\(byte)")
    }
    
    
}

do {
    
    
    let count = 2
    let ptr = UnsafeMutablePointer<Int>.allocate(capacity: count)
    let buffer = UnsafeMutableBufferPointer(start: ptr, count: count)
    for (i, _) in buffer.enumerated(){
        buffer[i] = Int(arc4random())
    }

    print(buffer)
    // Do stuff...

    ptr.deallocate()   // Don't forget to dealloc!
    
}

//MARK:Using Typed Pointers

do {
    
    let pointer = UnsafeMutablePointer<Int>.allocate(capacity: count)

    //初始化  count: 从当前位置起，初始化前两个单位
    pointer.initialize(repeating: 1, count: 2) //全部初始化为 1
   // pointer.initialize(to: 2)//第一个字节初始化化为1
    pointer.successor().initialize(to: 2)//第2个字节初始化为2
    pointer.successor().successor().initialize(to: 3)
    pointer.successor().successor().successor().initialize(to: 4)

    
    defer {
        pointer.deinitialize(count: count) //initialize 与deinitialize次数一致
        pointer.deallocate()
    }
    //设置 前边指定了 类型 Int，所以这里偏移实际 = 1 * Int.Stride
    pointer.advanced(by: 1).pointee = 6
    
    //读取
    print(pointer.pointee)
    print(pointer.advanced(by: 1).pointee)
    print((pointer+2).pointee)
    print((pointer+3).pointee)
}

//MARK:Converting Raw Pointers to Typed Pointers
do{
    let rawPointer = UnsafeMutableRawPointer.allocate(byteCount: bytecount, alignment: alignment)
    
    defer {
        rawPointer.deallocate()
    }
    
    let typedPointer = rawPointer.bindMemory(to: Int.self, capacity: count)
    typedPointer.initialize(repeating: 0, count: count)
    typedPointer.pointee = 42
    typedPointer.deinitialize(count: count)
}

//MARK:
do {
    let rawPointer = UnsafeMutableRawPointer.allocate(byteCount: bytecount, alignment: 1)
    
    defer {
        rawPointer.deallocate()
    }
    
    //类型为Int，读8个字节
    rawPointer.assumingMemoryBound(to: Int.self).pointee = 11
    rawPointer.advanced(by: 8).assumingMemoryBound(to: Int.self).pointee = 22
    
    rawPointer.load(as: Int.self)
    rawPointer.advanced(by: 8).load(as: Int.self)
    
    print(rawPointer.assumingMemoryBound(to: Int.self).pointee)
    
    print(unsafeBitCast(rawPointer, to: UnsafePointer<Int>.self).pointee)
}

//MARK: Getting The Bytes of an Instance
struct SampleStruct {
    let number: UInt32
    let flag: Bool
}
do {
    var sample = SampleStruct(number: 25, flag: false)
    
    //
    withUnsafeBytes(of: &sample) { (bytes)->Void in
        
    }
}

//Three Rules of Unsafe Club
/*
 1.Don’t return the pointer from withUnsafeBytes!
 
 2.Only bind to one type at a time!->bindMemory
 
 3. Don’t walk off the end  不要越界访问
 */
