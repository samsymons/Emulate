//
//  CartridgeFinder.swift
//  Emulate
//
//  Created by Sam Symons on 2015-04-15.
//  Copyright (c) 2015 Sam Symons. All rights reserved.
//

import UIKit

struct Cartridge {
    var name: String
    var artworkURL: NSURL
    var location: NSURL
    
    init(name: String, artworkURL: NSURL, location: NSURL) {
        self.name = name
        self.artworkURL = artworkURL
        self.location = location
    }
}

class CartridgeFinder: NSObject {
    var rootURL: NSURL
    
    convenience override init() {
        let defaultLocation = NSURL(fileURLWithPath: "ROMs/8080")
        self.init(rootURL: defaultLocation!)
    }
    
    init(rootURL: NSURL) {
        self.rootURL = rootURL
        super.init()
    }
    
    func cartridges() -> NSArray {
        let spaceInvadersURL = NSBundle.mainBundle().URLForResource("SpaceInvaders", withExtension: "rom")
        return []
    }
}
