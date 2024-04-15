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
	
	func testShouldWatchForComputedChanges() {
		// Given
		@Ref var number = 1
		let computed = Computed { number * 2}
		var oldValue: Int = 0
		var newValue: Int = 0
		let fakeWatchHandler = FakeWatchHandler<Int> { newV, oldV in
			newValue = newV
			oldValue = oldV
		}
		let watcher = Watch(computed, handler: fakeWatchHandler.handler)
		watcherStore = [watcher]
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeWatchHandler.callCount, 1)
		XCTAssertEqual(oldValue, 2)
		XCTAssertEqual(newValue, 4)
	}
	
	func testShouldNotWatchForChanges_afterDeinit() {
		// Given
		@Ref var number = 1
		let fakeWatchHandler = FakeWatchHandler<Int> { _,_ in }
		_ = Watch($number, handler: fakeWatchHandler.handler)
		
		// When
		number = 2
		
		// Then
		XCTAssertEqual(fakeWatchHandler.callCount, 0)
		XCTAssertEqual($number.observerCount, 0)
	}
}
