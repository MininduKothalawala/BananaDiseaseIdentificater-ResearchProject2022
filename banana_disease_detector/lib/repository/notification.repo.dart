import 'package:banana_disease_detector/models/disease.model.dart';
import 'package:banana_disease_detector/models/notification.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('Notifications');

  Future addNewNotification(NotificationIns notification) async {
    NotificationIns _notification = notification;
    // return collection.doc(userId).set(_Notification.toJson());
    return collection.add(_notification.toJson());
  }

  void updateNotification(
      NotificationIns Notification, String userId) async {
    await collection.doc(userId).update(Notification.toJson());
  }

  Future<NotificationIns> getNotificationDetails(String userID) async {
    var docSnapshot = await collection.doc(userID).get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    NotificationIns notification = NotificationIns.fromJson(data);
    return notification;
  }
}
