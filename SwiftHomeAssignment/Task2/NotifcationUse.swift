//
//  NotifcationUse.swift
//  Swift _Home _Assignment
//
//  Created by Dor Luzgarten on 20/06/2025.
//.

import SwiftUI

struct NotifcationUse: View {
    @State private var showBanner = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Button("Show Notification") {
                withAnimation {
                    showBanner = true
                }
                
            }
            .padding()
        }
        .notificationBanner(isPresented: $showBanner, message: "This is a notification banner!", style: .success)
        
    }
    
}

#Preview {
    NotifcationUse()
}
