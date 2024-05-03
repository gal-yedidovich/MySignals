//
//  Observer.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

import Foundation

private(set) var currentObserver: (any Observer)? = nil

protocol Observer: AnyObject {
	func onNotify(sourceChanged: Bool)
	
	func add(source: any ReactiveValue)
}

extension Observer {
	func scope<T>(handler: () -> T) -> T  {
		precondition(currentObserver !== self, "Infinite loop, you must not mutate values inside an observer. nor accessing computed within itself")
		let previousObserver = currentObserver
		currentObserver = self
		defer { currentObserver = previousObserver }
		return handler()
	}
}


/// Weak observer wrapper
class WeakObserver {
	weak var observer: (any Observer)?
	
	init(_ observer: any Observer) {
		self.observer = observer
	}
}

extension Array where Element : WeakObserver {
	mutating func reap () {
		self = self.filter { $0.observer != nil }
	}
}
