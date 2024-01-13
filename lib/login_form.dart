import 'package:flutter/material.dart';
import 'package:crimebott/crimehomepage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;
  String? _errorMessage; // New variable to store error message

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 15),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              fillColor: Colors.grey[400],
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              // You can add additional email validation logic if needed
              return null;
            },
            onSaved: (value) {
              _email = value;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              fillColor: Colors.grey[400],
              filled: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            onSaved: (value) {
              _password = value;
            },
          ),
          SizedBox(height: 20),
          if (_errorMessage != null) // Show error message if it exists
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                try {
                  UserCredential userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _email!,
                    password: _password!,
                  );

                  // Navigate to the home page after successful login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CrimeHomePage()),
                  );
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    // Set error message based on the authentication exception
                    if (e.code == 'user-not-found' ||
                        e.code == 'wrong-password') {
                      _errorMessage = 'Invalid email or password';
                    } else {
                      _errorMessage = 'Invalid email or password';
                    }
                  });
                }
              }
            },
            child: Text('Login'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              primary: Colors.red,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
