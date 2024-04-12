
public final class Signal<Value: Equatable> {
	private var observers: Set<Context> = []
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
		guard let observer = currentContext else { return }
		observers.insert(observer)
		observer.addSource(AnySource(source: self))
	}
	
#if DEBUG
	internal var observerCount: Int { observers.count }
#endif
}

extension Signal: Source {
	func untrack(context observer: Context) {
		observers.remove(observer)
	}
	
}

struct AnySource {
	let source: any Source
	
	init(source: any Source) {
		self.source = source
	}
	
	func untrack(_ observer: Context) {
		source.untrack(context: observer)
	}
}

protocol Source {
	func untrack(context: Context)
}
