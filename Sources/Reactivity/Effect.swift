//
//  Effect.swift
//  
//
//  Created by Gal Yedidovich on 12/04/2024.
//

import Foundation

public final class Effect {
	private let handler: () -> Void
	private var sources: [any ReactiveValue] = []
	
	init(handler: @escaping () -> Void) {
		self.handler = handler
		trigger()
	}
	
	private func trigger() {
		removeAllSources()
		scope(handler: handler)
	}
	
	private func removeAllSources() {
		for source in sources {
			source.remove(observer: self)
		}
		sources = []
	}
	
	deinit {
		removeAllSources()
	}
}

extension Effect: Observer {
	func onNotify(sourceChanged: Bool) {
		guard shouldUpdate() else { return }
		
		trigger()
	}
	
	private func shouldUpdate() -> Bool {
		for source in sources {
			if source.wasDirty(observer: self) {
				return true
			}
		}
		
		return false
	}
	
	func add(source: any ReactiveValue) {
		sources.append(source)
	}
}
