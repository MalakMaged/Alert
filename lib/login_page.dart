// login_page.dart
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'signup_page.dart';

import 'login_form.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  //text editing controllers
  // final emailController = TextEditingController();
  // final passwordController = TextEditingController();

  // //sign user in method
  // void signUserIn() async {
  //   await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: emailController.text, password: passwordController.text);
  // }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('ALERT'), centerTitle: true,
        backgroundColor: Colors.red, // Set the login page app bar color
        
      ),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Logo
              Container(
                height: 80,
                child: Image.asset(
                  'lib/icons/map-point.png',
                  color: Colors.grey[900],
                ),
                
              ),
              
              Text(
                "LOGIN\n",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffe6584e),
                ),
                
              ),
              
              Text(
                "Welcome back",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  
                ),
                
              ),
              
              LoginForm(),
              
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dont have an account?',
                    style: TextStyle(color: Colors.grey[900]),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                      
                    },
                    
                    child: Text(
                      'Sign up here',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


