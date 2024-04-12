//
//  Fakes.swift
//
//
//  Created by Gal Yedidovich on 12/04/2024.
//

import Foundation

class FakeComputedHandler<ComputedValue> {
	private let _handler: () -> ComputedValue
	var callCount = 0
	
	init(handler: @escaping () -> ComputedValue) {
		self._handler = handler
	}
	
	func handler() -> ComputedValue {
		callCount += 1
		return _handler()
	}
}
