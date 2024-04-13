//
//  Signal.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

public final class Signal<Value: Equatable> {
	private var _value: Value
	private let source = Source()
	
	public init(_ value: Value) {
		self._value = value
	}
	
	public var value: Value {
		get {
			source.track()
			return _value
		}
		set {
			guard newValue != _value else { return }
			
			source.notifyChange()
			_value = newValue
		}
	}
	
#if DEBUG
	internal var observerCount: Int { source.observerCount }
#endif
}

@propertyWrapper public struct Ref<T: Equatable> {
	private let signal: Signal<T>
	
	public init(wrappedValue initialValue: T) {
		self.signal = Signal(initialValue)
	}
	
	public var wrappedValue: T {
		get { signal.value }
		set { signal.value = newValue }
	}
	
	public var projectedValue: Signal<T> { signal }
}
