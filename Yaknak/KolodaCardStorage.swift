//
//  KolodaCardStorage.swift
//  Yaknak
//
//  Created by Sascha Melcher on 08/08/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import Foundation
import UIKit

extension KolodaView {
  
  func createCard(at index: Int, frame: CGRect? = nil) -> DraggableCardView {
    let cardView = generateCard(frame ?? frameForTopCard())
    configureCard(cardView, at: index)
    return cardView
  }
  
  func generateCard(_ frame: CGRect) -> DraggableCardView {
    let cardView = DraggableCardView(frame: frame)
    cardView.delegate = self
    
    return cardView
  }
  
  func configureCard(_ card: DraggableCardView, at index: Int) {
    let contentView = dataSource!.koloda(self, viewForCardAt: index)
    card.configure(contentView, overlayView: dataSource?.koloda(self, viewForCardOverlayAt: index))
  }
  
}

