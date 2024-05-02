//
//  Watch.swift
//
//
//  Created by Gal Yedidovich on 15/04/2024.
//

import Foundation

public class Watch<WatchedValue: Equatable> {
	private let handler: (WatchedValue, WatchedValue) -> Void
	private var currentValue: WatchedValue
	private let reactiveValue: any ReactiveValue<WatchedValue>
	
	public init(_ signal: Signal<WatchedValue>, handler: @escaping (WatchedValue, WatchedValue) -> Void) {
		self.handler = handler
		self.currentValue = signal.value
		self.reactiveValue = signal
		
		signal.add(observer: self)
	}
	
	public init(_ computed: Computed<WatchedValue>, handler: @escaping (WatchedValue, WatchedValue) -> Void) {
		self.handler = handler
		self.currentValue = computed.value
		self.reactiveValue = computed
		
		computed.add(observer: self)
	}
	
	deinit {
		reactiveValue.remove(observer: self)
	}
}

extension Watch: Observer {
	func onNotify() {
		let newValue = reactiveValue.value
		handler(newValue, currentValue)
		currentValue = newValue
	}
	
	func add(source: any ReactiveValue) {
	}
}
