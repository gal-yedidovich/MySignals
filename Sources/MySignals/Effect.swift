//
//  Effect.swift
//  
//
//  Created by Gal Yedidovich on 12/04/2024.
//

import Foundation

public final class Effect {
	private let handler: () -> Void
	private var sources: [AnySource] = []
	
	private lazy var observer = {
		Observer { [weak self] in
			guard let self else { return }
			trigger()
		} addSource: { [weak self] source in
			self?.sources.append(source)
		}
	}()
	
	init(handler: @escaping () -> Void) {
		self.handler = handler
		trigger()
	}
	
	private func trigger() {
		cleanSources()
		scope(with: observer) { [weak self] in
			guard let self else { return }
			handler()
		}
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
}
