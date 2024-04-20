//
//  SignalTests.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

import XCTest
import Reactivity

final class SignalTests: XCTestCase {
	@MainActor
	func testShouldCreateSignal() {
		// Given
		
		// When
		let signal = Signal(10)
		
		// Then
		XCTAssertEqual(signal.value, 10)
	}
	
	@MainActor
	func testShouldModifySignal() {
		// Given
		let signal = Signal(10)
		
		// When
		signal.value = 20
		
		// Then
		XCTAssertEqual(signal.value, 20)
	}
	
	func testShouldModifySignal() async {
		// Given
		let signal = Signal(10)
		
		// When
		await MainActor.run {
			signal.value = 20
		}
		
		// Then
		let value = await signal.value
		XCTAssertEqual(value, 20)
	}
}
