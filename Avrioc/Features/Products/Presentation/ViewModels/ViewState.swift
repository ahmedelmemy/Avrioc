//
//  ViewState.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Represents the loading lifecycle states of a data-driven view.
//

import Foundation

enum ViewState: Equatable, Sendable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
