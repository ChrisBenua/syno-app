import Foundation
import UIKit

/// Protocol with needed data for `DictionaryCollectionViewCell`
protocol IDictionaryCellConfiguration: class {
    /// Name of dictionary
    var dictName: String? { get set }
    /// Language of dictionary
    var language: String? { get set }
    /// Cards count in dictionary
    var cardsAmount: Int { get set }
    /// Translations count in dictionary
    var translationsAmount: Int { get set }
}

class DictionaryCellConfiguration: IDictionaryCellConfiguration {
    var dictName: String?
    
    var language: String?
    
    var cardsAmount: Int
    
    var translationsAmount: Int
    
    /**
     Creates new `DictionaryCellConfiguration`
     - Parameter dictName: Name of dictionary
     - Parameter language:Language of dictionary
     - Parameter cardsAmount:Cards count in dictionary
     - Parameter translationsAmount:Translations count in dictionary
     */
    init(dictName: String?, language: String?, cardsAmount: Int, translationsAmount: Int) {
        self.dictName = dictName
        self.language = language
        self.cardsAmount = cardsAmount
        self.translationsAmount = translationsAmount
    }
}

/// Protocol with needed actions with `DictionaryCollectionViewCell`
protocol IConfigurableDictionaryCell: IDictionaryCellConfiguration {
    /// Fills data in this `DictionaryCollectionViewCell`
    func setup(dictName: String, language: String, cardsAmount: Int, translationsAmount: Int)
    /// Fills data in this `DictionaryCollectionViewCell`
    func setup(config: IDictionaryCellConfiguration)
}

/// Collection view cell for displaying `DbUserDictionary` data
class DictionaryCollectionViewCell: UICollectionViewCell, IConfigurableDictionaryCell {
    public static let cellId = "DictCellID"
    
    func setup(dictName: String, language: String, cardsAmount: Int, translationsAmount: Int) {
        self.dictName = dictName
        self.language = language
        self.cardsAmount = cardsAmount
        self.translationsAmount = translationsAmount
        
        updateUI()
    }
    
    func setup(config: IDictionaryCellConfiguration) {
        setup(dictName: config.dictName ?? "", language: config.language ?? "", cardsAmount: config.cardsAmount, translationsAmount: config.translationsAmount)
    }
    
    /// updates `nameLabel`, `languageLabel`, `cardsAmountLabel` and `translationsAmountLabel`
    func updateUI() {
        self.nameLabel.text = self.dictName
        self.languageLabel.text = self.language
        self.cardsAmountLabel.text = "\(cardsAmount) карточек"
        self.translationsAmountLabel.text = "\(translationsAmount) переводов"
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundView = UIImageView(image: #imageLiteral(resourceName: "DictCellBackgroung"))
        
        let transAndLangStackView = UIStackView(arrangedSubviews: [translationsAmountLabel, languageLabel])
        transAndLangStackView.axis = .horizontal;transAndLangStackView.translatesAutoresizingMaskIntoConstraints = false
        transAndLangStackView.distribution = .fillProportionally
        
        
        let mainSV = UIStackView(arrangedSubviews: [nameLabel, cardsAmountLabel, transAndLangStackView])
        mainSV.axis = .vertical; mainSV.translatesAutoresizingMaskIntoConstraints = false
        mainSV.distribution = .fill
        nameLabel.heightAnchor.constraint(equalTo: mainSV.heightAnchor, multiplier: 0.4).isActive = true
        transAndLangStackView.heightAnchor.constraint(equalTo: cardsAmountLabel.heightAnchor, multiplier: 1).isActive = true
        
        self.contentView.addSubview(mainSV)
        mainSV.spacing = 8
        mainSV.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 20, paddingRight: 15, width: 0, height: 0)
    }
    
    /// Forbidden to create from storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Name of dictionary
    var dictName: String?
    /// Language of dictionary
    var language: String?
    /// Cards count in dictionary
    var cardsAmount: Int = -1
    /// Translations count in dictionary
    var translationsAmount: Int = -1
    
    /// Label for dictionary name
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .headerMainColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    /// Label for dictionary language
    let languageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .right
        
        return label
    }()
    
    /// Label for cards amount in dictionary
    let cardsAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .left
        
        return label
    }()
    
    /// Label for translations amount in dictionary
    let translationsAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .left
        
        return label
    }()
}
