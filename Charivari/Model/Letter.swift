//
//  LetterModel.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-29.
//

import SwiftUI

/// Structure représentant une lettre
struct Letter {
    var id: Int /// Id de la lettre
    var text: Character /// Charactère
    var isShown: Bool = true /// Booléan indiquant si la lettre est affichée ou pas
    var dragState: DragState = .unknown /// État du drag
    var offset: CGSize /// Offset de la lettre
}
