//
//  PolybeViewController.swift
//  Securité Info
//
//  Created by HOARAU Julien on 21/03/2020.
//  Copyright © 2020 HOARAU Julien. All rights reserved.
//

import UIKit

class PolybeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
//        print(CryptPolybe(message: "bonjour"))
//        print(DecryptPolyb(messageC: "12333224334336"))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //Le carré polybe aura 6*6 case afin d'avoir chaque lettre dans une case (26) et on pourra stocker par la suite les chiffre(10 : 1 à 6)
    func CreateSquarePolybe() -> [Array<String>] {//Créer le tableau Polye de 36 charactère de a à 0
        let alpha = "abcdefghijklmnopqrstuvwxyz1234567890"
        //print(alpha.count)
        let tab = Array(alpha)
        var t : [Array<String>] = []
        var index = 0
        for _ in 0...5{
            var x : [String] = []
            for _ in 0...5{
                x.append(String(tab[index]))
                index += 1
            }
            t.append(x)
        }
        //print(t)
        return t
    }
    
    func getNumbers(char : String, t : [Array<String>]) -> String  {//lecture ligne-Colonne
      
        var ligne : Int = 0
        var colonne : Int = 0
        var result = ""
        for c in 0..<t.count{
            for l in 0..<t[c].count{
                if t[l][c] == char {
                    ligne = l
                    colonne = c
                    result.append(String(ligne+1)+String(colonne+1))
                }
            }
        }
        print("Le charactere \(char) est codé : \(result)")
        return result
    }
    
    func getPair(messagecrypt : String) -> Array<(Int,Int)>{//assemble le message crypté en paire
        var i = 0
        let s  = Array(messagecrypt)
        print("get pair list => \(messagecrypt)")
        var tab : Array<(Int,Int)> = []
        while i < s.count - 1 {
            let x = Int(String(s[i]))
            let y = Int(String(s[i+1]))
            tab.append((x!,y!))
            
            i += 2
        }
        return tab
    }
    
    func getLetter(x : Int, y : Int, t: [Array<String>]) -> String{//Donne la lettre au coord x et y
        let letter = t[x-1][y-1]//le tableau commence de 1à6 | on lit ici la ligne puis la colone comme dans getNubers
        print("letter decode de (\(x),\(y)) : ",letter)
        return letter
    }
   
    func CryptPolybe(message : String) -> String{//Crypte le message
        let tab = CreateSquarePolybe()
        var crypt = ""
        for i in message {
            crypt.append(getNumbers(char: String(i), t: tab))//retourne les couples en string
        }
        return crypt
    }
    
    func DecryptPolyb(messageC : String) -> String{//décrypte le message
        let tab = CreateSquarePolybe()
        var mess = ""
        let num = getPair(messagecrypt: messageC)
        print("num => \(num)")
        for couple in num {
            mess.append(getLetter(x: couple.0, y: couple.1, t: tab))
        }
        return mess
    }
    @IBOutlet weak var TextField_Claire: UITextField!
    
    @IBOutlet weak var TextField_Crypt: UITextField!
    
    @IBAction func Btn_Crypt(_ sender: UIButton) {
        if !TextField_Claire.text!.isEmpty{
            TextField_Crypt.text! = CryptPolybe(message: TextField_Claire.text!)
        }
    }
    
    @IBAction func Btn_Decrypt(_ sender: UIButton) {
        if !TextField_Crypt.text!.isEmpty && TextField_Crypt.text!.count % 2 == 0{ //lance la fonction si le message crypté est non vide et conforme
            TextField_Claire.text! = DecryptPolyb(messageC: TextField_Crypt.text!)
        }
    }
    
    
    

}
