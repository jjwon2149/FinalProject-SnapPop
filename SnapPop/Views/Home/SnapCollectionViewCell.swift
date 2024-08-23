//
//  SnapCollectionViewCell.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/12/24.
//

import UIKit

class SnapCollectionViewCell: UICollectionViewCell {
    
    let snapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        let deleteImage = UIImage(systemName: "minus.circle.fill")
        button.setImage(deleteImage, for: .normal)
        button.tintColor = .red
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(snapImageView)
        contentView.addSubview(deleteButton)
        
        snapImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 이미지 뷰 제약 조건
            snapImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            snapImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            snapImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            snapImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 삭제 버튼 제약 조건
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.bounds.height * 0.02),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentView.bounds.width * 0.02),
            deleteButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.1),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with snap: Snap, isFirst: Bool, isEditing: Bool) {
        // 첫 번째 셀의 테두리 설정
        if isFirst {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = UIColor.customMainColor?.cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
        
        // 편집 모드에 따라 삭제 버튼 표시
        deleteButton.isHidden = !isEditing
        
        // Load the image from the first URL in the imageUrls array
        if let imageUrlString = snap.imageUrls.first {
            // Load the image using the original URL
            loadImage(from: imageUrlString)
        } else {
            snapImageView.image = nil
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)") // URL 확인
            snapImageView.image = nil
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)") // 에러 확인
                DispatchQueue.main.async {
                    self.snapImageView.image = nil
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to load image data.") // 데이터 확인
                DispatchQueue.main.async {
                    self.snapImageView.image = nil
                }
                return
            }
            
            DispatchQueue.main.async {
                self.snapImageView.image = image
            }
        }
        task.resume()
    }
}
