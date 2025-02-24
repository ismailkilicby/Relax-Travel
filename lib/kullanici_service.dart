import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neyimeshur/kullanici_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static var onAuthStateChanged;

  Future createUser(Users user) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('Users').doc(uid).set({
        'userID': uid,
        'namesurname': user.namesurname,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'password': user.password,
      });
    } catch (e) {
      print('Kullanıcı oluşturma hatalı: $e');
    }
  }

  Future updateUser(Users user) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('Users').doc(uid).update(user.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteUser(String userID) async {
    try {
      await _firestore.collection('Users').doc(userID).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<Users?> getUser() async {
    try {
      String uid = _auth.currentUser!.uid;

      DocumentSnapshot doc =
          await _firestore.collection('Users').doc(uid).get();

      if (doc.exists) {
        Users user = Users.fromMap(doc.data() as Map<String, dynamic>);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<Users>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Users').get();

      List<Users> users = querySnapshot.docs
          .map((doc) => Users.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return users;
    } catch (e) {
      print('Kullanıcı getirme hatası: $e');
      return [];
    }
  }
}
