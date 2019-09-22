//
//  DarkModeProtocol.swift
//  Fast Reader
//
//  Created by Илья Канищев on 11/08/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import Foundation

@objc public protocol DarkModeApplicable {
    @objc func toggleDarkMode()
    @objc func toggleLightMode()
}
