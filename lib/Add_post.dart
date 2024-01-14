import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/user.dart';
import 'post.dart';
import 'constants.dart';
import 'dashboard.dart';









class AddPostPage extends StatefulWidget {
  final String username;
  const AddPostPage({Key? key, required this.username}) : super(key: key);
  @override
  _AddPostPageState createState() => _AddPostPageState();
}



class _AddPostPageState extends State<AddPostPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  PostType _selectedType = PostType.robberyAssault;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUsername();
  }


  
  Future<DocumentSnapshot<Map<String, dynamic>>> _loadUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Add Post'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _userDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loading indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  String username = snapshot.data?['username'] ?? '';
                  return Text(
                    "Post as: $username",
                    style: TextStyle(fontSize: 20),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                filled: true,
                fillColor: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                filled: true,
                fillColor: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (var type in PostType.values)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: getColorForType(type),
                            child: Icon(
                              getIconForType(type),
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getCrimeType(type).toString(),
                            style: TextStyle(
                              color: _selectedType == type
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty &&
                    _contentController.text.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    
                    // Use the username passed to the widget
                    String username = widget.username;

                    // Use the current time as the timestamp
                    
                    DateTime timestamp = DateTime.now();

                    // Create the Post object with the updated fields
                    Post newPost = Post(
                      _titleController.text,
                      _contentController.text,
                      getCrimeType(_selectedType).toString().split('.').last,
                      getIconForType(_selectedType).codePoint.toString(),
                      username, // Use the 'username' variable
                      timestamp: timestamp,
                    );

                    Navigator.pop(context, newPost);
                  }
                }
              },
              child: const Text('Add Post'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                primary: Colors.green,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:crimebott/post.dart';
// import 'package:flutter/material.dart';
// import 'post.dart';
// import 'constants.dart';






// enum PostType { accident, robberyAssault, fireAccident }

// class AddPostPage extends StatefulWidget {
//   @override
//   _AddPostPageState createState() => _AddPostPageState();
// }

// class _AddPostPageState extends State<AddPostPage> {
//   PostType _selectedType = PostType.accident; // Default type
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();

//   String getCrimeType(PostType type) {
//     switch (type) {
//       case PostType.accident:
//         return 'Accident';
//       case PostType.robberyAssault:
//         return 'Robbery/Assault';
//       case PostType.fireAccident:
//         return 'Fire Accident';
//       default:
//         return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey,
//       appBar: AppBar(
//         title: Text('Add Post'),
//         backgroundColor: Colors.red,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(
//                 labelText: 'Title',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//                 fillColor: Colors.grey[400],
//                 filled: true,
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _contentController,
//               decoration: InputDecoration(
//                 labelText: 'Content',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//                 fillColor: Colors.grey[400],
//                 filled: true,
//               ),
//             ),
//             Row(
//               children: [
//                 Icon(
//                   Icons.location_pin,
//                   color: Colors.blue,
//                 ),
//                 SizedBox(width: 8),
//                 DropdownButtonFormField<PostType>(
//                   value: _selectedType,
//                   onChanged: (newValue) {
//                     setState(() {
//                       _selectedType = newValue!;
//                     });
//                   },
//                   items: [
//                     DropdownMenuItem(
//                       value: PostType.accident,
//                       child: Row(
//                         children: [
//                           Icon(Icons.location_pin, color: Colors.blue),
//                           SizedBox(width: 8),
//                           Text('Accident'),
//                         ],
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: PostType.robberyAssault,
//                       child: Row(
//                         children: [
//                           Icon(Icons.location_pin, color: Colors.purple),
//                           SizedBox(width: 8),
//                           Text('Robbery/Assault'),
//                         ],
//                       ),
//                     ),
//                     DropdownMenuItem(
//                       value: PostType.fireAccident,
//                       child: Row(
//                         children: [
//                           Icon(Icons.location_pin, color: Colors.orange),
//                           SizedBox(width: 8),
//                           Text('Fire Accident'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 if (_titleController.text.isNotEmpty &&
//                     _contentController.text.isNotEmpty) {
//                   final selectedPostType = getPostTypeFromString(
//                     _selectedType.toString().split('.').last,
//                   ); // Convert selected type to PostType enum
//                   final selectedIconData =
//                       crimeTypeIcons[selectedPostType]?.codePoint.toString() ??
//                           ''; // Get the icon data as a String
//                   Navigator.pop(
//                     context,
//                     Post(
//                       _titleController.text,
//                       _contentController.text,
//                       selectedPostType,
//                       selectedIconData,
//                       //'', // The username will be added in the DashboardPage
//                       //DateTime
//                       // .now(), // The timestamp will be added in the DashboardPage
//                     ),
//                   );
//                 }
//               },
//               child: Text('Add Post'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.all(20),
//                 primary: Colors.green,
//                 onPrimary: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'post.dart';
// // import 'constants.dart';

// // enum PostType { accident, robberyAssault, fireAccident }

// // class AddPostPage extends StatefulWidget {
// //   @override
// //   _AddPostPageState createState() => _AddPostPageState();
// // }

// // class _AddPostPageState extends State<AddPostPage> {
// //   PostType _selectedType = PostType.accident;
// //   final TextEditingController _titleController = TextEditingController();
// //   final TextEditingController _contentController = TextEditingController();

// //   String _getCrimeType(PostType type) {
// //     switch (type) {
// //       case PostType.accident:
// //         return 'Accident';
// //       case PostType.robberyAssault:
// //         return 'Robbery/Assault';
// //       case PostType.fireAccident:
// //         return 'Fire Accident';
// //       default:
// //         return '';
// //     }
// //   }

// //   String _getIconDataForType(PostType type) {
// //     switch (type) {
// //       case PostType.accident:
// //         return Icons.pin_drop.codePoint.toString();
// //       case PostType.robberyAssault:
// //         return Icons.pin_drop.codePoint.toString();
// //       case PostType.fireAccident:
// //         return Icons.pin_drop.codePoint.toString();
// //       default:
// //         return '';
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey,
// //       appBar: AppBar(
// //         title: const Text('Add Post'),
// //         backgroundColor: Colors.red,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 16),
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(
//                 labelText: 'Title',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[400],
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _contentController,
//               decoration: InputDecoration(
//                 labelText: 'Content',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[400],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 // Icon(Icons.pin_drop, color: Colors.blue),

//                 // Icon(
//                 //   IconData(int.parse(getIconForType(_selectedType)),
//                 //       fontFamily: 'MaterialIcons'),
//                 //   size: 50,
//                 //   color: Colors.black,
//                 // ),
//                 const SizedBox(width: 8),
//                 DropdownButton<PostType>(
//                   value: _selectedType,
//                   onChanged: (newValue) {
//                     setState(() {
//                       _selectedType = newValue!;
//                     });
//                   },
//                   items: [
//                     const DropdownMenuItem(
//                       value: PostType.accident,
//                       child: Row(
//                         children: [
//                           Icon(Icons.pin_drop, color: Colors.blue),
//                           SizedBox(width: 8),
//                           Text('Car Accident'),
//                         ],
//                       ),
//                     ),
//                     const DropdownMenuItem(
//                       value: PostType.robberyAssault,
//                       child: Row(
//                         children: [
//                           Icon(Icons.pin_drop, color: Colors.purple),
//                           SizedBox(width: 8),
//                           Text('Robbery/Assault'),
//                         ],
//                       ),
//                     ),
//                     const DropdownMenuItem(
//                       value: PostType.fireAccident,
//                       child: Row(
//                         children: [
//                           Icon(Icons.pin_drop, color: Colors.orange),
//                           SizedBox(width: 8),
//                           Text('Fire Accident'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 if (_titleController.text.isNotEmpty &&
//                     _contentController.text.isNotEmpty) {
//                   Navigator.pop(
//                     context,
//                     Post(
//                       _titleController.text,
//                       _contentController.text,
//                       _getCrimeType(
//                           _selectedType), // Assuming this method gets the crime type string
//                       _getIconDataForType(
//                           _selectedType), // Assuming this method gets the icon data string
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Add Post'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.all(20),
//                 primary: Colors.green,
//                 onPrimary: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// //       ),
// //     );
// //   }
// // }
//}
// //       ),
// //     );
// //   }
// // }
