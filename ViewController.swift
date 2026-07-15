import UIKit
import UserNotifications

class ViewController: UIViewController, UITextFieldDelegate {
    private let field = UITextField()
    private let btn = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        field.frame = CGRect(x: 20, y: 150, width: view.bounds.width - 40, height: 50)
        field.borderStyle = .roundedRect
        field.placeholder = "Введите текст..."
        field.delegate = self
        view.addSubview(field)
        
        btn.frame = CGRect(x: 20, y: 220, width: view.bounds.width - 40, height: 50)
        btn.setTitle("Отправить SMS", for: .normal)
        btn.addTarget(self, action: #selector(push), for: .touchUpInside)
        view.addSubview(btn)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= 160
    }

    @objc private func push() {
        let content = UNMutableNotificationContent()
        content.title = "Новое сообщение"
        content.body = field.text ?? ""
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, 
                                            content: content, 
                                            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false))
        
        UNUserNotificationCenter.current().add(request)
        field.text = ""
        field.resignFirstResponder()
    }
}
