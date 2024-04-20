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
	
	private lazy var observer = {
		Observer { [weak self] in
			self?.trigger()
		}
	}()
	
	@MainActor
	public init(_ signal: Signal<WatchedValue>, handler: @escaping (WatchedValue, WatchedValue) -> Void) {
		self.handler = handler
		self.currentValue = signal.value
		self.reactiveValue = signal
		
		signal.source.add(observer: observer)
	}
	
	@MainActor
	public init(_ computed: Computed<WatchedValue>, handler: @escaping (WatchedValue, WatchedValue) -> Void) {
		self.handler = handler
		self.currentValue = computed.value
		self.reactiveValue = computed
		
		computed.source.add(observer: observer)
	}
	
	private func trigger() {
		let newValue = reactiveValue.value
		handler(newValue, currentValue)
		currentValue = newValue
	}
	
	deinit {
		reactiveValue.source.remove(observer: observer)
	}
}


protocol ReactiveValue<Value> {
	associatedtype Value: Equatable
	var value: Value { get }
	var source: Source { get }
}

extension Signal: ReactiveValue {}
extension Computed: ReactiveValue {}
