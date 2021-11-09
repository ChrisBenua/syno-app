//
//  CardViewColors.swift
//  SynoWidgetExtension
//
//  Created by Krisitan Benua on 25.10.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import SwiftUI

struct CardViewColors {
  let backgroundView: (_ viewHeight: Double) -> AnyView
  let separatorColor: UIColor
  let headerColor: UIColor
  let translationForegroundColor: UIColor
  let transcriptionForegroundColor: UIColor
  let translationBackgroundColor: UIColor
}

extension CardViewColors {
  static let light = CardViewColors(
    backgroundView: { viewHeight in AnyView(RadialGradient(colors: [greenColor, endColor], center: UnitPoint(x: 0.5, y: 0), startRadius: 20, endRadius: viewHeight)) },
    separatorColor: UIColor.gray.withAlphaComponent(0.3),
    headerColor: .headerMainColor,
    translationForegroundColor: UIColor.label,
    transcriptionForegroundColor: UIColor.secondaryLabel,
    translationBackgroundColor: UIColor(red: 241.0 / 255, green: 241.0 / 255, blue: 241.0 / 255, alpha: 1)
  )
}

extension CardViewColors {
  static let dark = CardViewColors(
    backgroundView: { _ in AnyView(Color(red: 0.1, green: 0.1, blue: 0.1)) },
    separatorColor: UIColor.white.withAlphaComponent(0.3),
    headerColor: headerDarkColor,
    translationForegroundColor: UIColor.white,
    transcriptionForegroundColor: UIColor.lightGray,
    translationBackgroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
  )
}

private let greenColor = Color(red: 243.0 / 255, green: 248.0 / 255, blue: 241.0 / 255, opacity: 1)
private let endColor = Color(red: 249.0 / 255, green: 252.0 / 255, blue: 248.0 / 255, opacity: 1)
private let headerDarkColor = UIColor(red: 110.0/255, green: 149.0/255, blue: 188.0/266, alpha: 1)
