//
//  Configuration.swift
//  HelloWorldIos
//
//  Created by abhinav on 21/06/24.
//

import Foundation
import Adyen

internal enum ConfigurationConstants {
    // swiftlint:disable explicit_acl
    // swiftlint:disable line_length
    
   static let componentsEnvironment = Environment.test
    
    static let appName = "Adyen Demo"
    
    static let reference = "Test Order Reference - iOS UIHost"
    
    static var returnUrl: URL { .init(string: "ui-host://payments")! }
    
    static let shopperReference = "iOS Checkout Shopper"

    static let shopperEmail = "checkoutShopperiOS@example.org"
    
    static let additionalData = ["allow3DS2": true, "executeThreeD": true]
    
    static let recurringProcessingModel = "CardOnFile"

    static var apiContext: APIContext {
        if let apiContext = try? APIContext(environment: componentsEnvironment, clientKey: clientKey) {
            return apiContext
        }
        // swiftlint:disable:next force_try
        return try! APIContext(environment: componentsEnvironment, clientKey: "local_DUMMYKEYFORTESTING")
    }

    static let clientKey = "{YOUR_CLIENT_KEY}"

    static let demoServerAPIKey = "{YOUR_DEMO_SERVER_API_KEY}"

    static let merchantAccount = "{YOUR_MERCHANT_ACCOUNT}"

    static let appleTeamIdentifier = "{YOUR_APPLE_DEVELOPMENT_TEAM_ID}"

    static let applePayMerchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"

    static let lineItems = [[
        "description": "Socks",
        "quantity": "2",
        "amountIncludingTax": "300",
        "amountExcludingTax": "248",
        "taxAmount": "52",
        "id": "Item #2"
    ]]
    
    static var delegatedAuthenticationConfigurations: ThreeDS2Component.Configuration.DelegatedAuthentication {
        .init(localizedRegistrationReason: "Authenticate your card!",
              localizedAuthenticationReason: "Register this device!",
              appleTeamIdentifier: appleTeamIdentifier)
        
    }


    // swiftlint:enable explicit_acl
    // swiftlint:enable line_length
}
