import Foundation
import UIKit

/// Controller for presenting user's test result
class TestResultsViewController: UIViewController {
    /// Service responsible for inner table view logic in `TestResultsViewController`
    private var dataSource: ITestResultsControllerDataSource
    
    /// Label for user's result
    lazy var resultTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Результат"
        label.font = .systemFont(ofSize: 26)
        label.textAlignment = .right
        
        return label
    }()
    
    /// Label for user's result grade
    lazy var resultPercentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26)
        label.textAlignment = .left
        let result = GradeToStringAndColor.gradeToStringAndColor(gradePercentage: Double(self.dataSource.getPercentageScore()))
        label.textColor = result.1
        label.text = result.0
        
        return label
    }()
    
    /// Label for report
    lazy var reportTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Отчёт"
        label.font = .systemFont(ofSize: 26)
        label.textAlignment = .center
        
        return label
    }()
    
    /// table view for presenting report
    lazy var tableView: UITableView = {
        let tableView = PlainTableView()
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.delegate = self.dataSource
        tableView.dataSource = self.dataSource
        
        tableView.register(TestResultsTableViewCell.self, forCellReuseIdentifier: TestResultsTableViewCell.cellId)
        tableView.contentInset = .init(top: 0, left: 0, bottom: 5, right: 0)
        return tableView
    }()
    
    /// Wrapper view for `resultTextLabel` and `resultPercentageLabel`
    lazy var headerView: UIView = {
        let view = UIView()
        let innerView = UIView()
        
        let sv = UIStackView(arrangedSubviews: [self.resultTextLabel, self.resultPercentageLabel])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = 20
        innerView.addSubview(sv)
        
        sv.anchor(top: innerView.topAnchor, left: nil, bottom: innerView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        sv.centerXAnchor.constraint(equalTo: innerView.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [innerView, self.reportTextLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 10, paddingRight: 20, width: 0, height: 0)
        return view
    }()
    
    /// Wrapper view for `headerView` and `tableView`
    lazy var contentView: UIView = {
        let view = UIView()
        view.addSubview(self.headerView)
        view.addSubview(self.tableView)
        
        self.headerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.tableView.anchor(top: self.headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
        return view
    }()
    
    /// Main scroll view
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = true
        
        scrollView.addSubview(self.contentView)
        self.contentView.anchor(top: scrollView.contentLayoutGuide.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.contentLayoutGuide.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
        //self.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -10).isActive = true
        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        self.view.backgroundColor = .white
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        self.navigationItem.title = "Результат: " + (self.dataSource.getDictName() ?? "")
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закончить", style: .done, target: self, action: #selector(goBackToTestAndLearnController))
        //scrollView.contentSize = self.contentView.frame.size
    }
    
    /// End button click listener
    @objc func goBackToTestAndLearnController() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     Creates new `TestResultsViewController`
     - Parameter dataSource: service responsible for table view logic
     */
    init(dataSource: ITestResultsControllerDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        self.dataSource.reactor = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TestResultsViewController: ITestResultsControllerDataSourceReactor {
    func onShowController(controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func onScrollToRect(view: UIView, cellRect: CGRect) {
        var rect = view.convert(cellRect, to: scrollView)
        rect.origin.y += 40
        rect.origin.y = min(scrollView.contentSize.height - rect.size.height, rect.origin.y)
//        let containter = CGRect(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//        if (!rect.intersects(containter)) {
//            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.contentOffset.x, y: rect.maxY - scrollView.frame.size.height), animated: true)
//        }
        self.scrollView.scrollRectToVisible(rect, animated: true)
    }
}
