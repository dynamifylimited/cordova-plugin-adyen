//
//  InitialDataFlowProtocol.swift
//  HelloWorldIos
//
//  Created by abhinav on 21/06/24.
//

import Foundation
import Adyen

internal protocol InitialDataFlowProtocolV1: AnyObject {
    
    func requestAdyenSessionConfiguration(sessionId: String, sessionData: String, context: AdyenContext, completion: @escaping (Result<AdyenSession.Configuration, Error>) -> Void)
    
    func generateContext(clientKey: String, currencyCode: String, countryCode: String, value: Int) -> AdyenContext?
    
}

extension InitialDataFlowProtocolV1 {
    private var environmentMapping: [String: Environment] {
        return [
            "AU": .liveAustralia,
            // Add more mappings as needed
        ]
    }
    
    private func environment(for countryCode: String) -> Environment {
        return environmentMapping[countryCode] ?? .test
    }
    func generateContext(clientKey: String, currencyCode: String, countryCode: String, value: Int) -> AdyenContext? {
        do {
            let selectedEnvironment = environment(for: countryCode)
            let apiContext = try APIContext(
                environment: selectedEnvironment,
                clientKey: clientKey
            )
            // Create the amount with the value in minor units and the currency code.
            let amount = Amount(value: value, currencyCode: currencyCode)
            // Create the payment object with the amount and country code.
            let payment = Payment(amount: amount, countryCode: countryCode)
            // Create an instance of AdyenContext, passing the instance of APIContext, payment object, and optional analytics configuration.
            let adyenContext = AdyenContext(apiContext: apiContext, payment: payment)
            return adyenContext
        } catch {
            print("Failed to initialize APIContext: \(error.localizedDescription)")
            return nil
        }
    }
    
    internal func requestAdyenSessionConfiguration(sessionId: String, sessionData: String, context: AdyenContext, completion: @escaping (Result<AdyenSession.Configuration, Error>) -> Void) {
        let config = self.initializeSession(with: sessionId, data: sessionData, context: context)
        completion(.success(config))
    }
    
    private func initializeSession(with sessionId: String, data: String, context: AdyenContext) -> AdyenSession.Configuration {
        let configuration = AdyenSession.Configuration(
            sessionIdentifier: sessionId,
            initialSessionData: data,
            context: context
        )
        return configuration
    }
    
}
