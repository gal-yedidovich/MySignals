//
//  Source.swift
//
//
//  Created by Gal Yedidovich on 12/04/2024.
//

class Source {
	private var observers: Set<Observer> = []

	func track() {
		guard let observer = currentObserver else { return }
		observers.insert(observer)
		observer.add(source: self)
	}
	
	func add(observer: Observer) {
		observers.insert(observer)
	}
	
	func remove(observer: Observer) {
		observers.remove(observer)
	}
	
	func notifyChange() {
		for observer in observers {
			observer.onNotify()
		}
	}
	
#if DEBUG
	internal var observerCount: Int { observers.count }
#endif
}
