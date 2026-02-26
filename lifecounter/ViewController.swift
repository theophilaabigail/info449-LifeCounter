//
//  ViewController.swift
//  lifecounter
//
//  Created by Theophila Setiawan on 2/25/26.
//

import UIKit

class LifeCounterViewController: UIViewController {
    
    private let startingLife = 20
    private var playerOneCurrentLife = 20
    private var playerTwoCurrentLife = 20
    
    private let mainStackView = UIStackView()
    private let gameStatusLabel = UILabel()
    
    private let playerOneNameLabel = UILabel()
    private let playerOneLifeDisplay = UILabel()
    private let playerOneControlStack = UIStackView()
    
    private let playerTwoNameLabel = UILabel()
    private let playerTwoLifeDisplay = UILabel()
    private let playerTwoControlStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        refreshDisplay()
    }
    
    private func setupInterface() {
        view.backgroundColor = .systemBackground
        
        configureMainLayout()
        configurePlayerOneSection()
        configurePlayerTwoSection()
        configureGameStatusDisplay()
    }
    
    private func configureMainLayout() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 40
        mainStackView.distribution = .equalSpacing
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func configurePlayerOneSection() {
        let containerStack = createPlayerSection(
            nameLabel: playerOneNameLabel,
            name: "Player 1",
            lifeLabel: playerOneLifeDisplay,
            controlStack: playerOneControlStack,
            playerNumber: 1
        )
        mainStackView.addArrangedSubview(containerStack)
    }
    
    private func configurePlayerTwoSection() {
        let containerStack = createPlayerSection(
            nameLabel: playerTwoNameLabel,
            name: "Player 2",
            lifeLabel: playerTwoLifeDisplay,
            controlStack: playerTwoControlStack,
            playerNumber: 2
        )
        mainStackView.addArrangedSubview(containerStack)
    }
    
    private func createPlayerSection(nameLabel: UILabel, name: String, lifeLabel: UILabel, controlStack: UIStackView, playerNumber: Int) -> UIStackView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 16
        container.alignment = .center
        container.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textColor = playerNumber == 1 ? .systemBlue : .systemRed
        
        lifeLabel.text = "\(startingLife)"
        lifeLabel.font = .systemFont(ofSize: 48, weight: .semibold)
        lifeLabel.textColor = .label
        
        configureControlButtons(for: controlStack, playerNumber: playerNumber)
        
        container.addArrangedSubview(nameLabel)
        container.addArrangedSubview(lifeLabel)
        container.addArrangedSubview(controlStack)
        
        return container
    }
    
    private func configureControlButtons(for stack: UIStackView, playerNumber: Int) {
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonConfigs: [(String, Int)] = [("+", 1), ("-", -1), ("+5", 5), ("-5", -5)]
        
        for (title, value) in buttonConfigs {
            let button = createControlButton(title: title, value: value, playerNumber: playerNumber)
            stack.addArrangedSubview(button)
        }
    }
    
    private func createControlButton(title: String, value: Int, playerNumber: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGray5
        button.tintColor = .label
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        button.addAction(UIAction { [weak self] _ in
            self?.adjustLife(for: playerNumber, by: value)
        }, for: .touchUpInside)
        
        return button
    }
    
    private func configureGameStatusDisplay() {
        gameStatusLabel.text = ""
        gameStatusLabel.font = .systemFont(ofSize: 24, weight: .bold)
        gameStatusLabel.textColor = .systemOrange
        gameStatusLabel.textAlignment = .center
        gameStatusLabel.numberOfLines = 0
        gameStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(gameStatusLabel)
        
        NSLayoutConstraint.activate([
            gameStatusLabel.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 40),
            gameStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameStatusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            gameStatusLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func adjustLife(for playerNumber: Int, by amount: Int) {
        if playerNumber == 1 {
            playerOneCurrentLife += amount
        } else {
            playerTwoCurrentLife += amount
        }
        refreshDisplay()
    }
    
    private func refreshDisplay() {
        playerOneLifeDisplay.text = "\(playerOneCurrentLife)"
        playerTwoLifeDisplay.text = "\(playerTwoCurrentLife)"
        evaluateGameState()
    }
    
    private func evaluateGameState() {
        if playerOneCurrentLife <= 0 {
            gameStatusLabel.text = "Player 1 LOSES!"
        } else if playerTwoCurrentLife <= 0 {
            gameStatusLabel.text = "Player 2 LOSES!"
        } else {
            gameStatusLabel.text = ""
        }
    }
}

