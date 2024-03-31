//
//  ContentView.swift
//  DawaaiSwiftUi
//
//  Created by user1 on 10/01/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

import UserNotifications

//struct Medicine : Decodable , Identifiable {
//    var id : Int
//    var name : String
//    var type : String
//    var strength : String
//    var strengthUnit : String
//    var Image : String
//    var taken : Int
//    var toBeTake : Int
//    var nextDoseTime : Date
//    var dosageType : String
//    var dosage : Int
//    var quantity : Int
//    var expiryDate : Date
//    var startDate : Date
//    var remindForReorder : Bool
//    var breakfast : Bool
//    var lunch : Bool
//    var dinner : Bool
//    
//}



struct ContentView : View {
//    init() {
//        UITabBar.appearance().backgroundColor = UIColor(Color.pickerSelected)
//        }
//    @StateObject public var firestoreManager : FirestoreManager

    @Binding public var user : DawaaiUser
    @State public var TotalMedicines : [Medicine] = []

    @StateObject var model = FirestoreManager()
    public  var  meow : [Medicine]{model.fetchedMeds} ;
    
//    @StateObject var m = model.fetchedMeds;
//    print(model.fetchedMeds)

    
//    @State public var TotalMedicines : [Medicine] = []
//        Medicine(id: 1, name: "Dolo 650", type: "pill", strength: "650", strengthUnit: "mg", Image: "pill\(String(Int.random(in: 1...3)))", taken: 2, toBeTake: 3, nextDoseTime: Date(timeIntervalSince1970: 1708529400), dosageType: "Before eating", dosage: 3 , quantity: 10 , expiryDate: Date(timeIntervalSince1970: 1711305000) , startDate: Date() , remindForReorder:true, breakfast: true , lunch: true , dinner: true
//),
//            
//        Medicine(id: 2, name: "Amodep AT", type: "pill", strength: "650", strengthUnit: "mg", Image: "pill\(String(Int.random(in: 1...3)))", taken: 2, toBeTake: 3, nextDoseTime: Date(timeIntervalSince1970: 1708529400), dosageType: "Before eating", dosage: 3 , quantity: 10 , expiryDate: Date(timeIntervalSince1970: 1711305000) , startDate: Date() , remindForReorder:true, breakfast: true , lunch: false , dinner: true
//),
//
//            
//        Medicine(id: 3, name: "Amyron", type: "pill", strength: "650", strengthUnit: "mg", Image: "pill\(String(Int.random(in: 1...3)))", taken: 2, toBeTake: 3, nextDoseTime: Date(timeIntervalSince1970: 1708529400), dosageType: "Before eating", dosage: 3 , quantity: 10 , expiryDate: Date(timeIntervalSince1970: 1711305000) , startDate: Date() , remindForReorder:true, breakfast: true , lunch: false , dinner: true
//),
//
//            
//        Medicine(id: 4, name: "Cinarest", type: "pill", strength: "650", strengthUnit: "mg", Image: "pill\(String(Int.random(in: 1...3)))", taken: 2, toBeTake: 3, nextDoseTime: Date(timeIntervalSince1970: 1708529400), dosageType: "Before eating", dosage: 3 , quantity: 10 , expiryDate: Date(timeIntervalSince1970: 1711305000) , startDate: Date() , remindForReorder:true, breakfast: true , lunch: false , dinner: true
//),
//]
    var body: some View {
        TabView{
//            Text("\(meow.count)")

            HomeView(medicineCtas: model.fetchedMeds.filter({ Medicine in
                Medicine.expiryDate > Date()
            }), user: $user
            ).tabItem { Label("Home", systemImage: "house").onAppear(
                perform: {
                    model.fetchMedicines() }
              ) }
            AddMedicineView(medicineCards:  model.fetchedMeds).tabItem {
                Label("Meds", systemImage: "pill")
            }
//            HomeView(medicineCtas: model.fetchedMeds.filter { medicine in
//              medicine.expiryDate > Date() /*&& needsNotification(medicine: medicine*/)
//            }, user: $user)
//              .tabItem { Label("Home", systemImage: "house").onAppear(perform: model.fetchMedicines) }
//            AddMedicineView(medicineCards:  model.fetchedMeds)
//              .tabItem { Label("Meds", systemImage: "pill") }
//
//            
            
          FamilyLogView().tabItem {
              Label("Family log", systemImage: "person.3")
          }
            
            
            HistoryView(medicineCards: meow).tabItem {
                Label("History", systemImage: "calendar.badge.clock")
            }

        }.accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/).toolbarBackground(
            Color("bgColor"),
            for: .tabBar)    }
    
    
    private func needsNotification(medicine: Medicine) -> Bool {
      let now = Date()
      let nextDose = medicine.nextDoseTime
      let intervalSinceDose = now.timeIntervalSince(nextDose)

      // Check if next dose has passed and consider dosage frequency
      return intervalSinceDose >= 0 && intervalSinceDose <= 60 * 6  // Check within 6 minutes of next dose time
    }
}


