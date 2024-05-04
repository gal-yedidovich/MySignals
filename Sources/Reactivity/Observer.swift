//
//  Observer.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

import Foundation

private(set) var currentObserver: (any Observer)? = nil

protocol Observer: AnyObject, Hashable {
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
	
	fileprivate func asAnyHashable() -> AnyHashable {
		AnyHashable(self)
	}
	
	func asWeak() -> WeakObserver {
		WeakObserver(self)
	}
}


/// Weak observer wrapper
struct WeakObserver: Hashable {
	weak var observer: (any Observer)?
	
	init(_ observer: any Observer) {
		self.observer = observer
	}
	
	static func == (lhs: WeakObserver, rhs: WeakObserver) -> Bool {
		lhs.observer?.asAnyHashable() == rhs.observer?.asAnyHashable()
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(observer?.asAnyHashable())
	}
	
}

extension Set where Element == WeakObserver {
	mutating func reap () {
		self = self.filter { $0.observer != nil }
	}
}
