//
//  InitialDataFlowProtocol.swift
//  HelloWorldIos
//
//  Created by abhinav on 21/06/24.
//

import Foundation
import Adyen

internal protocol InitialDataFlowProtocol: AnyObject {
    var context: AdyenContext { get }
    
    func requestAdyenSessionConfiguration(completion: @escaping (Result<AdyenSession.Configuration, Error>) -> Void)
    
    func generateContext() -> AdyenContext?
    
}

extension InitialDataFlowProtocol {
    func generateContext() -> AdyenContext? {
        do {
            let apiContext = try APIContext(
                environment: Environment.test,
                clientKey: "test_5UZIW4YRQRB67IPVCWRT4VIHBMXGsssQ2NS"
            )
            // Create the amount with the value in minor units and the currency code.
            let amount = Amount(value: 1000, currencyCode: "EUR")
            // Create the payment object with the amount and country code.
            let payment = Payment(amount: amount, countryCode: "NL")
            // Create an instance of AdyenContext, passing the instance of APIContext, payment object, and optional analytics configuration.
            let adyenContext = AdyenContext(apiContext: apiContext, payment: payment)
            return adyenContext
        } catch {
            print("Failed to initialize APIContext: \(error.localizedDescription)")
            return nil
        }
    }
    
    internal func requestAdyenSessionConfiguration(completion: @escaping (Result<AdyenSession.Configuration, Error>) -> Void) {
        let sessionId = "CS834C310EBBEB783A"
        let sessionData = "Ab02b4c0!BQABAgAOUm1i/xCE5AcBKmNblJybzMoQHawaJBw1qMy0GUQ9A8TB9db3qrLLmugQzZfSTN+hQCtNbFx1q28dWoM4rv9GTU13+BXZyrMDwAVt8T2IGwORC6PIr3SfbX/SgJuDdzibHktfQt4nfo5yBzjEPvkzM/7BLfwB8uEUYGkUsnRzOaCt2/ahOzpKKblJgBpex4i5M1RXZ9LU5z/FSUJl59/z7/MqFdcmgklAiZJeyI/jsISx5xNZAMen2wLo5Xk0hhRPDUPhO0lw2kfNmQDvA64HoqFK6aiC2HjhLGSEivnKwb9M2nPD7cPAhP/qCmje/fTV+2k2OgtBTO/OoiiiGZ0yVNzun3D3niOQWiqm94Kg63yuVGt1Ob+LyfLh2yRKaGSmm7qC6wdC4WzywrqovRYUl8PZKfbvp7QsbMFxd8f4bQgYGBI9dJX5K7tjP4aNlR1g1DRafwFoU3kVONnnOgBKPY+bg6Y4Z1qi6J2q2y/nLZ1vmL7NubmIFRzbQbJLXnO7LxAJhRIRNRyefFGqmro+xpt2G2srBmQyXNOLqFFxIG9oBGMCZpPSdL1rRMLx3uyy8MTYZcRTGcp3U3Sp0MVZ9rmk8ZMfbC+ER9xxGNaHp7uwDnNNkHrItMPcEbUkpEAQiJHkNc3/MCFovPHoEehbMJwghxh23J/wFEmqBXylIwysq+HHo1lM25UyrksASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9KfSRXJTB+k3ir+hX/kWC/zSS2CoYp+24DFPr1tPbT5J8rWdNZZ17T7Boib63kbO6LLYhnGWjsbLH6bHjgRNI8z2li28MC88YYeCS9km4/VEqSzJDhdZDboTnAuLQyeWSyrP4Nnb9Gu0s9mNXnRZ7xAwGrWe+vmjCZA7cKC4q3E0BGSlZEu4vxEE5kA5POvSyjSn8DmQgrpyXamWxl3i7zWEMn2z+MJemxbUNK1H31SohEjo0SGNcss/NJDj2Ph1v/FstgSR3Ndd9dj14nqKxaeUXYIWK4Big+cJZaj4f03SKMlQr2y7Wpgcl8QEw4fzvwjmgcBrZes5dS0mgiJtiAb7dxO3GSmKsKczYwUb3xLODjhSs0oqMUtDnXom55HqXdWtDlhAFee44xMThpXg7ae9wcZhYoHd23LmS2VrzbxKc7ZnaBNTkWD28jDaxB/ulQUPUstCE7XWkZDSsqHpfHlm1232xax7YdjWL8KkmteuwE9oLAEZ6A3sYKWqFtwLTjXW6Ck7SgRDtOEbiHpUx5cMtye5wnpTy4HPIxqFuoavorfzpKRwLRI00BW7M8AXUG/O3zNEpEnVUYq6duhAP7EJStGma5JNEazt427nlLwYJ2fV2kScfR2S0i/ryfVpVbUAGMKpN7tcY3QaEdJT4E95S15VnTq3EHvvcIROZSLdGCFdqxsxkfzPgAjnSe+5ROVYm8vgDHuE1Mw5a2GBuZkJxoXKU8XFlOUulhGZl1K1NeMc5rEajKPchFDicKKzMEXquBppUfBcFWmvcPOu5KSrs/Q=="
       let config = self.initializeSession(with: sessionId, data: sessionData)
        completion(.success(config))
        }
    
    private func initializeSession(with sessionId: String, data: String) -> AdyenSession.Configuration {
            let configuration = AdyenSession.Configuration(
                sessionIdentifier: sessionId,
                initialSessionData: data,
                context: context
            )
            return configuration
        }
    
}
