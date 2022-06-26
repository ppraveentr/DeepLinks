//
//  AppDelegate.swift
//  DeeplinksApp
//
//  Created by Praveen Prabhakar on 25/06/22.
//

import UIKit
import Deeplinks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		setupDeepLink()
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}


}

extension AppDelegate: DeepLinkNavigatorProtocol {
	func getAppRootViewController() -> UIViewController? {
		return UIApplication.shared.windows.first?.rootViewController
	}

	func doAuthentication(deepLink: DeepLinkTemplateProtocol, afterLogin: () -> Void) {
		afterLogin()
	}

	func setupDeepLink() {
		DeepLinkQueue.instance.canExecuteQueue = true
		DeepLinkNavigator.instance.delegate = self
	}

	func executeDeepLink(deepLink: DeepLinkTemplateProtocol) -> Bool {
		switch deepLink.deepLink {
		case let .checkout(data):
			showCheckout(data)
		default:
			return false
		}
		return true
	}
}

extension AppDelegate {
	func showCheckout(_ data: DeepLink.DeepLinkValues?) {
		let checkout = CheckoutViewController(nibName: String(describing: CheckoutViewController.self), bundle: Bundle.main)
		let rootView = getAppRootViewController()
		rootView?.present(checkout, animated: true)
	}
}
