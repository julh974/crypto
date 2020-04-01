//
//  TranspositonRectViewController.swift
//  Securité Info
//
//  Created by HOARAU Julien on 24/03/2020.
//  Copyright © 2020 HOARAU Julien. All rights reserved.
//

import UIKit

class TranspositonRectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTextField()
        
    }
    
    
    func createTable(message: String, key : String) -> [Array<String>]{
        var tab : [Array<String>] = []
        var messageInTable : [String] = []
        let k = Array(key)
        let m = Array(message)
        
        //on concatène la clé et le message tout en supprimant les espaces
        for i in 0..<key.count{
            //if k[i] != " "{
                messageInTable.append(String(k[i]))
            //}
        }
        for i in 0..<m.count{
            //if m[i] != " "{
                messageInTable.append(String(m[i]))
            //}
        }
        
        for _ in 0..<(key.count - (message.count % key.count)){
            messageInTable.append(" ") //on rajoute des espace pour completer le tableau
        }
        
        //========================
        var t : [String] = []
        for i in 0..<messageInTable.count{//ordorne les characteres dans les bonnes case du tableau
            //print(messageInTable[i]," => ",i%3)
            if i % key.count == key.count - 1 {
                t.append(messageInTable[i])
                tab.append(t)
                t = []
            }else{
                t.append(messageInTable[i])
            }
        }
        //print(tab)
        return tab
    }
   
    
    
    func getCol(tab : [Array<String>], c : Int) -> [String]{//donne la colonne
        var t : [String] = []
        for i in 0..<tab.count{
            t.append((tab[i][c]))
        }
        return t
    }
    
    func display(tab : [Array<Any>]) {
        for i in tab{
            print(i)
        }
    }
    
    func castKeyToInt(key : String) -> [Int]{
        
        var t : [Int] = []
        for i in key{
            t.append(Int(UnicodeScalar(String(i))!.value))
        }
        //print(t)
        return t
    }
        
    func tri(tab : [Int]) -> [Int]{
        var t = tab
        var x : [Int] = []
        var min = 256 //valeur max + 1
        while x.count < tab.count {
            min = 256
            for i in t{
                //print("min : ",min," i :",i)
                if min > i{
                    min = i
                }
            }
            //print("ajout de :",min)
            x.append(min)
            let index = t.firstIndex(of: min)//donne l'index de min dans la list
            t.remove(at: index!)
        }
        print("liste trié",x)
        return x
        //min a la valeur la plus petite
    }
    
    func getAsciiChar(t : [Int]) -> [String]{//affiche les lettres affichable sinon affiche l'e-hexa décimal
         //print("Valeur modifier : ",t)
         var tab : [String] = []
         for i in t {
             //print(" i => ",i)
             let char = UnicodeScalar(i)!
             if Character(char).isLetter || Character(char).isNumber || Character(char).isSymbol || Character(char).isPunctuation {//test si les charactères sont affichables
                 tab.append(String(Character(char)))
             }else{
                 //print("i  cast to Hex :",String(format: "%02X", i))//cast i en Hex
                 let hex : String = "\\x" + String(format: "%02X", i)//on rajoute \x devant Hex
                 tab.append(hex)
            }
        }
        return tab
    }
    
    func crypt(message : String, key : String) -> String {
        let table1 = createTable(message: message, key: key)//création de la table
        var table = table1
        var keyTable = table[0]
        let tab_tri = tri(tab: castKeyToInt(key: key))//table trié selonn les index
        var m : [Array<String>] = []
        for i in tab_tri{
            
            
            let letter = getAsciiChar(t: [i])//donne la lettre au quelle elle appartient
            let ind = keyTable.firstIndex(of: String(letter[0]))!
            m.append(getCol(tab: table, c: ind))// -> ajoute une colonne dans m
            
            print("lettre ajouté : ",letter[0])
           
            //on supprime la colonne pour eviter les occurences
            for x in 0..<table1.count{
                print("supp : ",table[x][ind])
                table[x].remove(at: ind)
            }
            keyTable = table[0]// màj de la clé
            
            
        }
        //print(m)
        
        //return m
        var mc = ""
        for block in m{
            for l in block{
                mc.append(l)
            }
        }
        return mc
    }
    
    
    
    func decrypt(mc : String, key : String) -> String {
        let division = mc.count / key.count
        //print(mc.count, mc)
        
        let m = Array(mc)
        var i = 0
        var tab : [Array<String>] = []
        var t : [String]
        while i < mc.count{
            t = []
            for j in 0..<division{
                t.append(String(m[i]))
                i += 1
            }
            tab.append(t)
        }
        
        //on met les valeur dans l'ordre selon la clé
        var to = tab
        var x = 0
        let k = Array(key)
        var tab_final : [Array<String>] = []
        while x < key.count {
            for j in to{
                if j[0] == String(k[x]){
                    print(j)
                    tab_final.append(j)
                    to.remove(at: to.firstIndex(of: j)!)//évite les occurences
                    x += 1
                }
            }
        }
        var message_decrypt : [String] = []
        for i in 0..<tab_final[0].count{
            for j in 0..<tab_final.count{
                //print(tab_final[j][i])
                message_decrypt.append(tab_final[j][i])
            }
        }
        var m1 = ""//elimine la clé
        for i in key.count..<message_decrypt.count{
            m1.append(message_decrypt[i])
        }
        
        print(m1)//faire une fonction qui supprime le sur plus d'espace
        return m1
        
        
    }
    
    @IBOutlet weak var TextField_Clair: UITextField!
    
    @IBOutlet weak var TexteField_crypt: UITextField!
    
    @IBOutlet weak var TextField_key: UITextField!
    
    @IBAction func Btn_crypter(_ sender: Any) {
        TexteField_crypt.text! = crypt(message: TextField_Clair.text!, key: TextField_key.text!)
    }
    
    @IBAction func Btn_Decrypter(_ sender: Any) {
        TextField_Clair.text! = decrypt(mc: TexteField_crypt.text!, key: TextField_key.text!)
    }
    
    func setupTextField(){
        
        TextField_Clair.delegate = self
        TexteField_crypt.delegate = self
        TextField_key.delegate = self
           
       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
       view.addGestureRecognizer(tapGesture)
       }
       
       @objc private func hideKeyBoard(){
           TextField_Clair.resignFirstResponder()
           TexteField_crypt.resignFirstResponder()
        TextField_key.resignFirstResponder()
       }
    
       
}


extension TranspositonRectViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
