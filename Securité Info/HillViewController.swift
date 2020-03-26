//
//  HillViewController.swift
//  Securité Info
//
//  Created by HOARAU Julien on 22/03/2020.
//  Copyright © 2020 HOARAU Julien. All rights reserved.
//

import UIKit

class HillViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //MainCryptHill(m: "\\x0a\\x05", k: "9457")
        //print(getFirstNumber(nb: 25))
        //print(pgcd(a: 43, b: 26))
        //print(GetInverseMod(k: 43, mod: 26))
        
//        print(MainCryptHill(m: "ab", k: [3,5,6,17]))
//        print(MainDecryptHill(m: "ñ\\x93", k: [3,5,6,17]))
        print("test =  \(-12 % 256)")
        let k = [9,4,5,7]
        let c = MainCryptHill1(k: k, s: "bonjour les amis")
        //print(CanBeUseHill(k: k, modulo: 256))
       // print(GetInverseMod(k: calculKinverse(k: k), mod: 256))
        //MainCryptHill1(k: k, s: "hell")
        print(MainDecryptHill(m: c, k: k))
        
        
        
    }
     func getAsciiInt(m : String) -> [Int]{//divise le message par caractère et stocke leur valeur décimal dans un tableau
         print("\nmessage clair : ",m)
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
                     print("\t (Hex) Int : \(Int(hex, radix: 16)!)")
                     tab.append(Int(hex, radix: 16)!)
                 }
             }else{
                 tab.append(Int(UnicodeScalar(String(mess[i]))!.value))
                 print("\t Int : \(Int(UnicodeScalar(String(mess[i]))!.value))\n")
                 i += 1
             }
         }
         return tab
     }
    
    func div2(mess:[Int]) -> [Array<Int>]{ //divise le message par block de deux
        var t : [Array<Int>] = []
        let m = Array(mess)
        var i = 0
        while i < m.count {
            if i < m.count - 1{
                let x = [(m[i]),(m[i+1])]
                t.append(x)
                i += 2
            }
            if i == m.count - 1 {
                t.append([Int(m[i]),32])//on rajoute un 0 --> (NULL)  si l'élément ne forme pas une paire
                i += 1
            }
        }
        return t
    }
    
    func getAsciiChar(t : [Int]) -> [String]{//affiche les lettres affichable sinon affiche l'e-hexa décimal
         print("Valeur modifier : ",t)
         var tab : [String] = []
         for i in t {
             print(" i => ",i)
             let char = UnicodeScalar(i)!
            if Character(char).isLetter || Character(char).isNumber || Character(char).isSymbol || Character(char).isPunctuation || Character(char).asciiValue == 32{//test si les charactères sont affichables (espace compris)
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
    
    func CryptHill(k : [Int], c1 : Int, c2 : Int) -> [String] {
        let a = k[0]
        let b = k[1]
        let c = k[2]
        let d = k[3]
        //var tab : [String] = []
        
        
        let x = (a*c1 + b*c2)%256 //table ascii étendu
        let y = (c*c1 + d*c2)%256
        
        return getAsciiChar(t: [x,y])
    }

    func castKey(k : String) -> [Int]{//on part du principe que k contient 4 int
        let t = Array(k)
        var x : [Int] = []
        for i in t {
            x.append(Int(String(i))!)
        }
        return x
    }
    
    
    
    
    func pgcd(a:Int,b:Int) -> Int{//function récursive pgcd
        if b == 0 {
            return a
        }else{
            return pgcd(a: b, b: a%b)
        }
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
    
    
    func DecryptHill(k : [Int], x1 : Int, x2 : Int) -> [String] {
        let a = k[0]
        let b = k[1]
        let c = k[2]
        let d = k[3]
        //var tab : [String] = []
        
        let nb_inv = a*d - b*c
        print("Inverse(nb)  : \(nb_inv) =  \(GetInverseMod(k: nb_inv, mod: 256))")
        if GetInverseMod(k: nb_inv, mod: 256) != 0 {
            let inv = GetInverseMod(k: nb_inv, mod: 256)
            
            var a1 = (d * inv) % 256
            var b1 = (-b * inv) % 256
            var c1 = (-c * inv) % 256
            var d1 = (a * inv) % 256
            
            //operation pour rester dans les positif
            if a1 < 0 {
                a1 = (a1 + 256) % 256
            }
            if b1 < 0 {
                b1 = (b1 + 256) % 256
            }
            if c1 < 0 {
                c1 = (c1 + 256) % 256
            }
            if d1 < 0 {
                d1 = (d1 + 256) % 256
            }
            print("valeur originial = a: \(a) ,b: \(b) ,c: \(c) ,d: \(d) ")
            print("valeur modifier = a: \(a1) ,b: \(b1) ,c: \(c1) ,d: \(d1) ")
            let x = (a1*x1 + b1*x2)%256 //table ascii étendu
            let y = (c1*x1 + d1*x2)%256
            
            
            return getAsciiChar(t: [x,y])
        }
        
        
        return ["Error"]
    }
    
   
    
    func MainDecryptHill(m: String, k : [Int]) -> String{
       let mess2 = div2(mess: getAsciiInt(m: m))//transform les lettre en Int
       //let key = castKey(k: k)
       var messCrypt : [Array<String>] = []
       for c in mess2 {
           let k0 = c[0]
           let k1 = c[1]
           messCrypt.append(DecryptHill(k: k, x1: k0, x2: k1))
       }
       var s = ""
       for j in messCrypt {
           for i in j {
               s.append(i)
           }
       }
       return s
        
    }
    
    func CanBeUseHill(k :[Int], modulo : Int) -> Bool{
        let a = k[0]
        let b = k[1]
        let c = k[2]
        let d = k[3]
        
        print("nb = ", (a*d - b*c) )
        print("pgcd = ",pgcd(a: (a*d - b*c), b: modulo))
        if pgcd(a: a*d - b*c, b: modulo) == 1 {
            return true
        }else{
            return false
        }
    }
    
    func calculKinverse(k :[Int]) -> Int {
        let a = k[0]
        let b = k[1]
        let c = k[2]
        let d = k[3]
        
        return (a*d - b*c)
    }
    
    func MainCryptHill1(k : [Int], s : String) -> String{
        if CanBeUseHill(k: k, modulo: 256){
            let mess2 = div2(mess: getAsciiInt(m: s))//transform les lettre en Int
            //let key = castKey(k: k)
            var messCrypt : [Array<String>] = []
            for c in mess2 {
                let k0 = c[0]
                let k1 = c[1]
                messCrypt.append(CryptHill(k: k, c1: k0, c2: k1))
            }
            var s = ""
            for j in messCrypt {
                for i in j {
                    s.append(i)
                }
            }
            print(s)
            return s
        }else{
            print("la matrice n'est pas conforme")
            return ""
        }
    }
    
    @IBOutlet weak var TextField_Clair: UITextField!
    @IBOutlet weak var TextField_Crypté: UITextField!
    @IBOutlet weak var a: UITextField!
    @IBOutlet weak var b: UITextField!
    @IBOutlet weak var c: UITextField!
    @IBOutlet weak var d: UITextField!
    
    
    @IBAction func Btn_Crypt(_ sender: Any) {
        let ta = a.text!
        let tb = b.text!
        let tc = c.text!
        let td = d.text!
        if !ta.isEmpty && !tb.isEmpty && !tc.isEmpty && !td.isEmpty{
            TextField_Crypté.text! = MainCryptHill1(k: [Int(ta)!,Int(tb)!,Int(tc)!,Int(td)!], s: TextField_Clair.text!)
        }
        
    }
    
    @IBAction func Btn_Decrypt(_ sender: Any) {
        let ta = a.text!
        let tb = b.text!
        let tc = c.text!
        let td = d.text!
        if !ta.isEmpty && !tb.isEmpty && !tc.isEmpty && !td.isEmpty{
            TextField_Clair.text! = MainDecryptHill(m: TextField_Crypté.text!, k: [Int(ta)!,Int(tb)!,Int(tc)!,Int(td)!])
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
