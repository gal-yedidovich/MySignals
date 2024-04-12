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
	let onNotify: () -> Void
	let addSource: (AnySource) -> Void
	
	init(onNotify: @escaping () -> Void, addSource: @escaping (AnySource) -> Void) {
		self.onNotify = onNotify
		self.addSource = addSource
	}
	
	public static func == (lhs: Observer, rhs: Observer) -> Bool {
		lhs === rhs
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(Unmanaged.passUnretained(self).toOpaque())
	}
}
