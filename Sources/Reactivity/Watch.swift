//
//  Watch.swift
//
//
//  Created by Gal Yedidovich on 15/04/2024.
//

import Foundation

private enum ReactiveValue<Value: Equatable> {
	case signal(Signal<Value>)
	case computed(Computed<Value>)
	
	var value: Value {
		switch self {
		case .signal(let signal):
			return signal.value
		case .computed(let computed):
			return computed.value
		}
	}
	
	var source: Source {
		switch self {
		case .signal(let signal):
			return signal.source
		case .computed(let computed):
			return computed.source
		}
	}
}

public class Watch<WatchedValue: Equatable> {
	private let handler: (WatchedValue, WatchedValue) -> Void
	private var currentValue: WatchedValue
	private let reactiveValue: ReactiveValue<WatchedValue>
	
	private lazy var observer = {
		Observer { [weak self] in
			self?.trigger()
		}
	}()
	
	public init(_ signal: Signal<WatchedValue>, handler: @escaping (WatchedValue, WatchedValue) -> Void) {
		self.handler = handler
		self.currentValue = signal.value
		self.reactiveValue = .signal(signal)
		
		signal.source.add(observer: observer)
	}
	
	public init(_ computed: Computed<WatchedValue>, handler: @escaping (WatchedValue, WatchedValue) -> Void) {
		self.handler = handler
		self.currentValue = computed.value
		self.reactiveValue = .computed(computed)
		
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
