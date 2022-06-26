//
//  CheckoutViewController.swift
//  DeeplinksApp
//
//  Created by Praveen Prabhakar on 26/06/22.
//

import UIKit
import Deeplinks

class CheckoutViewController: UIViewController {

	@IBAction func productCartDeepLink(_ sender: Any) {
		let deepLink: DeepLink = .productCart(data: DeepLink.DeepLinkValues(query: ["String" : "Any"]))
		_ = DeepLinkNavigator.executeDeepLink(with: deepLink)
	}
}
