//
//  CheckoutDeepLinkTemplate.swift
//  Deeplinks
//
//  Created by Praveen Prabhakar on 15/06/22.
//

import Foundation

public struct CheckoutDeepLinkTemplate: DeepLinkTemplateProtocol {
	public var deepLink: DeepLink {
		deepLinkObj
	}

	private let deepLinkObj: DeepLink

	public init(deepLink: DeepLink) {
		deepLinkObj = deepLink
	}
}
