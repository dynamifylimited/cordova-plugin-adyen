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
    private var sessionCompleted = false

    override func pluginInitialize() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adyenHandleOpenURL(_:)),
            name: NSNotification.Name.CDVPluginHandleOpenURL,
            object: nil
        )
    }

    @objc func adyenHandleOpenURL(_ notification: NSNotification) {
        guard let url = notification.object as? URL else { return }
        RedirectComponent.applicationDidOpen(from: url)
    }

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

        // Allow merchant identifier to be passed from JS; fall back to default
        if let customMerchantId = paymentRequest["merchantIdentifier"] as? String, !customMerchantId.isEmpty {
            self.merchantIdentifier = customMerchantId
        }

        AdyenLogging.isEnabled = true
        self.callbackId = command.callbackId
        self.sessionCompleted = false
        self.context = generateContext(clientKey: clientKey, currencyCode: currency, countryCode: countryCode, value: value, isTesting: isTesting)
        self.sessionId = id
        self.SessionData = sessionData
        self.clientKey = clientKey

        self.dropInConfiguration = initializeApplePay(currencyCode: currency, countryCode: countryCode, value: value, returnUrl: returnUrl)


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

    private func initializeApplePay(currencyCode: String, countryCode: String, value: Int, returnUrl: String) -> DropInComponent.Configuration {

        let dropInConfiguration = DropInComponent.Configuration()

        if let url = URL(string: returnUrl) {
            dropInConfiguration.actionComponent.threeDS.requestorAppURL = url
               print("Return URL configured: \(returnUrl)")
           } else {
               print("Invalid return URL: \(returnUrl)")
           }

        // Check if device supports Apple Pay before attempting configuration
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            print("Apple Pay Error: Device does not support Apple Pay")
            return dropInConfiguration
        }

        do {
            let amount = Amount(value: value, currencyCode: currencyCode)
            let payment = Payment(amount: amount, countryCode: countryCode)
            let applePayPayment = try ApplePayPayment(payment: payment, brand: "Everyday")
            dropInConfiguration.applePay = .init(payment: applePayPayment, merchantIdentifier: self.merchantIdentifier)
            print("Apple Pay configured successfully")
            return dropInConfiguration
        } catch {
            print("Apple Pay configuration failed with ApplePayPayment: \(error.localizedDescription)")
        }

        // Fallback: try PKPaymentRequest approach
        do {
            let paymentRequest = PKPaymentRequest()
            paymentRequest.merchantIdentifier = self.merchantIdentifier
            paymentRequest.countryCode = countryCode
            paymentRequest.currencyCode = currencyCode
            paymentRequest.supportedNetworks = [.visa, .masterCard, .amex, .discover]
            paymentRequest.merchantCapabilities = .capability3DS
            paymentRequest.paymentSummaryItems = [
                PKPaymentSummaryItem(label: "Everyday", amount: NSDecimalNumber(value: Double(value) / 100.0), type: .final)
            ]

            dropInConfiguration.applePay = try .init(paymentRequest: paymentRequest)
            print("Apple Pay configured successfully (PKPaymentRequest fallback)")
            return dropInConfiguration
        } catch {
            print("Apple Pay configuration failed with PKPaymentRequest: \(error.localizedDescription)")
            return dropInConfiguration
        }
    }

    private func dropInComponent(from session: AdyenSession) -> DropInComponent {
        let paymentMethods = session.sessionContext.paymentMethods
        let dropInConfiguration = self.dropInConfiguration!
        let component = DropInComponent(paymentMethods: paymentMethods,
                                        context: self.context!,
                                        configuration: dropInConfiguration,
                                        title:"app")
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
        let alertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        guard let topViewController = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("No root view controller available to present the alert.")
        }

        let isSuccess = (resultCode == "Authorised" || resultCode == "Received" || resultCode == "Pending" || resultCode == "PresentToShopper")

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.dropInComponent?.finalizeIfNeeded(with: isSuccess) {}

            topViewController.dismiss(animated: true) {
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
                    guard let self else { return }
                    print("dismissing top view controller")
                    if !self.sessionCompleted {
                        self.handlePluginResult(resultCode: "Cancelled", callbackId: self.callbackId)
                    }
                }
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
        sessionCompleted = true
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
        if sessionCompleted { return }
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
