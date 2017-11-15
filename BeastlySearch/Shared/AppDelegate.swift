//
//  AppDelegate.swift
//  BeastlySearch
//
//  Created by Trevor Beasty on 11/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

import UIKit
import CoreData

fileprivate enum Client {
    case filterCompositor
    case filterSelectorScene
    case coreDataFilterCompositor
    
    var viewController: UIViewController {
        switch self {
        case .filterCompositor:
            return FilterCompositorClient.usedCarExample()
        case .filterSelectorScene:
            return FilterSelectorSceneClient.usedCarsFilterSelectorScene()
        case .coreDataFilterCompositor:
            return CoreDataClient.carExample()
        }
    }
    
    static var nonInteractive: [Client] { return [.filterCompositor, .coreDataFilterCompositor] }
    static var interactive: [Client] { return [.filterSelectorScene] }
    
    static func runNonInteractive() {
        nonInteractive.forEach { (client) in
            let _ = client.viewController
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Client.runNonInteractive()
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        
        return true
    }

}

