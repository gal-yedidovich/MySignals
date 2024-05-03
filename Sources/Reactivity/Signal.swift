//
//  Signal.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

public final class Signal<Value: Equatable>: ReactiveValue {
	private var _value: Value
	
	private var observers: [WeakObserver] = [] // TODO: use a set for uniqueness
	
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
			
			_value = newValue
			notifyChange()
		}
	}
	
	private func track() {
		guard let observer = currentObserver else { return }
		add(observer: observer)
		observer.add(source: self)
	}
	
	private func notifyChange() {
		for weakObserver in observers {
			weakObserver.observer?.onNotify(sourceChanged: true)
		}
	}
	
	func add(observer: any Observer) {
		if observers.contains(where: { $0.observer === observer }) {
			return
		}
		observers.append(WeakObserver(observer))
	}
	
	func remove(observer: any Observer) {
		observers.reap()
		guard let index = observers.firstIndex(where: { $0.observer === observer }) else {
			return
		}
		observers.remove(at: index)
	}

	func wasDirty(observer: any Observer) -> Bool { true }
	
#if DEBUG
	internal var observerCount: Int { observers.count }
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
