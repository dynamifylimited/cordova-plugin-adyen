import Adyen
@objc(Adyen) class Adyen: CDVPlugin, InitialDataFlowProtocolV1 {
    
    
    //    private var dropInExample: DropInExample?
    
    private var session: AdyenSession?
    private var clientKey: String = ""
    private var sessionId: String = ""
    private var SessionData: String = ""
    private var context: AdyenContext?
    private var dropInComponent: DropInComponent?
    private var callbackId: String = ""
    
    
    internal weak var presenter: PresenterExampleProtocol?
    
    //    @objc(pluginInitialize)
    //      override func pluginInitialize() {
    //        DispatchQueue.global().async {
    //            self.dropInExample = DropInExample()
    //        }
    //      }
    
    
    @objc(echo:)
    func echo(command: CDVInvokedUrlCommand) {
        //        dropInExample?.start()
        guard let paymentRequest = command.argument(at: 0) as? [String: Any],
              let amountDict = paymentRequest["amount"] as? [String: Any],
              let currency = amountDict["currency"] as? String,
              let value = amountDict["value"] as? Int,
              let countryCode = paymentRequest["countryCode"] as? String,
              let expiresAt = paymentRequest["expiresAt"] as? String,
              let id = paymentRequest["id"] as? String,
              let merchantAccount = paymentRequest["merchantAccount"] as? String,
              let reference = paymentRequest["reference"] as? String,
              let returnUrl = paymentRequest["returnUrl"] as? String,
              let shopperLocale = paymentRequest["shopperLocale"] as? String,
              let mode = paymentRequest["mode"] as? String,
              let sessionData = paymentRequest["sessionData"] as? String,
              let clientKey = paymentRequest["clientKey"] as? String else {
            // Handle invalid arguments error
            //            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid payment request arguments")
            //            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            sendErrorResult(resultCode: "Error", callbackId: self.callbackId)
            return
        }
        
        
        self.callbackId = command.callbackId
        self.context = generateContext(clientKey: clientKey, currencyCode: currency, countryCode: countryCode, value: value)
        self.sessionId = id
        self.SessionData = sessionData
        self.clientKey = clientKey
        
        
        loadSession { [weak self] response in
            guard let self else { return }
            print("here 2")
            
            
            print("here 3")
            
            switch response {
                
            case let .success(session):
                print("here 4")
                self.session = session
                self.presentComponent(with: session)
                
            case let .failure(error):
                print("here 5")
                self.presentAlert(with: error)
            }
        }
        
    }
    
    
    func presentt(viewController: UIViewController, completion: (() -> Void)?) {
        print("here 21")
        // Ensure there is a visible view controller to present from
        guard let currentViewController = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("No root view controller available to present from.")
        }
        
