//
//  DeepLinkQueue.swift
//  Deeplinks
//
//  Created by Praveen Prabhakar on 24/06/22.
//

import Foundation
import Combine

public class DeepLinkQueue {
	public static let instance = DeepLinkQueue()

	public enum State {
		case idle
		case queuing // blocks can be added to the Queue
		case executing // executing the queue, can't add blocks
	}

	public private(set) var state: State = .idle
	@Published public var canExecuteQueue = false
	private var continueQueuing = false
	lazy var cancellable: AnyCancellable = {
		$canExecuteQueue
			.sink() {
				self.continueQueuing = $0
				debugPrint("QueStatus: \(self.state), canExecute: \(self.continueQueuing), value: \($0)")
				if $0 {
					self.startExecuting()
				} else {
					self.startQueuing()
				}
			}
	}()

	private lazy var queue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.maxConcurrentOperationCount = 1
		operationQueue.isSuspended = true
		return operationQueue
	}()

	private init() {
		_ = cancellable
	}
}

extension DeepLinkQueue {
	func startExecuting() {
		self.state = .executing
		runQueue()
	}

	func startQueuing() {
		self.state = .queuing
		queue.isSuspended = true
	}

	func runQueue() {
		guard self.state == .executing else { return }

		// make the queue idle when we are done executing
		queue.addOperation { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.state = .idle
		}

		guard continueQueuing else {
			startQueuing()
			return
		}

		queue.isSuspended = false
	}

	// Add a DeepLinkActionBlock to the queue
	func queueBlock(_ block: @escaping DeepLinkActionBlock) -> Bool {
		guard self.state == .queuing else { return false }
		let operation = BlockOperation(block: block)
		if let lastOperation = queue.operations.last {
			operation.addDependency(lastOperation)
		}
		queue.addOperation(operation)
		return true
	}

	func pauseQueue() {
		guard self.state == .executing else { return }
		queue.isSuspended = true
	}

	func continueExecuting() {
		guard self.state == .queuing else { return }
		queue.isSuspended = false
	}
}
