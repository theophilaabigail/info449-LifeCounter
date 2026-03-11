//
//  ViewController.swift
//  lifecounter
//
//  Created by Theophila Setiawan on 2/25/26.
//

import UIKit

struct Player {
    var name: String
    var life: Int
    let id: Int
}

struct HistoryEvent {
    let playerName: String
    let change: Int
    let timestamp: Date
    
    var description: String {
        let absChange = abs(change)
        let verb = change > 0 ? "gained" : "lost"
        let lifeWord = absChange == 1 ? "life" : "life"
        return "\(playerName) \(verb) \(absChange) \(lifeWord)."
    }
}

class LifeCounterViewController: UIViewController {
    
    private let startingLife = 20
    private var players: [Player] = []
    private var history: [HistoryEvent] = []
    private var gameHasStarted = false
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let topButtonStack = UIStackView()
    private let addPlayerButton = UIButton(type: .system)
    private let historyButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let mainStackView = UIStackView()
    private let gameStatusLabel = UILabel()
    private var playerViews: [Int: PlayerView] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePlayers()
        setupInterface()
        refreshDisplay()
    }
    
    
    private func initializePlayers() {
        for i in 1...4 {
            players.append(Player(name: "Player \(i)", life: startingLife, id: i))
        }
    }
    
    private func setupInterface() {
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        configureTopButtons()
        configureMainLayout()
        configureGameStatusDisplay()
        createAllPlayerViews()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func configureTopButtons() {
        topButtonStack.axis = .horizontal
        topButtonStack.spacing = 12
        topButtonStack.distribution = .fillEqually
        topButtonStack.translatesAutoresizingMaskIntoConstraints = false
        
        addPlayerButton.setTitle("Add Player", for: .normal)
        addPlayerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addPlayerButton.backgroundColor = .systemGreen
        addPlayerButton.tintColor = .white
        addPlayerButton.layer.cornerRadius = 8
        addPlayerButton.addAction(UIAction { [weak self] _ in
            self?.addNewPlayer()
        }, for: .touchUpInside)
        
        historyButton.setTitle("History", for: .normal)
        historyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        historyButton.backgroundColor = .systemBlue
        historyButton.tintColor = .white
        historyButton.layer.cornerRadius = 8
        historyButton.addAction(UIAction { [weak self] _ in
            self?.showHistory()
        }, for: .touchUpInside)
        
        resetButton.setTitle("Reset", for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        resetButton.backgroundColor = .systemRed
        resetButton.tintColor = .white
        resetButton.layer.cornerRadius = 8
        resetButton.addAction(UIAction { [weak self] _ in
            self?.resetGame()
        }, for: .touchUpInside)
        
        topButtonStack.addArrangedSubview(addPlayerButton)
        topButtonStack.addArrangedSubview(historyButton)
        topButtonStack.addArrangedSubview(resetButton)
        
        contentView.addSubview(topButtonStack)
        
        NSLayoutConstraint.activate([
            topButtonStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            topButtonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topButtonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            topButtonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureMainLayout() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topButtonStack.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func configureGameStatusDisplay() {
        gameStatusLabel.text = ""
        gameStatusLabel.font = .systemFont(ofSize: 20, weight: .bold)
        gameStatusLabel.textColor = .systemOrange
        gameStatusLabel.textAlignment = .center
        gameStatusLabel.numberOfLines = 0
        gameStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(gameStatusLabel)
        
        NSLayoutConstraint.activate([
            gameStatusLabel.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 20),
            gameStatusLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            gameStatusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            gameStatusLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            gameStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createAllPlayerViews() {
        for player in players {
            let playerView = PlayerView(player: player)
            playerView.delegate = self
            playerViews[player.id] = playerView
            mainStackView.addArrangedSubview(playerView)
        }
    }
    
    private func addNewPlayer() {
        guard players.count < 8 else { return }
        
        let newPlayerId = (players.map { $0.id }.max() ?? 0) + 1
        let newPlayer = Player(name: "Player \(newPlayerId)", life: startingLife, id: newPlayerId)
        players.append(newPlayer)
        
        let playerView = PlayerView(player: newPlayer)
        playerView.delegate = self
        playerViews[newPlayer.id] = playerView
        mainStackView.addArrangedSubview(playerView)
        
        updateAddPlayerButton()
    }
    
    private func updateAddPlayerButton() {
        addPlayerButton.isEnabled = !gameHasStarted && players.count < 8
        addPlayerButton.alpha = addPlayerButton.isEnabled ? 1.0 : 0.5
    }
    
    private func showHistory() {
        let historyVC = HistoryViewController(history: history)
        let navController = UINavigationController(rootViewController: historyVC)
        present(navController, animated: true)
    }
    
    private func resetGame() {
        let alert = UIAlertController(title: "Reset Game", message: "Are you sure you want to reset the game?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.performReset()
        })
        present(alert, animated: true)
    }
    
    private func performReset() {
        players.removeAll()
        history.removeAll()
        gameHasStarted = false
        
        for (_, playerView) in playerViews {
            playerView.removeFromSuperview()
        }
        playerViews.removeAll()
        
        initializePlayers()
        createAllPlayerViews()
        refreshDisplay()
        updateAddPlayerButton()
    }
    
    private func adjustLife(for playerId: Int, by amount: Int) {
        guard let index = players.firstIndex(where: { $0.id == playerId }) else { return }
        
        if !gameHasStarted {
            gameHasStarted = true
            updateAddPlayerButton()
        }
        
        players[index].life += amount
        
        let event = HistoryEvent(playerName: players[index].name, change: amount, timestamp: Date())
        history.append(event)
        
        refreshDisplay()
    }
    
    private func changePlayerName(playerId: Int, newName: String) {
        guard let index = players.firstIndex(where: { $0.id == playerId }) else { return }
        players[index].name = newName
        playerViews[playerId]?.updatePlayer(players[index])
    }
    
    private func refreshDisplay() {
        for player in players {
            playerViews[player.id]?.updatePlayer(player)
        }
        evaluateGameState()
    }
    
    private func evaluateGameState() {
        let losers = players.filter { $0.life <= 0 }
        
        if losers.count == players.count - 1 && players.count > 1 {
            let winner = players.first { $0.life > 0 }
            let alert = UIAlertController(title: "Game Over!", message: "\(winner?.name ?? "Someone") wins!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.performReset()
            })
            if presentedViewController == nil {
                present(alert, animated: true)
            }
        } else if losers.count == 1 {
            gameStatusLabel.text = "\(losers[0].name) LOSES!"
        } else if losers.count > 1 {
            let loserNames = losers.map { $0.name }.joined(separator: ", ")
            gameStatusLabel.text = "\(loserNames) LOSE!"
        } else {
            gameStatusLabel.text = ""
        }
    }
}

extension LifeCounterViewController: PlayerViewDelegate {
    func didAdjustLife(playerId: Int, by amount: Int) {
        adjustLife(for: playerId, by: amount)
    }
    
    func didTapPlayerName(playerId: Int, currentName: String) {
        let alert = UIAlertController(title: "Change Name", message: "Enter new name for \(currentName)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = currentName
            textField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            if let newName = alert?.textFields?.first?.text, !newName.isEmpty {
                self?.changePlayerName(playerId: playerId, newName: newName)
            }
        })
        present(alert, animated: true)
    }
}

protocol PlayerViewDelegate: AnyObject {
    func didAdjustLife(playerId: Int, by amount: Int)
    func didTapPlayerName(playerId: Int, currentName: String)
}

class PlayerView: UIView {
    weak var delegate: PlayerViewDelegate?
    private var player: Player
    
    private let containerStack = UIStackView()
    private let nameLabel = UILabel()
    private let lifeLabel = UILabel()
    private let controlStack = UIStackView()
    private let customAmountTextField = UITextField()
    private let customAmountButton = UIButton(type: .system)
    
    init(player: Player) {
        self.player = player
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        containerStack.axis = .vertical
        containerStack.spacing = 12
        containerStack.alignment = .center
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        setupNameLabel()
        setupLifeLabel()
        setupControls()
    }
    
    private func setupNameLabel() {
        nameLabel.text = player.name
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = getPlayerColor(id: player.id)
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nameTapped)))
        
        containerStack.addArrangedSubview(nameLabel)
    }
    
    private func setupLifeLabel() {
        lifeLabel.text = "\(player.life)"
        lifeLabel.font = .systemFont(ofSize: 40, weight: .semibold)
        lifeLabel.textColor = .label
        
        containerStack.addArrangedSubview(lifeLabel)
    }
    
    private func setupControls() {
        let mainControlStack = UIStackView()
        mainControlStack.axis = .vertical
        mainControlStack.spacing = 10
        mainControlStack.alignment = .center
        mainControlStack.translatesAutoresizingMaskIntoConstraints = false
        
        controlStack.axis = .horizontal
        controlStack.spacing = 8
        controlStack.distribution = .fillEqually
        controlStack.translatesAutoresizingMaskIntoConstraints = false
        
        let plusButton = createButton(title: "+", value: 1)
        let minusButton = createButton(title: "-", value: -1)
        let plus5Button = createButton(title: "+5", value: 5)
        let minus5Button = createButton(title: "-5", value: -5)
        
        controlStack.addArrangedSubview(plusButton)
        controlStack.addArrangedSubview(minusButton)
        controlStack.addArrangedSubview(plus5Button)
        controlStack.addArrangedSubview(minus5Button)
        
        let customStack = createCustomAmountControl()
        
        mainControlStack.addArrangedSubview(controlStack)
        mainControlStack.addArrangedSubview(customStack)
        
        containerStack.addArrangedSubview(mainControlStack)
        
        NSLayoutConstraint.activate([
            controlStack.widthAnchor.constraint(equalTo: containerStack.widthAnchor, multiplier: 0.95)
        ])
    }
    
    private func createButton(title: String, value: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemGray5
        button.tintColor = .label
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didAdjustLife(playerId: self.player.id, by: value)
        }, for: .touchUpInside)
        
        return button
    }
    
    private func createCustomAmountControl() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        customAmountTextField.placeholder = "10"
        customAmountTextField.text = "10"
        customAmountTextField.textAlignment = .center
        customAmountTextField.keyboardType = .numberPad
        customAmountTextField.font = .systemFont(ofSize: 16, weight: .medium)
        customAmountTextField.borderStyle = .roundedRect
        customAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        customAmountButton.setTitle("+/-", for: .normal)
        customAmountButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        customAmountButton.backgroundColor = .systemIndigo
        customAmountButton.tintColor = .white
        customAmountButton.layer.cornerRadius = 8
        customAmountButton.translatesAutoresizingMaskIntoConstraints = false
        customAmountButton.addAction(UIAction { [weak self] _ in
            self?.customAmountButtonTapped()
        }, for: .touchUpInside)
        
        stack.addArrangedSubview(customAmountTextField)
        stack.addArrangedSubview(customAmountButton)
        
        NSLayoutConstraint.activate([
            customAmountTextField.widthAnchor.constraint(equalToConstant: 60),
            customAmountTextField.heightAnchor.constraint(equalToConstant: 40),
            customAmountButton.heightAnchor.constraint(equalToConstant: 40),
            customAmountButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [UIBarButtonItem.flexibleSpace(), doneButton]
        customAmountTextField.inputAccessoryView = toolbar
        
        return stack
    }
    
    @objc private func customAmountButtonTapped() {
        dismissKeyboard()
        
        guard let text = customAmountTextField.text, let amount = Int(text), amount > 0 else {
            return
        }
        
        let alert = UIAlertController(title: "Adjust Life", message: "Add or remove \(amount) life?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add +\(amount)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didAdjustLife(playerId: self.player.id, by: amount)
        })
        alert.addAction(UIAlertAction(title: "Remove -\(amount)", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didAdjustLife(playerId: self.player.id, by: -amount)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let windowScene = window?.windowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
    
    @objc private func dismissKeyboard() {
        customAmountTextField.resignFirstResponder()
    }
    
    @objc private func nameTapped() {
        delegate?.didTapPlayerName(playerId: player.id, currentName: player.name)
    }
    
    private func getPlayerColor(id: Int) -> UIColor {
        let colors: [UIColor] = [.systemBlue, .systemRed, .systemGreen, .systemPurple, .systemOrange, .systemPink, .systemTeal, .systemIndigo]
        return colors[(id - 1) % colors.count]
    }
    
    func updatePlayer(_ player: Player) {
        self.player = player
        nameLabel.text = player.name
        lifeLabel.text = "\(player.life)"
        nameLabel.textColor = getPlayerColor(id: player.id)
    }
}

class HistoryViewController: UIViewController, UITableViewDataSource {
    private let history: [HistoryEvent]
    private let tableView = UITableView()
    
    init(history: [HistoryEvent]) {
        self.history = history
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "History"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissHistory))
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func dismissHistory() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.isEmpty ? 1 : history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        
        if history.isEmpty {
            cell.textLabel?.text = "No history yet. Start playing!"
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.textAlignment = .center
        } else {
            let event = history[history.count - 1 - indexPath.row]
            cell.textLabel?.text = event.description
            cell.textLabel?.numberOfLines = 0
        }
        
        return cell
    }
}

