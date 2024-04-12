//
//  Context.swift
//  
//
//  Created by Gal Yedidovich on 11/04/2024.
//

import Foundation


private(set) var currentContext: Context? = nil

func scope(context: Context, scopedHandler: @escaping () -> Void) {
	let previousContext = currentContext
	currentContext = context
	scopedHandler()
	currentContext = previousContext
}


public class Context: Hashable {
	let onNotify: () -> Void
	let addSource: (AnySource) -> Void
	
	init(onNotify: @escaping () -> Void, addSource: @escaping (AnySource) -> Void) {
		self.onNotify = onNotify
		self.addSource = addSource
	}
	
	public static func == (lhs: Context, rhs: Context) -> Bool {
		lhs === rhs
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(Unmanaged.passUnretained(self).toOpaque())
	}
}
