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
	private let signal: Signal<WatchedValue>
	
	private lazy var observer = {
		Observer { [weak self] in
			self?.trigger()
		}
	}()
	
	public init(_ signal: Signal<WatchedValue>, handler: @escaping (WatchedValue, WatchedValue) -> Void) {
		self.handler = handler
		self.currentValue = signal.value
		self.signal = signal
		
		signal.source.add(observer: observer)
	}
	
	private func trigger() {
		let newValue = signal.value
		handler(newValue, currentValue)
		currentValue = newValue
	}
	
	deinit {
		signal.source.remove(observer: observer)
	}
}
