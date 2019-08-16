//
//  AppDelegate.swift
//  ColorScreen
//
//  Created by Nick Trienens on 05/25/2019.
//  Copyright (c) 2019 Nick Trienens. All rights reserved.
//

import DeviceKit
import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white

        FirebaseConfiguration.shared.setLoggerLevel(FirebaseLoggerLevel.min)
        FirebaseApp.configure()

//        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: "us-west-2:b48635c0-74dd-48ee-b8f1-b522b476b9db")
//        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider)
//        AWSServiceManager.default().defaultServiceConfiguration = configuration

        if Device.current.isOneOf([Device.iPadMini4, Device.iPadMini5, Device.iPadMini3, Device.iPadPro11Inch]) {
            window?.rootViewController = PadViewController()
        } else {
            window?.rootViewController = PhoneViewController()
        }
        window?.makeKeyAndVisible()

        return true
    }
}
