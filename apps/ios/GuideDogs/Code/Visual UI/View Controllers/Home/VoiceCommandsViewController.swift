import UIKit

/// 用于展示常用语音指令的页面。
class VoiceCommandsViewController: UITableViewController {

    // 每个指令包含命令文本及其说明
    private let commands: [(command: String, description: String)] = [
        (GDLocalizedString("voice_commands.around_me.command"), GDLocalizedString("voice_commands.around_me.description")),
        (GDLocalizedString("voice_commands.ahead_of_me.command"), GDLocalizedString("voice_commands.ahead_of_me.description")),
        (GDLocalizedString("voice_commands.nearby_markers.command"), GDLocalizedString("voice_commands.nearby_markers.description")),
        (GDLocalizedString("voice_commands.my_location.command"), GDLocalizedString("voice_commands.my_location.description")),
        (GDLocalizedString("voice_commands.search.command"), GDLocalizedString("voice_commands.search.description"))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = GDLocalizedString("voice_commands.title")
        // 注册默认单元格
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommandCell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commands.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommandCell", for: indexPath)
        let entry = commands[indexPath.row]
        // 显示命令文本
        cell.textLabel?.text = entry.command
        // 提供说明作为辅助文本，可通过 VoiceOver 阅读
        cell.detailTextLabel?.text = entry.description
        cell.accessibilityTraits = .button
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = commands[indexPath.row]
        // 使用 VoiceOver 公告朗读指令与说明，方便视障用户记忆
        let message = "\(entry.command)。\(entry.description)"
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
