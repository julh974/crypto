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
        
    
        
        let key =     "\\x0123456789abcdef"
        let message = "Ok"
        
        //11110011 01000101 01100011 00111111 00110001 10100110 01001000 01101010
        //11110011 01000101 01100011 00111111 00110001 10100110 01001000 01101010
        
    }
    
    func prepareText(m:String) -> [String]{
        let m_int = getAsciiInt(m: m)
        var b = ""
        var zero = ""
        var tab_bin : [String] = []
        for i in m_int{
            b = String(i,radix:2)//convertion en binaire
            for _ in b.count..<8{
                zero.append("0")
            }
            b = zero + b
            //print("b :",b)
            tab_bin.append(b)//rajoute le nb binaire au tableau (8bits)
            zero.removeAll()
        }
        //print("tab_bin : ",tab_bin)
        var tab_block : [String] = []
        var block = ""
        for i in 0..<tab_bin.count{
            if i % 8 == 7 { //fait des block de 64bits
                block.append(tab_bin[i])
                tab_block.append(block)
                block.removeAll()
            }else{
                block.append(tab_bin[i])
            }
        }
        
        tab_block.append(block)//permet d'avoir des block de 64 bit si il y a plus 64 bits
        //print("tab_blocs : ",tab_block[tab_block.count - 1])
        
        var bc = tab_block[tab_block.count - 1]//dernier block non completé
        if bc.count < 64 {
            for i in bc.count..<64{//completion du block
                bc.append("0")
            }
            //supression du block incomplet dans le tableau
            tab_block.remove(at: tab_block.count-1)
            tab_block.append(bc)//ajout d'une nouveau bloc complété
        }
        
        print(tab_block,":",tab_block[0].count)
        return tab_block
    }
    
    
    func prepaMessage(m:String) -> [String]{
        let message_int = getKey(key: m)//getAsciiInt(m: m)
        print("txt :",message_int,"(\(message_int.count))")
        
        let message_bin = message_int //IntToBin(List: message_int)
        if message_bin.count < 64{
            //blocs de 64 bit
            let m = Array(message_bin)
            var tab_blocs : [String] = []
            var bloc = ""
            for i in 0..<message_bin.count{//crée des groupe de 64 bits
                if i % 64 == 63 {
                    bloc.append(m[i])
                    tab_blocs.append(bloc)
                    bloc.removeAll()
                }else{
                    bloc.append(m[i])
                }
            }
            tab_blocs.append(ajustBloc(m: bloc))//gere le block incomplet
            print("nombre de blocs générés : ",tab_blocs.count)
            print("texte binaire = \(tab_blocs)")
            return tab_blocs
        }else{
            return [message_bin]
        }
        
    }
    
    func feistel(Ki:[String],G_0:String,D_0:String)->String{
        print("\n==============================||       Itération schéma de Feistel       ||==============================\n")
        print("G0 = \(G_0)")
        print("D0 = \(D_0)")
        print("\n==============================||       Itération 1       ||==============================\n")
        print("K = \(Ki[0])")
        let tab_E = getTableExpansion()
        var D_E = P(key_binaire: D_0, PC1: tab_E)
        print("E = \(D_E)")

        
        var G : [String] = [D_0]
        var D : [String] = [XOR(a: G_0, b: Confusion(D: D_0, K: Ki[0]))]
                for i in 1..<Ki.count{
            print("\n==============================||       Itération \(i+1)       ||==============================\n")
            print("K = \(Ki[i])")
            D_E = P(key_binaire: D[i-1], PC1: tab_E)
            print("E = \(D_E)")
    
            G.append(D[i-1])
            D.append(XOR(a: G[i-1], b: Confusion(D: D[i-1], K: Ki[i])))
            print("G\(i+1) = \(G[i])")
            print("D\(i+1) = \(D[i])")

        }
        let G16D16 = D[G.count-1]+G[D.count-1]
        print("G16D16 : ",P(key_binaire: G16D16, PC1: getTablePInv()))
        return G16D16
    }
    
    func Confusion(D: String, K : String) -> String{//retourne 4bits
        let tab_E = getTableExpansion()
        let D_E = P(key_binaire: D, PC1: tab_E)
        //print("E = \(D_E)")
        let B = cut8(m: XOR(a: D_E, b: K))// Tableau de 8 morceaux de 6bits
        print("B (8): ",B)
        var f = ""
        for i in 0..<B.count{
            let coord = BinCoord(Bin: B[i])
            print("S\(i+1) [\(coord[0])][\(coord[1])] = \(ReadS(i: i, Ligne: coord[0], Colonne: coord[1]))")
            f.append(ReadS(i: i, Ligne: coord[0], Colonne: coord[1]))//32 BITS
        }
        print("B : \(f)")
        let bin_final = P(key_binaire: f, PC1: getTablePermuFinal())
        //print("val Confusion : ",bin_final)
        return bin_final
        
    }
   
    
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
    
    
//    func IntToBin(List : [Int]) -> String{//convertie un Int en binaire (String)
//        var tab : [String] = []
//        var b = ""
//        for i in List{
//            let bin = String(i,radix: 2)
//
//            for _ in bin.count..<8 {
//                b.append("0")//rajoute le nombre de 0 (8bits)
//            }
//            //rajoute le 0 devant le nb binaire
//            b.append(bin)
//            tab.append(b)
//            b = ""
//        }
//        var a = ""
//        for i in tab{
//            a.append(i)//converti la table en String
//        }
//        return a
//    }
    
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
            }else{
                print("error")
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
            //print(tab_binaire.joined(),": Key binaire (",binaire.count,")")
            return binaire
        }
        print("error")
        return ""//retourne vide si la clé n'est pas conforme
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
        //print("\n============* C1 à C16 *=============\n")
        //print("C1 :\t \(C1)")
        //Boucle de 2 à 16
        for i in 2...16{
            if [2,9,16].contains(i){//si i est dans le tableau => decalage de 1 vers la gauche
                tabOfC.append(permutCircuG(T: tabOfC[i-2], ind: 1))
                //print("C\(i) :\t \(permutCircuG(T: tabOfC[i-2], ind: 1))")
            }else{//sinon décalage de 2 vers la gauche
                tabOfC.append(permutCircuG(T: tabOfC[i-2], ind: 2))
                //print("C\(i) :\t \(permutCircuG(T: tabOfC[i-2], ind: 2))")
            }
        }
        return tabOfC
    }
    
    func getDs(D0 : String) -> [String]{
           var tabOfD : [String] = [] // var contenir les 16 D (1à16)
           let D1 = permutCircuG(T: D0, ind: 1)// i = 1 Donc un decalage vers la gauche
           tabOfD.append(D1) //ajout de D1
           //print("\n============* D1 à D16 *=============\n")
           //print("D1 :\t \(D1)")
           //Boucle de 2 à 16
           for i in 2...16{
               if [2,9,16].contains(i){//si i est dans le tableau => decalage de 1 vers la gauche
                   tabOfD.append(permutCircuG(T: tabOfD[i-2], ind: 1))
                   //print("D\(i) :\t \(permutCircuG(T: tabOfD[i-2], ind: 1))")
               }else{//sinon décalage de 2 vers la gauche
                   tabOfD.append(permutCircuG(T: tabOfD[i-2], ind: 2))
                   //print("D\(i) :\t \(permutCircuG(T: tabOfD[i-2], ind: 2))")
               }
           }
           return tabOfD
       }
    
    
    
    func getKi(Ci : [String],Di: [String], PC2 : [Int]) -> [String]{
        //nb de Ci = nb de Di
        var tK : [String] = []
        for i in 0..<Ci.count{//table de K non modifier par pc2
            tK.append(Ci[i]+Di[i])//ajout des deux moitiées
            //print("k\(i+1) = \(Ci[i]+Di[i])")
        }
        //print("\n=====================* Table des Ki *====================\n")
        //Modification avec PC2
        var ki = ""
        var tab_ki : [String] = []
        for k in tK{
            let tab_K = Array(k)
            for x in PC2{
                ki.append(tab_K[x-1])//le x ème bit devient le 1er etc ...
            }
            tab_ki.append(ki)
            //print("k\(tab_ki.count) =\t \(ki)")
            ki.removeAll()// ràZ pour le prochain k
        }
        return tab_ki
    }
    
    func ajustBloc(m : String) -> String{//renvoie un tableau de Blocs (64BITS)
        var block = m
        if m.count < 64{//on gère le cas ou si le texte est représenté avec moin de 64 bit
            for _ in m.count..<64{
                block.append("0")
            }
        }
        return block
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
    
    func getAsciiChar(t : [Int]) -> [String]{//affiche les lettres affichable sinon affiche l'e-hexa décimal
         //print("Valeur modifier  : ",t)
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
    
    
    
    
    
    func BinCoord(Bin : String) -> [Int]{
        let b = Array(Bin)
        var ligne = ""
        var colonne = ""
        
        ligne = String(b[0])+String(b[b.count-1])//premier et dernier bit
        colonne = String(b[1])+String(b[2])+String(b[3])+String(b[4])
        
        //convertion binaire en décimal
        //print("ligne = \(Int(ligne, radix: 2)!)")
        //print("colonne = \(Int(colonne, radix: 2)!)")
        
        
        return [Int(ligne, radix: 2)!, Int(colonne, radix: 2)! ] //retourne ligne puis colonne
    }
    
    func ReadS(i:Int,Ligne:Int,Colonne:Int) -> String{
        let S = getTableS()
        let n = S[i][Ligne][Colonne]
        
        let b = String(n,radix: 2)
        var bin = ""
        for _ in b.count..<4{//met le nb binaire sur 4bits
            bin.append("0")
        }
        bin.append(b)
        return bin
    }
    
    
    
    func diversKey(k:String) -> [String]{//transforme la clé en 16 sous clé
        print("\n==============================|| Préparation de la clé ||==============================\n")
        print("PHASE 1 :\n")
        print("clé = \(k)\n")
        let key_bin = getKey(key: k)
        let tablePC = getTablePC1()
        let key_pi = P(key_binaire: key_bin, PC1: tablePC)
        //print(key_pi,": key PC1 (",key_pi.count,")")
        //let new_key_pi = PermuInit(key_binaire: key_bin, PC: tablePC) //8 bit en trop
        //print("=======================\n",key_pi,"\n",new_key_pi)
        let CD = C0D0(pc1: key_pi)
        let C0 = CD[0]
        let D0 = CD[1]
        
        let tCs = getCs(C0: C0)
        let tDs = getDs(D0: D0)
        let PC2 = getTabPC2()
        let table_Ki = getKi(Ci: tCs, Di: tDs, PC2: PC2)
        
        return table_Ki
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
    
    func getTablePermuFinal() -> [Int]{
        let tab = [16,7,20,21,
                   29,12,28,17,
                   1,15,23,26,
                   5,18,31,10,
                   2,8,24,14,
                   32,27,3,9,
                   19,13,30,6,
                   22,11,4,25]
        return tab
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
                [13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9]
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
            [3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14]
        
        ]
        
    let S5 =
        [
            [2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9],
            [14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6],
            [4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14],
            [11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3]
        
        ]
        
    let S6 =
        [
            [12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11],
            [10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8],
            [9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6],
            [4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13]
        
        ]
        
    let S7 =
        [
            [4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1],
            [13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6],
            [1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2],
            [6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12]
        ]
        
    let S8 =
        [
            [13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7],
            [1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2],
            [7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8],
            [2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11]
        ]
        return [S1,S2,S3,S4,S5,S6,S7,S8]
    }
    
    func getTableExpansion() -> [Int]{
        let e = [
            32,1,2,3,4,5,
            4,5,6,7,8,9,
            8,9,10,11,12,13,
            12,13,14,15,16,17,
            16,17,18,19,20,21,
            20,21,22,23,24,25,
            24,25,26,27,28,29,
            28,29,30,31,32,1]
        return e
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
    
    func getTablePInv() -> [Int]{
        let t =
        [
            40,8,48,16,56,24,64,32,
            39,7,47,15,55,23,63,31,
            38,6,46,14,54,22,62,30,
            37,5,45,13,53,21,61,29,
            36,4,44,12,52,20,60,28,
            35,3,43,11,51,19,59,27,
            34,2,42,10,50,18,58,26,
            33,1,41,9,49,17,57,25,
        ]
        return t
    }
    
    func cryptDes(message:String, key:String){
        let table_Ki = diversKey(k: key)
           
            
            //print("\n==============================|| Fin de la préparation de la clé ||==============================\n")
            print("\n==============================||      Préparation du texte       ||==============================\n")
            print("PHASE 2 :\n")
            let x = prepareText(m: message)
            var ens_message = ""
            for i in 0..<x.count{
        //      let x = prepaMessage(m: message)
                //let i = 0
                let Y = P(key_binaire: x[i], PC1: getTableP())
                let G0D0 = getG0D0(Y: Y)

                let G_0 = G0D0[0]
                let D_0 = G0D0[1]
                let z = feistel(Ki: table_Ki, G_0: G_0, D_0: D_0)
                let result = P(key_binaire: z, PC1: getTablePInv())
                print("message coder en binaire: ", result)
                //print(cut8(m: result))
                let res_t = cut8(m: result)//résultat binaire
                var r_int : [Int] = []
                for i in res_t{
                    r_int.append(Int(i,radix: 2)!)
                    print("ent = ",Int(i,radix: 2)!)
                }
                let t = getAsciiChar(t: r_int)
                var mess = ""
                for i in t{
                    mess.append(i)
                }
                ens_message.append(mess)
            }
            print("message encoder = ", ens_message)
            
    }
}
