//
//  DeepLinkNavigator.swift
//  Deeplinks
//
//  Created by Praveen Prabhakar on 15/06/22.
//

import Foundation
import UIKit
import SafariServices

public protocol DeepLinkNavigatorProtocol {
	func getAppRootViewController() -> UIViewController?
	func doAuthentication(deepLink: DeepLinkTemplateProtocol, afterLogin: DeepLinkActionBlock)
	func executeDeepLink(deepLink: DeepLinkTemplateProtocol) -> Bool
}

public class DeepLinkNavigator: NSObject {

	public static let instance = DeepLinkNavigator()

	public var delegate: DeepLinkNavigatorProtocol?

	public static func executeDeepLink(with deepLink: DeepLink) -> Bool {
		guard let deepLink = deepLink.template() else { return false }
		let block = {
			// pause the pending actions, until the asynch methods below complete
			DeepLinkQueue.instance.pauseQueue()
			OperationQueue.main.addOperation {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					guard let navController = Self.instance.delegate?.getAppRootViewController() else { return }
					navController.dismissAlertsAndModels {
						Self.instance.loginIfNeeded(deepLink) {
							Self.instance.presentDeepLink(deepLink)
							DeepLinkQueue.instance.continueExecuting()
						}
					}
				}
			}
		}

		// this can happen when a deeplink is executed after the app is in the foreground
		// in this case we just run the block and bypass the queue
		if DeepLinkQueue.instance.state == .idle {
			block()
		} else {
			_ = DeepLinkQueue.instance.queueBlock(block)
		}

		return true
	}
}

extension DeepLinkNavigator {
	func presentDeepLink(_ deepLink: DeepLinkTemplateProtocol) {
		_ = delegate?.executeDeepLink(deepLink: deepLink)
	}
}

// MARK: Login
extension DeepLinkNavigator {
	func loginIfNeeded(_ deepLink: DeepLinkTemplateProtocol, afterLogin: @escaping DeepLinkActionBlock) {
		guard let delegate = Self.instance.delegate else {
			afterLogin()
			return
		}
		delegate.doAuthentication(deepLink: deepLink, afterLogin: afterLogin)
	}
}

public extension UIViewController {

	var getTopViewController: UIViewController? {
		DeepLinkNavigator.instance.delegate?.getAppRootViewController()
	}

	// Its not possible to push a card on top of a half card or an alert,
	// so lets dismiss it first if its on top
	func dismissAlertsAndModels(completion: @escaping (() -> Void)) {
		if !dismissAlertsAndHalfCardsLayerOne(completion: completion) {
			completion()
		}
	}

	func dismissAlertsAndHalfCardsLayerOne(completion: @escaping (() -> Void)) -> Bool {
		var isComplete = false
		guard let controller = getTopViewController, let presentedController = controller.presentedViewController else {
			   return isComplete
		}
	
		let dismissBlock: (UIViewController?) -> Void = { subController in
			if let nav = subController as? UINavigationController {
				nav.popToRootViewController(animated: false)
			}
			subController?.dismiss(animated: false) { [weak self] in
				// This is a recursive call that will stop recursing when all these patterns are dismissed
				self?.dismissAlertsAndModels {
					completion()
					return
				}
			}
		}

		if
			let presentedController = (presentedController as? UINavigationController),
			let childController = presentedController.topViewController,
				childController is UIAlertController || childController is SFSafariViewController {

			isComplete = true
			if let childPresentedController = childController.presentedViewController {
				if let nav = controller.presentedViewController as? UINavigationController {
					nav.popToRootViewController(animated: false)
				}
				dismissBlock(childPresentedController)
			}
			dismissBlock(presentedController)
		} else if (controller as? UINavigationController)?.topViewController?.presentedViewController == presentedController {
			isComplete = true
			dismissBlock(presentedController)
		}
		return isComplete
	}
}
