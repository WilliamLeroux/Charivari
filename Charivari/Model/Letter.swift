//
//  LetterModel.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-29.
//

import SwiftUI
struct Letter {
    var id: Int
    var text: Character
    var isShown: Bool = true
    var dragState: DragState = .unknown
    var offset: CGSize
    var lastOffset: CGRect = .zero
}
