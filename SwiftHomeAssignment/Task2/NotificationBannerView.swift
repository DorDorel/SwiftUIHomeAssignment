//
//  NotificationBannerView.swift
//  Swift_Home_Assignment
//
//  Created by Dor Luzgarten on 20/06/2025.
//

import SwiftUI

// MARK: Banner Style
enum BannerStyle {
    case success, error, info

    var backgroundColor: Color {
        switch self {
        case .success: return Color.green.opacity(0.9)
        case .error: return Color.red.opacity(0.9)
        case .info: return Color.blue.opacity(0.9)
        }
    }
    
    var textColor: Color {
        Color.white
    }
}

// MARK: Banner Modifier
struct NotificationBannerModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let style: BannerStyle
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if isPresented {
                NotificationBannerView(message: message, style: style)
                    .transition(.move(edge: .top)
                        .combined(with: .opacity))
                    .onAppear {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isPresented = false
                            }
                        }
                            
                    }
                    
            }

        }
        .animation(.easeInOut, value: isPresented)

    }
}


// MARK: Banner View
struct NotificationBannerView: View {
    let message: String
    let style: BannerStyle
    
    var body: some View {
        VStack {
            Text (message)
                .font(.headline)
                .foregroundStyle(style.textColor)
                .padding()
                .frame(maxWidth: .infinity)
                .background(style.backgroundColor)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
            
           
        }
    
    }
}

#Preview {
    NotificationBannerView(message: "new notification", style: .success)
      
}
