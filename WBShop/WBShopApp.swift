//
//  WBShopApp.swift
//  WBShop
//
//  Created by Полина Гельман on 28.06.2026.
//

import SwiftUI
import Core

@main
struct WBShopApp: App {
    init() {
            ServiceLocator.shared.register(service: AuthService() as AuthServicing)
            ServiceLocator.shared.register(service: UserService() as UserServicing)
        }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
