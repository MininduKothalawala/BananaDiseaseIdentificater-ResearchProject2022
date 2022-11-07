 
import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 

class FarmerRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('Farmers');

  Future addNewFarmer(Farmer farmer, String userId) async {
    Farmer _farmer = farmer;
    _farmer.userId = userId;
    return collection.doc(userId).set(_farmer.toJson());
  }

  void updateFarmer(Farmer Farmer, String userId) async {
    await collection.doc(userId).update(Farmer.toJson());
  }

  Future<Farmer> getFarmerDetails(String userID) async {
    var docSnapshot = await collection.doc(userID).get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    Farmer farmer = Farmer.fromJson(data);
    return farmer;
  }
 


}
