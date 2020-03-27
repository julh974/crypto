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

        
        
        let k = "bonjour"
        let key = "\\x0123456789abcdef"
        print("\n==============================|| Préparation de la clé ||==============================\n")
        print("PHASE 1 :\n")
        let key_bin = getKey(key: k)
        let tablePC = getTablePC1()
        let key_pi = P(key_binaire: key_bin, PC1: tablePC)
        print(key_pi,": key PC1 (",key_pi.count,")")
        //let new_key_pi = PermuInit(key_binaire: key_bin, PC: tablePC) //8 bit en trop
        //print("=======================\n",key_pi,"\n",new_key_pi)
        let CD = C0D0(pc1: key_pi)
        let C0 = CD[0]
        let D0 = CD[1]
        
        let tCs = getCs(C0: C0)
        let tDs = getDs(D0: D0)
        let PC2 = getTabPC2()
        let table_Ki = getKi(Ci: tCs, Di: tDs, PC2: PC2)
       
        
        //print("\n==============================|| Fin de la préparation de la clé ||==============================\n")
        print("\n==============================||      Préparation du texte       ||==============================\n")
        print("PHASE 2 :\n")
        
        
        let message = "secret" //si le nb est superieur à 8 -> on boucle le message
        let message_int = getAsciiInt(m: message)
        let message_bin = IntToBin(List: message_int)
        let block_bin = ajustBloc(m: message_bin)
        print("message binnaire(\(block_bin.count)) =",block_bin)
        let Y = P(key_binaire: block_bin, PC1: getTableP())
        print("Y=P(X) =",Y,"(\(Y.count))")
        let G0D0 = getG0D0(Y: Y)
        let G_0 = G0D0[0]
        let D_0 = G0D0[1]
        print("G0 : \(G0D0[0])")
        print("D0 : \(G0D0[1])")
        
        
        
        print("\n==============================||       Itération schéma de Feistel       ||==============================\n")
        print("PHASE 3 :\n")
        
        Confusion(D: D_0, K: table_Ki[0])
        
        
        
        
        
        
        
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
        print("message clair : \t",m)
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
    
    
    func IntToBin(List : [Int]) -> String{//convertie un Int en binaire (String)
        var tab : [String] = []
        var b = ""
        for i in List{
            let bin = String(i,radix: 2)
            
            for _ in bin.count..<8 {
                b.append("0")//rajoute le nombre de 0 (8bits)
            }
            //rajoute le 0 devant le nb binaire
            b.append(bin)
            tab.append(b)
            b = ""
        }
        var a = ""
        for i in tab{
            a.append(i)//converti la table en String
        }
        return a
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
            print(tab_binaire.joined(),": Key binaire (",binaire.count,")")
            return binaire
        }
        return ""//retourne vide si la clé n'est pas conforme
    }
    
    
    
    func getTablePC1() ->[Int]{ //doute sur la permutation
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
    
    //permute les indince selon le tableau entrée
    func P(key_binaire : String, PC1 : [Int]) -> String{
        var pc1 = ""
        let k = Array(key_binaire)
        for i in PC1{
            pc1.append(k[i-1])
        }
        
        return pc1
    }
    
    
    
    
    func C0D0(pc1 : String) -> [String] {
        let mid = pc1.count / 2
        var C = ""//28 1ER BITS
        var D = ""//28 DERNIER BITS
        let p = Array(pc1)
        
        for i in 0..<mid{
            C.append(p[i])
        }
        for i in mid..<pc1.count{
            D.append(p[i])
        }
        
        return [C,D]
    }
    
    func permutCircuG(T : String, ind : Int) -> String{
        let t = Array(T)
        var sto : [String] = []
        let nb = T.count //permet de gerer les débordement
        for i in 0..<ind % nb {//nb element à stocker
            sto.append(String(t[i]))
        }
        //suprime les n premier élément
        let t1 = (t.dropFirst(ind%nb))
        //ajout des element stocker
        var strSto = ""
        for i in sto{
            strSto.append(i)        }
        //convertion en chaine de caractere
        var m = ""
        for i in t1{
            m.append(i)
        }
        m.append(strSto)
        return m
    }
    
    func getCs(C0 : String) -> [String]{
        var tabOfC : [String] = [] // var contenir les 16 C (1à16)
        let C1 = permutCircuG(T: C0, ind: 1)// i = 1 Donc un decalage vers la gauche
        tabOfC.append(C1) //ajout de C1
        print("\n============* C1 à C16 *=============\n")
        print("C1 :\t \(C1)")
        //Boucle de 2 à 16
        for i in 2...16{
            if [2,9,16].contains(i){//si i est dans le tableau => decalage de 1 vers la gauche
                tabOfC.append(permutCircuG(T: tabOfC[i-2], ind: 1))
                print("C\(i) :\t \(permutCircuG(T: tabOfC[i-2], ind: 1))")
            }else{//sinon décalage de 2 vers la gauche
                tabOfC.append(permutCircuG(T: tabOfC[i-2], ind: 2))
                print("C\(i) :\t \(permutCircuG(T: tabOfC[i-2], ind: 2))")
            }
        }
        return tabOfC
    }
    
    func getDs(D0 : String) -> [String]{
           var tabOfD : [String] = [] // var contenir les 16 D (1à16)
           let D1 = permutCircuG(T: D0, ind: 1)// i = 1 Donc un decalage vers la gauche
           tabOfD.append(D1) //ajout de D1
           print("\n============* D1 à D16 *=============\n")
           print("D1 :\t \(D1)")
           //Boucle de 2 à 16
           for i in 2...16{
               if [2,9,16].contains(i){//si i est dans le tableau => decalage de 1 vers la gauche
                   tabOfD.append(permutCircuG(T: tabOfD[i-2], ind: 1))
                   print("D\(i) :\t \(permutCircuG(T: tabOfD[i-2], ind: 1))")
               }else{//sinon décalage de 2 vers la gauche
                   tabOfD.append(permutCircuG(T: tabOfD[i-2], ind: 2))
                   print("D\(i) :\t \(permutCircuG(T: tabOfD[i-2], ind: 2))")
               }
           }
           return tabOfD
       }
    
    func getTabPC2() -> [Int]{
        let t =
            [
                14,17,11,24,01,05,
                03,28,15,06,21,10,
                23,19,12,04,26,08,
                16,07,27,20,13,02,
                41,52,31,37,47,55,
                30,40,51,45,33,48,
                44,49,39,56,34,53,
                46,42,50,36,29,32
            ]
        return t
    }
    
    func getKi(Ci : [String],Di: [String], PC2 : [Int]) -> [String]{
        //nb de Ci = nb de Di
        var tK : [String] = []
        for i in 0..<Ci.count{//table de K non modifier par pc2
            tK.append(Ci[i]+Di[i])//ajout des deux moitiées
            //print("k\(i+1) = \(Ci[i]+Di[i])")
        }
        print("\n=====================* Table des Ki *====================\n")
        //Modification avec PC2
        var ki = ""
        var tab_ki : [String] = []
        for k in tK{
            let tab_K = Array(k)
            for x in PC2{
                ki.append(tab_K[x-1])//le x ème bit devient le 1er etc ...
            }
            tab_ki.append(ki)
            print("k\(tab_ki.count) =\t \(ki)")
            ki.removeAll()// ràZ pour le prochain k
        }
        return tab_ki
    }
    
    func ajustBloc(m : String) -> String{//renvoie un tableau de Blocs (64BITS)
        var block = ""
        if m.count < 64{//on gère le cas ou si le texte est représenté avec moin de 64 bit
            for _ in m.count..<64{
                block.append("0")
            }
            block.append(m)
        }
        return block
    }
    
    func getTableP() -> [Int]{
        let t = [
        58,50,42,34,26,18,10,02,
        60,52,44,36,28,20,12,04,
        62,54,46,38,30,22,14,06,
        64,56,48,40,32,24,16,08,
        57,49,41,33,25,17,09,01,
        59,51,43,35,27,19,11,03,
        61,53,47,37,29,21,13,05,
        63,55,49,39,31,23,15,07]
        
        return t
    }
    
    func getG0D0(Y: String) -> [String]{
        let mid = Y.count / 2
        let y = Array(Y)
        var G0 = ""
        var D0 = ""
        for i in 0..<mid{
            G0.append(y[i])
        }
        for i in mid..<Y.count{
            D0.append(y[i])
        }
        return [G0,D0]
    }
    
    func getTableExpansion() -> [Int]{
        let e = [
            32,1,2,3,4,5,
            4,5,6,7,8,9,
            8,9,10,11,12,13,
            12,13,14,15,16,17,
            16,17,18,19,20,21,
            20,21,22,23,24,25,
            24,25,26,27,28,28,
            28,29,30,31,32,1]
        return e
    }
    
    func XOR(a:String,b :String)->String{
        var r = ""
        let A = Array(a)
        let B = Array(b)
        for i in 0..<a.count{
            if A[i] == B[i]{
                r.append("0")
            }else{
                r.append("1")
            }
        }
        return r
    }
    
    func cut8(m : String) -> [String]{//coupe en 8 morceaux
        let n = m.count / 8
        var tab : [String] = []
        var s = ""
        let t = Array(m)
        for i in 0..<m.count{
            if i % n == n-1{
                s.append(t[i])
                tab.append(s)
                s.removeAll()
            }else{
                s.append(t[i])
            }
            
        }
        return tab
    }
    
    func Confusion(D: String, K : String){
        let tab_E = getTableExpansion()
        let D_E = P(key_binaire: D, PC1: tab_E)
        print("XOR")
        print("\(D_E)\n\(K)")
        print(XOR(a: D_E, b: K))
        let B = cut8(m: XOR(a: D_E, b: K))// Tableau de 8 morceaux de 6bits
        print(B)
        
    }
    
    func getTableS() -> Array<Array<Array<Int>>>{
        let S1 =
            [
                [14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7],
                [0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8],
                [4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0],
                [15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13]
            ]
        
        let S2 =
            [
                [15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10],
                [3,13,14,7,15,2,8,14,12,0,1,10,6,9,11,5],
                [0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15],
                [0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15]
            ]
    let S3 =
        [
            [10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8],
            [13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1],
            [13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7],
            [1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12]
        ]
        
    let S4 =
        [
            [7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15],
            [13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9],
            [10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4],
            [3,15,0,6,10,1,13,8,9,41,5,11,12,7,2,14]
        
        ]
        
    let S5 =
        [
            [2,12,4,1,7,10,11,6,8,5,3,15,0,4,9],
            [14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6],
            [4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14],
            [11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3]
        
        ]
        
    let S6 =
        [
            [12,1,10,15,9,2,6,8,8,0,13,3,4,14,7,5,11],
            [10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8],
            [9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6],
            [4,3,2,12,9,5,15,10,11,4,1,7,6,0,8,13]
        
        ]
        
    let S7 =
        [
            [4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1],
            [13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6],
            [1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2],
            [2,6,11,13,8,1,4,10,7,9,5,15,14,2,3,12]
        ]
        
    let S8 =
        [
            [13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7],
            [1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2],
            [7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8],
            [2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11]
        ]
        return [S1,S2,S3,S4,S6,S7,S8]
    }
    

}
