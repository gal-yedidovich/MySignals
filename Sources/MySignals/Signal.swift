//
//  Signal.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

public final class Signal<Value: Equatable> {
	private var observers: Set<Observer> = []
	private var _value: Value
	
	public init(_ value: Value) {
		self._value = value
	}
	
	public var value: Value {
		get {
			track()
			return _value
		}
		set {
			guard newValue != _value else { return }
			
			for observer in observers {
				observer.onNotify()
			}
			
			_value = newValue
		}
	}
	
	private func track() {
		guard let observer = currentObserver else { return }
		observers.insert(observer)
		observer.addSource(AnySource(source: self))
	}
	
#if DEBUG
	internal var observerCount: Int { observers.count }
#endif
}

extension Signal: Source {
	func untrack(context observer: Observer) {
		observers.remove(observer)
	}
}
