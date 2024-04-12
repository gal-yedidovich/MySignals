//
//  ComputedTests.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

import XCTest
@testable import MySignals

final class ComputedTests: XCTestCase {
	func testShouldComputeSignal() {
		// Given
		let signal = Signal(5)
		let fakeHandler = FakeComputedHandler { signal.value * 2 }
		
		// When
		let computed = Computed(handler: fakeHandler.handler)
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 0)
		XCTAssertEqual(computed.value, 10)
		XCTAssertEqual(fakeHandler.callCount, 1)
		XCTAssertEqual(computed.observerCount, 0)
	}
	
	func testShouldRecompute_whenSignalUpdates() {
		// Given
		let signal = Signal(5)
		let fakeHandler = FakeComputedHandler { signal.value * 2 }
		let computed = Computed(handler: fakeHandler.handler)
		XCTAssertEqual(computed.value, 10)
		
		// When
		signal.value = 30
		
		// Then
		XCTAssertEqual(fakeHandler.callCount, 1)
		XCTAssertEqual(computed.value, 60)
		XCTAssertEqual(fakeHandler.callCount, 2)
	}
	
	func testShouldNotRecompute_whenSignalUnchanged() {
		// Given
		let signal = Signal("bubu")
		let fakeHandler = FakeComputedHandler { signal.value.count }
		
		// When
		let computed = Computed(handler: fakeHandler.handler)
		
		// Then
		XCTAssertEqual(computed.value, 4)
		XCTAssertEqual(computed.value, 4)
		XCTAssertEqual(computed.value, 4)
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldNotRecompute_whenSignalChangeRedundant() {
		// Given
		let signal = Signal("bubu")
		let fakeHandler = FakeComputedHandler { "\(signal.value) \(signal.value)" }
		let computed = Computed(handler: fakeHandler.handler)
		XCTAssertEqual(computed.value, "bubu bubu")
		
		// When
		signal.value = "bubu"
		
		// Then
		XCTAssertEqual(computed.value, "bubu bubu")
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldUntrackSources_whenComputedDeinit() {
		// Given
		let signal1 = Signal(true)
		let signal2 = Signal(1)
		let computed1 = Computed { "Deadpool" }
		let fakeHandler = FakeComputedHandler { "\(signal1.value) \(signal2.value) \(computed1.value)" }
		var computed2: Computed<String>? = Computed(handler: fakeHandler.handler)
		XCTAssertEqual(computed2?.value, "true 1 Deadpool")
		XCTAssertEqual(signal1.observerCount, 1, "computed should track source 1")
		XCTAssertEqual(signal2.observerCount, 1, "computed should track source 2")
		XCTAssertEqual(computed1.observerCount, 1, "computed should track source 3")
		
		// When
		computed2 = nil
		
		// Then
		XCTAssertEqual(signal1.observerCount, 0, "computed observer should be untracked by source 1")
		XCTAssertEqual(signal2.observerCount, 0, "computed observer should be untracked by source 2")
		XCTAssertEqual(computed1.observerCount, 0, "computed observer should be untracked by source 3")
	}
	
	func testShouldNotTrackUnreachableSignals() {
		// Given
		let signal1 = Signal(true)
		let signal2 = Signal(1)
		let fakeHandler = FakeComputedHandler {
			if signal1.value {
				return "bubu the king"
			}
			
			return "\(signal1.value) count"
		}
		let computed = Computed(handler: fakeHandler.handler)
		XCTAssertEqual(computed.value, "bubu the king")
		
		// When
		signal2.value = 2
		
		// Then
		XCTAssertEqual(computed.value, "bubu the king")
		XCTAssertEqual(signal2.observerCount, 0, "computed should not track unreachable source 2")
		XCTAssertEqual(fakeHandler.callCount, 1)
	}
	
	func testShouldTrackAnotherComputed() {
		// Given
		let signal1 = Signal(true)
		let computed1 = Computed { "\(signal1.value)" }
		let fakeHandler2 = FakeComputedHandler { computed1.value.count }
		let computed2 = Computed(handler: fakeHandler2.handler)
		XCTAssertEqual(computed1.observerCount, 0, "first computed should not be tracked before second computed evaluates")
		XCTAssertEqual(computed2.value, 4)
		XCTAssertEqual(computed1.observerCount, 1, "first computed should be tracked now")
		XCTAssertEqual(fakeHandler2.callCount, 1)
		
		// When
		signal1.value = false
		
		// Then
		XCTAssertEqual(computed2.value, 5, "")
		XCTAssertEqual(fakeHandler2.callCount, 2)
	}
	
	func testShouldRecomputedOnce_whenMultipleSourceChange() {
		// Given
		let signal1 = Signal(1)
		let signal2 = Signal(2)
		let fakeHandler = FakeComputedHandler { signal1.value + signal2.value }
		let computed = Computed(handler: fakeHandler.handler)
		XCTAssertEqual(computed.value, 3)
		XCTAssertEqual(fakeHandler.callCount, 1)
		
		// When
		signal1.value = 10
		signal2.value = 3
		
		// Then
		XCTAssertEqual(computed.value, 13)
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
		XCTAssertEqual(fakeHandler1.callCount, 1, "should not recompute 'clean' copmuted")
	}
}
