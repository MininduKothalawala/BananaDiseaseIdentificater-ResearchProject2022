import 'package:banana_disease_detector/models/disease.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiseaseLocaterRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('Diseases');

  Future addNewDiseaseLocater(DiseaseLocater diseaseLocater) async {
    DiseaseLocater _diseaseLocater = diseaseLocater;
    // return collection.doc(userId).set(_diseaseLocater.toJson());
    return collection.add(_diseaseLocater.toJson());
  }

  void updateDiseaseLocater(
      DiseaseLocater DiseaseLocater, String userId) async {
    await collection.doc(userId).update(DiseaseLocater.toJson());
  }

  Future<DiseaseLocater> getDiseaseLocaterDetails(String userID) async {
    var docSnapshot = await collection.doc(userID).get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    DiseaseLocater diseaseLocater = DiseaseLocater.fromJson(data);
    return diseaseLocater;
  }
}
