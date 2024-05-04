//
//  Computed.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

import Foundation

public final class Computed<ComputedValue: Hashable> {
	private let id = UUID()
	private let handler: () -> ComputedValue
	private var cachedValue: ComputedValue? = nil
	private var status: Status = .sourcesChanged
	private var sources: Set<AnyReactiveValue> = []
	private var observers: Set<WeakObserver> = []
	
	public init(handler: @escaping () -> ComputedValue) {
		self.handler = handler
	}
	
	public var value: ComputedValue {
		track()
		if isNotClean {
			cachedValue = recompute()
		}
		return cachedValue!
	}
	
	private var isNotClean: Bool {
		switch status {
		case .clean: return false
		case .sourcesChanged: return true
		case .maybeDirty: return findDirtySource()
		}
	}
	
	private func findDirtySource() -> Bool {
		for source in sources {
			if source.reactiveValue.wasDirty(observer: self) {
				return true
			}
		}
		
		return false
	}
	
	private func track() {
		guard let observer = currentObserver else { return }
		add(observer: observer)
		observer.add(source: self)
	}
	
	private func recompute() -> ComputedValue {
		removeAllSources()
		let value = scope(handler: handler)
		status = .clean
		return value
	}
	
	private func notifyObservers(sourceChanged: Bool, except: (any Observer)? = nil) {
		var copy = observers
		if let weakObserver = except?.asWeak() {
			copy.remove(weakObserver)
		}
		for weakObserver in copy {
			weakObserver.observer?.onNotify(sourceChanged: sourceChanged)
		}
	}
	
	deinit {
		removeAllSources()
	}
	
#if DEBUG
	internal var observerCount: Int { observers.count }
#endif
}

extension Computed: ReactiveValue {
	func add(observer: any Observer) {
		observers.insert(observer.asWeak())
	}
	
	func wasDirty(observer: any Observer) -> Bool {
		guard isNotClean else { return false }
		
		let prev = cachedValue
		cachedValue = recompute()
		
		let valueChanged = cachedValue != prev
		if valueChanged {
			notifyObservers(sourceChanged: true, except: observer)
		}
		
		return valueChanged
	}
	
	func remove(observer: any Observer) {
		observers.reap()
		observers.remove(observer.asWeak())
	}
}

extension Computed: Observer {
	func onNotify(sourceChanged: Bool) {
		if status != .sourcesChanged {
			status = sourceChanged ? .sourcesChanged : .maybeDirty
		}
		
		notifyObservers(sourceChanged: false)
	}
	
	func add(source: any ReactiveValue) {
		sources.insert(AnyReactiveValue(reactiveValue: source))
	}
	
	private func removeAllSources() {
		for source in sources {
			source.reactiveValue.remove(observer: self)
		}
		sources = []
	}
}

private extension Computed {
	enum Status {
		case clean
		case sourcesChanged
		case maybeDirty
	}
}

extension Computed: Hashable {
	public static func == (lhs: Computed<ComputedValue>, rhs: Computed<ComputedValue>) -> Bool {
		lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
