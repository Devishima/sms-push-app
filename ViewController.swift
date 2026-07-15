import UIKit
import UserNotifications

class ViewController: UIViewController, UITextFieldDelegate {
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let charCountLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        // Главный контейнер
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Заголовок
        titleLabel.text = "SMS Push"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Описание
        descriptionLabel.text = "Отправьте уведомление себе"
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        // Текстовое поле
        textField.placeholder = "Введите сообщение..."
        textField.font = .systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.backgroundColor = .secondarySystemBackground
        textField.textColor = .label
        textField.delegate = self
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textField)
        
        // Счётчик символов
        charCountLabel.text = "0/160"
        charCountLabel.font = .systemFont(ofSize: 12, weight: .medium)
        charCountLabel.textColor = .tertiaryLabel
        charCountLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(charCountLabel)
        
        // Кнопка отправки
        sendButton.setTitle("Отправить", for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 12
        sendButton.layer.masksToBounds = true
        sendButton.addTarget(self, action: #selector(sendNotification), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        // Констрейнты для контейнера
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        // Констрейнты для элементов
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Описание
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Текстовое поле
            textField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 52),
            
            // Счётчик символов
            charCountLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            charCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Кнопка отправки
            sendButton.topAnchor.constraint(equalTo: charCountLabel.bottomAnchor, constant: 24),
            sendButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        // Добавляем tap gesture для скрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let remaining = 160 - newText.count
        charCountLabel.text = "\(newText.count)/160"
        charCountLabel.textColor = remaining < 20 ? .systemOrange : .tertiaryLabel
        
        return newText.count <= 160
    }

    @objc private func sendNotification() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Ошибка", message: "Введите сообщение")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "SMS Push App"
        content.body = text
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    self.showAlert(title: "Успех! ✅", message: "Уведомление отправлено")
                    self.textField.text = ""
                    self.charCountLabel.text = "0/160"
                    self.textField.resignFirstResponder()
                } else {
                    self.showAlert(title: "Ошибка", message: error?.localizedDescription ?? "Не удалось отправить")
                }
            }
        }
    }

    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
