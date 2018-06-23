//
//  ProgressButton.swift
//  places
//

import UIKit

class ProgressButton: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var buttonClicked:(() -> Void)?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("ProgressButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTaped)))
    }
    
    @objc func buttonTaped(){
        if let closure = buttonClicked {
            closure()
        }
    }
    
    func resetButton(){
        self.progressView.setProgress(0.0, animated: false)
        self.uploadLabel.text = "Upload"
    }
    
    func setUploading(){
        self.uploadLabel.text = "Uploading..."
    }
    
    func setupProgress(progress:Float) {
        self.progressView.setProgress(progress, animated: true)
    }
}
