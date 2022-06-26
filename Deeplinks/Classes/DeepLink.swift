//
//  DeepLink.swift
//  Deeplinks
//
//  Created by Praveen Prabhakar on 15/06/22.
//

import Foundation
import UIKit

public typealias DeepLinkActionBlock = () -> Void

public protocol DeepLinkTemplateProtocol {
	var deepLink: DeepLink { get }

	init(deepLink: DeepLink)
}

public enum DeepLink {
	case unknown
	case productCart(data: DeepLinkValues?)
	case reviewCart(data: DeepLinkValues?)
	case checkout(data: DeepLinkValues?)

	public struct DeepLinkValues {
		public var query: [String: Any]

		public init(query: [String: Any]) {
			self.query = query
		}
	}
}

//enum DeepLinkConstants {
//	static let productCart = "productCart"
//	static let reviewCart = "reviewCart"
//	static let checkout = "checkout"
//}

extension DeepLink {
	func template() -> DeepLinkTemplateProtocol? {
		switch self {
		case .checkout:
			return CheckoutDeepLinkTemplate(deepLink: self)
		default:
			return nil
		}
	}
}
