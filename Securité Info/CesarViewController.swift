//
//  CesarViewController.swift
//  Securité Info
//
//  Created by HOARAU Julien on 20/03/2020.
//  Copyright © 2020 HOARAU Julien. All rights reserved.
//

import UIKit

class CesarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(mainCrypCesar(m: "abc", c: 1))
        print(mainDecryptCesar(m: "bcd", c: 1))
    }
    

    func getAsciiInt(m : String) -> [Int]{//divise le message par caractère et stocke leur valeur décimal dans un tableau
        print("message clair : ",m)
        var tab : [Int] = []
        let mess = Array(m)
        var i = 0
        while i <= (mess.count - 1){
            if mess[i] == "\\" && i < mess.count - 1 {//permet de detecter l'hexadécimal dans le texte de la forme \x00
                if mess[i+1] == "x" {
                    print("Détection de l'Hexa")
                    var hex : String = ""
                    i += 2 //on saute le \x
                    var j = 0
                    while j != 2 {
                        print("lettre hexa : ",mess[i])
                        hex.append(mess[i])
                        i += 1
                        j += 1 //compteur pour l'hexadécimal
                    }
                    tab.append(Int(hex, radix: 16)!)
                }
            }else{
                tab.append(Int(UnicodeScalar(String(mess[i]))!.value))//ajoute la valeur ascii au tableau (les non ascii sont aussi traités)
                i += 1
            }
        }
        return tab
    }
    
    func getAsciiChar(t : [Int]) -> [String]{//affiche les lettres affichable sinon affiche l'e-hexa décimal
         print("Valeur modifier : ",t)
         var tab : [String] = []
         for i in t {
             let char = UnicodeScalar(i)!
             if Character(char).isLetter || Character(char).isNumber || Character(char).isSymbol || Character(char).isPunctuation {//test si les charactères sont affichables
                 tab.append(String(Character(char)))
             }else{
                 print("i(",i,")  cast to Hex :",String(format: "%02X", i))//cast i en Hex
                 let hex : String = "\\x" + String(format: "%02X", i)//on rajoute \x devant Hex
                 tab.append(hex)
            }
        }
        return tab
    }
    
    func concat(t: [String]) -> String{ //concat les elements du tableau en Chaine de caractères
        var mess = ""
        for i in t{
            mess += i
        }
        print("message cryptée : ",mess)
        return mess
    }
    
    func CrypCesar(cle : Int, t: [Int]) -> [Int]{
        var tab : [Int] = []
        let modulo = 256
        for i in t {
            tab.append((i+cle)%modulo)
        }
        return tab
    }
    
    func DecrypCesar(cle : Int, t: [Int]) -> [Int]{
        var tab : [Int] = []
        let modulo = 256
        for i in t {
            tab.append((i-cle)%modulo)
        }
        return tab
    }
    
    func mainCrypCesar(m : String, c : Int) -> String{
        return concat(t: getAsciiChar(t: CrypCesar(cle: c, t: getAsciiInt(m: m))))
    }
    
    func mainDecryptCesar(m : String, c : Int) -> String{
        return concat(t: getAsciiChar(t: DecrypCesar(cle: c, t: getAsciiInt(m: m))))
    }
    

    @IBOutlet weak var TextField_Claire: UITextField!
    @IBOutlet weak var TextField_Crypt: UITextField!
    @IBOutlet weak var TextField_Cle: UITextField!
    @IBAction func Btn_Crypt(_ sender: UIButton) {
        if TextField_Cle.text!.isEmpty{
            TextField_Cle.text! = "0"
        }
        if Character(TextField_Cle.text!).isNumber {
            TextField_Crypt.text = mainCrypCesar(m: TextField_Claire.text!, c: Int(TextField_Cle.text!)!)
        }
        
        
    }
    @IBAction func Btn_Decrypt(_ sender: UIButton) {
        if TextField_Cle.text!.isEmpty{
            TextField_Cle.text! = "0"
        }
        if Character(TextField_Cle.text!).isNumber {
            TextField_Claire.text = mainDecryptCesar(m: TextField_Crypt.text!, c: Int(TextField_Cle.text!)!)
        }
    }
}
