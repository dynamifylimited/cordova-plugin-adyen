//
//  DropInExample.swift
//  HelloWorldIos
//
//  Created by abhinav on 21/06/24.
//

import Foundation
import Adyen

internal final class DropInExample: InitialDataFlowProtocol {
    
    private var session: AdyenSession?
    private var dropInComponent: DropInComponent?
    internal lazy var context: AdyenContext = generateContext()!
    internal weak var presenter: PresenterExampleProtocol?
    
    internal init() {}
    
    
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
    
    internal func start() {
        print("hre 1")
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
                                        context: context,
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
        requestAdyenSessionConfiguration { [weak self] response in
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
    
    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
           presenter?.dismiss {
               // Payment is processed. Add your code here.
               let title = success ? "Success" : "Error"
               self.presenter?.presentAlert(withTitle: title, message: message)
           }
       }
    
    
    
}

extension DropInExample: AdyenSessionDelegate {

    func didComplete(with result: AdyenSessionResult, component: Component, session: AdyenSession) {
        print(result)
    }

    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        dismissAndShowAlert(false, error.localizedDescription)
    }

    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension DropInExample: PresentationDelegate {
    internal func present(component: PresentableComponent) {
        print("here 20")
        // The implementation of this delegate method is not needed when using AdyenSession as the session handles the presentation
    }
}

