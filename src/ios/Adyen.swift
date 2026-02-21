import Adyen
import PassKit
@objc(Adyen) class Adyen: CDVPlugin, InitialDataFlowProtocolV1 {
    
    private var session: AdyenSession?
    private var clientKey: String = ""
    private var sessionId: String = ""
    private var SessionData: String = ""
    private var context: AdyenContext?
    private var dropInComponent: DropInComponent?
    private var callbackId: String = ""
    private var dropInConfiguration: DropInComponent.Configuration? = nil
    private var merchantIdentifier = "merchant.com.adyen.dynamifyadyen"
        
    @objc(requestCharge:)
    func requestCharge(command: CDVInvokedUrlCommand) {
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
              let isTesting = paymentRequest["isTesting"] as? Bool,
              let clientKey = paymentRequest["clientKey"] as? String else {
            sendErrorResult(resultCode: "Error", callbackId: self.callbackId)
            return
        }
        
        AdyenLogging.isEnabled = true
        self.callbackId = command.callbackId
        self.context = generateContext(clientKey: clientKey, currencyCode: currency, countryCode: countryCode, value: value, isTesting: isTesting)
        self.sessionId = id
        self.SessionData = sessionData
        self.clientKey = clientKey
        
        self.dropInConfiguration = initializeApplePay(currencyCode: currency, countryCode: countryCode, value: value)
        
        loadSession { [weak self] response in
            guard let self else { return }
            switch response {
            case let .success(session):
                self.session = session
                self.presentComponent(with: session)
            case let .failure(error):
                self.presentAlert(with: error)
            }
        }
        
    }
    
    
    func presentAdyenComponent(viewController: UIViewController, completion: (() -> Void)?) {
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
        let dropIn = dropInComponent(from: session)
        presentAdyenComponent(viewController: dropIn.viewController, completion: nil)
        dropInComponent = dropIn
    }
    
    private func initializeApplePay(currencyCode: String, countryCode: String, value: Int) -> DropInComponent.Configuration {
        print("initializing apple pay")
        do {
            let dropInConfiguration = DropInComponent.Configuration()
            let amount = Amount(value: value, currencyCode: currencyCode)
            let payment = Payment(amount: amount, countryCode: countryCode)
            let applePayPayment = try ApplePayPayment(payment: payment, brand: "Everyday")
            dropInConfiguration.applePay = .init(payment: applePayPayment, merchantIdentifier: self.merchantIdentifier)
            return dropInConfiguration
        } catch {
            return DropInComponent.Configuration()
        }
    }
    
    private func dropInComponent(from session: AdyenSession) -> DropInComponent {
        let paymentMethods = session.sessionContext.paymentMethods
        let dropInConfiguration = self.dropInConfiguration!
        let component = DropInComponent(
            paymentMethods: paymentMethods,
            context: self.context!,
            configuration: dropInConfiguration,
            title:"app"
        )
        component.delegate = session
        component.partialPaymentDelegate = session
        return component
    }
    
    private func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
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
        requestAdyenSessionConfiguration (sessionId: self.sessionId, sessionData: self.SessionData, context: self.context!){ [weak self] response in
            guard let self else { return }
            switch response {
            case let .success(config):
                AdyenSession.initialize(with: config,
                                        delegate: self,
                                        presentationDelegate: self,
                                        completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
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
            
            self.handlePluginResult(resultCode: resultCode, callbackId: self.callbackId)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
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
                    self?.handlePluginResult(resultCode: "Cancelled" , callbackId: self!.callbackId)
                }
            } else {
                //                    topViewController.present(alertController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func handlePluginResult(resultCode: String, callbackId: String) {
        switch resultCode {
        case "Authorised", "Received", "Pending", "PresentToShopper", "Cancelled":
            self.sendSuccessResult(resultCode: resultCode, callbackId: callbackId)
        default:
            self.sendErrorResult(resultCode: resultCode, callbackId: callbackId)
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
    }
    
    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}
    
}

extension Adyen: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        // The implementation of this delegate method is not needed when using AdyenSession as the session handles the presentation
    }
}

