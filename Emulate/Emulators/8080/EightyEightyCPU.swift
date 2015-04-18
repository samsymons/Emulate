//
//  EightyEightyCPU.swift
//  Emulate
//
//  Created by Sam Symons on 2015-04-16.
//  Copyright (c) 2015 Sam Symons. All rights reserved.
//

import UIKit

struct EightyEightyConditionCodes {
    var z: Bool = false // Zero flag, for when a result is 0
    var s: Bool = false // Sign flag, set when the MSB is 1
    var p: Bool = false // Parity flag
    var cy: Bool = false // Carry flag
    var ac: Bool = false // Auxillary carry
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
        while executionLength < 30 {
            let byte = bytes[Int(self.state.pc)]
            var length = 1
            
            switch byte {
            case 0x00, 0x10, 0x20, 0x30:
                length = nop(byte)
            case 0x04:
                self.state.b += 1
                logicFlagsZSP(self.state.b)
            case 0x05:
                self.state.b -= 1
                logicFlagsZSP(self.state.b)
            case 0x06:
                length = mviBd8(byte)
            // case 0x13:
            // length = inxD(byte)
            case 0x21:
                length = lxi(byte)
            case 0xc3:
                length = jmp(byte)
            case 0xcd:
                length = calla16(byte)
            default:
                length = unimplementedInstruction(byte)
            }
            
            self.state.pc = self.state.pc + UInt16(length)
            executionLength++
        }
    }
    
    // MARK: - Private
    
    private func resetCPU() {
        self.conditionCodes = EightyEightyConditionCodes()
        self.state = EightyEightyState()
    }
    
    private func dataFromPath(path: String) -> UnsafeBufferPointer<UInt8> {
        let data = NSData(contentsOfFile: path)
        let ptr = UnsafePointer<UInt8>(data!.bytes)
        
        return UnsafeBufferPointer<UInt8>(start:ptr, count:data!.length)
    }
    
    private func memoryAddress(hi: UInt8, lo: UInt8) -> UInt16 {
        let bytes:[UInt8] = [hi, lo]
        return UnsafePointer<UInt16>(bytes).memory
    }
    
    private func byte(offset: Int) -> UInt8 {
        return self.data![Int(self.state.pc + UInt16(offset))]
    }
    
    // MARK: - Instructions
    
    func nop(opcode: UInt8) -> Int {
        println(NSString(format: "NOP: %02hhx", opcode))
        return 1
    }
    
    func decrB(opcode: UInt8) -> Int {
        // s.d, s.e = hilo(adr(s.d, s.e) + 1)
        
        return 1;
    }
    
    func inxD(opcode: UInt8) -> Int {
        // s.d, s.e = hilo(adr(s.d, s.e) + 1)
        
        return 1;
    }
    
    func lxi(opcode: UInt8) -> Int {
        println(NSString(format: "LXI H, d16: %02hhx", opcode))
        
        self.state.h = byte(2)
        self.state.l = byte(1)
        
        return 3
    }
    
    func mviBd8(opcode: UInt8) -> Int {
        println(NSString(format: "MVI B, d8: %02hhx", opcode))
        self.state.b = byte(1)
        
        return 2
    }
    
    func jmp(opcode: UInt8) -> Int {
        let address = memoryAddress(byte(1), lo: byte(2))
        self.state.pc = address
        
        println(NSString(format: "JUMPING: %04lx", address))
        
        return 3
    }
    
    func unimplementedInstruction(opcode: UInt8) -> Int {
        println(NSString(format: "Unimplemented instruction: %02hhx", opcode))
        return 1
    }
    
    // MARK: - Calling
    
    func call(address: UInt16) {
        println("CALL: UNIMPLEMENTED")
    }
    
    func calla16(opcode: UInt8) -> Int {
        let address = memoryAddress(byte(1), lo: byte(2))
        call(address)
        
        return 3
    }
    
    // MARK: - Arithmetic
    
    func ana(byte: UInt8) {
        self.state.a &= byte
        logicFlagsA()
    }
    
    func xra(byte: UInt8) {
        self.state.a ^= byte
        logicFlagsA()
    }
    
    func ora(byte: UInt8) {
        self.state.a |= byte
        logicFlagsA()
    }
    
    // MARK: - Flags
    
    func logicFlagsA() {
        self.conditionCodes.cy = false
        self.conditionCodes.ac = false
        self.conditionCodes.z = (self.state.a == UInt8(0))
        self.conditionCodes.s = (0x80 == self.state.a & 0x80)
        self.conditionCodes.p = parity(self.state.a)
    }
    
    func logicFlagsZSP(value: UInt8) {
        self.conditionCodes.z = value == 0
        self.conditionCodes.s = 0x80 == (value & 0x80)
        self.conditionCodes.p = parity(value)
    }
    
    func parity(byte: UInt8) -> Bool {
        return false
    }
}
