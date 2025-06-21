//
//  NotificationViewExtension.swift
//  Swift _Home _Assignment
//
//  Created by Dor Luzgarten on 20/06/2025.
//

import SwiftUI

extension View {
    func notificationBanner(isPresented: Binding<Bool>, message: String, style: BannerStyle = .info) -> some View {
        modifier(NotificationBannerModifier(isPresented: isPresented, message: message, style: style))
    }
}
