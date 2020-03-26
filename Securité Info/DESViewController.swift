//
//  DESViewController.swift
//  Securité Info
//
//  Created by HOARAU Julien on 26/03/2020.
//  Copyright © 2020 HOARAU Julien. All rights reserved.
//

import UIKit

class DESViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //let message = "ok"
        
//        let num_dec = getAsciiInt(m: message)// -> [int]
//        let num_binaire = castBin(List: num_dec)// -> [Int]
//        let num_bin_ajust = AjustBin(t: num_binaire)
//        let block = Adaptbloc(t: num_bin_ajust)
//        //print(block)
//        //print(divis2(t: block))
        
//        let key = "12345678"
//        let key_num = getAsciiInt(m: key)
//        let key_bin = IntToBin(List: key_num)
//        //print(key_bin)
//        let k = "100100011010001010110011110001001101010111100110111101111"
//        print(k.count)
        let k = "bonjour"
        let key = "\\x0123456789abcdef"
        let key_bin = getKey(key: k)
        let tablePC = getTablePC1()
        PI(key_binaire: key_bin, PC1: tablePC)
    }
    
    
    
    //functions Data Encryption Standard
    /*
        64 bits -> (56 bits utilisé pour crypter et 8 bits de controle)
     
        Repose sur un schéma de Feistel
        
        Clé:
            - calcul 16 sous clé de 48 bits chacune
            - chaque block de 64 Bit subit les traitement suivants :
                * Permutation Initial
                * Itération : applique 16 fois le schema de Feistel; n-ième tour: fct confusion-diffusion
                * Permutation finale
     
     
     */
    
    //function prenant que deux symbole max pour convertir un hex en Int
    func getAsciiInt(m : String) -> [Int]{//divise le message par caractère et stocke leur valeur décimal dans un tableau
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
    
    
    func IntToBin(List : [Int]) -> [String]{//convertie un Int en binaire (String)
        var tab : [String] = []
        for i in List{
            tab.append(String(i,radix: 2))
        }
        return tab
    }
    
    func getKey(key: String) -> String{
        if key.count > 8 {//on gere le cas si l'hexadécimal represente un nombre et non une lettre
            let k = Array(key)
            var hex = "" //variable qui va contenir l'hexa
            for i in 2..<k.count{//on saute "\" et le "x"
                hex.append(k[i])
            }
            let bin : String = String(Int(hex, radix: 16)!, radix: 2)//converti hexa en binaire (String)
            if bin.count <= 64 {//on accepte s'il y a 64 bit ou moin
                //print("Hexa accepté")
                //print(bin," : ",bin.count)
                
                //ajustement à 64
                var binaire = ""
                for _ in bin.count..<64{
                    binaire.append("0")
                }
                binaire.append(bin)
                //print(binaire," : ",binaire.count)
                
               
                return binaire
            }
        }else{//Gestion du cas ou ce sont des lettre
            
            let decimal : [Int] = getAsciiInt(m: key)
            var bin : [String] = []
            for i in decimal{
                bin.append(String(i, radix: 2))//converti Int en binaire
            }
            
            //ajuste le nombre de bit
            var tab_binaire : [String] = []
            var b = ""
            //rajoute les paquets de 8 bit manquant
            for _ in bin.count..<8{
                tab_binaire.append("00000000")
            }
            
            for t in bin{//rajoute les 0 manquant pour faire des blocs de 8 bit
                for _ in t.count..<8{
                    b.append("0")
                }
                b.append(t)
                tab_binaire.append(b)
                b.removeAll()
            }
            let binaire = tab_binaire.joined()
            print(tab_binaire.joined(),": ",binaire.count)
            return binaire
        }
        return ""//retourne vide si la clé n'est pas conforme
    }
    
    func getTablePC1() ->[Int]{
        let tab = [57,49,41,33,25,17, 9,
                    1,58,50,42,34,26,18,
                   10, 2,59,51,43,35,27,
                   19,11, 3,60,52,44,36,
                   63,55,47,39,31,23,15,
                    7,62,54,46,38,30,22,
                   14, 6,61,53,45,37,29,
                   21,13, 5,28,20,12, 4]
        return tab
    }
    
    func PI(key_binaire : String, PC1 : [Int]){
        var pc1 = ""
        let k = Array(key_binaire)
        for i in PC1{
            pc1.append(k[i])
        }
        print("pc1 : ",pc1,": ",pc1.count)
    }
    
    
    
    
    

}
