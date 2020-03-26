//
//  AtbashViewController.swift
//  Securité Info
//
//  Created by HOARAU Julien on 18/03/2020.
//  Copyright © 2020 HOARAU Julien. All rights reserved.
//

import UIKit
import Foundation

class AtbashViewController: UIViewController {

    @IBOutlet weak var TextField_Clair: UITextField!
    @IBOutlet weak var TextField_Crypt: UITextField!
   
    
    @IBAction func BCrypt(_ sender: UIButton) {
        TextField_Crypt.text = ""
        TextField_Crypt.text = algoAtbash(message: TextField_Clair.text!)
        
        
    }
    
    @IBAction func Bdecrypt(_ sender: UIButton) {
        TextField_Clair.text = ""
        TextField_Clair.text = algoAtbash(message: TextField_Crypt.text!)
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
                tab.append(Int(UnicodeScalar(String(mess[i]))!.value))
                i += 1
            }
        }
        return tab
    }

           
    func atbash(t : [Int]) -> [Int]{//modifie les valeur ascii (atbash)
        print("Valeur Ascii du message : ",t)
        var tab : [Int] = []
        for i in t {
            let x = 256 - 1 - i //func atbash : f(x) = taille du tableau - 1 - index
            tab.append(x)
        }
        return tab
    }
           
    func getAsciiChar(t : [Int]) -> [String]{//affiche les lettres affichable sinon affiche l'e-hexa décimal
        print("Valeur modifier par Atbash : ",t)
        var tab : [String] = []
        for i in t {
            print(" i => ",i)
            let char = UnicodeScalar(i)!
            if Character(char).isLetter || Character(char).isNumber || Character(char).isSymbol || Character(char).isPunctuation {//test si les charactères sont affichables
                tab.append(String(Character(char)))
            }else{
                print("i  cast to Hex :",String(format: "%02X", i))//cast i en Hex
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
           
    
    //code et décode le message pour atbash
    func algoAtbash(message : String) -> String{//utilise l'ensemble des fonctions ci-dessus
       return concat(t: getAsciiChar(t: atbash(t: getAsciiInt(m: message))))
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("===============================")
        let he = "hélo"
        let h = Array(he)
        var i : Int = 0
        while i < h.count {
            
            print(" i = ",UnicodeScalar(String(h[i]))!.value)
            i += 1
        }
    
        
    }
}
