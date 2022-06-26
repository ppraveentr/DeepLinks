//
//  ProductCartViewController.swift
//  DeeplinksApp
//
//  Created by Praveen Prabhakar on 26/06/22.
//

import UIKit
import Deeplinks

class ProductCartViewController: UIViewController {

	@IBAction func checkoutDeepLink(_ sender: Any) {
		let deepLink: DeepLink = .checkout(data: DeepLink.DeepLinkValues(query: ["String" : "Any"]))
		_ = DeepLinkNavigator.executeDeepLink(with: deepLink)
	}
}
