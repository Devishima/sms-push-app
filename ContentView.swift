import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var message: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let maxChars = 500
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Заголовки
            VStack(alignment: .leading, spacing: 8) {
                Text("SMS Push")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("Отправьте уведомление себе")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 10)
            
            // TextEditor с кастомным контейнером
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $message)
                    .frame(minHeight: 120, maxHeight: 150)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .onChange(of: message) { newValue in
                        if newValue.count > maxChars {
                            message = String(newValue.prefix(maxChars))
                        }
                    }
                
                Text("\(message.count)/\(maxChars)")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(message.count > 400 ? .orange : .secondary)
                    .padding(12)
            }
            
            // Кнопки
            VStack(spacing: 12) {
                Button(action: sendNotification) {
                    Text("Отправить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button("Очистить") {
                    message = ""
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(24)
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Уведомление"), message: Text(alertMessage), dismissButton: .default(Text("ОК")))
        }
    }
    
    func sendNotification() {
        guard !message.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Ваше сообщение"
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "Ошибка: \(error.localizedDescription)"
                } else {
                    alertMessage = "Успешно отправлено!"
                    message = ""
                }
                showingAlert = true
            }
        }
    }
}
