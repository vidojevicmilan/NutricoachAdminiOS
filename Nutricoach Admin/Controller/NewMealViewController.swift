//
//  NewMealViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 3/2/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class NewMealViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    var uid: String!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var scView: UIScrollView!
    var titleTextField: UITextField!
    var ingPicker: UIPickerView!
    var ingTextField: UITextField!
    var amountTextField: UITextField!
    var ingAddButton: UIButton!
    var summaryView: UIView!
    var ingViews = [UIView]()
    var macrosSum = (kcal: 0, protein: 0, carbs: 0, fat: 0)
    var macrosSumView: UIView!
    var submitButton: UIButton!
    
    var selectedIng: String!
    var selectedIngIndex: Int!
    
    
    let ingsDB = Database.database().reference().child("ingredients")
    var ingredientsFromDB = [(id: String, name: String, carbs: Float, protein: Float, fat: Float, kcal: Int, unit: String)]()
    var pickerData = [String]()
    var ingsForUpload = [String:Ingreedient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cal = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.day = 14
        datePicker.minimumDate = Date()
        datePicker.maximumDate = cal.date(byAdding: comps, to: Date())

        
        initScView()
        initSubmitButton()
        initTitleTextField()
        initIngPicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchIngredients()
        
    }
    
    func initScView() {
        scView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    }
    
    func initTitleTextField() {
        titleTextField = UITextField()
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        scView.addSubview(titleTextField)
        titleTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -6).isActive = true
        titleTextField.layer.cornerRadius = 8
        titleTextField.heightAnchor.constraint(equalToConstant: 32).isActive = true
        titleTextField.backgroundColor = .white
        titleTextField.topAnchor.constraint(equalTo: scView.topAnchor, constant: 6).isActive = true
        titleTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 6).isActive = true
        titleTextField.textAlignment = .center
        titleTextField.placeholder = "Title"
        titleTextField.delegate = self
    }
    
    func initIngPicker() {
        
        let conView = UIView()
        scView.addSubview(conView)
        conView.translatesAutoresizingMaskIntoConstraints = false
        conView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 6).isActive = true
        conView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 6).isActive = true
        conView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -6).isActive = true
        conView.layer.cornerRadius = 8
        conView.backgroundColor = .white
        
        ingAddButton = UIButton()
        ingAddButton.translatesAutoresizingMaskIntoConstraints = false
        scView.addSubview(ingAddButton)
        ingAddButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        ingAddButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        ingAddButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 12).isActive = true
        ingAddButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        ingAddButton.layer.cornerRadius = 8
        ingAddButton.setTitle("Add", for: .normal)
        ingAddButton.backgroundColor = UIColor(red: 23/255, green: 128/255, blue: 251/255, alpha: 1)
        ingAddButton.addTarget(self, action: #selector(addIngButtonHandle), for: .touchUpInside)
        
        amountTextField = UITextField()
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        scView.addSubview(amountTextField)
        amountTextField.bottomAnchor.constraint(equalTo: ingAddButton.bottomAnchor).isActive = true
        amountTextField.topAnchor.constraint(equalTo: ingAddButton.topAnchor).isActive = true
        amountTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        amountTextField.layer.cornerRadius = 8
        amountTextField.trailingAnchor.constraint(equalTo: ingAddButton.leadingAnchor, constant: -5).isActive = true
        amountTextField.widthAnchor.constraint(equalToConstant: 70).isActive = true
        amountTextField.placeholder = "Amount"
        amountTextField.delegate = self
        
        ingTextField = UITextField()
        ingPicker = UIPickerView()
        ingPicker.delegate = self
        ingPicker.backgroundColor = .white
        ingTextField.inputView = ingPicker
        ingTextField.translatesAutoresizingMaskIntoConstraints = false
        scView.addSubview(ingTextField)
        ingTextField.layer.cornerRadius = 8
        ingTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        ingTextField.topAnchor.constraint(equalTo: amountTextField.topAnchor).isActive = true
        ingTextField.bottomAnchor.constraint(equalTo: amountTextField.bottomAnchor).isActive = true
        ingTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        ingTextField.trailingAnchor.constraint(equalTo: amountTextField.leadingAnchor, constant: -5).isActive = true
        ingTextField.placeholder = "Choose Ingredient"
        ingTextField.delegate = self
        
        conView.bottomAnchor.constraint(equalTo: ingTextField.bottomAnchor, constant: 6).isActive = true
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let addNewButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewIngredientButtonHandle))
        
        toolbar.setItems([doneButton,flex, addNewButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        
        ingTextField.inputAccessoryView = toolbar
    }
    
    @objc func addIngButtonHandle(sender: UIButton!) {
        // Add selected ingredient to list
        let amount = Int(amountTextField.text ?? "n/a")
        if amount != nil {
            ingsForUpload[ingredientsFromDB[selectedIngIndex].id] = Ingreedient(name: ingredientsFromDB[selectedIngIndex].name, amount: amount!,unit: ingredientsFromDB[selectedIngIndex].unit)
            // Add new ingredient View
            refreshIngredientsViewsList()
        } else {
            SVProgressHUD.showError(withStatus: "Must input whole number!")
            SVProgressHUD.dismiss(withDelay: 2)
        }
        
        
    }
    
    @objc func addNewIngredientButtonHandle(sender: UIButton!) {
        let NewIngVC = NewIngredientViewController()
        navigationController?.pushViewController(NewIngVC, animated: true)
    }
    
    func refreshIngredientsViewsList() {
        for i in ingViews {
            i.removeFromSuperview()
        }
        ingViews = [UIView]()
        macrosSum = (kcal: 0, protein: 0, carbs: 0, fat: 0)
        
        // ingsForUpload is a dictionary, it can't have multiple data with same id
        var i : Int = 0
        for ing in ingsForUpload {
            let id = ing.key
            var ingredient: (id: String, name: String, carbs: Float, protein: Float, fat: Float, kcal: Int, unit: String)!
            for ingre in ingredientsFromDB where ingre.id == id {
                ingredient = ingre
            }
            let amount = ing.value.amount
            let name = ingredient.name
            let kcal = Float(ingredient.kcal) * 0.01 * Float(amount)
            let pro = ingredient.protein * 0.01 * Float(amount)
            let carb = ingredient.carbs * 0.01 * Float(amount)
            let fat = ingredient.fat * 0.01 * Float(amount)
            let unit = ingredient.unit
            
            macrosSum.kcal += Int(kcal)
            macrosSum.protein += Int(pro)
            macrosSum.carbs += Int(carb)
            macrosSum.fat += Int(fat)
            
            let newView = UIView()
            ingViews.append(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
            scView.addSubview(newView)
            newView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 6).isActive = true
            newView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -6).isActive = true
            newView.layer.cornerRadius = 8
            newView.backgroundColor = .white
            
            if i == 0 {
                newView.topAnchor.constraint(equalTo: ingTextField.bottomAnchor, constant: 12).isActive = true
                
            } else {
                newView.topAnchor.constraint(equalTo: ingViews[i-1].bottomAnchor, constant: 6).isActive = true
            }
            
            let nameLab = UILabel()
            nameLab.translatesAutoresizingMaskIntoConstraints = false
            newView.addSubview(nameLab)
            nameLab.topAnchor.constraint(equalTo: newView.topAnchor, constant: 3).isActive = true
            nameLab.leadingAnchor.constraint(equalTo: newView.leadingAnchor, constant: 10).isActive = true
            nameLab.text = name
            
            let amountLab = UILabel()
            amountLab.translatesAutoresizingMaskIntoConstraints = false
            newView.addSubview(amountLab)
            amountLab.topAnchor.constraint(equalTo: newView.topAnchor, constant: 3).isActive = true
            amountLab.trailingAnchor.constraint(equalTo: newView.trailingAnchor, constant: -10).isActive = true
            amountLab.text = "\(amount) " + unit
            
            let kcalLab = UILabel()
            kcalLab.translatesAutoresizingMaskIntoConstraints = false
            newView.addSubview(kcalLab)
            kcalLab.topAnchor.constraint(equalTo: nameLab.bottomAnchor, constant: 3).isActive = true
            kcalLab.leadingAnchor.constraint(equalTo: newView.leadingAnchor, constant: 6).isActive = true
            kcalLab.text = "Kcal: \(Int(kcal))"
            
            let proLab = UILabel()
            proLab.translatesAutoresizingMaskIntoConstraints = false
            newView.addSubview(proLab)
            proLab.topAnchor.constraint(equalTo: kcalLab.bottomAnchor, constant: 3).isActive = true
            proLab.leadingAnchor.constraint(equalTo: newView.leadingAnchor, constant: 6).isActive = true
            proLab.text = "Protein: \(Int(pro))g"
            
            let carbLab = UILabel()
            carbLab.translatesAutoresizingMaskIntoConstraints = false
            newView.addSubview(carbLab)
            carbLab.topAnchor.constraint(equalTo: proLab.bottomAnchor, constant: 3).isActive = true
            carbLab.leadingAnchor.constraint(equalTo: newView.leadingAnchor, constant: 6).isActive = true
            carbLab.text = "Carbs: \(Int(carb))g"
            
            let fatLab = UILabel()
            fatLab.translatesAutoresizingMaskIntoConstraints = false
            newView.addSubview(fatLab)
            fatLab.topAnchor.constraint(equalTo: carbLab.bottomAnchor, constant: 3).isActive = true
            fatLab.leadingAnchor.constraint(equalTo: newView.leadingAnchor, constant: 6).isActive = true
            fatLab.text = "Fats: \(Int(fat))g"
            
            newView.bottomAnchor.constraint(equalTo: fatLab.bottomAnchor, constant: 3).isActive = true
            
            i+=1
        }
        showMacrosSum()
        
    }
    
    func showMacrosSum() {
        if macrosSumView != nil {
            macrosSumView.removeFromSuperview()
        }
        if ingViews.count > 0 {
            
            submitButton.isHidden = false
            
            macrosSumView = UIView()
            macrosSumView.translatesAutoresizingMaskIntoConstraints = false
            scView.addSubview(macrosSumView)
            macrosSumView.topAnchor.constraint(equalTo: ingViews.last!.bottomAnchor, constant: 6).isActive = true
            macrosSumView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 6).isActive = true
            macrosSumView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -6).isActive = true
            macrosSumView.backgroundColor = .white
            macrosSumView.layer.cornerRadius = 8
            
            let titleLab = UILabel()
            titleLab.translatesAutoresizingMaskIntoConstraints = false
            macrosSumView.addSubview(titleLab)
            titleLab.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            titleLab.topAnchor.constraint(equalTo: macrosSumView.topAnchor, constant: 3).isActive = true
            titleLab.text = "Macros Sum for Meal"
            
            let kcalLab = UILabel()
            kcalLab.translatesAutoresizingMaskIntoConstraints = false
            macrosSumView.addSubview(kcalLab)
            kcalLab.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            kcalLab.topAnchor.constraint(equalTo: titleLab.bottomAnchor, constant: 3).isActive = true
            kcalLab.text = "kcal: \(macrosSum.kcal)"
            
            let proLab = UILabel()
            proLab.translatesAutoresizingMaskIntoConstraints = false
            macrosSumView.addSubview(proLab)
            proLab.leadingAnchor.constraint(equalTo: macrosSumView.leadingAnchor).isActive = true
            proLab.topAnchor.constraint(equalTo: kcalLab.bottomAnchor, constant: 3).isActive = true
            proLab.text = "Protein: \(macrosSum.protein)"
            proLab.textAlignment = .center
            proLab.widthAnchor.constraint(equalToConstant: (self.view.frame.width-12)/3).isActive = true
            
            let carbLab = UILabel()
            carbLab.translatesAutoresizingMaskIntoConstraints = false
            macrosSumView.addSubview(carbLab)
            carbLab.leadingAnchor.constraint(equalTo: proLab.trailingAnchor).isActive = true
            carbLab.topAnchor.constraint(equalTo: kcalLab.bottomAnchor, constant: 3).isActive = true
            carbLab.text = "Carbs: \(macrosSum.carbs)"
            carbLab.textAlignment = .center
            carbLab.widthAnchor.constraint(equalToConstant: (self.view.frame.width-12)/3).isActive = true
            
            let fatLab = UILabel()
            fatLab.translatesAutoresizingMaskIntoConstraints = false
            macrosSumView.addSubview(fatLab)
            fatLab.leadingAnchor.constraint(equalTo: carbLab.trailingAnchor).isActive = true
            fatLab.topAnchor.constraint(equalTo: kcalLab.bottomAnchor, constant: 3).isActive = true
            fatLab.text = "Fats: \(macrosSum.fat)"
            fatLab.textAlignment = .center
            fatLab.widthAnchor.constraint(equalToConstant: (self.view.frame.width-12)/3).isActive = true
            
            macrosSumView.bottomAnchor.constraint(equalTo: fatLab.bottomAnchor, constant: 6).isActive = true
            
            scView.bottomAnchor.constraint(equalTo: macrosSumView.bottomAnchor, constant: 70).isActive = true
        }
        
    }
    
    func initSubmitButton() {
        submitButton = UIButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(submitButton)
        submitButton.bottomAnchor.constraint(equalTo: scView.bottomAnchor, constant: -6).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        submitButton.widthAnchor.constraint(equalToConstant: self.view.frame.width*0.8).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = UIColor(red: 23/255, green: 128/255, blue: 251/255, alpha: 1)
        submitButton.layer.cornerRadius = 8
        submitButton.isHidden = true
        
        submitButton.addTarget(self, action: #selector(submitButtonHandle), for: .touchUpInside)
    }
    
    @objc func submitButtonHandle(sender: UIButton!) {
        let title = titleTextField.text
        if !(title?.isEmpty ?? true) {
            Database.database().reference().child("users/\(uid!)/lastMealDate").observeSingleEvent(of: .value) { (snap) in
                let formater = DateFormatter()
                formater.dateFormat = "yyyyMMdd"
                let date = formater.string(from: self.datePicker.date)
                var lastMealDate = snap.value as? Int
                if lastMealDate != nil{
                    if lastMealDate! >= Int(date)! {
                        lastMealDate = Int(date)!
                    }
                } else {
                    lastMealDate = Int(date)
                }
                Database.database().reference().child("users/\(self.uid!)/lastMealDate").setValue(lastMealDate)
                Database.database().reference().child("mealPlans/\(self.uid!)/dates/\(Int(date)!)").setValue(true)
                for i in self.ingsForUpload {
                    Database.database().reference().child("mealPlans/\(self.uid!)/meals").child(date).child(title!).child(i.key).setValue(["name":i.value.name,"amount":i.value.amount,"unit":i.value.unit])
                }
                
                SVProgressHUD.showSuccess(withStatus: "Added new meal")
            }
        } else {
            SVProgressHUD.showError(withStatus: "Must fill all fields!")
            SVProgressHUD.dismiss(withDelay: 2)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIng = pickerData[row]
        ingTextField.text = selectedIng
        selectedIngIndex = row
        amountTextField.placeholder = ingredientsFromDB[row].unit
    }
    
    func fetchIngredients() {
        ingredientsFromDB = [(id: String, name: String, carbs: Float, protein: Float, fat: Float, kcal: Int, unit: String)]()
        pickerData = [String]()
        ingsDB.observeSingleEvent(of: .value) { (snap) in
            SVProgressHUD.show()
            for i in snap.children {
                let ing = i as! DataSnapshot
                let id = ing.key
                let name = ing.childSnapshot(forPath: "name").value as! String
                let carbs = ing.childSnapshot(forPath: "carbs").value as! Float
                let protein = ing.childSnapshot(forPath: "protein").value as! Float
                let fat = ing.childSnapshot(forPath: "fat").value as! Float
                let kcal = ing.childSnapshot(forPath: "kcal").value as! Int
                let unit = ing.childSnapshot(forPath: "unit").value as! String
                self.pickerData.append(name)
                self.ingredientsFromDB.append((id: id, name: name, carbs: carbs, protein: protein, fat: fat, kcal: kcal, unit: unit))
            }
            self.ingPicker.reloadAllComponents()
            SVProgressHUD.dismiss()
        }
    }
    
    
}
