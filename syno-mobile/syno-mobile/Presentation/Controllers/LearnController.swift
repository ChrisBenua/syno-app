//
//  LearnController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 20.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class LearnCollectionViewController: UIViewController {
    
    private var dataSource: ILearnControllerTableViewDataSource
    
    weak var actionsDelegate: ILearnControllerActionsDelegate?
    
    lazy var tableView: UITableView = {
        let tableView = PlainTableView()
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.register(TranslationReadonlyTableViewCell.self, forCellReuseIdentifier: TranslationReadonlyTableViewCell.cellId())
        
        return tableView
    }()
    
    lazy var collectionContainerView: UIView = {
        let view = BaseShadowView()
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)

        view.containerViewBackgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1)
        view.cornerRadius = 20
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.controlsView)
        view.addSubview(self.tableView)
        
        self.controlsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.tableView.anchor(top: self.controlsView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 15, width: 0, height: 0)
        self.tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -25).isActive = true
        
        return view
    }()
    
    lazy var cardNumberLabel: UILabel = {
        let cardNumberLabel = UILabel(); cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNumberLabel.font = UIFont.systemFont(ofSize: 20)
        cardNumberLabel.textAlignment = .center
        
        return cardNumberLabel
    }()
    
    lazy var translationsNumberLabel: UILabel = {
        let translationsNumberLabel = UILabel(); translationsNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        translationsNumberLabel.font = UIFont.systemFont(ofSize: 20)
        translationsNumberLabel.textAlignment = .center
        
        return translationsNumberLabel
    }()
    
    func updateHeaderData() {
        cardNumberLabel.text = "\(self.dataSource.state.itemNumber + 1)/\(self.dataSource.viewModel.count)"
        translationsNumberLabel.text = "\(self.dataSource.viewModel.getItems(currCardPos: self.dataSource.state.itemNumber).count) переводов"
        translatedWordView.translatedWordLabel.text = self.dataSource.viewModel.getTranslatedWord(cardPos: self.dataSource.state.itemNumber)
    }
    
    lazy var translatedWordView: TranslatedWordView = {
        let translatedWordView = TranslatedWordView()
        translatedWordView.translatedWordLabel.isUserInteractionEnabled = false
        
        return translatedWordView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        
        
        let cardNumberLabel = self.cardNumberLabel
        
        let translationsNumberLabel = self.translationsNumberLabel
        
        let sepView = UIView(); sepView.translatesAutoresizingMaskIntoConstraints = false
        let sepView1 = UIView(); sepView1.translatesAutoresizingMaskIntoConstraints = false
        
        let sv = UIStackView(arrangedSubviews: [cardNumberLabel, sepView, translatedWordView, sepView1, translationsNumberLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        
        sepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.2).isActive = true
        sepView1.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.15).isActive = true
        
        view.addSubview(sv)
        sv.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        sv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sv.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        
        return view
    }()
    
    lazy var controlsView: UIView = {
        let plusOneButton = CommonUIElements.defaultSubmitButton(text: "+1", backgroundColor: UIColor.init(red: 96.0/255, green: 157.0/255, blue: 248.0/255, alpha: 1.0))
        plusOneButton.addTarget(self, action: #selector(onPlusOneClick), for: .touchUpInside)
        
        let showAllButton = CommonUIElements.defaultSubmitButton(text: "Все", backgroundColor: UIColor.init(red: 96.0/255, green: 157.0/255, blue: 248.0/255, alpha: 1.0))
        showAllButton.addTarget(self, action: #selector(onShowAllClick), for: .touchUpInside)
        
        let view = UIView()
        view.addSubview(plusOneButton)
        view.addSubview(showAllButton)
        
        plusOneButton.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 30, width: 0, height: 0)
        showAllButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 30, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        
        plusOneButton.widthAnchor.constraint(equalTo: showAllButton.widthAnchor).isActive = true
        showAllButton.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.15).isActive = true
        
        return view
    }()
    
    @objc func onPlusOneClick() {
        self.actionsDelegate?.onPlusOne()
    }
    
    @objc func onShowAllClick() {
        self.actionsDelegate?.onShowAll()
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.addSubview(self.headerView)
        view.addSubview(self.collectionContainerView)
        
        self.headerView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.headerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        self.collectionContainerView.anchor(top: self.headerView.bottomAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        self.collectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.collectionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        
//        scrollView.addSubview(self.headerView)
//        scrollView.addSubview(self.collectionContainerView)
        scrollView.addSubview(self.contentView)
        
//        self.headerView.anchor(top: scrollView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        self.headerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
//        self.headerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40).isActive = true
        
        self.contentView.anchor(top: scrollView.topAnchor, left: nil, bottom: scrollView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -30).isActive = true
        
        return scrollView
    }()
    
    @objc func endLearn() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSwipe(_ sender:UIPanGestureRecognizer) {
        if sender.state == .changed {
            let translation = sender.translation(in: contentView)
            print(translation)
            contentView.transform = CGAffineTransform(translationX: translation.x, y: 0)
        } else if sender.state == .ended {
            let translation = sender.translation(in: contentView)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                if translation.x < -50 && self.dataSource.state.itemNumber < self.dataSource.viewModel.count - 1 {
                    self.contentView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                } else if translation.x > 50 && self.dataSource.state.itemNumber > 0 {
                    self.contentView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                }
            }) { (_) in
                if translation.x < -50 && self.dataSource.state.itemNumber < self.dataSource.viewModel.count - 1 {
                    self.contentView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    self.actionsDelegate?.onNext()
                } else if translation.x > 50 && self.dataSource.state.itemNumber > 0 {
                    self.contentView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    self.actionsDelegate?.onPrev()
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.contentView.transform = .identity
                    print("IDENTITY")
                })
            }
        } else if sender.state != .possible {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.contentView.transform = .identity
                print("IDENTITY222, \(sender.state.rawValue)")
            })
        }
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            switch sender.direction {
            case .left:
                print("Left Swipe")
                if self.dataSource.state.itemNumber < self.dataSource.viewModel.count - 1 {
                    self.contentView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                }
            case .right:
                print("Right Swipe")
                if self.dataSource.state.itemNumber > 0 {
                    self.contentView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                }
            default:
                print("break")
                break
            }
        }) { (_) in
            switch sender.direction {
            case .left:
                if self.dataSource.state.itemNumber < self.dataSource.viewModel.count - 1 {
                    self.contentView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    self.actionsDelegate?.onNext()

                }
            case .right:
                if self.dataSource.state.itemNumber > 0 {
                    self.contentView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    self.actionsDelegate?.onPrev()
                }
            default:
                break
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.contentView.transform = .identity
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer.direction = .left
        recognizer.delegate = self
        let recognizer1 = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer1.direction = .right
        recognizer1.delegate = self
        self.scrollView.addGestureRecognizer(recognizer)
        self.scrollView.addGestureRecognizer(recognizer1)

        
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закончить", style: .done, target: self, action: #selector(endLearn))
        
        self.view.backgroundColor = .white
        self.dataSource.delegate = self
        
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        //self.tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1, constant: -60).isActive = true
        self.navigationItem.title = self.dataSource.viewModel.dictName
        self.navigationItem.setHidesBackButton(true, animated:true)
        updateHeaderData()
    }
    
    init(dataSource: ILearnControllerTableViewDataSource) {
        self.dataSource = dataSource
        self.actionsDelegate = self.dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LearnCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
        //handleSwipe(scrollView.panGestureRecognizer)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //handleSwipe(scrollView.panGestureRecognizer)
    }
    
    //scrollView
}

extension LearnCollectionViewController: ILearnControllerDataSourceReactor {
    func reload() {
        self.tableView.reloadData()
        self.updateHeaderData()
    }
    
    func addItems(indexPaths: [IndexPath]) {
        self.tableView.insertRows(at: indexPaths, with: .automatic)
    }
}

extension LearnCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
