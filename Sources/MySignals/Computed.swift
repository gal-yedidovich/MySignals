//
//  Computed.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

public final class Computed<ComputedValue: Equatable> {
	private let handler: () -> ComputedValue
	private var cachedValue: ComputedValue? = nil
	private var isDirty = true
	private var sources: [AnySource] = []
	private var observers: Set<Observer> = []
	
	private lazy var observer = {
		Observer { [weak self] in
			guard let self else { return }
			isDirty = true
			for observer in observers {
				observer.onNotify()
			}
		} addSource: { [weak self] anySignal in
			self?.sources.append(anySignal)
		}
	}()
	
	public init(handler: @escaping () -> ComputedValue) {
		self.handler = handler
	}
	
	public var value: ComputedValue {
		if isDirty {
			cleanSources()
			track()
			scope(with: observer) { [weak self] in
				guard let self else { return }
				cachedValue = handler()
			}
			isDirty = false
		}
		return cachedValue!
	}
	
	private func track() {
		guard let observer = currentObserver else { return }
		observers.insert(observer)
		observer.addSource(AnySource(source: self))
	}
	
	private func cleanSources() {
		for source in sources {
			source.untrack(observer)
		}
		sources = []
	}
	
	deinit {
		cleanSources()
	}
	
#if DEBUG
	internal var observerCount: Int { observers.count }
#endif
}

extension Computed: Source {
	func untrack(context: Observer) {
		observers.remove(context)
	}
}
