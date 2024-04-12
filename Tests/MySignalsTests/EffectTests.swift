//
//  EffectTests.swift
//
//
//  Created by Gal Yedidovich on 12/04/2024.
//

import XCTest
@testable import MySignals

class EffectTests: XCTestCase {
	/// Allows to keep reference to effects during tests
	private var effectsStore: [Effect] = []
	
	func testShouldTriggerAnEffect_whenCreated() {
		// Given
		let fakeHandler = FakeEffectHandler {}
		
		// When
		_ = Effect(handler: fakeHandler.handler)
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldTriggerAnEffect_whenSourceChanges() {
		// Given
		let signal = Signal(1)
		let fakeHandler = FakeEffectHandler { _ = signal.value * 2 }
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		signal.value = 2
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 2)
	}
	
	func testShouldNotTrigger_whenSourceChangeRedundant() {
		// Given
		let signal = Signal(1)
		let fakeHandler = FakeEffectHandler { _ = signal.value * 2 }
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		signal.value = 1
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldTriggerDeepChanges() {
		// Given
		struct Value: Equatable {
			var num: Int
		}
		let signal = Signal(Value(num: 1))
		let fakeHandler = FakeEffectHandler { _ = signal.value.num * 2 }
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		signal.value.num = 2
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 2)
	}
	
	func testShouldUntrackSources_whenEffectDeinit() {
		// Given
		let signal1 = Signal(true)
		let signal2 = Signal(1)
		let computed1 = Computed { "Deadpool" }
		let fakeHandler = FakeEffectHandler {
			_ = "\(signal1.value) \(signal2.value) \(computed1.value)"
		}
		effectsStore = [Effect(handler: fakeHandler.handler)]
		XCTAssertEqual(signal1.observerCount, 1, "computed should track source 1")
		XCTAssertEqual(signal2.observerCount, 1, "computed should track source 2")
		XCTAssertEqual(computed1.observerCount, 1, "computed should track source 3")
		
		// When
		effectsStore = []
		
		// Then
		XCTAssertEqual(signal1.observerCount, 0, "effect should untrack source 1")
		XCTAssertEqual(signal2.observerCount, 0, "effect should untrack source 2")
		XCTAssertEqual(computed1.observerCount, 0, "effect should untrack source 3")
	}
	
	func testShouldNotTrackUnreachableSignals() {
		// Given
		let signal1 = Signal(true)
		let signal2 = Signal(1)
		let fakeHandler = FakeEffectHandler {
			if signal1.value {
				_ = "bubu the king"
			}
			
			_ = "\(signal1.value) count"
		}
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		signal2.value = 2
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldTrackMultipleSources() {
		// Given
		let signal1 = Signal(true)
		let signal2 = Signal(1)
		let fakeHandler = FakeEffectHandler {
			if signal1.value {
				_ = "bubu the king"
				return
			}
			
			_ = "\(signal2.value) count"
		}
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		signal2.value = 2
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldMultipleEffectTrackSameSource() {
		// Given
		let signal1 = Signal(true)
		let signal2 = Signal(1)
		let fakeHandler = FakeEffectHandler {
			_ = signal1.value
			_ = signal2.value
		}
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		XCTAssertEqual(fakeHandler.callCount, 1)

		// When
		signal1.value = false
		signal2.value = 2
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 3)
	}
}

class FakeEffectHandler {
	let _handler: () -> Void
	private(set) var callCount = 0
	
	init(handler: @escaping () -> Void) {
		self._handler = handler
	}
	
	func handler() {
		callCount += 1
		_handler()
	}
}
