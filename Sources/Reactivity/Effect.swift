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
		onNotify()
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
	func onNotify() {
		removeAllSources()
		scope(handler: handler)
	}
	
	func add(source: any ReactiveValue) {
		sources.append(source)
	}
}
