 
import 'package:banana_disease_detector/models/instructor.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 

class InstructorRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('Instructors');

  Future addNewInstructor(Instructor instructor, String userId) async {
    Instructor _instructor = instructor;
    _instructor.userId = userId;
    return collection.doc(userId).set(_instructor.toJson());
  }

  void updateInstructor(Instructor Instructor, String userId) async {
    await collection.doc(userId).update(Instructor.toJson());
  }

  Future<Instructor> getInstructorDetails(String userID) async {
    var docSnapshot = await collection.doc(userID).get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    Instructor instructor = Instructor.fromJson(data);
    return instructor;
  }
 


}
