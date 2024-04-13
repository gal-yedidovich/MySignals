//
//  Effect.swift
//  
//
//  Created by Gal Yedidovich on 12/04/2024.
//

import Foundation

public final class Effect {
	private let handler: () -> Void
	
	private lazy var observer = {
		Observer { [weak self] in self?.trigger() }
	}()
	
	init(handler: @escaping () -> Void) {
		self.handler = handler
		trigger()
	}
	
	private func trigger() {
		observer.removeAllSources()
		observer.scope(handler: handler)
	}
	
	deinit {
		observer.removeAllSources()
	}
}
