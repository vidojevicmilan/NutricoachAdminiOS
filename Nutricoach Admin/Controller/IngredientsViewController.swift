//
//  IngredientsViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 4/18/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import Firebase

class IngredientsViewController: UITableViewController {

    @IBOutlet weak var newIngredientButton: UIBarButtonItem!
    var ingredients = [(id: String, name: String, unit: String, kcal: Int, protein: Float, carbs: Float, fat: Float, image: UIImage? )]()
    var ingredientsDB : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientsDB = Database.database().reference().child("ingredients")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ingredients = [(id: String, name: String, unit: String, kcal: Int, protein: Float, carbs: Float, fat: Float, image: UIImage? )]()
        fetchIngredients()
        setChildRemovedObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ingredientsDB.removeAllObservers()
        super.viewDidDisappear(animated)
    }
    
   
    @IBAction func newIngButtonAction(_ sender: Any) {
        let NewIngVC = NewIngredientViewController()
        navigationController?.pushViewController(NewIngVC, animated: true)
    }
    
    func fetchIngredients() {
        ingredientsDB.observe(.childAdded) { (snap) in
            let id = snap.key
            let name = snap.childSnapshot(forPath: "name").value as! String
            let unit = snap.childSnapshot(forPath: "unit").value as! String
            let kcal = snap.childSnapshot(forPath: "kcal").value as! Int
            let protein = snap.childSnapshot(forPath: "protein").value as! Float
            let carbs = snap.childSnapshot(forPath: "carbs").value as! Float
            let fat = snap.childSnapshot(forPath: "fat").value as! Float
            let imageString = snap.childSnapshot(forPath: "image").value as? String
            var image: UIImage? = nil
            if let imageString = imageString {
                if let decodedImageData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
                    image = UIImage(data: decodedImageData)
                }
            }
            
            self.ingredients.append((id, name, unit, kcal, protein, carbs, fat, image))
            self.tableView.reloadData()
        }
    }
    
    func setChildRemovedObserver() {
        ingredientsDB.observe(.childRemoved) { (snap) in
            let key = snap.key
            var index = -1
            for i in 0...self.ingredients.count-1 {
                if self.ingredients[i].id == key {
                    index = i
                }
            }
            if index != -1 {
                self.ingredients.remove(at: index)
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    //TODO: Make custom table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ingredients[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let ing = ingredients[indexPath.row]
        let editIngVC = NewIngredientViewController()
        editIngVC.calledForEdit = true
        editIngVC.ingredientForEdit = (ing.id, ing.name, ing.unit, ing.kcal, ing.protein, ing.carbs, ing.fat)
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(editIngVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ingredientsDB.child(ingredients[indexPath.row].id).removeValue()
            self.ingredients.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
}
