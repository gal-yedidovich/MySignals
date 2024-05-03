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
	private var sourcesChanged = false
	private var sources: [any ReactiveValue] = [] //TODO: use set
	private var observers: [WeakObserver] = [] //TODO: use set
	
	public init(handler: @escaping () -> ComputedValue) {
		self.handler = handler
	}
	
	public var value: ComputedValue {
		track()
		if cachedValue == nil || sourcesChanged || (maybeDirty && findDirtySource()) {
			cachedValue = recompute()
		}
		return cachedValue!
	}
	
	private func findDirtySource() -> Bool {
		for source in sources {
			if source.wasDirty(observer: self) {
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
		sourcesChanged = false
		maybeDirty = false
		return value
	}
	
	private func notifyObservers(sourceChanged: Bool, except: (any Observer)? = nil) {
		let filtered = observers.lazy.filter { $0.observer !== except }
		for weakObserver in filtered {
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
		if observers.contains(where: { $0 === observer }) {
			return
		}
		observers.append(WeakObserver(observer))
	}
	
	func wasDirty(observer: any Observer) -> Bool {
		guard maybeDirty else { return false }
		guard sourcesChanged || findDirtySource() else { return false }
		
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
		guard let index = observers.firstIndex(where: { $0 === observer }) else {
			return
		}
		observers.remove(at: index)
	}
}

extension Computed: Observer {
	func onNotify(sourceChanged: Bool) {
		maybeDirty = true
		if sourceChanged {
			self.sourcesChanged = true
		}
		
		notifyObservers(sourceChanged: false)
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
