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
                clientKey: "test_5UZIW4YRQRB67IPVCWRT4VIHBMXGQ2NS"
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
        let sessionId = "CS41DE792FC22864CC"
        let sessionData = "Ab02b4c0!BQABAgABr778+8PcS18gYxKntb9zrdXMRAP7ysqDroTD99hDLCj0JQeBzdYsckNXEJSS9QOEMDGV4Sx0eI8IzQaXP/lImTDgsGWfoSlsgDXpK2f3VSRezBv93q3THxxSNtRG2xP3UCIQWjzRF9llB5iGFG9qkv5Ket0D7ACbOrmRsZbTIZcJZ6bntKehKVqauiDAvcvZdfz0ZvZY/oY+FaG4clZAhhDc2UULEuaTNzZFFXGnWJw83TKtKeY8cLtEnLzQOuYrlFShE7TiUrcCKF2hHesoktcIRnYNCtdXfciVtVeUjPBmdXugiyCzOnxct6cx1wnkUyxcKWrB/ytmoU8U/8peg4CwR/iP7BX7QS6YUjb5CgG4GgRNZu9El8S4RCNo14V704uGa+Yl5JY0Jsh/fBRxAmklq4isoDN3TqgoXVlqgAiOb/pyupiWkzXVXqwAoLolnXaKClTvX8yYOGpxkAXPQHuWm8uRjcz45DZBrcYZZfWL+1k99A+hcmuadHkeJTNlXLAmJO3qMnIkiD9022iHKEqLO3xibVOIjJiuE2mSAgiiltQsvFUfZWHGeanHNlV0ebEovD9j44Qm4mhDWKAsjEsfI1GPM7jaT2z3Zkf2Y9lfvL6xF1EzFXkX9aRV4qRA8lzFduo61gMB8b8fDXQj/VXFiq8YQXZBiuSFssy65Aw0UJcRvH6lw3dVuqkASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9FNrPXjG8OzyXSRp/cZxXO8KxXLTNJE7p4A/Qv8uQKaad5weJfYr689/Ck4kTEHuAUe7m60E0vx3N5YbqUdosXn8XTemocyM2/eheX/e5EfHDSiyf3rNfJcXf+wqUbp6WGyZ/ORG811ZHnQlaBCBuE0BaaAz2Zac25bDkZdaM3i6eWYxzd7Pey7M2PrwxeNIP/C2+hCKt8QAVuA6DUrVV3csIv267hikbqJVerJn3eLxr7i5jGTzt6xMrgwgCJkhxcBlG/G/ehtpKKxoaVUsbjvTvwosBlNowil/8xuV7Ixm9o+77foVpMxd6xceIyHX24cotxZycEfrUdMDHmK92Z7mrNjxjXClVVvEDJmh9swMP53EqFztd3D8uN28JN6x7asRAbdkmKphY0LQ3+SuHRd+NFW/2h2uiEu2aXeBX3ik991zoQyRh0kALsGooJBJ6YzPzq8D3QW9hfMmDzQCCd0sJr3AVE58qxEiMY6vd3klCVzjHIpWt7Q4sT8P0B022sZJRw6BA+BGcIVO6G5JT2rn+M0mOBJE9kGc0jxgUaFw8NZyaRatKRXPhkhaWkKkZmnif+rwXDLiBKQFQVC3gOeQq2/WdQlThX0k84F9e5tomco/U55rsMkeGUs1W5OjcIyM24BRERXx74dDSGzGiMHl0QCzT6VNiE8ORYkSYwC1/QJbC2UJn/OkRES/cCim2NBuheFDWZP+Wy0ywp0ki00sY8rX2y+z6PLouJm3dko0RnTJKY56xVHqoUxX2exex5vsED0LAQuUsiq4q1wbUjKqeNvY="
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
