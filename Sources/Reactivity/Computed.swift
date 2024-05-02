//
//  Computed.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

public final class Computed<ComputedValue: Equatable> {
	private let handler: () -> ComputedValue
	private var cachedValue: ComputedValue? = nil
	private var maybeDirty = true
	private var sources: [any ReactiveValue] = [] //TODO: use set
	private var observers: [WeakObserver] = [] //TODO: use set
	
	public init(handler: @escaping () -> ComputedValue) {
		self.handler = handler
	}
	
	public var value: ComputedValue {
		track()
		if (maybeDirty && findDirtySource()) || cachedValue == nil {
			removeAllSources()
			cachedValue = scope(handler: handler)
			maybeDirty = false
		}
		return cachedValue!
	}
	
	private func findDirtySource() -> Bool {
		for source in sources {
			if source.wasDirty() {
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
	
	deinit {
		removeAllSources()
	}
	
#if DEBUG
	internal var observerCount: Int { observers.count }
#endif
}

extension Computed: ReactiveValue {
	func add(observer: any Observer) {
		if observers.contains(where: { $0 === observer }) {
			return
		}
		observers.append(WeakObserver(observer))
	}
	
	func wasDirty() -> Bool {
		guard findDirtySource() else { return false }
		
		let prev = cachedValue
		removeAllSources()
		cachedValue = scope(handler: handler)
		maybeDirty = false
		return cachedValue != prev
	}
	
	func remove(observer: any Observer) {
		observers.reap()
		guard let index = observers.firstIndex(where: { $0 === observer }) else {
			return
		}
		observers.remove(at: index)
	}
}

extension Computed: Observer {
	func onNotify() {
		maybeDirty = true
		for observer in observers {
			observer.observer?.onNotify()
		}
	}
	
	func add(source: any ReactiveValue) {
		sources.append(source)
	}
	
	private func removeAllSources() {
		for source in sources {
			source.remove(observer: self)
		}
		sources = []
	}
}
