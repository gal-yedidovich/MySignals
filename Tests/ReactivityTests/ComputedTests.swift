//
//  ComputedTests.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

import XCTest
@testable import Reactivity

final class ComputedTests: XCTestCase {
	func testShouldComputeConstant() {
		// Given
		let fakeHandler = FakeComputedHandler { 10 + 10 }
		
		// When
		let computed = Computed(handler: fakeHandler.handler)
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 0)
		XCTAssertEqual(computed.value, 20)
		XCTAssertEqual(fakeHandler.callCount, 1)
		XCTAssertEqual(computed.observerCount, 0)
		XCTAssertEqual(computed.sourceCount, 0)
	}
	
	func testShouldComputeSignal() {
		// Given
		@Ref var number = 5
		let fakeHandler = FakeComputedHandler { number + number }
		
		// When
		let computed = Computed(handler: fakeHandler.handler)
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 0)
		XCTAssertEqual(computed.value, 10)
		XCTAssertEqual(fakeHandler.callCount, 1)
		XCTAssertEqual(computed.observerCount, 0)
		XCTAssertEqual(computed.sourceCount, 1)
	}
	
	func testShouldRecompute_whenSignalChanges() {
		// Given
		@Ref var number = 5
		let fakeHandler = FakeComputedHandler { number + number }
		let computed = Computed(handler: fakeHandler.handler)
		XCTAssertEqual(computed.value, 10)
		
		// When
		number = 30
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 1)
		XCTAssertEqual(computed.value, 60)
		XCTAssertEqual(fakeHandler.callCount, 2)
	}
	
	func testShouldTrackAnotherComputed() {
		// Given
		@Ref var flag = true
		let computed1 = Computed { "\(flag)" }
		let fakeHandler2 = FakeComputedHandler { computed1.value.count }
		let computed2 = Computed(handler: fakeHandler2.handler)
		XCTAssertEqual(computed1.observerCount, 0, "first computed should not be tracked before second computed evaluates")
		XCTAssertEqual(computed2.value, 4)
		XCTAssertEqual(computed1.observerCount, 1, "first computed should be tracked now")
		XCTAssertEqual(fakeHandler2.callCount, 1)
		
		// When
		flag = false
		
		// Then
		XCTAssertEqual(computed2.value, 5, "")
		XCTAssertEqual(fakeHandler2.callCount, 2)
	}
	
	func testShouldNotRecompute_whenSignalUnchanged() {
		// Given
		@Ref var name = "bubu"
		let fakeHandler = FakeComputedHandler { name.count }
		
		
		// When
		@Derived(handler: fakeHandler.handler) var computed: Int
		
		// Then
		XCTAssertEqual(computed, 4)
		XCTAssertEqual(computed, 4)
		XCTAssertEqual(computed, 4)
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldNotRecompute_whenSignalChangeRedundant() {
		// Given
		@Ref var name = "bubu"
		let fakeHandler = FakeComputedHandler { "\(name) \(name)" }
		@Derived(handler: fakeHandler.handler) var computed: String
		XCTAssertEqual(computed, "bubu bubu")
		
		// When
		name = "bubu"
		
		// Then
		XCTAssertEqual(computed, "bubu bubu")
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldNotRecompute_whenComputedChangeRedundant() {
		// Given
		@Ref var number = 2
		let fakeEvenHandler = FakeComputedHandler { number % 2 == 0 }
		@Derived(handler: fakeEvenHandler.handler) var isEven: Bool
		let fakeMsgHandler = FakeComputedHandler { "value is \(isEven ? "even" : "odd")" }
		@Derived(handler: fakeMsgHandler.handler) var computed: String
		XCTAssertEqual(computed, "value is even")
		XCTAssertEqual(fakeEvenHandler.callCount, 1)
		XCTAssertEqual(fakeMsgHandler.callCount, 1)
		
		// When
		number = 4
		
		// Then
		XCTAssertEqual(computed, "value is even")
		XCTAssertEqual(fakeEvenHandler.callCount, 2)
		XCTAssertEqual(fakeMsgHandler.callCount, 1)
	}
	
	func testShouldUntrackSources_whenComputedDeinit() {
		// Given
		@Ref var flag = true
		@Ref var number = 1
		@Derived var computed1 = "Deadpool"
		let fakeHandler = FakeComputedHandler { "\(flag) \(number) \(computed1)" }
		var computed2: Computed<String>? = Computed(handler: fakeHandler.handler)
		XCTAssertEqual(computed2?.value, "true 1 Deadpool")
		XCTAssertEqual($flag.observerCount, 1, "computed should track source 1")
		XCTAssertEqual($number.observerCount, 1, "computed should track source 2")
		XCTAssertEqual($computed1.observerCount, 1, "computed should track source 3")
		
		// When
		computed2 = nil
		
		// Then
		XCTAssertEqual($flag.observerCount, 0, "computed should untrack source 1")
		XCTAssertEqual($number.observerCount, 0, "computed should untrack source 2")
		XCTAssertEqual($computed1.observerCount, 0, "computed should untrack source 3")
	}
	
	func testShouldNotTrackUnreachableSignals() {
		// Given
		@Ref var flag = true
		@Ref var number = 1
		let fakeHandler = FakeComputedHandler {
			if flag {
				return "bubu the king"
			}
			
			return "\(number) count"
		}
		let computed = Computed(handler: fakeHandler.handler)
		XCTAssertEqual(computed.value, "bubu the king")
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(computed.value, "bubu the king")
		XCTAssertEqual($number.observerCount, 0, "computed should not track unreachable source 2")
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldRecomputedOnce_whenMultipleSourceChange() {
		// Given
		@Ref var number1 = 1
		@Ref var number2 = 2
		let fakeHandler = FakeComputedHandler { number1 + number2 }
		@Derived var sum: Int = fakeHandler.handler()
		XCTAssertEqual(sum, 3)
		XCTAssertEqual(fakeHandler.callCount, 1)
		
		// When
		number1 = 10
		number2 = 3
		
		// Then
		XCTAssertEqual(sum, 13)
		XCTAssertEqual(fakeHandler.callCount, 2)
	}
	
	func testShouldShouldRecomputeOnlyDirtySources() {
		// Given
		let signal1 = Signal("Bubu")
		let signal2 = Signal(true)
		let fakeHandler1 = FakeComputedHandler { "Name is \(signal1.value)" }
		let computed1 = Computed(handler: fakeHandler1.handler)
		let fakeHandler2 = FakeComputedHandler { "\(computed1.value), is alive: \(signal2.value)" }
		let computed2 = Computed(handler: fakeHandler2.handler)
		
		XCTAssertEqual(computed2.value, "Name is Bubu, is alive: true")
		
		// When
		signal2.value = false
		
		// Then
		XCTAssertEqual(computed2.value, "Name is Bubu, is alive: false")
		XCTAssertEqual(fakeHandler1.callCount, 1, "should not recompute 'clean' computed")
	}
	
	func testShouldMultipleComputedTrackSameSource() {
		// Given
		let signal1 = Signal("Bubu is the king")
		let fakehandler1 = FakeComputedHandler { signal1.value.count }
		let computed1 = Computed(handler: fakehandler1.handler)
		let computed2 = Computed { computed1.value % 10 }
		let computed3 = Computed { computed1.value / 5 }
		
		XCTAssertEqual(computed2.value, 6)
		XCTAssertEqual(computed3.value, 3)
		XCTAssertEqual(fakehandler1.callCount, 1)
		
		// When
		signal1.value = "I am groot"
		
		// Then
		XCTAssertEqual(signal1.observerCount, 1)
		XCTAssertEqual(computed1.observerCount, 2)
		XCTAssertEqual(computed2.observerCount, 0)
		XCTAssertEqual(computed3.observerCount, 0)
		
		XCTAssertEqual(computed2.value, 0)
		XCTAssertEqual(computed3.value, 2)
		XCTAssertEqual(fakehandler1.callCount, 2)
	}
}
