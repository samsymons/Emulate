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
    var ac: Bool = false // Auxiliary carry
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
    var memory: Array<UInt8> = []
}

class EightyEightyCPU: NSObject {
    let instructionLengths: Array<Int>
    var conditionCodes: EightyEightyConditionCodes
    var state: EightyEightyState
    var data: UnsafeBufferPointer<UInt8>?
    
    override init() {
        self.conditionCodes = EightyEightyConditionCodes()
        self.state = EightyEightyState()
        
        self.instructionLengths = [
            1, 3, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
            1, 3, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
            1, 3, 3, 1, 1, 1, 2, 1, 1, 1, 3, 1, 1, 1, 2, 1,
            1, 3, 3, 1, 1, 1, 2, 1, 1, 1, 3, 1, 1, 1, 2, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 1, 3, 3, 3, 1, 2, 1, 1, 1, 3, 3, 3, 3, 2, 1,
            1, 1, 3, 2, 3, 1, 2, 1, 1, 1, 3, 2, 3, 3, 2, 1,
            1, 1, 3, 1, 3, 1, 2, 1, 1, 1, 3, 1, 3, 3, 2, 1,
            1, 1, 3, 1, 3, 1, 2, 1, 1, 1, 3, 1, 3, 3, 2, 1
        ]
    }
    
    func emulate(filePath: String) {
        let bytes = self.dataFromPath(filePath)
        self.data = bytes
        
        var executionLength = 0
        
        // while executionLength < 30 {
        while self.state.pc < 10 {
            let byte = bytes[Int(self.state.pc)]
            var length = self.instructionLengths[Int(self.state.pc)]
            
            switch byte {
            case 0x00, 0x10, 0x20, 0x30, 0x08, 0x18, 0x28, 0x38:
                nop(byte)
            case 0x04:
                self.state.b += 1
                logicFlagsZSP(self.state.b)
            case 0x05:
                self.state.b -= 1
                logicFlagsZSP(self.state.b)
            case 0x06:
                mviBd8(byte)
            // case 0x13:
            // length = inxD(byte)
            case 0x21:
                lxi(byte)
            case 0x40:
                self.state.b = self.state.b
            case 0x41:
                self.state.b = self.state.c
            case 0x42:
                self.state.b = self.state.d
            case 0x43:
                self.state.b = self.state.e
            case 0x44:
                self.state.b = self.state.h
            case 0x45:
                self.state.b = self.state.l
            case 0x47:
                self.state.b = self.state.a
            case 0x48:
                self.state.c = self.state.b
            case 0x49:
                self.state.c = self.state.c
            case 0x4a:
                self.state.c = self.state.d
            case 0x4b:
                self.state.c = self.state.e
            case 0x4c:
                self.state.c = self.state.h
            case 0x4d:
                self.state.c = self.state.l
            case 0x4f:
                self.state.c = self.state.a
            case 0x50:
                self.state.d = self.state.b
            case 0x51:
                self.state.d = self.state.c
            case 0x52:
                self.state.d = self.state.d
            case 0x53:
                self.state.d = self.state.e
            case 0x54:
                self.state.d = self.state.h
            case 0x55:
                self.state.d = self.state.l
            case 0x57:
                self.state.d = self.state.a
            case 0x58:
                self.state.e = self.state.b
            case 0x59:
                self.state.e = self.state.c
            case 0x5a:
                self.state.e = self.state.d
            case 0x5b:
                self.state.e = self.state.e
            case 0x5c:
                self.state.e = self.state.h
            case 0x5e:
                self.state.e = self.state.l
            case 0x5f:
                self.state.e = self.state.a
            case 0xc1:
                self.state.c = self.state.memory.removeLast()
                self.state.b = self.state.memory.removeLast()
                self.state.sp -= 2
            case 0xc3:
                jmp(byte)
            case 0xc5:
                self.state.memory.append(self.state.b)
                self.state.memory.append(self.state.c)
                self.state.sp += 2
            case 0xcd:
                calla16(byte)
            case 0xd4:
                cnc(byte)
            case 0xe5:
                self.state.memory.append(self.state.l)
                self.state.memory.append(self.state.h)
                self.state.sp += 2
            default:
                unimplementedInstruction(byte)
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
    
    func nop(opcode: UInt8) {
        println(NSString(format: "NOP: %02hhx", opcode))
    }
    
    func decrB(opcode: UInt8) {
        // s.d, s.e = hilo(adr(s.d, s.e) + 1)
    }
    
    func inxD(opcode: UInt8) {
        // s.d, s.e = hilo(adr(s.d, s.e) + 1)
    }
    
    func lxi(opcode: UInt8) {
        println(NSString(format: "LXI H, d16: %02hhx", opcode))
        
        self.state.h = byte(2)
        self.state.l = byte(1)
    }
    
    func mviBd8(opcode: UInt8) {
        println(NSString(format: "MVI B, d8: %02hhx", opcode))
        self.state.b = byte(1)
    }
    
    func jmp(opcode: UInt8) {
        let address = memoryAddress(byte(1), lo: byte(2))
        self.state.pc = address
        
        println(NSString(format: "JUMPING: %04lx", address))
    }
    
    func unimplementedInstruction(opcode: UInt8) {
        println(NSString(format: "Unimplemented instruction: %02hhx", opcode))
    }
    
    // MARK: - Calling
    
    func call(address: UInt16) {
        println("CALL: UNIMPLEMENTED")
    }
    
    func cnc(opcode: UInt8) {
        if !self.conditionCodes.cy {
            let address = memoryAddress(byte(1), lo: byte(2))
            call(address)
        }
    }
    
    func calla16(opcode: UInt8) {
        let address = memoryAddress(byte(1), lo: byte(2))
        call(address)
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
