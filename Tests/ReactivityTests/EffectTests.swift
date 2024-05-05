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
	
	func testShouldTrackSignalChanges() {
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
	
	func testShouldTrackSignalAndComputedChanges() {
		// Given
		@Ref var number = 1
		@Derived var double = number * 2
		let fakeHandler = FakeEffectHandler { _ = double }
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 2)
	}
	
	func testShouldNotTrigger_whenSignalChangeRedundant() {
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
	
	func testShouldNotTrigger_whenComputedChangeRedundant() {
		// Given
		@Ref var number = 1
		@Derived var computed = number < 10
		let fakeHandler = FakeEffectHandler { _ = computed }
		let effect = Effect(handler: fakeHandler.handler)
		effectsStore = [effect]
		
		// When
		number = 5
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldTriggerDeepChanges() {
		// Given
		struct Value: Hashable {
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
		@Derived var computed = "Deadpool"
		let fakeHandler = FakeEffectHandler {
			_ = "\(flag) \(number) \(computed)"
		}
		effectsStore = [Effect(handler: fakeHandler.handler)]
		XCTAssertEqual($flag.observerCount, 1, "computed should track source 1")
		XCTAssertEqual($number.observerCount, 1, "computed should track source 2")
		XCTAssertEqual($computed.observerCount, 1, "computed should track source 3")
		
		// When
		effectsStore = []
		
		// Then
		XCTAssertEqual($flag.observerCount, 0, "effect should untrack source 1")
		XCTAssertEqual($number.observerCount, 0, "effect should untrack source 2")
		XCTAssertEqual($computed.observerCount, 0, "effect should untrack source 3")
	}
	
	func testShouldNotTrackUnreachableSignals() {
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
	
	func testShouldTrackMultipleSources() {
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
	
	func testShouldMultipleEffectsTrackSameSource() {
		// Given
		@Ref var number = 1
		@Derived var double: Int = number + number
		let fakeHandler1 = FakeEffectHandler { _ = double }
		let effect1 = Effect(handler: fakeHandler1.handler)
		let fakeHandler2 = FakeEffectHandler { _ = double }
		let effect2 = Effect(handler: fakeHandler2.handler)
		let fakeHandler3 = FakeEffectHandler { _ = double }
		let effect3 = Effect(handler: fakeHandler3.handler)
		effectsStore = [effect1, effect2, effect3]
		XCTAssertEqual(fakeHandler1.callCount, 1)
		XCTAssertEqual(fakeHandler2.callCount, 1)
		XCTAssertEqual(fakeHandler3.callCount, 1)
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeHandler1.callCount, 2)
		XCTAssertEqual(fakeHandler2.callCount, 2)
		XCTAssertEqual(fakeHandler3.callCount, 2)
	}
	
	func testShouldMultipleEffectsUnTrackSameSource() {
		// Given
		@Ref var number = 1
		@Derived var double: Int = number * 2
		effectsStore = [
			Effect { _ = double },
			Effect { _ = double },
			Effect { _ = double },
		]
		XCTAssertEqual($double.observerCount, 3)
		
		// When
		effectsStore = []
		
		// Then
		XCTAssertEqual($double.observerCount, 0)
	}
}
