import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Add_post.dart';
import 'post.dart';
import 'constants.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser!;
  TextEditingController _usernameController = TextEditingController();
  CollectionReference get postRef => _firestore.collection('posts');
  CollectionReference get userRef => _firestore.collection('users');

  List<Post> posts = [];

  PostType getCrimeTypeFromString(String value) {
    switch (value) {
      case 'CarAccident':
        return PostType.accident;
      case 'robberyAssault':
        return PostType.robberyAssault;
      case 'fireAccident':
        return PostType.fireAccident;
      default:
        return PostType.accident; // Default value if not found
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Call the function to load username
    _fetchPosts();
  }

  Future<void> _deletePost(Post post) async {
    try {
      QuerySnapshot<Object?> postSnapshot =
          await postRef.where('content', isEqualTo: post.content).get();
//await confirmation dialog func
      if (postSnapshot.docs.isNotEmpty) {
        bool confirmDelete =
            await _showConfirmationDialog(); // Show confirmation dialog

        if (confirmDelete) {
          await postRef.doc(postSnapshot.docs.first.id).delete();
          await _fetchPosts(); // Refresh posts after deletion
        }
      }
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

//if you want to confirm deleting post else do not change
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Deletion'),
              content: Text('Are you sure you want to delete this post?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false (cancel)
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Return true (continue with deletion)
                  },
                  child: Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false; // If user dismisses the dialog, consider it as canceling the deletion
  }

  Future<void> _loadUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _usernameController.text = userData['username'] ?? '';
      });
    }
  }

  Future<void> _fetchPosts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> postSnapshot =
          (await postRef.get()) as QuerySnapshot<Map<String, dynamic>>;
      setState(() {
        posts =
            postSnapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
          Map<String, dynamic> data = doc.data()!;

          // Use a default value for 'PostType' if it's null
          String crimeType =
              data['PostType'] != null ? data['PostType'].toString() : '';
          // Use a default value for 'username' if it's null
          String username = data['username'] ?? '';

          // Use a default timestamp if it's null
          DateTime timestamp = data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now();

          return Post(
            data['title'],
            data['content'],
            crimeType,
            data['iconData'],
            username,
            timestamp: timestamp,
          );
        }).toList();
        // Sort the posts by timestamp
        posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('News Feed'),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/background_img.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            PostType currentType = posts[index].crimeType;
            IconData icon = getIconForType(currentType);
            Color color = getColorForType(currentType);
            String crimeType = getCrimeType(currentType);
            String username = posts[index].username; // Access username

            return Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xffc2bfbf),
                border: Border.all(
                  color: Color(0xffd76961),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: Icon(
                  getIconForType(posts[index].crimeType),
                  color: getColorForType(posts[index].crimeType),
                  size: 36, // Adjust the size here as needed
                ),
                title: Text(
                  posts[index].title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posted by: ${posts[index].username}', // Display username
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff9f2e26),
                      ),
                    ),
                    Text(
                      posts[index].content,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${getCrimeType(posts[index].crimeType)}',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '${posts[index].formattedTimestamp}',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                trailing: Ink(
                  decoration: ShapeDecoration(
                    color: Colors.black, // Set the background color to black
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete,
                        color: Colors.black), // Set icon color to white
                    onPressed: () {
                      _deletePost(posts[index]); // Call delete function
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final User? user = _auth.currentUser; // Ensure user is defined
          if (user != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddPostPage(username: user.displayName ?? 'Anonymous'),
              ),
            );
            if (result != null && result is Post) {
              result.username =
                  user.displayName ?? 'Anonymous'; // Assign the username
              await _addPost(result);
              await _fetchPosts();
            }
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.post_add,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _addPost(Post post) async {
    try {
      User? user = _auth.currentUser;
      post.username = user?.displayName ?? 'Anonymous'; // Assign the username
      if (user != null) {
        postRef.add({
          'title': post.title,
          'content': post.content,
          'PostType': getCrimeType(post.crimeType),
          'iconData': post.iconData,
          'username': post.username, // Use post's username
          'timestamp': FieldValue.serverTimestamp(),
        });
        // Refresh posts after adding the new post
        await _fetchPosts();
      }
    } catch (e) {
      print('Error adding post: $e');
    }
  }
}
