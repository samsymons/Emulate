//
//  EightyEightyCPU.swift
//  Emulate
//
//  Created by Sam Symons on 2015-04-16.
//  Copyright (c) 2015 Sam Symons. All rights reserved.
//

import UIKit

struct EightyEightyConditionCodes {
    var z: UInt8 = 0 // Zero flag, for when a result is 0
    var s: UInt8 = 0 // Sign flag, set when the MSB is 1
    var p: UInt8 = 0 // Parity flag
    var cy: UInt8 = 0
    var ac: UInt8 = 0
}

struct EightyEightyState {
    var a: UInt8 = 0
    var b: UInt8 = 0
    var c: UInt8 = 0
    var d: UInt8 = 0
    var e: UInt8 = 0
    var h: UInt8 = 0
    var l: UInt8 = 0
    var sp: UInt16 = 0
    var pc: UInt16 = 0
}

class EightyEightyCPU: NSObject {
    var conditionCodes: EightyEightyConditionCodes
    var state: EightyEightyState
    var data: UnsafeBufferPointer<UInt8>?
    
    override init() {
        self.conditionCodes = EightyEightyConditionCodes()
        self.state = EightyEightyState()
    }
    
    func emulate(filePath: String) {
        let bytes = self.dataFromPath(filePath)
        self.data = bytes
        
        var executionLength = 0
        
        // while self.state.pc < 10 {
        while executionLength < 10 {
            let byte = bytes[Int(self.state.pc)]
            var length = 1
            
            switch byte {
            case 0x00, 0x10, 0x20, 0x30:
                length = nop(byte)
            case 0x06:
                length = mviBd8(byte)
            case 0xc3:
                length = jmp(byte)
            case 0xcd:
                length = jmp(byte)
            case 0xe6:
                length = jmp(byte)
            default:
                length = unimplementedInstruction(byte)
            }
            
            self.state.pc = self.state.pc + UInt16(length)
            executionLength++
        }
    }
    
    // MARK: - Private
    
    private func dataFromPath(path: String) -> UnsafeBufferPointer<UInt8> {
        let data = NSData(contentsOfFile: path)
        let ptr = UnsafePointer<UInt8>(data!.bytes)
        
        return UnsafeBufferPointer<UInt8>(start:ptr, count:data!.length)
    }
    
    private func memoryAddress(hi: UInt8, lo: UInt8) -> UInt16 {
        let bytes:[UInt8] = [hi, lo]
        return UnsafePointer<UInt16>(bytes).memory
    }
    
    // MARK: - Instructions
    
    func nop(byte: UInt8) -> Int {
        println(NSString(format: "NOP: %02hhx", byte))
        return 1
    }
    
    func mviBd8(byte: UInt8) -> Int {
        println(NSString(format: "MVI B, d8: %02hhx", byte))
        
        let argument = self.data![Int(self.state.pc + UInt16(1))]
        self.state.b = argument
        
        return 2
    }
    
    func jmp(byte: UInt8) -> Int {
        let hiByte = self.data![Int(self.state.pc + UInt16(1))]
        let loByte = self.data![Int(self.state.pc + UInt16(2))]
        
        let address = memoryAddress(hiByte, lo: loByte)
        self.state.pc = address
        
        println(NSString(format: "JUMPING: %04lx", address))
        
        return 3
    }
    
    func unimplementedInstruction(byte: UInt8) -> Int {
        println(NSString(format: "Unimplemented instruction: %02hhx", byte))
        return 1
    }
}
