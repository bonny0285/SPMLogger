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
    private var logViewTag = 17
    public var loggerValues: [String] = [] 
    
    //MARK: - Lifecycle

    public init() {
        super.init(frame: .zero)
        setupContentView()
        setupTopBarView()
        setupTitleLabel()
        setupButtons()
        setupTableView()
        createLogView(isPresented: false)
        addPinchGesture()
        Log.shared.onCallBack = { [weak self] result in
            guard let self = self else { return }
            self.loggerValues = result
            self.tableView.reloadData()
        }
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
        titleLabel.text = "Log Console"
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor).isActive = true
    }
    
    private func setupButtons() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 12)
        saveButton.titleLabel?.textColor = .white
        saveButton.addTarget(self, action: #selector(saveButtonWasPressed(_:)), for: .touchUpInside)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.textColor = .white
        clearButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 12)
        clearButton.addTarget(self, action: #selector(clearButtonWasPressed(_:)), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [saveButton, clearButton])
        stack.axis = .horizontal
        stack.spacing = 20
        topBarView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -20).isActive = true
        stack.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 10).isActive = true
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
    
    func createLogView(isPresented: Bool) {
        let window = UIApplication.shared.windows.first

        guard isPresented == false else {
            let window = UIApplication.shared.windows.first
            let view = window?.viewWithTag(logViewTag)
            view?.removeFromSuperview()
            return
        }

//        BaseViewController.logViewIsPresented = true
//
        let logWidth = window?.frame.size.width ?? 200
        let logFrame = CGRect(x: 0, y: 50, width: logWidth, height: 250)
        
        window?.rootViewController?.view.addSubview(self)
        
        self.frame = logFrame
//        logView = LogView(frame: logFrame, logPublisher: Log.shared.$logHistory.eraseToAnyPublisher())
        self.tag = logViewTag

        
        createPanGestureRecognizer(targetView: self)
    }

    private func createPanGestureRecognizer(targetView: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(panGesture:)))
        targetView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        // get translation
        let window = UIApplication.shared.windows.first
        let view = window?.rootViewController?.view
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(.zero, in: view)
        // println(translation)

        // create a new Label and give it the parameters of the old one
        let label = panGesture.view!
        label.center = CGPoint(x: label.center.x+translation.x, y: label.center.y+translation.y)
        label.isMultipleTouchEnabled = true
        label.isUserInteractionEnabled = true

        if panGesture.state == UIGestureRecognizer.State.began {
            // add something you want to happen when the Label Panning has started
        }

        if panGesture.state == UIGestureRecognizer.State.ended {
            // add something you want to happen when the Label Panning has ended
        }

        if panGesture.state == UIGestureRecognizer.State.changed {
            // add something you want to happen when the Label Panning has been change ( during the moving/panning )
        } else {
            // or something when its not moving
        }
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
            return loggerValues.count
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
