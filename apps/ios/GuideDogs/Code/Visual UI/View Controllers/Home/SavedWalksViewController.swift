import UIKit

/// 用于展示用户保存的散步路线列表的页面。
class SavedWalksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// 用于显示列表的表格视图
    private let tableView = UITableView()

    /// 示例数据，后续可替换为用户真实保存的路线
    private let savedWalks = [
        "晨间公园环线",
        "市中心漫步",
        "河畔悠闲散步"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // 页面标题，可在 Localizable.strings 中添加键 saved_walks.title
        self.title = GDLocalizedString("saved_walks.title")
        view.backgroundColor = UIColor.systemBackground

        // 设置表格代理
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // 注册基础的单元格类型
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // 将表格加入视图层级并添加约束
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedWalks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = savedWalks[indexPath.row]
        // 将每条路线声明为按钮，方便 VoiceOver 识别
        cell.accessibilityTraits = .button
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 点击某条路线时弹出提示，后续可在这里启动实际导航逻辑
        let alert = UIAlertController(
            title: savedWalks[indexPath.row],
            message: GDLocalizedString("saved_walks.selected_message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: GDLocalizedString("general.alert.dismiss"), style: .cancel))
        present(alert, animated: true)
    }
}
