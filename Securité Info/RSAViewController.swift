//
//  RSAViewController.swift
//  Securité Info
//
//  Created by HOARAU Julien on 30/03/2020.
//  Copyright © 2020 HOARAU Julien. All rights reserved.
//

import UIKit

class RSAViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
//        let message = "Bonjour les amis"
//
//        let x = mainCryptRSA(m: message, p: 47, q: 71, e: 79)
//        mainDecryptRSA(m: x, p: 47, q: 71, e: 79)
        //detecZ(m: ["001245","3020","000"])
        //addZero(z: ["00","","00"], n: [1245,3020,0])
        setupTextField()
        
        
    }
    
    func addZero(z:[String],n:[Int])->[String]{
        var tab : [String] = []
        for i in 0..<z.count{
            if !z[i].isEmpty{
                tab.append(z[i]+String(n[i]))
            }else{
                tab.append(String(n[i]))
            }
        }
        //print(tab)
        return tab
    }
    
    func detecZ(m:[String])-> [String]{
        var num = ""
        var tab : [String] = []
        for i in m {
           let t = Array(String(i))
            if t[0] == "0"{//si le premier élément est égale 0 alors on le sauvegarde
                var indice = 0
                while indice < t.count  {
                    if t[indice] == "0" && indice != t.count-1{//evite la duplication d'un zero si c'est que de 0
                        num.append("0")//ajout le nb de 0 qu'on detect dans le nombre
                    }
                    indice += 1
                }
                tab.append(num)//ajoutes les 0 dans le tableau
                num.removeAll()//RàZ
            }else{
                tab.append("")//on ajoute un élément vide pour conserver le rang pour identifier le nombre dans la table
            }
        }
        //print("table de 0 = \(tab)")
        return tab
    }
    
    
    func mainDecryptRSA(m:String,p:Int,q:Int,e:Int)->String{
        print("\n** Décrypter **\n")
        
        let phi = get_phi_N(p: p, q: q)
        let n = get_n(p: p, q: q)
        let d = GetInverseMod(k: e, mod: phi)
        if pgcd(a: e, b: phi) == 1{
            print("e est validé\n")
            print("\t clé publique : (\(e),\(n))")
            print("\t clé privé    : (\(d),\(n))\n")
        }else{
            print("e n'est pas validé")
        }
        
        let tab_crypt = split_crypt(mc: m )
        let Tabz = detecZ(m: tab_crypt)
        var tab_decrypter : [Int] = []
        for i in tab_crypt{
           tab_decrypter.append(decrypter(m: Int(i)!, d: d, n: n))
        }
        let tab_decrypt_bon = addZero(z: Tabz, n: tab_decrypter)
        print("tableau decrypter =>",tab_decrypt_bon)
        //on concat le tableau de décrypté en block inferieur à 255 (table ascii) et on suite on affiche les symboles lié au entier
        print(concat(t: getAsciiChar(t: selectNumber(m: concat(t: tab_decrypt_bon), x: 255))))
        //return concat(t: getAsciiChar(t: selectNumber(m: concatNumber(t: tab_decrypter), x: 255)))
        
        return concat(t: getAsciiChar(t: selectNumber(m: concat(t: tab_decrypt_bon), x: 255)))
    }
    
    func mainCryptRSA(m:String,p:Int,q:Int,e:Int)->String{
        print("\n** Crypter **\n")
        let phi = get_phi_N(p: p, q: q)
        let n = get_n(p: p, q: q)
        let d = GetInverseMod(k: e, mod: phi)
        if pgcd(a: e, b: phi) == 1{
            print("e est validé\n")
        }else{
            print("e n'est pas validé")
        }
        print("\t clé publique : (\(e),\(n))")
        print("\t clé privé    : (\(d),\(n))\n")
        
        let tab_char = prepaMessage(m: m)
        let tab = selectNumber(m: tab_char, x: n)
        //crypter
        //print(tab_char,"\n",tab)
        let tabZ = detecZ(m: tab)
        var tab_crypt : [Int] = []
        for i in tab{
            tab_crypt.append(crypter(m: Int(i)!, e: e, n: n))//tableau crypter
        }
        let tab_bon = addZero(z: tabZ, n: tab_crypt)
        //ajout de la fonction 0
        print("tableau crypter =>",tab_bon)
        print("message cyrpter = \(concat_crypt(t: tab_bon))\n")
        return concat_crypt(t: tab_bon)
        
    }
    
    
    
    func concat_crypt(t:[String])->String{
        var mess = ""
        for i in t{
            mess.append(i)
            mess.append(" ")
        }
        return mess
    }
    
    func split_crypt(mc : String)->[String]{
        let m = Array(mc)
        var number = ""
        var tab : [String] = []
        for i in m{
            if i == " "{
                if !number.isEmpty{
                    tab.append(number)
                    number.removeAll()
                }
            }else{
                number.append(i)
            }
        }
        if !number.isEmpty{
            tab.append(number)
        }
        return tab
    }
    
    func selectNumber(m: String, x:Int)-> [String]{//divise la chaine pour avoir un un bloc Int < n
        //var number = ""
        var tab : [String] = []
        var ms = m
        var s = m //var temp
        //print(m)
        while ms.count > 0{
            if Double(s)! < Double(x) {
                tab.append(s)//ajout de s dans le tableau
                ms = String(ms.dropFirst(s.count))//màj
                s = ms
            }else{
                s = String(s.dropLast(1))//on décrémente d'une lettre
            }
        }
        return tab
    }
    
    func prepaMessage(m:String)->String{
        return concatNumber(t: getAsciiInt(m: m))
    }
    
    func concatNumber(t:[Int])->String{
        var c = ""
        for i in t{
            c.append(String(i))
        }
        return c
    }
    
    func getAsciiInt(m : String) -> [Int]{//divise le message par caractère et stocke leur valeur entiere dans un tableau
        print("message clair : ",m)
        var tab : [Int] = []
        let mess = Array(m)
        var i = 0
        while i <= (mess.count - 1){
            if mess[i] == "\\" && i < mess.count - 1 {//permet de detecter l'hexadécimal dans le texte de la forme \x00
                if mess[i+1] == "x" {
                    //print("Détection de l'Hexa")
                    var hex : String = ""
                    i += 2 //on saute le \x
                    var j = 0
                    while j != 2 {
                        //print("lettre hexa : ",mess[i])
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
    
    func getAsciiChar(t : [String]) -> [String]{//affiche les lettres affichable sinon affiche l'e-hexa décimal
         //print("Valeur modifier par Atbash : ",t)
         var tab : [String] = []
         for i in t {
             //print(" i => ",i)
             let char = UnicodeScalar(Int(i)!)!
            if Character(char).isLetter || Character(char).isNumber || Character(char).isSymbol || Character(char).isPunctuation || Character(char) == " " {//test si les charactères sont affichables
                 tab.append(String(Character(char)))
             }else{
                 //print("i  cast to Hex :",String(format: "%02X", i))//cast i en Hex
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
        //print("message cryptée : ",mess)
        return mess
    }
    
    
    func expmod(a:Int,y:Int,n:Int)->Int{//func recursive qui calcule l'exposant modulaire
        if y % 2 == 0{
            return expmod(a: ((a*a)%n), y: Int(y/2), n: n) % n
        }
        else{
            if y != 1 {
                return (a%n)*expmod(a: ((a*a)%n), y: Int((y-1)/2), n: n) % n
            }else{
                return a%n
            }
        }
    }
    


    func crypter(m : Int,e: Int, n: Int)->Int{
        //print("Crypter : \(m)^\(e) % \(n) = \(expmod(a: m, y: e, n: n))")
        return expmod(a: m, y: e, n: n)
    }
    
    func decrypter(m: Int,d: Int,n: Int)->Int{
        //print("Décrypter : \(m)^\(d) % \(n) = \(expmod(a: m, y: d, n: n)))")
        return expmod(a: m, y: d, n: n)
    }
    
    
    func pgcd(a:Int,b:Int) -> Int{//function récursive pgcd
        if b == 0 {
            return a
        }else{
            return pgcd(a: b, b: a%b)
        }
    }
    
    
    func get_phi_N(p:Int,q:Int) -> Int{
        return (p-1)*(q-1)
    }
    
    func get_n(p:Int,q:Int)->Int{
        return p*q
    }
    
    
    func GetInverseMod(k:Int, mod : Int) -> Int{//calcul l'inverse k (mod n)
        var n = mod
        var b = k
        var t0 = 0
        var t = 1
        var q = Int(n/b)
        var r = n - (q * b)
        while r > 0 {
            var temp = t0 - (t * q)
            if temp >= 0 {
                temp = temp % mod
            }else{
                temp = mod - ((-temp) % mod)
            }
            t0 = t
            t = temp
            n = b
            b = r
            q = Int(n/b)
            r = n - (q * b)
        }
        if b == 1 {
            return t
        }else{
            return 0
        }
    }
    
    
    @IBOutlet weak var TextField_Claire: UITextField!
    @IBOutlet weak var TextField_Crypt: UITextField!
    
    @IBOutlet weak var TextField_P: UITextField!
    @IBOutlet weak var TextField_Q: UITextField!
    @IBOutlet weak var TextField_E: UITextField!

    @IBOutlet weak var Label_error: UILabel!
    
    
    @IBAction func crypt(_ sender: UIButton) {
        //on regarde si tous les champs sont remplis
        if !TextField_Claire.text!.isEmpty && !TextField_P.text!.isEmpty && !TextField_Q.text!.isEmpty && !TextField_E.text!.isEmpty{
            if pgcd(a: Int(TextField_E.text!)!, b: get_phi_N(p: Int(TextField_P.text!)!, q: Int(TextField_Q.text!)!)) == 1{
                TextField_Crypt.text! = mainCryptRSA(m: TextField_Claire.text!, p: Int(TextField_P.text!)!, q: Int(TextField_Q.text!)!, e: Int(TextField_E.text!)!)
                Label_error.text! = ""
            }else{
                Label_error.text! = "E non conforme"
            }
        }else{
            Label_error.text! = "Remplissez tout les champs svp"
        }
    }
    
    @IBAction func decrypt(_ sender: UIButton) {
        if !TextField_Crypt.text!.isEmpty && !TextField_P.text!.isEmpty && !TextField_Q.text!.isEmpty && !TextField_E.text!.isEmpty{
            if pgcd(a: Int(TextField_E.text!)!, b: get_phi_N(p: Int(TextField_P.text!)!, q: Int(TextField_Q.text!)!)) == 1{
                TextField_Claire.text! = mainDecryptRSA(m: TextField_Crypt.text!, p: Int(TextField_P.text!)!, q: Int(TextField_Q.text!)!, e: Int(TextField_E.text!)!)
                Label_error.text! = ""
            }else{
                Label_error.text! = "E non conforme"
            }
        }else{
            Label_error.text! = "Remplissez tout les champs svp"
        }
    }
    
    func setupTextField(){
     
        TextField_Claire.delegate = self
        TextField_Crypt.delegate = self
        TextField_P.delegate = self
        TextField_Q.delegate = self
        TextField_E.delegate = self
        
        
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
    view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyBoard(){
        TextField_Claire.resignFirstResponder()
        TextField_Crypt.resignFirstResponder()
        TextField_Q.resignFirstResponder()
        TextField_P.resignFirstResponder()
        TextField_E.resignFirstResponder()
    }
    
}
extension RSAViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
