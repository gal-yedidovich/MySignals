//
//  WatchTests.swift
//
//
//  Created by Gal Yedidovich on 15/04/2024.
//

import XCTest
@testable import Reactivity

final class WatchTests: XCTestCase {
	private var watcherStore: [Watch<Int>] = []
	
	func testShouldCreateWatch() {
		// Given
		@Ref var number = 1
		let fakeWatchHandler = FakeWatchHandler<Int> { _,_ in }
		
		// When
		_ = Watch($number, handler: fakeWatchHandler.handler)
		
		// Then
		XCTAssertEqual(fakeWatchHandler.callCount, 0)
	}
	
	func testShouldWatchForSignalChanges() {
		// Given
		@Ref var number = 1
		var oldValue: Int = 0
		var newValue: Int = 0
		let fakeWatchHandler = FakeWatchHandler<Int> { newV, oldV in
			newValue = newV
			oldValue = oldV
		}
		let watcher = Watch($number, handler: fakeWatchHandler.handler)
		watcherStore = [watcher]
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeWatchHandler.callCount, 1)
		XCTAssertEqual(oldValue, 1)
		XCTAssertEqual(newValue, 2)
	}
	
	func testShouldNotTriggerWatch_whenSignalChangeRedundant() {
		// Given
		@Ref var number = 1
		let fakeWatchHandler = FakeWatchHandler<Int> { _,_ in }
		let watcher = Watch($number, handler: fakeWatchHandler.handler)
		watcherStore = [watcher]
		
		// When
		number = 1
		
		// Then
		XCTAssertEqual(fakeWatchHandler.callCount, 0)
	}
	
	func testShouldWatchForComputedChanges() {
		// Given
		@Ref var number = 1
		@Derived var computed = number * 2
		var oldValue: Int = 0
		var newValue: Int = 0
		let fakeWatchHandler = FakeWatchHandler<Int> { newV, oldV in
			newValue = newV
			oldValue = oldV
		}
		let watcher = Watch($computed, handler: fakeWatchHandler.handler)
		watcherStore = [watcher]
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeWatchHandler.callCount, 1)
		XCTAssertEqual(oldValue, 2)
		XCTAssertEqual(newValue, 4)
	}
	
	func testShouldNotTriggerWatch_whenComputedChangesRedundant() {
		// Given
		@Ref var number = 1
		@Derived var computed = number < 10 ? 0 : 1
		let fakeWatchHandler = FakeWatchHandler<Int> { _,_ in }
		let watcher = Watch($computed, handler: fakeWatchHandler.handler)
		watcherStore = [watcher]
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeWatchHandler.callCount, 0)
	}
	
	func testShouldWatchForImplicitComputedChanges() {
		// Given
		@Ref var number = 1
		var oldValue: Int = 0
		var newValue: Int = 0
		let fakeWatchHandler = FakeWatchHandler<Int> { newV, oldV in
			newValue = newV
			oldValue = oldV
		}
		let watcher = Watch(number + 1, handler: fakeWatchHandler.handler)
		watcherStore = [watcher]
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeWatchHandler.callCount, 1)
		XCTAssertEqual(oldValue, 2)
		XCTAssertEqual(newValue, 3)
	}
	
	func testShouldNotWatchForChanges_afterDeinit() {
		// Given
		@Ref var number = 1
		let fakeWatchHandler = FakeWatchHandler<Int> { _,_ in }
		_ = Watch(number, handler: fakeWatchHandler.handler)
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeWatchHandler.callCount, 0)
		XCTAssertEqual($number.observerCount, 0)
	}
	
	func testShouldTriggerMultipleWatch_withSignal() {
		// Given
		@Ref var number = 10
		var newValue1 = 0
		var newValue2 = 0
		var newValue3 = 0
		let fakeWatchHandler1 = FakeWatchHandler<Int> { newV,_ in newValue1 = newV }
		let fakeWatchHandler2 = FakeWatchHandler<Int> { newV,_ in newValue2 = newV + 5 }
		let fakeWatchHandler3 = FakeWatchHandler<Int> { newV,_ in newValue3 = newV + 10 }
		let watch1 = Watch($number, handler: fakeWatchHandler1.handler)
		let watch2 = Watch($number, handler: fakeWatchHandler2.handler)
		let watch3 = Watch($number, handler: fakeWatchHandler3.handler)
		watcherStore = [watch1, watch2, watch3]
		
		// When
		number = 20
		
		// Then
		XCTAssertEqual(fakeWatchHandler1.callCount, 1)
		XCTAssertEqual(fakeWatchHandler2.callCount, 1)
		XCTAssertEqual(fakeWatchHandler3.callCount, 1)
		XCTAssertEqual(newValue1, 20)
		XCTAssertEqual(newValue2, 25)
		XCTAssertEqual(newValue3, 30)
	}
	
	func testShouldTriggerMultipleWatch_withComputed() {
		// Given
		@Ref var number = 5
		@Derived var double = number + number
		var newValue1 = 0
		var newValue2 = 0
		var newValue3 = 0
		let fakeWatchHandler1 = FakeWatchHandler<Int> { newV,_ in newValue1 = newV }
		let fakeWatchHandler2 = FakeWatchHandler<Int> { newV,_ in newValue2 = newV + 5 }
		let fakeWatchHandler3 = FakeWatchHandler<Int> { newV,_ in newValue3 = newV + 10 }
		let watch1 = Watch($double, handler: fakeWatchHandler1.handler)
		let watch2 = Watch($double, handler: fakeWatchHandler2.handler)
		let watch3 = Watch($double, handler: fakeWatchHandler3.handler)
		watcherStore = [watch1, watch2, watch3]
		
		// When
		number = 10
		
		// Then
		XCTAssertEqual(fakeWatchHandler1.callCount, 1)
		XCTAssertEqual(fakeWatchHandler2.callCount, 1)
		XCTAssertEqual(fakeWatchHandler3.callCount, 1)
		XCTAssertEqual(newValue1, 20)
		XCTAssertEqual(newValue2, 25)
		XCTAssertEqual(newValue3, 30)
	}
}
