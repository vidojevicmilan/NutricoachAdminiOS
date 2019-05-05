//
//  UserDetailsViewController.swift
//  Nutricoach Admin
//
//  Created by Milan Vidojevic on 2/26/19.
//  Copyright © 2019 Milan Vidojevic. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class UserDetailsViewController: UIViewController {

    var user: User?
    var userDB = Database.database().reference().child("users")
    var mealsDatesDB = Database.database().reference().child("mealPlans")
    var mealsDB = Database.database().reference().child("mealPlans")
    var meals = [Meal]()
    var scViewBottomConstraint: NSLayoutConstraint!
    var userInfoView: UIView!
    var userGoalView: UIView!
    var kcalGoal: UITextField!
    var carbsGoal: UITextField!
    var proGoal: UITextField!
    var fatGoal: UITextField!
    var daysView: UIScrollView!
    var daysButtons = [UIButton]()
    var mealViews = [UIView]()
    @IBOutlet weak var scView: UIView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var newMealButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = user?.name ?? user!.email
        userDB = userDB.child(user!.id)
        mealsDB = mealsDB.child(user!.id).child("meals")
        mealsDatesDB = mealsDatesDB.child(user!.id).child("dates")
        initScrollView()
        initUserInfoView()
        initUserGoal()
        initCornerButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initDaysScrollView()
        fetchMeals(for: Date())
    }
    
    
    func initScrollView() {
        scView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    }
    
    func initUserInfoView() {
        userInfoView = UIView()
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        scView.addSubview(userInfoView)
        userInfoView.topAnchor.constraint(equalTo: scView.topAnchor, constant: 6).isActive = true
        userInfoView.leadingAnchor.constraint(equalTo: scView.leadingAnchor, constant: 6).isActive = true
        userInfoView.widthAnchor.constraint(equalToConstant: self.view.frame.width-12).isActive = true
        userInfoView.layer.cornerRadius = 8
        userInfoView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.addSubview(infoLabel)
        infoLabel.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 12).isActive = true
        infoLabel.topAnchor.constraint(equalTo: userInfoView.topAnchor, constant: 3).isActive = true
        infoLabel.text = "User info"
        infoLabel.font = UIFont.systemFont(ofSize: 18, weight: .light)
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 6).isActive = true
        nameLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 3).isActive = true
        nameLabel.text = "Name: \(user?.name ?? "n/a")"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        let ageLabel = UILabel()
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.addSubview(ageLabel)
        ageLabel.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 6).isActive = true
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3).isActive = true
        ageLabel.text = "Age: \(user?.userInfo?.age ?? 0)"
        ageLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        let weightLabel = UILabel()
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.addSubview(weightLabel)
        weightLabel.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 6).isActive = true
        weightLabel.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 3).isActive = true
        weightLabel.text = "Weight: \(user?.userInfo?.weight ?? 0)kg"
        weightLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        let heightLabel = UILabel()
        heightLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.addSubview(heightLabel)
        heightLabel.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 6).isActive = true
        heightLabel.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 3).isActive = true
        heightLabel.text = "Height: \(user?.userInfo?.height ?? 0)cm"
        heightLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        let goalLabel = UILabel()
        goalLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.addSubview(goalLabel)
        goalLabel.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 6).isActive = true
        goalLabel.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 3).isActive = true
        goalLabel.text = "Goal: \(user?.userInfo?.goal ?? "n/a")"
        goalLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        let activityLabel = UILabel()
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.addSubview(activityLabel)
        activityLabel.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 6).isActive = true
        activityLabel.topAnchor.constraint(equalTo: goalLabel.bottomAnchor, constant: 3).isActive = true
        activityLabel.text = "Activity: \(user?.userInfo?.activity ?? "n/a")"
        activityLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        userInfoView.bottomAnchor.constraint(equalTo: activityLabel.bottomAnchor, constant: 6).isActive = true
    }
    
    func initUserGoal() {
        userGoalView = UIView()
        userGoalView.translatesAutoresizingMaskIntoConstraints = false
        scView.addSubview(userGoalView)
        userGoalView.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 6).isActive = true
        userGoalView.leadingAnchor.constraint(equalTo: scView.leadingAnchor, constant: 6).isActive = true
        userGoalView.widthAnchor.constraint(equalToConstant: self.view.frame.width-12).isActive = true
        userGoalView.layer.cornerRadius = 8
        userGoalView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let goalsLabel = UILabel()
        goalsLabel.translatesAutoresizingMaskIntoConstraints = false
        userGoalView.addSubview(goalsLabel)
        goalsLabel.leadingAnchor.constraint(equalTo: userGoalView.leadingAnchor, constant: 12).isActive = true
        goalsLabel.topAnchor.constraint(equalTo: userGoalView.topAnchor, constant: 3).isActive = true
        goalsLabel.text = "User goals"
        goalsLabel.font = UIFont.systemFont(ofSize: 18, weight: .light)
        
        kcalGoal = UITextField()
        kcalGoal.translatesAutoresizingMaskIntoConstraints = false
        userGoalView.addSubview(kcalGoal)
        kcalGoal.topAnchor.constraint(equalTo: goalsLabel.bottomAnchor, constant: 3).isActive = true
        kcalGoal.leadingAnchor.constraint(equalTo: userGoalView.leadingAnchor, constant: 6).isActive = true
        kcalGoal.placeholder = "  \(user?.prescribedMacros?.kcal ?? 0) kcal"
        kcalGoal.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        kcalGoal.widthAnchor.constraint(equalToConstant: 200).isActive = true
        kcalGoal.layer.cornerRadius = 8

        carbsGoal = UITextField()
        carbsGoal.translatesAutoresizingMaskIntoConstraints = false
        userGoalView.addSubview(carbsGoal)
        carbsGoal.topAnchor.constraint(equalTo: kcalGoal.bottomAnchor, constant: 3).isActive = true
        carbsGoal.leadingAnchor.constraint(equalTo: userGoalView.leadingAnchor, constant: 6).isActive = true
        carbsGoal.placeholder = "  \(user?.prescribedMacros?.carbs ?? 0)g carbs"
        carbsGoal.widthAnchor.constraint(equalToConstant: 200).isActive = true
        carbsGoal.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        carbsGoal.layer.cornerRadius = 8

        proGoal = UITextField()
        proGoal.translatesAutoresizingMaskIntoConstraints = false
        userGoalView.addSubview(proGoal)
        proGoal.topAnchor.constraint(equalTo: carbsGoal.bottomAnchor, constant: 3).isActive = true
        proGoal.leadingAnchor.constraint(equalTo: userGoalView.leadingAnchor, constant: 6).isActive = true
        proGoal.placeholder = "  \(user?.prescribedMacros?.protein ?? 0)g protein"
        proGoal.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        proGoal.widthAnchor.constraint(equalToConstant: 200).isActive = true
        proGoal.layer.cornerRadius = 8

        fatGoal = UITextField()
        fatGoal.translatesAutoresizingMaskIntoConstraints = false
        userGoalView.addSubview(fatGoal)
        fatGoal.topAnchor.constraint(equalTo: proGoal.bottomAnchor, constant: 3).isActive = true
        fatGoal.leadingAnchor.constraint(equalTo: userGoalView.leadingAnchor, constant: 6).isActive = true
        fatGoal.placeholder = "  \(user?.prescribedMacros?.fat ?? 0)g fat"
        fatGoal.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        fatGoal.widthAnchor.constraint(equalToConstant: 200).isActive = true
        fatGoal.layer.cornerRadius = 8

        let submit = UIButton()
        submit.translatesAutoresizingMaskIntoConstraints = false
        userGoalView.addSubview(submit)
        submit.trailingAnchor.constraint(equalTo: userGoalView.trailingAnchor, constant: -6).isActive = true
        submit.topAnchor.constraint(equalTo: proGoal.bottomAnchor, constant: 6).isActive = true
        submit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        submit.setTitle("Submit", for: .normal)
        submit.layer.cornerRadius = 8
        submit.backgroundColor = UIColor(red: 23/255, green: 128/255, blue: 251/255, alpha: 1)
        submit.setTitleColor(.white, for: .normal)
        submit.addTarget(self, action: #selector(submitHandler), for: .touchUpInside)
        
        userGoalView.bottomAnchor.constraint(equalTo: submit.bottomAnchor, constant: 6).isActive = true
        
    }
    
    @objc func submitHandler() {
        let k = Int(kcalGoal.text ?? "n/a")
        let c = Int(carbsGoal.text ?? "n/a")
        let p = Int(proGoal.text ?? "n/a")
        let f = Int(fatGoal.text ?? "n/a")
        
        if (k != nil) && (c != nil) && (p != nil) && (f != nil) {
            let children = ["kcal":k, "carbs":c, "protein":p, "fat":f]
            userDB.child("prescribedMacros").setValue(children)
            SVProgressHUD.showSuccess(withStatus: "Successfully updated prescribed macros")
            SVProgressHUD.dismiss(withDelay: 2)
        } else {
            SVProgressHUD.showError(withStatus: "Error: All fields must be whole numbers!")
            SVProgressHUD.dismiss(withDelay: 2)
        }
        
    }
    
    func initCornerButtons() {
        chatButton.layer.cornerRadius = 30
        chatButton.backgroundColor = UIColor(red: 23/255, green: 128/255, blue: 251/255, alpha: 1)
        
        newMealButton.layer.cornerRadius = 30
        newMealButton.backgroundColor = UIColor(red: 23/255, green: 128/255, blue: 251/255, alpha: 1)
    }

    @IBAction func chatButtonClick(_ sender: Any) {
        let ChatVC = ChatViewController()
        ChatVC.user = (id: user!.id, name: user!.name!)
        navigationController?.pushViewController(ChatVC, animated: true)
    }
    
    @IBAction func newMealButtonClick(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewMeal" {
            (segue.destination as! NewMealViewController).uid = user?.id
        }
    }
    
    func initDaysScrollView() {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        scView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: scView.leadingAnchor, constant: 15).isActive = true
        label.topAnchor.constraint(equalTo: userGoalView.bottomAnchor, constant: 6).isActive = true
        label.text = "Meal plan"
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        
        var dates = [String]()
        if daysView != nil {
            daysView.removeFromSuperview()
            daysButtons = [UIButton]()
        }
        
        daysView = UIScrollView()
        daysView.translatesAutoresizingMaskIntoConstraints = false
        scView.addSubview(daysView)
        daysView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6).isActive = true
        daysView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        daysView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        daysView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        daysView.backgroundColor = .clear
        daysView.showsHorizontalScrollIndicator = false
        
        mealsDatesDB.observeSingleEvent(of: .value) { (snap) in
            let dict = snap.value as? [String : Any]
            dates = [String]()
            
            if !(dict?.isEmpty ?? true) {
                for item in dict! {
                    dates.append(item.key)
                }
            }
            
            dates.sort(by: <)
            
            for i in 0..<dates.count {
                let button = UIButton()
                self.daysView.addSubview(button)
                self.daysButtons.append(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                
                let form = DateFormatter()
                form.dateFormat = "yyyyMMdd"
                let d = form.date(from: dates[i])
                form.dateFormat = "dd MMM y"
                button.setTitle(form.string(from: d!), for: .normal)
                
                button.topAnchor.constraint(equalTo: self.daysView.topAnchor).isActive = true
                button.heightAnchor.constraint(equalTo: self.daysView.heightAnchor).isActive = true
                button.widthAnchor.constraint(equalTo: button.titleLabel!.widthAnchor, constant: 10).isActive = true
                button.setTitleColor(.black, for: .normal)
                button.layer.cornerRadius = 10
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .thin)
                button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
                if i == 0 {
                    button.leadingAnchor.constraint(equalTo: self.daysView.leadingAnchor, constant: 6).isActive = true
                } else {
                    button.leadingAnchor.constraint(equalTo: self.daysButtons[i-1].trailingAnchor, constant: 6).isActive = true
                }
                
            }
            if self.daysButtons.count != 0 {
                self.daysView.trailingAnchor.constraint(equalTo: self.daysButtons.last!.trailingAnchor, constant: 6).isActive = true
                let form = DateFormatter()
                form.dateFormat = "dd MMM y"
                let d = form.string(from: Date())
                
                for b in self.daysButtons {
                    b.addTarget(self, action: #selector(self.dayButtonTap), for: .touchUpInside)
                    if b.titleLabel?.text == d {
                        b.backgroundColor = UIColor(red: 0, green: 131/255, blue: 249/255, alpha: 1)
                        b.setTitleColor(.white, for: .normal)
                    }
                }
            }
        }
    }
    
    @objc func dayButtonTap(sender: UIButton!) {
        for b in daysButtons {
            b.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            b.setTitleColor(.black, for: .normal)
        }
        sender.backgroundColor = UIColor(red: 0, green: 131/255, blue: 249/255, alpha: 1)
        sender.setTitleColor(.white, for: .normal)
        let form = DateFormatter()
        form.dateFormat = "dd MMM y"
        let d = form.date(from: sender.titleLabel!.text!)
        fetchMeals(for: d!)
    }
    
    func fetchMeals(for date: Date){
        let form = DateFormatter()
        form.dateFormat = "yyyyMMdd"
        let d = form.string(from: date)
        mealsDB.child(d).observeSingleEvent(of: .value) { (DataSnapshot) in
            self.populateScrollViewWithMeals(meals: DataSnapshot)
        }
    }
    
    func populateScrollViewWithMeals(meals: DataSnapshot){
        var mealList = [Meal]()
        for m in mealViews {
            m.removeFromSuperview()
        }
        mealViews = [UIView]()
        let children = meals.children
        for meal in children {
            let m = meal as! DataSnapshot
            let title = m.key
            var ings = [Ingreedient]()
            let ingreedients = m.children
            for i in ingreedients {
                let ing = i as! DataSnapshot
                
                let name = ing.childSnapshot(forPath: "name").value as! String
                let amount = ing.childSnapshot(forPath: "amount").value as! Int
                let unit = ing.childSnapshot(forPath: "unit").value as! String
                let ingr = Ingreedient(name: name, amount: amount, unit: unit)
                ings.append(ingr)
            }
            mealList.append(Meal(title: title, ingreedients: ings))
        }
        // We have complete meal list, now make UIVeiws and attach them...
        if !mealList.isEmpty {
            for i in 0...mealList.count - 1{
                let mealView = UIView()
                mealView.translatesAutoresizingMaskIntoConstraints = false
                scView.addSubview(mealView)
                mealView.leadingAnchor.constraint(equalTo: scView.leadingAnchor, constant: 6).isActive = true
                mealView.widthAnchor.constraint(equalToConstant: self.view.frame.width - 12).isActive = true
                mealView.layer.cornerRadius = 10
                mealView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
                mealView.tag = i
                mealViews.append(mealView)
            }
            self.meals = mealList
            for i in 0...mealViews.count - 1 {
                if i == 0 {
                    mealViews[i].topAnchor.constraint(equalTo: self.daysView.bottomAnchor, constant: 6).isActive = true
                    initialize(meal: mealList[i], in: mealViews[i])
                } else {
                    mealViews[i].topAnchor.constraint(equalTo: mealViews[i-1].bottomAnchor, constant: 6).isActive = true
                    initialize(meal: mealList[i], in: mealViews[i])
                }
            }
            scView.bottomAnchor.constraint(equalTo: (mealViews.last?.bottomAnchor)!, constant: 150).isActive = true
        }
    }
    
    func initialize(meal: Meal, in view: UIView) {
        let titleLab = UILabel()
        titleLab.translatesAutoresizingMaskIntoConstraints = false
        titleLab.text = meal.title
        view.addSubview(titleLab)
        titleLab.font = UIFont.systemFont(ofSize: 20.0)
        titleLab.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        titleLab.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        titleLab.numberOfLines = 0
        
        var previousLab = titleLab
        for ing in meal.ingreedients {
            let lab = UILabel()
            lab.translatesAutoresizingMaskIntoConstraints = false
            lab.text = "\(ing.name) : \(ing.amount)\(ing.unit)"
            view.addSubview(lab)
            lab.font = UIFont.systemFont(ofSize: 14.0)
            lab.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
            lab.topAnchor.constraint(equalTo: previousLab.bottomAnchor, constant: 10).isActive = true
            lab.numberOfLines = 0
            previousLab = lab
        }
        
        view.bottomAnchor.constraint(equalTo: previousLab.bottomAnchor, constant: 10).isActive = true
    }
    
}
