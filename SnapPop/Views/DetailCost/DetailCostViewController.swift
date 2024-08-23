//
//  DetailCostViewController.swift
//  SnapPop
//
//  Created by 이인호 on 8/19/24.
//
//
import UIKit

class DetailCostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - Properties
    private let viewModel: DetailCostViewModel
    
    // 금액 계산 셀 열기 위한 변수
    private var isOpen = false
    
    // MARK: - UIComponents
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        return tableView
    }()
    
    // MARK: - Initializers
    init(viewModel: DetailCostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Methods
    func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        let cells: [(AnyClass, String)] = [
            (TitleCell2.self, TitleCell2.identifier),
            (DescriptionCell.self, DescriptionCell.identifier),
            (AddCostCell.self, AddCostCell.identifier),
            (OneTimeCostCell.self, OneTimeCostCell.identifier),
            (CalculateCostCell.self, CalculateCostCell.identifier)
        ]
        
        for (cellClass, identifier) in cells {
            tableView.register(cellClass, forCellReuseIdentifier: identifier)
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        title = "상세내역"

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveButtonTapped))
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        viewModel.saveData { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return isOpen ? 2 : 1
        case 2:
            return isOpen ? 1 : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "상세 정보"
        case 1:
            return "상세 비용"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleCell2.identifier, for: indexPath) as? TitleCell2 else { return UITableViewCell() }
                cell.textField.delegate = self // 텍스트 필드 델리게이트 설정
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionCell.identifier, for: indexPath) as? DescriptionCell else { return UITableViewCell() }
                cell.textField.delegate = self // 텍스트 필드 델리게이트 설정
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: AddCostCell.identifier, for: indexPath) as? AddCostCell else { return UITableViewCell() }
                cell.toggleSwitch.isOn = self.isOpen
                
                cell.onToggleSwitchChanged = { [weak self] isOn in
                    guard let self = self else { return }
                    self.isOpen = isOn
                    self.tableView.reloadSections([1, 2], with: .automatic)
                }
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OneTimeCostCell.identifier, for: indexPath) as? OneTimeCostCell else { return UITableViewCell() }
                return cell
            default:
                return UITableViewCell()
            }
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CalculateCostCell.identifier, for: indexPath) as? CalculateCostCell else { return UITableViewCell() }
            cell.onCalculate = { [weak self] result in
                guard let self = self else { return }
                guard let oneTimeCostCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? OneTimeCostCell else { return }
                oneTimeCostCell.updateCost(with: result)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - Keyboard Handling

    // 화면을 터치했을 때 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // Return 키를 눌렀을 때 키보드 내리기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
