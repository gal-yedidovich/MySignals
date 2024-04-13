//
//  Observer.swift
//
//
//  Created by Gal Yedidovich on 11/04/2024.
//

private(set) var currentObserver: Observer? = nil

func scope(with observer: Observer, scopedHandler: @escaping () -> Void) {
	let previousContext = currentObserver
	currentObserver = observer
	scopedHandler()
	currentObserver = previousContext
}

public class Observer: Hashable {
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
	
	public static func == (lhs: Observer, rhs: Observer) -> Bool {
		lhs === rhs
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(Unmanaged.passUnretained(self).toOpaque())
	}
}
