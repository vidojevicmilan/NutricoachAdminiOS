//
//  ArticleViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 4/20/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ArticleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var article: Article?
    var articleId: String!
    var isCalledForEdit : Bool!
    private var sv : UIScrollView!
    private var imagePicker : UIImagePickerController!
    private var thumbnailImage : UIImageView!
    private var titleTextView : UITextView!
    private var textTextView : UITextView!
    private var imageForUpload : UIImage!
    private var submitButton : UIButton!
    private var imageSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initScrollView()
        initSubmitButton()
    }
    
    func initScrollView(){
        sv = UIScrollView()
        sv.backgroundColor = .white
        sv.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sv)
        NSLayoutConstraint.activate([
            sv.topAnchor.constraint(equalTo: self.view.topAnchor),
            sv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            sv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sv.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        
        if !isCalledForEdit {
            article = Article(title: "Enter a title...", text: "Enter a text...", thumbnail: UIImage(named: "gallery")!)
        }
        
        let aspect: Float = Float(article!.Thumbnail.size.width) / Float(article!.Thumbnail.size.height)
        thumbnailImage = UIImageView()
        thumbnailImage.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImage.image = article?.Thumbnail
        sv.addSubview(thumbnailImage)
        thumbnailImage.contentMode = .scaleAspectFit
        thumbnailImage.topAnchor.constraint(equalTo: sv.topAnchor).isActive = true
        thumbnailImage.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        thumbnailImage.heightAnchor.constraint(equalToConstant: (self.view.frame.width / CGFloat(aspect))).isActive = true
        thumbnailImage.isUserInteractionEnabled = true
        thumbnailImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped)))
        
        let underImageLabel = UILabel()
        underImageLabel.translatesAutoresizingMaskIntoConstraints = false
        sv.addSubview(underImageLabel)
        underImageLabel.text = "Tap on image to load from gallery"
        underImageLabel.font = UIFont.systemFont(ofSize: 13)
        underImageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        underImageLabel.topAnchor.constraint(equalTo: thumbnailImage.bottomAnchor, constant: 6).isActive = true
        
        titleTextView = UITextView()
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.text = article?.Title
        sv.addSubview(titleTextView)
        titleTextView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        titleTextView.layer.cornerRadius = 8
        titleTextView.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        titleTextView.topAnchor.constraint(equalTo: underImageLabel.bottomAnchor, constant: 10).isActive = true
        titleTextView.widthAnchor.constraint(equalToConstant: self.view.frame.width - 40).isActive = true
        titleTextView.isEditable = true
        titleTextView.sizeToFit()
        titleTextView.isScrollEnabled = false
        
        
        textTextView = UITextView()
        textTextView.translatesAutoresizingMaskIntoConstraints = false
        textTextView.text = article!.Text
        sv.addSubview(textTextView)
        textTextView.leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: 10).isActive = true
        textTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 10).isActive = true
        textTextView.widthAnchor.constraint(equalToConstant: self.view.frame.width-20).isActive = true
        textTextView.isEditable = true
        textTextView.font = UIFont.systemFont(ofSize: 16)
        textTextView.sizeToFit()
        textTextView.isScrollEnabled = false
        textTextView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        textTextView.layer.cornerRadius = 8
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        textTextView.inputAccessoryView = toolbar
    }
    
    func initSubmitButton() {
        submitButton = UIButton()
        sv.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.centerXAnchor.constraint(equalTo: sv.centerXAnchor).isActive = true
        submitButton.topAnchor.constraint(equalTo: textTextView.bottomAnchor, constant: 6).isActive = true
        submitButton.widthAnchor.constraint(equalToConstant: self.view.frame.width*0.8).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = UIColor(red: 23/255, green: 128/255, blue: 251/255, alpha: 1)
        submitButton.layer.cornerRadius = 8
        
        submitButton.addTarget(self, action: #selector(submitButtonHandle), for: .touchUpInside)
        
        sv.bottomAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 200).isActive = true
    }
    
    @objc func submitButtonHandle(sender: UIButton!) {
        view.endEditing(true)
        let title = titleTextView.text!
        let text = textTextView.text!
        var ref = Database.database().reference().child("articles")
        if isCalledForEdit {
            ref = ref.child(articleId)
        } else {
            ref = ref.childByAutoId()
        }
        if imageSet {
            let meta = StorageMetadata()
            meta.contentType = "image/png"
            Storage.storage().reference().child("articles/\(ref.key!).png").putData(imageForUpload.pngData()!, metadata: meta, completion: { (meta, err) in
                if err != nil {
                    print(err.debugDescription)
                } else {
                    ref.setValue(["title":title, "text":text])
                }
            })
        } else {
            ref.setValue(["title":title, "text":text])
        }
    }
    
    @objc private func imageViewTapped(_ recognizer: UITapGestureRecognizer) {
        print("image tapped")
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: {
            print("imagePicker presented")
        })
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        //textTextView.endEditing(true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            thumbnailImage.image = image
            imageForUpload = image
            imageSet = true
        }
        else {
            SVProgressHUD.showError(withStatus: "Error opening image")
        }
        dismiss(animated: true, completion: nil)
    }
    
}
