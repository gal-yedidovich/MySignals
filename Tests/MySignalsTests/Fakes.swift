//
//  Fakes.swift
//
//
//  Created by Gal Yedidovich on 12/04/2024.
//

import Foundation

class FakeComputedHandler<ComputedValue> {
	private let _handler: () -> ComputedValue
	private(set) var callCount = 0
	
	init(handler: @escaping () -> ComputedValue) {
		self._handler = handler
	}
	
	func handler() -> ComputedValue {
		callCount += 1
		return _handler()
	}
}

class FakeEffectHandler {
	private let _handler: () -> Void
	private(set) var callCount = 0
	
	init(handler: @escaping () -> Void) {
		self._handler = handler
	}
	
	func handler() {
		callCount += 1
		_handler()
	}
}
