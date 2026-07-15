import SwiftUI
import UserNotifications

@main
struct SMSPushApp: App {
    init() {
        // Запрос разрешений при запуске
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
