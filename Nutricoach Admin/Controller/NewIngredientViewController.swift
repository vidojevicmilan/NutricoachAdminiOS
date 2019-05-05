//
//  NewIngredientViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 3/20/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import Firebase
import Photos
import SVProgressHUD
import FirebaseStorage

class NewIngredientViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var calledForEdit = false
    var ingredientForEdit: (id: String, name: String, unit: String, kcal: Int, protein: Float, carbs: Float, fat: Float)!
    var scrollView: UIScrollView!
    var nameTextField: UITextField!
    var unitTextField: UITextField!
    var kcalTextField: UITextField!
    var proteinTextField: UITextField!
    var carbsTextField: UITextField!
    var fatTextField: UITextField!
    var imageForUpload: UIImage!
    var imageView: UIImageView!
    var imageSet = false
    var imageViewLabel: UILabel!
    var submitButton: UIButton!
    var imagePicker = UIImagePickerController()
    let ingredientsDB = Database.database().reference().child("ingredients")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initScrollView()
        initTextFields()
        initImageView()
        initSubmitButton()
        if calledForEdit {
            fillFieldsWithData()
        }
    }
    
    func initView() {
        self.view.backgroundColor = .white
        navigationController?.navigationItem.title = "Add New"
    }
    
    func initScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
      
        scrollView.backgroundColor = UIColor.white

        let sbh = UIApplication.shared.statusBarFrame.size.height
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: (navigationController?.navigationBar.frame.height)! + sbh).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    }
    
    func initTextFields() {
        
        nameTextField = UITextField()
        scrollView.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 6).isActive = true
        nameTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 6).isActive = true
        nameTextField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 12).isActive = true
        nameTextField.placeholder = "Name"
        nameTextField.font = UIFont.systemFont(ofSize: 22)
        nameTextField.textAlignment = .center
        nameTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        nameTextField.layer.cornerRadius = 8
        nameTextField.delegate = self
        
        unitTextField = UITextField()
        scrollView.addSubview(unitTextField)
        unitTextField.translatesAutoresizingMaskIntoConstraints = false
        unitTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 6).isActive = true
        unitTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 6).isActive = true
        unitTextField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 12).isActive = true
        unitTextField.placeholder = "Unit"
        unitTextField.font = UIFont.systemFont(ofSize: 22)
        unitTextField.textAlignment = .center
        unitTextField.layer.cornerRadius = 8
        unitTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        unitTextField.delegate = self
        
        kcalTextField = UITextField()
        scrollView.addSubview(kcalTextField)
        kcalTextField.translatesAutoresizingMaskIntoConstraints = false
        kcalTextField.topAnchor.constraint(equalTo: unitTextField.bottomAnchor, constant: 6).isActive = true
        kcalTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 6).isActive = true
        kcalTextField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 12).isActive = true
        kcalTextField.placeholder = "Kcal"
        kcalTextField.font = UIFont.systemFont(ofSize: 22)
        kcalTextField.textAlignment = .center
        kcalTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        kcalTextField.layer.cornerRadius = 8
        kcalTextField.delegate = self
        
        proteinTextField = UITextField()
        scrollView.addSubview(proteinTextField)
        proteinTextField.translatesAutoresizingMaskIntoConstraints = false
        proteinTextField.topAnchor.constraint(equalTo: kcalTextField.bottomAnchor, constant: 6).isActive = true
        proteinTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 6).isActive = true
        proteinTextField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 12).isActive = true
        proteinTextField.placeholder = "Protein"
        proteinTextField.font = UIFont.systemFont(ofSize: 22)
        proteinTextField.textAlignment = .center
        proteinTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        proteinTextField.layer.cornerRadius = 8
        proteinTextField.delegate = self
        
        carbsTextField = UITextField()
        scrollView.addSubview(carbsTextField)
        carbsTextField.translatesAutoresizingMaskIntoConstraints = false
        carbsTextField.topAnchor.constraint(equalTo: proteinTextField.bottomAnchor, constant: 6).isActive = true
        carbsTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 6).isActive = true
        carbsTextField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 12).isActive = true
        carbsTextField.placeholder = "Carbs"
        carbsTextField.font = UIFont.systemFont(ofSize: 22)
        carbsTextField.textAlignment = .center
        carbsTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        carbsTextField.layer.cornerRadius = 8
        carbsTextField.delegate = self
        
        fatTextField = UITextField()
        scrollView.addSubview(fatTextField)
        fatTextField.translatesAutoresizingMaskIntoConstraints = false
        fatTextField.topAnchor.constraint(equalTo: carbsTextField.bottomAnchor, constant: 6).isActive = true
        fatTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 6).isActive = true
        fatTextField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 12).isActive = true
        fatTextField.placeholder = "Fat"
        fatTextField.font = UIFont.systemFont(ofSize: 22)
        fatTextField.textAlignment = .center
        fatTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        fatTextField.layer.cornerRadius = 8
        fatTextField.delegate = self
        
    }
    
    func initImageView() {
        imageView = UIImageView()
        scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: fatTextField.bottomAnchor, constant: 6).isActive = true
        imageView.widthAnchor.constraint(lessThanOrEqualToConstant: self.view.frame.width - 12).isActive = true
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: self.view.frame.width - 12).isActive = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "gallery")
        imageView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped)))
        
        imageViewLabel = UILabel()
        scrollView.addSubview(imageViewLabel)
        imageViewLabel.translatesAutoresizingMaskIntoConstraints = false
        imageViewLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imageViewLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 3).isActive = true
        imageViewLabel.text = "Tap on image to select from gallery"
        imageViewLabel.font = UIFont.systemFont(ofSize: 12)
        
    }
    
    func initSubmitButton() {
        submitButton = UIButton()
        scrollView.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        submitButton.topAnchor.constraint(equalTo: imageViewLabel.bottomAnchor, constant: 6).isActive = true
        submitButton.widthAnchor.constraint(equalToConstant: self.view.frame.width*0.8).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = UIColor(red: 23/255, green: 128/255, blue: 251/255, alpha: 1)
        submitButton.layer.cornerRadius = 8
        
        submitButton.addTarget(self, action: #selector(submitButtonHandle), for: .touchUpInside)
        
        scrollView.bottomAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 50).isActive = true
    }
    
    @objc private func imageViewTapped(_ recognizer: UITapGestureRecognizer) {
        print("image tapped")
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: {
            print("imagePicker presented")
        })
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            imageForUpload = image
            imageSet = true
        }
        else {
            print("Error opening image")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func submitButtonHandle(sender: UIButton!) {
        
        let name = nameTextField.text
        let unit = unitTextField.text
        let kcal = Int(kcalTextField?.text ?? "n/a")
        let protein = Float(proteinTextField?.text ?? "n/a")
        let carbs = Float(carbsTextField?.text ?? "n/a")
        let fat = Float(fatTextField?.text ?? "n/a")
        
        if name!.isEmpty || unit!.isEmpty || kcal==nil || protein==nil || carbs==nil || fat==nil {
            SVProgressHUD.showError(withStatus: "Invalid input")
        } else {
            if imageSet {
                let ingredient : [String : Any] = ["name":name!, "unit":unit!, "kcal":kcal!, "protein":protein!, "carbs":carbs!, "fat":fat!]
                
                let imageData: Data = imageForUpload.pngData()!
                let meta = StorageMetadata()
                meta.contentType = "image/png"
                
                if calledForEdit {
                    ingredientsDB.child(ingredientForEdit.id).setValue(ingredient)
                    let ingRef = Storage.storage().reference().child("ingredients/\(ingredientForEdit.id).png")
                    ingRef.putData(imageData, metadata: meta)
                } else {
                    let ref = ingredientsDB.childByAutoId()
                    ref.setValue(ingredient)
                    let ingRef = Storage.storage().reference().child("ingredients/\(ref.key!).png")
                    ingRef.putData(imageData, metadata: meta)
                }
                
                SVProgressHUD.showSuccess(withStatus: "\(name!) successfully added")
                
            } else {
                let ingredient : [String : Any] = ["name":name!, "unit":unit!, "kcal":kcal!, "protein":protein!, "carbs":carbs!, "fat":fat!]
                if calledForEdit {
                    ingredientsDB.child(ingredientForEdit.id).setValue(ingredient)
                } else {
                    ingredientsDB.childByAutoId().setValue(ingredient)
                }
                
                SVProgressHUD.showSuccess(withStatus: "\(name!) successfully added")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
            case .authorized: print("Access is granted by user")
            case .notDetermined: PHPhotoLibrary.requestAuthorization({
                (newStatus) in print("status is \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized { /* do stuff here */ print("success") }
                })
            case .restricted:  print("User do not have access to photo album.")
            case .denied: print("User has denied the permission.")
        }
    }
    
    func fillFieldsWithData() {
        nameTextField.text = ingredientForEdit.name
        unitTextField.text = ingredientForEdit.unit
        kcalTextField.text = "\(ingredientForEdit.kcal)"
        proteinTextField.text = "\(ingredientForEdit.protein)"
        carbsTextField.text = "\(ingredientForEdit.carbs)"
        fatTextField.text = "\(ingredientForEdit.fat)"
        let ingRef = Storage.storage().reference().child("ingredients/\(ingredientForEdit.id).png")
        var image : UIImage!
        ingRef.getData(maxSize: 1024*1024*3) { (data, err) in
            if err != nil {
                print(err.debugDescription)
            } else {
                image = UIImage(data: data!)
                self.imageView.image = image
            }
        }
    }
}
