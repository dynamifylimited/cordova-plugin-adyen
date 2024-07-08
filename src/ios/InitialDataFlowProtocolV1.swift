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
    func generateContext(clientKey: String, currencyCode: String, countryCode: String, value: Int) -> AdyenContext? {
        do {
            let apiContext = try APIContext(
                environment: Environment.test,
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
//        let sessionId = "CSBDBC367BB12D3E80"
//        let sessionData = "Ab02b4c0!BQABAgA6IH9I//JTySk0nQycM0fB8p/S/DJEdZ/2T/Q86M6nNl8z8oJl20uNOrDefEti/eucfxrxe7v/aBU/Tu8VlSeLW2kRBisxXKEPsK1jc/tTX19SRc/MI/07nbQdBuwzw59a7V33khjwz7i55C3grWMsLERuxsnmYH1iXsPAQhVtKaGClGOQzx8PHEbe5whV6kxPPdKhC/c49izEIM7st1/btXHOlvTsidkQUCsK7PcrAwPZ8IZOpacZbXmKbC8ijnrVrgI7FVsUKC09Wj8Jv49C0zi8qqiGWUTYLdLYSPRrdlSxRDvtzOhhZw8lLHMS3E2gQj425GXLdhYDHjJI3mKiTFDvS000WSO268DzbyQBR7aNyu+4wHxRNasZkCLgg7g4Fdc+vDY/L1tJuYI5+qRdWhrz4mubs/M3XYnRz8Zx+uyEeuDmEWbyZHgQoVusq1H2Khm6SwTZ1vdYxIQA6Lg2vN3DFznkI8th2xHjzI9v0dt21skvSBaCE0GHPRbMtK+Dg79svEJxRIWBjvg3mujRngO4Vztgfq1vDiXVn24OtDlwQsgLwEqjxtW6pyU97cwkZVVeQ20ADu2gazrUeDFnX6vjefqngbAmmSb0jr6Yny+Oqbhj7Onc0cDoDsYaNqv37PbGZfCaDMQl4M4eN3ul48HPSmd+SqUdgGtKA0ct8wz4iEJO5YL4jUOTcn8ASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9TVkFdjPn1mwiOnXbXc1czEAZW5EZaWJTFw6w5HhFdAB/Y9OBiHn7ofPZv7Cre8/rR/0vkzdnR0Bnf0fMFPgiF4eKPTGlqUTW1ZNaXvz4nI6Xb4vaTo77JIFDEdIJ2wa2cFnYRQQMQ5vYvq0Aq5kmeFwWVd3xIxO2XLZGSGhTmJF4Uqrs7sBxczexryU4AKPHo8VmX3VwnO2P1TlC/ZLJ1RfT4xHHMqpGSt1nq2uvrvjWWfyD6KstjvQ6S5DMKJonBrfqBbJri7RKNYeHJ0VjTZZXAG7D95e0Vaz2llCBvnZklIJ6OPR4W8iB7Lg6EL+RAyPkYfKcDN6zzvyNxfiBsxk6dHO+95hnH7c7eNXpakXPmOjPfTgDofuBraGngQY0jLjzg7UaorvgUVKvGTjAhlkUP1PkLvKEMaKE4ItLl+xr1YzpnvexPTl9nv3rJ7b6lGA3SlYQ732Y3a+t1IQlc3zvrQQGlcMoujt9xmokZHfuZe5CUCZR4m9GV3VCo0C9f0xjRP7TUTHq3S2FMCsx57fyOz+B1ab0j174ESlu6qWDavKOySVTubSwugXTxulN4dxfXhzNpwbiIyD7x/phab+9eE/H5R8BxjyEQx++6fLbg+tIDGDB4bo1Q66iiY9nSr4nwi+j24YqyzxVsA=="
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