        // Check if there is already a presented view controller
        if let presentedViewController = currentViewController.presentedViewController {
            presentedViewController.dismiss(animated: false) {
                currentViewController.present(viewController, animated: true, completion: completion)
            }
        } else {
            currentViewController.present(viewController, animated: true, completion: completion)
        }
    }
    
    private func presentComponent(with session: AdyenSession) {
        print("here 17")
        let dropIn = dropInComponent(from: session)
        presentt(viewController: dropIn.viewController, completion: nil)
        print("here 18")
        dropInComponent = dropIn
        print("here 19")
        
    }
    
    private func dropInComponent(from session: AdyenSession) -> DropInComponent {
        print("here 13")
        let paymentMethods = session.sessionContext.paymentMethods
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        context: self.context!,
                                        title: ConfigurationConstants.appName)
        print("here 14")
        component.delegate = session
        print("here 15")
        component.partialPaymentDelegate = session
        print("here 16")
        
        return component
    }
    
    private func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        print("here 11")
        print(error.localizedDescription)
        let errorMessage = error.localizedDescription
        
        // Create UIAlertController
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        
        // Add retry action if retryHandler is provided
        if let retryHandler = retryHandler {
            alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                retryHandler()
            }))
        }
        
        // Add cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Get the top-most view controller to present the alert
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    
    
    private func loadSession(completion: @escaping (Result<AdyenSession, Error>) -> Void) {
        print ("here 6")
        requestAdyenSessionConfiguration (sessionId: self.sessionId, sessionData: self.SessionData, context: self.context!){ [weak self] response in
            print ("here 7")
            guard let self else { return }
            
            print ("here 8")
            
            switch response {
            case let .success(config):
                AdyenSession.initialize(with: config,
                                        delegate: self,
                                        presentationDelegate: self,
                                        completion: completion)
                print ("here 9")
            case let .failure(error):
                completion(.failure(error))
                print ("here 10")
            }
        }
    }
    
    func getSessionsData() -> String {
        return "Ab02b4c0!BQABAgBOAjAoXzGZQQNwdB7D17XRULITLO/R1Nmz3nIbM+Llx89byTgpUFQUA0CFAv4+XG5zHCn6BbN4vw2twTKqanToYZqJqaKQ9pX4Lw6DhbwZo3U1DIiHlx53lIJwb4Vuec/u1BCtU8SvroBFqah2eXHpksVLIYxrWtgcnokUxVUy4kbysJ9lC6oSVEft7vo1I31c+IPQSrn/7UlkjAXQ4lde//PQVsPQv2qnAPUBY1O9Qc9wVAQuUgQPrXVnbbHXyJ6hrciQSXdtabg1OCBFLGulTdcId3t1pKGvbispG66JiarsT9fRBkg+QUUBcDoO/scc4AXaklNQNcvoV8TjWxh6wxaINszZDWM7+r35G6gmGJx4vgfN/OrmFNKRbaYfns6d2AG13Uk6UrY7Is2xkuGjG9eQ5BvV3f4BIrD6BI0w609g321DZfI3BSW+ZM4sRSv77ay6MwWwdLx4qGXeUSn4hHLEyhIlVTkat5vvMDrxo4uxpovxZuhiVK+rhDRTo9M55RqikpMsGvzr8/nYv2Bqw+6C1/tA6hb/FRb+GQ/FYw3oxKCHpH/ljnKugYNI1pD6JQyGKP8bjFDk5Kq9qWSmybj7q9+1ytllP2cr+GXewA+cx+ujyGfmQOJqIUbce579fc5L1Zt+pC1BZkX7/0rJf5vyiB3QUMkBCs7XmdEVIwwl9u+Ei9WOi2a4Z9IASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9GzeLxTDQz79iItZA1WVEQwDvjL9XW/usyanRwcwGbbCtv5mtQL6ELibxoRQKXoBib44VbycsIxEBPQRrtensDuBwkelBNthvi9yHNfO4/KSRsW1AsxBdw9HXOItbrtY/iO9d0YIIbZsC8yHy4/EY2yycUjkGe9E45F9ycfkJCBEdRkmpkMyLLKf6RI61qnUgDB6sPL4x6SPE4EzrxENJEXOUS+nYb7lu4dfJofwSciTAh/feoM1nb86NSZ4UCbJ+HCEdTGugz89KE43VDipApsAFDh/RHvO95Sn+X6i1hptAV1+9BSv0DhEa84fejawwkgnE7Er6xkcJHWsQpjhEfd2gxqg9qSA2raip53X0Un4qBcjXuWdSYipuWd4oiZhOw8vznvxqYGDvKV/f1bOu9Dj0hGeGk6kln/0ouTX7Cmsa1fmKwlQD7QDnwNDFLc790VEc5KEhdjzK2BUEk17OEkDbHdmnwj+srkxFBGTdk2I63Bgmavicy8C89icxvY01WlfX5dWH3wYcyBU5zXqlLqllo4PUgP/WGXc5aGEicqfm1Qv/v8UQteZhn+ROaFkiiyFFYoJHEWSwwb1I6nBttjpsHjJzEA3NTQogBFwbBHqlAWndfOnvOEDL2dDy4TuuBcmJ"
    }
    
    func presentAlert(withTitle title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        guard let topViewController = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("No root view controller available to present the alert.")
        }
        
        DispatchQueue.main.async {
            if let presentedViewController = topViewController.presentedViewController {
                presentedViewController.present(alertController, animated: true, completion: nil)
            } else {
                topViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    private func dismissAndShowAlert(withTitle: String, message : String, resultCode: String) {
        //        let title = success ? "Success" : "Error"
        let alertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        guard let topViewController = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("No root view controller available to present the alert.")
        }
        
        DispatchQueue.main.async {
            if let presentedViewController = topViewController.presentedViewController {
                presentedViewController.dismiss(animated: true) {
                    topViewController.present(alertController, animated: true, completion: nil)
                }
            } else {
                topViewController.present(alertController, animated: true, completion: nil)
            }
            
            self.sendSuccessResult(resultCode: resultCode, callbackId: self.callbackId)
        }
    }
    
    func getSessionId() -> String {
        return "CSEF83B7707477A224"
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("something happened")
        return RedirectComponent.applicationDidOpen(from: url)
    }
    
    func dismissDropIn() -> Void {
        guard let topViewController = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("No root view controller available to present the alert.")
        }
        dropInComponent?.finalizeIfNeeded(with: true) { [weak self] in
            guard let self else { return }
            if let presentedViewController = topViewController.presentedViewController {
                presentedViewController.dismiss(animated: true) { [weak self] in
                    print("dismissing top view controller")
                }
            } else {
                //                    topViewController.present(alertController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func sendErrorResult(resultCode: String, callbackId: String) {
        let resultData: [String: Any] = ["resultCode": resultCode]
        let pluginResult = CDVPluginResult(status: .error, messageAs: resultData)
        self.commandDelegate.send(pluginResult, callbackId: callbackId)
    }
    
    func sendSuccessResult(resultCode: String, callbackId: String) {
        let resultData: [String: Any] = ["resultCode": resultCode]
        let pluginResult = CDVPluginResult(status: .ok, messageAs: resultData)
        self.commandDelegate.send(pluginResult, callbackId: callbackId)
    }
    
    
}


extension Adyen: AdyenSessionDelegate {
    
    func didComplete(with result: AdyenSessionResult, component: Component, session: AdyenSession) {
        print("adyen sesion result" , result.resultCode)
        switch result.resultCode {
        case SessionPaymentResultCode.authorised:
            dismissAndShowAlert(withTitle: "Success", message: "Payment successful", resultCode: result.resultCode.rawValue)
        case SessionPaymentResultCode.pending:
            dismissAndShowAlert(withTitle: "Pending", message: "Did not receive the order waiting for completion", resultCode: result.resultCode.rawValue)
        case SessionPaymentResultCode.received:
            dismissAndShowAlert(withTitle: "Received", message: "Received the order waiting for completion", resultCode: result.resultCode.rawValue)
        case SessionPaymentResultCode.refused:
            dismissAndShowAlert(withTitle: "Refused", message: "The payment was refused. Please try after sometime", resultCode: result.resultCode.rawValue)
        case SessionPaymentResultCode.cancelled:
            dismissAndShowAlert(withTitle: "Cancelled", message: "The payment was cancelled", resultCode: result.resultCode.rawValue)
        case SessionPaymentResultCode.error:
            dismissAndShowAlert(withTitle: "Error", message: "Error occurred during payment processing", resultCode: result.resultCode.rawValue)
        case SessionPaymentResultCode.presentToShopper:
            dismissAndShowAlert(withTitle: "Received", message: "Received the order waiting for completion", resultCode: result.resultCode.rawValue)
        }
        
    }
    
    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        print("adyen session failed")
        print(error)
        switch error {
        case ComponentError.cancelled:
            dismissDropIn()
        default:
            dismissAndShowAlert(withTitle: "Error", message: error.localizedDescription, resultCode: "Error")
        }
        //        dismissAndShowAlert(false, error.localizedDescription)
    }
    
    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}
    
}

extension Adyen: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        print("here 20")
        // The implementation of this delegate method is not needed when using AdyenSession as the session handles the presentation
    }
}

