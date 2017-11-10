//
//  ClientUtilities.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit

typealias VoidClosure = () -> Void
typealias VCClosure = () -> UIViewController

class ClientUtilites {
    
    static func exampleWith(title: String, description: String, ends: Bool = true, example: VCClosure) -> UIViewController {
        let dash = String(repeating: "-", count: 10)
        print("\n\n\(dash)\n\nSTART OF EXAMPLE: \(title)\n\nDescription: \(description)\n\n\(dash)")
        let vc = example()
        if ends == true { print("\n\(dash)\n\nEND OF EXAMPLE: \(title)\n\n\(dash)") }
        return vc
    }
    
}
