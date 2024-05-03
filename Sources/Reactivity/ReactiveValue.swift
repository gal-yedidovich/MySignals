//
//  ReactiveValue.swift
//  
//
//  Created by Gal Yedidovich on 03/05/2024.
//

import Foundation

protocol ReactiveValue<Value>: AnyObject {
	associatedtype Value: Equatable
	var value: Value { get }
	
	func wasDirty(observer: any Observer) -> Bool
	
	func add(observer: any Observer)
	
	func remove(observer: any Observer)
}
