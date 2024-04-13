//
//  EffectTests.swift
//
//
//  Created by Gal Yedidovich on 12/04/2024.
//

import XCTest
@testable import Reactivity

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
		@Ref var number = 1
		let fakeHandler = FakeEffectHandler { _ = number }
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 2)
	}
	
	func testShouldNotTrigger_whenSourceChangeRedundant() {
		// Given
		@Ref var number = 1
		let fakeHandler = FakeEffectHandler { _ = number }
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		number = 1
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldTriggerDeepChanges() {
		// Given
		struct Value: Equatable {
			var num: Int
		}
		@Ref var value = Value(num: 1)
		let fakeHandler = FakeEffectHandler { _ = value.num }
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		value.num = 2
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 2)
	}
	
	func testShouldUntrackSources_whenEffectDeinit() {
		// Given
		@Ref var flag = true
		@Ref var number = 1
		let computed1 = Computed { "Deadpool" }
		let fakeHandler = FakeEffectHandler {
			_ = "\(flag) \(number) \(computed1.value)"
		}
		effectsStore = [Effect(handler: fakeHandler.handler)]
		XCTAssertEqual($flag.observerCount, 1, "computed should track source 1")
		XCTAssertEqual($number.observerCount, 1, "computed should track source 2")
		XCTAssertEqual(computed1.observerCount, 1, "computed should track source 3")
		
		// When
		effectsStore = []
		
		// Then
		XCTAssertEqual($flag.observerCount, 0, "effect should untrack source 1")
		XCTAssertEqual($number.observerCount, 0, "effect should untrack source 2")
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
