//
//  Observer.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

private(set) var currentObserver: Observer? = nil

public class Observer {
	private var sources: [Source] = []
	let onNotify: () -> Void
	
	init(onNotify: @escaping () -> Void) {
		self.onNotify = onNotify
	}
	
	func add(source: Source) {
		sources.append(source)
	}
	
	func removeAllSources() {
		for source in sources {
			source.remove(observer: self)
		}
		sources = []
	}
	
	func scope<T>(handler: () -> T) -> T {
		let previousObserver = currentObserver
		currentObserver = self
		defer { currentObserver = previousObserver }
		return handler()
	}
}

extension Observer: Hashable {
	public static func == (lhs: Observer, rhs: Observer) -> Bool {
		lhs === rhs
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(Unmanaged.passUnretained(self).toOpaque())
	}
}
