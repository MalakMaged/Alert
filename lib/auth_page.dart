// import 'package:crimebott/crimehomepage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:crimebott/login_page.dart';
// //import 'package:firebase_auth/firebase_auth.dart';




// class AuthPage extends StatelessWidget {
//   const AuthPage({Key? key});
// //authentication

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             //If user is logged in
//             return CrimeAppHomePage();
//           } else {
//             //if user is NOT logged in
//             return LoginPage();
//           }
//         },
//       ),
//     );
//   }
// }