class FirestoreManager : ObservableObject{
    init() {
        fetchMedicines()
    }

    @Published  var fetchedMeds : [Medicine] = []

    
    
    private func needsNotification(medicine: Medicine) -> Bool {
      let now = Date()
      let nextDose = medicine.nextDoseTime
      let intervalSinceDose = now.timeIntervalSince(nextDose)

      // Check if next dose has passed and consider dosage frequency
      return intervalSinceDose >= 0 && intervalSinceDose <= 60 * 6 // Check within 6 minutes of next dose time
    }

//    private func scheduleNotification(for medicine: Medicine) {
//      let content = UNMutableNotificationContent()
//      content.title = "It's time to take your \(medicine.name)!"
//      content.body = medicine.name
//
//      let calendar = Calendar.current
//      let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: medicine.nextDoseTime)
//      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
//      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//      UNUserNotificationCenter.current().add(request) { (error) in
//        if let error = error {
//          print("Error scheduling notification:", error.localizedDescription)
//        } else {
//          print("Scheduled notification for \(medicine.name)")
//        }
//      }
//    }
    private func scheduleNotification(for medicine: Medicine) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "It's time to take your \(medicine.name)!"
        content.body = medicine.name
        content.userInfo = ["medicineID": medicine.id] // Attach medicine ID
        
        // Create notification trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: medicine.nextDoseTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification:", error.localizedDescription)
            } else {
                print("Scheduled notification for \(medicine.name)")
            }
        }
    }


    
    func fetchMedicines (){
        
        let db = Firestore.firestore();
        let docRef = db.collection("Users").document("o3VXdqMV47PpRXaZmPyuQUzFhyh2")
        
        docRef.getDocument { (document, error) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }
            
            if let document = document, document.exists {
                
                guard let data = document.data() else {
                    print("No data found in document")
                    return
                }

                if let medicinesData = data["medicines"] as? [[String: Any]] {
                    
                    var uniqueMeds = Set<Medicine>();

                    for i in 0..<medicinesData.count {
//                        print(medicinesData[i]["nextDostTime"])
//                        let nextDoseTime = medicinesData[i]["nextDostTime"]
                        
                        uniqueMeds.insert(Medicine(id: Int(i), name: medicinesData[i]["name"]! as! String, type: medicinesData[i]["type"]! as! String, strength: medicinesData[i]["strength"]! as! String, strengthUnit: medicinesData[i]["strengthUnit"]! as! String, Image: medicinesData[i]["Image"]! as! String, taken: medicinesData[i]["taken"]! as! Int, toBeTaken: medicinesData[i]["toBeTaken"]! as! Int, nextDoseTime: Date(timeIntervalSince1970: medicinesData[i]["nextDostTime"] as! TimeInterval
                                                                                                                                                                                                                                                                                                                                                                                                        ), dosageType: medicinesData[i]["dosageType"] as! String
                                                         , dosage: medicinesData[i]["dosage"] as! Int
                                                         , quantity: medicinesData[i]["quantity"] as! Int
                                                         , expiryDate: Date(timeIntervalSince1970: medicinesData[i]["expiryDate"] as! TimeInterval), startDate: Date(timeIntervalSince1970: medicinesData[i]["startDate"] as! TimeInterval), remindForReorder: (medicinesData[i]["remindForReorder"] != nil), breakfast: (medicinesData[i]["remindForReorder"] != nil), lunch: (medicinesData[i]["remindForReorder"] != nil), dinner: (medicinesData[i]["remindForReorder"] != nil), pillImage: medicinesData[i]["pillImage"] as! String))

                    }
                    
                    self.fetchedMeds = Array(uniqueMeds)
                    
                    
                } else {
                    print("No")
                }
                                      
//                print(self.fetchedMeds)
                for medicine in self.fetchedMeds {
//                            if self.needsNotification(medicine: medicine) {
                              self.scheduleNotification(for: medicine)
                            }
                          

      
                       }
            
                   }


            
            
        }
    }
