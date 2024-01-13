// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class Userr {
  final String username;
  final String email;
  final String mobileNumber;
  final String password;

  Userr({
    required this.username,
    required this.email,
    required this.mobileNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
    };
  }
}

//Fetch user data from Firebase Authentication
// Future<User?> getCurrentUser() async {
//   User? user;
//   try {
//     UserCredential userCredential =
//         await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: 'user_email',
//       password: 'user_password',
//     );
//     var firebaseUser = userCredential.user;

//     // Fetch user details from Firestore or another database
//     // This is a dummy example; replace it with your actual code
//     var userData = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(firebaseUser?.uid)
//         .get();
//     String? username = userData.data()?['username'];
//     String? email = userData.data()?['email'];
//     String? mobileNumber = userData.data()?['mobileNumber'];
//     String? password = userData.data()?['password'];

//     user = Userr(
//       uid: firebaseUser?.uid ?? '',
//       username: username ?? '',
//       email: email ?? '',
//       mobileNumber: mobileNumber ?? '',
//       password: password ?? '',
//     ) as User?;
//   } catch (e) {
//     print(e.toString());
//   }
//   return user;
// }
