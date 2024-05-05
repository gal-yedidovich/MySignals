//
//  Effect.swift
//  
//
//  Created by Gal Yedidovich on 12/04/2024.
//

import Foundation

public final class Effect {
	private let id = UUID()
	private let handler: () -> Void
	private var sources: Set<AnyReactiveValue> = []
	
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
			source.reactiveValue.remove(observer: self)
		}
		sources = []
	}
	
	deinit {
		removeAllSources()
	}
}

extension Effect: Observer {
	func onNotify(sourceChanged: Bool) {
		guard sourceChanged || shouldUpdate() else { return }
		
		trigger()
	}
	
	private func shouldUpdate() -> Bool {
		sources.contains { $0.reactiveValue.wasDirty(observer: self) }
	}
	
	func add(source: any ReactiveValue) {
		sources.insert(AnyReactiveValue(reactiveValue: source))
	}
}

extension Effect: Hashable {
	public static func == (lhs: Effect, rhs: Effect) -> Bool {
		lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
