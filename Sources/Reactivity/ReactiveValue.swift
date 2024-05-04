//
//  ReactiveValue.swift
//  
//
//  Created by Gal Yedidovich on 03/05/2024.
//

import Foundation

protocol ReactiveValue<Value>: AnyObject, Hashable {
	associatedtype Value: Hashable
	var value: Value { get }
	
	func wasDirty(observer: any Observer) -> Bool
	
	func add(observer: any Observer)
	
	func remove(observer: any Observer)
}

struct AnyReactiveValue: Hashable {
	let reactiveValue: (any ReactiveValue)
	
	static func == (lhs: AnyReactiveValue, rhs: AnyReactiveValue) -> Bool {
		AnyHashable(lhs.reactiveValue) == AnyHashable(rhs.reactiveValue)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(AnyHashable(reactiveValue))
	}
}
