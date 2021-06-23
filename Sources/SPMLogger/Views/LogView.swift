//
//  File.swift
//  
//
//  Created by Bonafede Massimiliano on 23/06/21.
//

import UIKit

public class LogView: UIView {
    
    //MARK: - Outlets

    public var contentView: UIView = UIView()
    public var topBarView: UIView = UIView()
    public var titleLabel: UILabel = UILabel()
    public var clearButton: UIButton = UIButton()
    public var saveButton: UIButton = UIButton()
    public var tableView: UITableView = UITableView()
    
    //MARK: - Properties

    private let cellIdentifier = "LogCell"
    private var oldValue = 0
    private var currentIndex = 0
    public var loggerValues: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: - Lifecycle

    public init() {
        super.init(frame: .zero)
        setupContentView()
        setupTopBarView()
        setupTitleLabel()
        setupButtons()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Methods

    private func setupContentView() {
        self.addSubview(contentView)
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
    }
    
    private func setupTopBarView() {
        contentView.addSubview(topBarView)
        topBarView.backgroundColor = .black
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        topBarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        topBarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        topBarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        topBarView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setupTitleLabel() {
        topBarView.addSubview(titleLabel)
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor).isActive = true
    }
    
    private func setupButtons() {
        saveButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 12)
        saveButton.addTarget(self, action: #selector(saveButtonWasPressed(_:)), for: .touchUpInside)
        clearButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 12)
        clearButton.addTarget(self, action: #selector(clearButtonWasPressed(_:)), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [saveButton, clearButton])
        stack.axis = .horizontal
        stack.spacing = 20
        topBarView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -20).isActive = true
    }
    
    private func setupTableView() {
        contentView.addSubview(tableView)
        tableView.register(LogCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
    }
    
    //MARK: - Actions

    @objc func saveButtonWasPressed(_ sender: UIButton) {
//        guard Log.shared.logHistory.count > 0 else { return }
//
//        saveButton.isEnabled = false
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd_hh-mm-ss"
//        formatter.locale = Locale.current
//        formatter.timeZone = TimeZone.current
//
//        let logHistoryString = Log.shared.logHistory.joined(separator: "\n")
//        let fileName = "bticino_log_\(formatter.string(from: Date.now)).txt"
//        FileHelper.saveAndShowAlert(text: logHistoryString, onDirectory: "logs", fileName: fileName) {
//            self.saveButton.isEnabled = true
//        }
    }
    
    @objc func clearButtonWasPressed(_ sender: UIButton) {
//        Log.cleanHistory()
//        oldValue = 0
//        currentIndex = 0
    }
}

//MARK: - UITableViewDelegate

extension LogView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = UIColor.green.withAlphaComponent(1)
            cell.textLabel?.text = loggerValues[indexPath.row]
            return cell
        }
        
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
    
//    private enum Section { case main }
//
//    private func configureDataSource() -> UITableViewDiffableDataSource<Section, String> {
//        return UITableViewDiffableDataSource(tableView: tableView) { (tableView, indexPath, text) -> UITableViewCell? in
//            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.logCell, for: indexPath)
//
//            cell?.textLabel?.numberOfLines = 0
//            cell?.textLabel?.textColor = UIColor.green.withAlphaComponent(1)
//            cell?.textLabel?.text = text
//
//            return cell
//        }
//    }
//
//    private func snapshotDataSource(from data: [String]) {
//        var snapshot = NSDiffableDataSourceSnapshot<MainManager.Section, String>()
//        snapshot.appendSections([.main])
//
//        currentIndex = max(oldValue, 0)
//        oldValue = data.count
//
//        snapshot.appendItems(data)
//        dataSource.apply(snapshot)
//    }
}

//MARK: - Pinch and Resizable

extension LogView {

    private func addPinchGesture() {
        self.isUserInteractionEnabled = true
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(resizeView(_:))))
    }

    @objc func resizeView(_ sender: UIPinchGestureRecognizer) {
        guard let senderView = sender.view else { return }

        var recognizerScale: CGFloat = 1.0
        let maxScale: CGFloat = 1.5
        let minScale: CGFloat = 0.8

        if sender.state == .began || sender.state == .changed {
            if recognizerScale < maxScale && sender.scale > 1.0 {
                senderView.transform = senderView.transform.scaledBy(x: sender.scale, y: sender.scale)
                recognizerScale *= sender.scale
                sender.scale = 1.0
            }
            if recognizerScale > minScale && sender.scale < 1.0 {
                senderView.transform = senderView.transform.scaledBy(x: sender.scale, y: sender.scale)
                recognizerScale *= sender.scale
                sender.scale = 1.0
            }
        }
    }

}
