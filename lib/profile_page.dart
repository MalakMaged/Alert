import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crimebott/login_page.dart';
import 'package:crimebott/models/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _mobileNumberController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedField = 'Email';
  List<String> _fields = ['Username', 'Email', 'Password', 'Mobile Number'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _usernameController.text = userData['username'] ?? '';
        _emailController.text = user.email ?? '';
        _mobileNumberController.text = userData['mobileNumber'] ?? '';
      });
    }
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      backgroundColor: Color(0xffc2bfbf),
      appBar: AppBar(
        title: Text('Profile Page'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/road.jpg'), // Replace with your image path
            fit: BoxFit.cover, // Adjust the fit as needed
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the Row horizontally
                  children: [
                    Center(
                      // Center the text vertically
                      child: Text(
                        'Hi, ${user?.displayName ?? _usernameController.text}!',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                        width:
                            5), // Adjust the space between text and icon as needed
                    Icon(
                      Icons.location_pin,
                      color: Colors.black,
                      size: 24,
                    ),
                  ],
                ),

                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Colors.blueGrey,
                      width: 2.0,
                    ),
                    color: Colors
                        .grey[400], // Set the background color of the container
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors
                          .grey[400], // Set the color behind the dropdown items
                    ),
                    child: DropdownButton<String>(
                      value: _selectedField,
                      items: _fields.map((field) {
                        return DropdownMenuItem<String>(
                          value: field,
                          child: Text(
                            field,
                            style: TextStyle(
                                color: Colors.black), // Set text color
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedField = value!;
                        });
                      },
                      underline: Container(), // Remove the default underline
                    ),
                  ),
                ),

                SizedBox(height: 20.0),
                TextField(
                  controller: _getControllerForSelectedField(),
                  decoration: InputDecoration(
                    labelText: _selectedField,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Colors.blueGrey), // Set border color
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          BorderSide(color: Colors.black), // Set border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Colors.red), // Set focused border color
                    ),
                    fillColor: Colors.grey[400],
                    filled: true,
                  ),
                ),
                SizedBox(height: 200.0),
                ElevatedButton(
                  onPressed: () {
                    _updateProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Update $_selectedField'),
                ),
                // sign out button
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    signOut(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('LogOut'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextEditingController _getControllerForSelectedField() {
    switch (_selectedField) {
      case 'Username':
        return _usernameController;
      case 'Email':
        return _emailController;
      case 'Password':
        return _passwordController;
      default:
        return TextEditingController();
    }
  }

  Future<void> _updateProfile() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String? password = await _showPasswordPrompt();

        if (password != null) {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);

          if (_selectedField == 'Password') {
            if (_passwordController.text.isNotEmpty) {
              await user.updatePassword(_passwordController.text);
            } else {
              throw Exception(
                  "New password is required for updating the password");
            }
          } else if (_selectedField == 'Email') {
            if (_emailController.text.isNotEmpty) {
              await user.updateEmail(_emailController.text);
            } else {
              throw Exception("New email is required for updating the email");
            }
          }

          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!'),
            ),
          );
        }
      }
    } catch (error) {
      print('Error updating profile: $error');
      String errorMessage = 'Error updating profile. Please try again.';
      if (error is FirebaseAuthException) {
        errorMessage = error.message ?? errorMessage;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  Future<String?> _showPasswordPrompt() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String password = '';

        return AlertDialog(
          title: Text('Enter your current password'),
          content: TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
            ),
            onChanged: (value) {
              password = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(password);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
