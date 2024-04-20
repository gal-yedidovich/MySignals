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
	internal let source = Source()
	
	private lazy var observer = {
		Observer { [weak self] in
			guard let self else { return }
			isDirty = true
			source.notifyChange()
		}
	}()
	
	public init(handler: @escaping () -> ComputedValue) {
		self.handler = handler
	}
	
	@MainActor
	public var value: ComputedValue {
		source.track()
		if isDirty {
			observer.removeAllSources()
			cachedValue = observer.scope(handler: handler)
			isDirty = false
		}
		return cachedValue!
	}
	
	deinit {
		observer.removeAllSources()
	}
	
#if DEBUG
	internal var observerCount: Int { source.observerCount }
#endif
}
