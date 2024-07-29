//
//  PresenterExampleProtocol.swift
//  HelloWorldIos
//
//  Created by abhinav on 21/06/24.
//

import Foundation
import UIKit

internal protocol PresenterExampleProtocol: AnyObject {

    func present(viewController: UIViewController, completion: (() -> Void)?)

    func showLoadingIndicator()
    
    func hideLoadingIndicator()
    
    func dismiss(completion: (() -> Void)?)

    func presentAlert(withTitle title: String, message: String?)

    func presentAlert(with error: Error, retryHandler: (() -> Void)?)
}

