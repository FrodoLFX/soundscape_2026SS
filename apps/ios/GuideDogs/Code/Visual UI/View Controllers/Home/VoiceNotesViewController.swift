import UIKit
import AVFoundation

/// 管理并回放语音笔记的视图控制器。
class VoiceNotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    private var tableView: UITableView!
    private var recordButton: UIButton!
    private var voiceNotes: [URL] = []
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = GDLocalizedString("voice_notes.title")
        view.backgroundColor = .systemBackground

        // 录音按钮
        recordButton = UIButton(type: .system)
        recordButton.setTitle(GDLocalizedString("voice_notes.record_button"), for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        recordButton.accessibilityTraits = .button
        view.addSubview(recordButton)

        // 列表视图
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VoiceNoteCell")
        view.addSubview(tableView)

        // 布局
        NSLayoutConstraint.activate([
            recordButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        loadVoiceNotes()
    }

    // MARK: - 数据加载
    /// 获取文档目录的 URL
    private func documentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    /// 加载所有保存的语音笔记文件
    private func loadVoiceNotes() {
        let directory = documentsDirectory()
        do {
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            voiceNotes = files.filter { $0.pathExtension == "m4a" }
                .sorted { $0.lastPathComponent > $1.lastPathComponent }
        } catch {
            DDLogError("Failed to load voice notes: \(error)")
        }
    }

    // MARK: - 录音控制
    @objc private func recordButtonTapped() {
        if let recorder = audioRecorder, recorder.isRecording {
            finishRecording(success: true)
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if allowed {
                        let filename = self.documentsDirectory().appendingPathComponent("voiceNote-\(Date().timeIntervalSince1970).m4a")
                        let settings: [String: Any] = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        do {
                            self.audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                            self.audioRecorder?.delegate = self
                            self.audioRecorder?.record()
                            self.recordButton.setTitle(GDLocalizedString("voice_notes.stop_button"), for: .normal)
                        } catch {
                            DDLogError("Failed to start recording: \(error)")
                        }
                    } else {
                        // 如果用户拒绝麦克风权限
                        let alert = UIAlertController(
                            title: GDLocalizedString("voice_notes.permission_denied.title"),
                            message: GDLocalizedString("voice_notes.permission_denied.message"),
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: GDLocalizedString("general.alert.dismiss"), style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        } catch {
            DDLogError("Audio session error: \(error)")
        }
    }

    private func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        recordButton.setTitle(GDLocalizedString("voice_notes.record_button"), for: .normal)
        if success {
            loadVoiceNotes()
            tableView.reloadData()
        }
    }

    // AVAudioRecorderDelegate：录制完成后的回调
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishRecording(success: flag)
    }

    // MARK: - 表格数据源
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voiceNotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceNoteCell", for: indexPath)
        let url = voiceNotes[indexPath.row]
        // 将文件名中的时间戳转换成人类可读时间
        let name = url.deletingPathExtension().lastPathComponent
        let timestampString = name.replacingOccurrences(of: "voiceNote-", with: "")
        let timestamp = TimeInterval(timestampString) ?? 0
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        cell.textLabel?.text = formatter.string(from: date)
        cell.accessibilityTraits = .button
        return cell
    }

    // MARK: - 列表点击回放
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playVoiceNote(at: indexPath.row)
    }

    private func playVoiceNote(at index: Int) {
        let url = voiceNotes[index]
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            DDLogError("Failed to play audio: \(error)")
        }
    }
}
