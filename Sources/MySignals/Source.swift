//
//  Source.swift
//
//
//  Created by Gal Yedidovich on 12/04/2024.
//

protocol Source {
	func untrack(context: Observer)
}

struct AnySource {
	let source: any Source
	
	init(source: any Source) {
		self.source = source
	}
	
	func untrack(_ observer: Observer) {
		source.untrack(context: observer)
	}
}
