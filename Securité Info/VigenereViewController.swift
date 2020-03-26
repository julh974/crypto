//
//  VigenereViewController.swift
//  Securité Info
//
//  Created by HOARAU Julien on 20/03/2020.
//  Copyright © 2020 HOARAU Julien. All rights reserved.
//

import UIKit

class VigenereViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    func repeatKey(m : String, k : String) -> String{//repète les char de la clé afin d'avoir le meme nombre d'element que celle du message
        var rk : String = k //clé qui va etre répété
        if m.count > k.count{
            let tm = Array(m)
            let tk = Array(k)
            var i = tk.count
            while i < tm.count {
                rk.append(tk[i % tk.count])
                i += 1
            }
            
        }
        return rk
    }
    
    func getAsciiInt(m : String) -> [Int]{//divise le message par caractère et stocke leur valeur décimal dans un tableau
        var tab : [Int] = []
        let mess = Array(m)
        var i = 0
        while i <= (mess.count - 1){
            if mess[i] == "\\" && i < mess.count - 1 {//permet de detecter l'hexadécimal dans le texte de la forme \x00
                if mess[i+1] == "x" {
                    var hex : String = ""
                    i += 2 //on saute le \x
                    var j = 0
                    while j != 2 {
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
    
    func CryptVigenere(m : [Int], k : [Int]) -> [Int]{//les deux tableaux ont la meme taille
    
        var tab : [Int] = []
        for i in 0..<k.count {
            
            let x = (m[i] + k[i]) % 256 //Taille de la table ascii étendu
            //print("Décalage : abs(",m[i]," - ",k[i],") % 256 = ",abs(m[i] - k[i]))
            tab.append(x)
        }
        return tab
    }
    
    
    func DecryptVigenere(m : [Int], k : [Int]) -> [Int]{//les deux tableaux ont la meme taille
        var tab : [Int] = []
        for i in 0..<k.count {
            let x = (m[i] - k[i]) % 256
            tab.append(abs(x))
        }
        return tab
    }
    
    func MainCryptVigenere(message : String, key : String) -> String{//Crypte le message
        print("===VIGENERE===")
        print("Message Claire : ",message)
        print("Clé : ",key)
        return concat(t: getAsciiChar(t: CryptVigenere(m: getAsciiInt(m: message), k: getAsciiInt(m: repeatKey(m: message, k:  key)))))
    }
    
    func MainDecryptVigenere(message : String, key : String) -> String{//decrypte le message
        print("===VIGENERE===")
        print("Message Cripté : ",message)
        print("Clé : ",key)
        return concat(t: getAsciiChar(t: DecryptVigenere(m: getAsciiInt(m: message), k: getAsciiInt(m: repeatKey(m: message, k:  key)))))
    }
    
    @IBOutlet weak var TextField_Claire: UITextField!
    @IBOutlet weak var TextField_Crypt: UITextField!
    @IBOutlet weak var TextField_Cle: UITextField!
    

    @IBAction func Btn_Crypt(_ sender: UIButton) {
        if !TextField_Cle.text!.isEmpty && !TextField_Claire.text!.isEmpty{
            TextField_Crypt.text! = MainCryptVigenere(message: TextField_Claire.text!, key: TextField_Cle.text!)
        }
    }
    
    @IBAction func Btn_Decrypt(_ sender: UIButton) {
        if !TextField_Cle.text!.isEmpty && !TextField_Crypt.text!.isEmpty {
            TextField_Claire.text! = MainDecryptVigenere(message: TextField_Crypt.text!, key: TextField_Cle.text!)
        }
    }
    
}
