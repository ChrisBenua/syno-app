import Foundation
import UIKit

/// Protocol defining data needed for `CardCollectionViewCell`
protocol ICardCellConfiguration {
    /// Card's translated word
    var translatedWord: String? { get set }
    /// Card's translations
    var translations: [String]? { get set }
}

class CardCellConfiguration: ICardCellConfiguration {
    var translatedWord: String?
    
    var translations: [String]?
    
    /**
     Creates new `CardCellConfiguration`
     - Parameter translatedWord: Card's translated word
     - Parameter translations: Card's translations
     */
    init(translatedWord: String?, translations: [String]?) {
        self.translatedWord = translatedWord
        self.translations = translations
    }
}

/// Protocol for setting data for `CardCollectionViewCell`
protocol IConfigurableCardCell {
    /// Fills data inside cell
    func setup(configuration: ICardCellConfiguration)
}

/// Collection view cell for displaying card in edit mode
class CardCollectionViewCell: UICollectionViewCell, IConfigurableCardCell {
    public static let cellId = "CardCellID"

    var translatedWord: String?
    var translations: [String]?
    
    /// Updates `translatedWordLabel` and `translationsLabel`
    func updateUI() {
        self.translatedWordLabel.text = translatedWord
        var translationsText = (translations ?? []).reversed().reduce("", { (res, curr) -> String in
            if curr.hasSuffix("?") {
                return res + " " + curr
            } else {
                return res + ", " + curr
            }
        })
        
        if translationsText.count > 0 {
            let index = translationsText.index(after: translationsText.startIndex)
            translationsText = String(translationsText[index...])
        }
        
        self.translationsLabel.text = translationsText
    }
    
    func setup(configuration: ICardCellConfiguration) {
        self.translatedWord = configuration.translatedWord
        self.translations = configuration.translations
        
        updateUI()
    }
    
    /// Label for displaying card's translated word
    let translatedWordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .headerMainColor
        
        label.textAlignment = .left
        return label
    }()
    
    /// Label for displaying card's translations
    let translationsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        
        label.textAlignment = .right
        return label
    }()
    
    lazy var baseShadowView: BaseShadowView = {
        //let view = BaseShadowView()
        let view = BaseShadowView(containerViewInsets: UIEdgeInsets(top: 2, left: 0, bottom: 4, right: 0))
        view.shadowView.layer.shadowOpacity = 0.25
        view.cornerRadius = 10
        view.shadowView.shadowOffset = CGSize(width: -1, height: 2.5)
        view.containerViewBackgroundColor = UIColor(red: 239.0/255, green: 239.0/255, blue: 239.0/255, alpha: 1)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        //self.backgroundView = UIImageView(image: #imageLiteral(resourceName: "CardCellBackground"))
        self.contentView.addSubview(baseShadowView)
        //self.contentView.layer.cornerRadius = 10
        //self.contentView.clipsToBounds = true
        baseShadowView.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 3, paddingBottom: 0, paddingRight: 2, width: 0, height: 0)
        
        self.baseShadowView.containerView.addSubview(translatedWordLabel)
        
        translatedWordLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        
        self.baseShadowView.containerView.addSubview(translationsLabel)
        translatedWordLabel.anchor(top: self.baseShadowView.topAnchor, left: self.baseShadowView.leftAnchor, bottom: self.baseShadowView.bottomAnchor, right: self.translationsLabel.leftAnchor, paddingTop: 2, paddingLeft: 6, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
        
        translationsLabel.anchor(top: self.baseShadowView.topAnchor, left: nil, bottom: self.baseShadowView.bottomAnchor, right: self.baseShadowView.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 5, paddingRight: 7, width: 0, height: 0)
        
    }
    
    /// Forbidden to create from Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
