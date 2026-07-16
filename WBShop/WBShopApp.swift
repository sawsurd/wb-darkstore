//
//  WBShopApp.swift
//  WBShop
//
//  Created by Полина Гельман on 28.06.2026.
//

import SwiftUI

@main
struct WBShopApp: App {
    init() {
        setupApiToken()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupApiToken() {
        let serviceName = "com.wbshop.api"
        let accountName = "authToken"
        
        if KeychainHelper.shared.read(service: serviceName, account: accountName) == nil {
            if let plistPath = Bundle.main.object(forInfoDictionaryKey: "APIToken") as? String,
               !plistPath.isEmpty {
                
                KeychainHelper.shared.save(plistPath, service: serviceName, account: accountName)
            }
        }
    }
}
