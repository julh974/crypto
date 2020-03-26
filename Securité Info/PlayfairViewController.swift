//
//  PlayfairViewController.swift
//  Securité Info
//
//  Created by HOARAU Julien on 21/03/2020.
//  Copyright © 2020 HOARAU Julien. All rights reserved.
//

import UIKit

class PlayfairViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let tab = CreateTablePlayfair(k: "exemple playfair")
//        Display(t: tab)
        
    }
    

    func CreateTablePlayfair(k : String) -> [String]{
        let key = Array(k)
        let alpha = Array("abcdefghijklmnopqrstuvwxyz1234567890")
        var tab : [String] = []
        var i = 0
        while i < key.count {
            if !tab.contains(String(key[i])) && key[i] != " "{ //éliminé les espaces et les récurrences
                tab.append(String(key[i]))
            }
            i += 1
        }
        //print("tab with only key : \(tab)")
        var j = 0
        while j < alpha.count {
            if !tab.contains(String(alpha[j])) && alpha[j] != " "{ //éliminé les espaces et les récurrences
                tab.append(String(alpha[j]))
            }
            j += 1
        }
        //print("tab : \(tab)")
        return tab
    }
    
    func Display(t : [String]) -> [Array<String>]{
        var index = 0
        var tableau : Array<[String]> = []
        for _ in 0..<6{
            var tab : [String] = []
            for _ in 0..<6{
                
                tab.append(t[index])
                index += 1
            }
            tableau.append(tab)
            print(tab)
        }
        print("\n")
        return tableau
    }
    
    func getNumbers(char : String, t : [Array<String>]) -> String  {// -> renvoie le numero (ligne colonne)
        var ligne : Int = 0
        var colonne : Int = 0
        var result = ""
        for c in 0..<t.count{
            for l in 0..<t[c].count{
                if t[l][c] == char {
                    ligne = l
                    colonne = c
                    result.append(String(ligne)+String(colonne))//stock dans un les coord dans une chaine de caractère
                    
                }
            }
        }
        print("Le charactere \(char) est codé : \(result)")
        return result
    }
    
    func cryptregles(x1:Int,y1:Int,x2:Int,y2:Int, t : [Array<String>]) -> String { //retourne un couple de lettre
        var lettres : String = ""
        print("X1: \(x1), Y1: \(y1) \t X2:\(x2) Y2: \(y2)")
        
        if y1 == y2 || x1 == x2 { //Si les lettres sont sur la meme ligne ou Si les lettres sont sur la meme colonne
            if x1 == x2 {//Si les lettres sont sur la meme colonne
                lettres.append(String(t[x1][(y1+1)%6]))
                lettres.append(String(t[x2][(y2+1)%6]))
            }else{//Si les lettres sont sur la meme ligne
                lettres.append(String(t[(x1+1)%6][y1]))
                lettres.append(String(t[(x2+1)%6][y2]))
                
            }
        }else{//si les deux lettres sont sur les coin d'un rectangle
            let p = String(t[x2][y1])
            let s = String(t[x1][y2])
            print("1er : \(p) \t 2ème : \(s)")
            lettres.append(s)
            lettres.append(p)
        }
        return lettres
    }
    
    func decryptregles(x1:Int,y1:Int,x2:Int,y2:Int, t : [Array<String>]) -> String { //retourne un couple de lettre
        var lettres : String = ""
        print("X1: \(x1), Y1: \(y1) \t X2:\(x2) Y2: \(y2)")
        
        if y1 == y2 || x1 == x2 { //Si les lettres sont sur la meme ligne ou Si les lettres sont sur la meme colonne
            if x1 == x2 {//Si les lettres sont sur la meme colonne
                lettres.append(String(t[x1][(y1+5)%6]))//atteint le caractere précedent
                lettres.append(String(t[x2][(y2+5)%6]))//atteint le caractere précedent
            }else{//Si les lettres sont sur la meme ligne
                lettres.append(String(t[(x1+5)%6][y1]))//atteint le caractere précedent
                lettres.append(String(t[(x2+5)%6][y2]))//atteint le caractere précedent
                
            }
        }else{//si les deux lettres sont sur les coin d'un rectangle
            let p = String(t[x2][y1])
            let s = String(t[x1][y2])
            print("1er lettre : \(p) \t 2ème lettre : \(s)")
            lettres.append(s)
            lettres.append(p)
        }
        return lettres
    }
    
    func div2(mess:String) -> [Array<String>]{ //divise le message par block de deux
        var t : [Array<String>] = []
        let m = Array(mess)
        var i = 0
        while i < m.count {
            if i < m.count - 1{
                let x = [String(m[i]),String(m[i+1])]
                t.append(x)
                i += 2
            }
            if i == m.count - 1 {
                t.append([String(m[i]),"x"])//on rajoute un x si l'élément ne forme pas une paire
                i += 1
            }
        }
        return t
    }
    
    func MainCryptPlayfair(message : String, key : String) -> String{
        let m = div2(mess: message)//tableau de message div 2:2
        let tab:[Array<String>] = Display(t: CreateTablePlayfair(k: key))//Création du tableau
        var mc = ""
        for couple in m {
            let coord0 = Array(String(getNumbers(char: couple[0], t: tab)))
            let coord1 = Array(String(getNumbers(char: couple[1], t: tab)))
            print(coord0,coord1)
            mc.append(cryptregles(x1:  Int(String(coord0[0]))!, y1: Int(String(coord0[1]))!, x2: Int(String(coord1[0]))!, y2: Int(String(coord1[1]))!, t: tab))
        }
        return mc
    }
    
    func MainDecryptPlayfair(message : String, key : String) -> String{
        let m = div2(mess: message)//tableau de message div 2:2
        let tab:[Array<String>] = Display(t: CreateTablePlayfair(k: key))//Création du tableau
        var mc = ""
        for couple in m {
            let coord0 = Array(String(getNumbers(char: couple[0], t: tab)))
            let coord1 = Array(String(getNumbers(char: couple[1], t: tab)))
            print(coord0,coord1)
            mc.append(decryptregles(x1:  Int(String(coord0[0]))!, y1: Int(String(coord0[1]))!, x2: Int(String(coord1[0]))!, y2: Int(String(coord1[1]))!, t: tab))
        }
        return mc
    }
    
    @IBOutlet weak var TexteField_Clair: UITextField!
    @IBOutlet weak var TexteField_Crypt: UITextField!
    @IBOutlet weak var TexteField_key: UITextField!
    
    @IBAction func Btn_Crypt(_ sender: UIButton) {
        TexteField_Crypt.text! = MainCryptPlayfair(message: TexteField_Clair.text!, key: TexteField_key.text!)
    }
    
    @IBAction func Btn_Decrypt(_ sender: UIButton) {
        TexteField_Clair.text! = MainDecryptPlayfair(message: TexteField_Crypt.text!, key: TexteField_key.text!)
    }
    
    
    
}
