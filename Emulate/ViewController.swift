//
//  ViewController.swift
//  Emulate
//
//  Created by Sam Symons on 2015-04-15.
//  Copyright (c) 2015 Sam Symons. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let finder = CartridgeFinder()
        finder.cartridges()
        
        let path = NSBundle.mainBundle().pathForResource("SpaceInvaders", ofType: "rom")
        let cpu = EightyEightyCPU()
        cpu.emulate(path!)
    }

}
