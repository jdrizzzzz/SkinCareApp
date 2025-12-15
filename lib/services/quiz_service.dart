import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizService { // handles saving + loading quiz data for the user
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance; //get the currently logged in user

  Future<void> saveQuizAnswers(Map<String, dynamic> answers) async {
    final uid = _auth.currentUser?.uid; // get the logged in user's uid
    if (uid == null) {
      throw Exception("User not logged in");
    }

    // users = collection that stores all users
    // uid = document for THIS specific user
    await _db.collection('users').doc(uid).set({
      'quizAnswers': answers,
      'quizUpdatedAt': FieldValue.serverTimestamp(),
    },
        SetOptions(merge: true)); //doesnt overwrite user documents (only update/add)
  }

  Future<Map<String, dynamic>?> loadQuizAnswers() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get(); // get user's document from firestore
    final data = doc.data(); //get data
    if (data == null) return null;

    final qa = data['quizAnswers'];

    if (qa is Map) {
      return qa.cast<String, dynamic>();
    }
    return null;     // quizAnswers doesn't exist or is invalid
  }
}
