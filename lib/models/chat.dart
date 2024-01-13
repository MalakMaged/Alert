// import 'package:flutter/material.dart';

// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   TextEditingController _messageController = TextEditingController();
//   List<ChatMessage> _messages = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey,
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         title: Text('Chat with Police'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return _buildMessage(_messages[index]);
//               },
//             ),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessage(ChatMessage message) {
//     return ListTile(
//       title: Container(
//         padding: EdgeInsets.all(10.0),
//         decoration: BoxDecoration(
//           color: message.isSentByUser ? Color(0xff6995b8) : Colors.grey,
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               message.text,
//               style: TextStyle(color: Colors.grey[200]),
//             ),
//             SizedBox(height: 4.0),
//             Text(
//               message.timestamp,
//               style: TextStyle(fontSize: 12.0, color: Colors.white70),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.send),
//             color: Colors.red,
//             onPressed: () {
//               _sendMessage();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _sendMessage() {
//     String messageText = _messageController.text;
//     if (messageText.isNotEmpty) {
//       setState(() {
//         ChatMessage message = ChatMessage(
//           text: messageText,
//           isSentByUser: true,
//           timestamp: _getCurrentTimestamp(),
//         );
//         _messages.add(message);
//         _messageController.clear();
//       });
//     }
//   }

//   String _getCurrentTimestamp() {
//     DateTime now = DateTime.now();
//     String formattedDate = "${now.hour}:${now.minute}";
//     return formattedDate;
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isSentByUser;
//   final String timestamp;

//   ChatMessage({
//     required this.text,
//     required this.isSentByUser,
//     required this.timestamp,
//   });
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatScreen extends StatelessWidget {
//   final TextEditingController _messageController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Alert Chat'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream:
//                   FirebaseFirestore.instance.collection('messages').snapshots(),
//               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//                 var messages = snapshot.data!.docs;
//                 List<Widget> messageWidgets = [];
//                 for (var message in messages) {
//                   var messageText = message['text'];
//                   var messageSender = message['sender'];

//                   var messageWidget = MessageWidget(messageSender, messageText);
//                   messageWidgets.add(messageWidget);
//                 }
//                 return ListView(
//                   children: messageWidgets,
//                 );
//               },
//             ),
//           ),
//           _buildMessageInputField(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageInputField() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               decoration: InputDecoration(
//                 hintText: 'Enter your message...',
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.send),
//             onPressed: () {
//               _sendMessage();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _sendMessage() {
//     var text = _messageController.text;
//     if (text.isNotEmpty) {
//       FirebaseFirestore.instance.collection('messages').add({
//         'text': text,
//         'sender': FirebaseAuth.instance.currentUser!.uid,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       _messageController.clear();
//     }
//   }
// }

// class MessageWidget extends StatelessWidget {
//   final String sender;
//   final String text;

//   MessageWidget(this.sender, this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             sender,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(text),
//         ],
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  ScrollController _scrollController = ScrollController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatRef =
      FirebaseDatabase.instance.reference().child('chats');
  final String adminUserId = 'LdbimA6KumgDfbtONWFAL3ZSW433';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    User? currentUser = _auth.currentUser;
    String currentUserId = currentUser?.uid ?? '';

    // Determine the chat path based on user and admin
    String chatPath = currentUserId.compareTo(adminUserId) < 0
        ? '$currentUserId/$adminUserId'
        : '$adminUserId/$currentUserId';

    _chatRef.child(chatPath).onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic>? data =
            event.snapshot.value as Map<String, dynamic>?;

        if (data != null) {
          List<ChatMessage> messages = [];
          data.forEach((key, value) {
            String content = value['text'];
            // messages.add(ChatMessage.fromJson(value));
            // Ensure 'timestamp' is in the correct format
            String timestamp = value['timestamp'] ?? '';

            messages.add(ChatMessage(
              messageId: key,
              text: content,
              senderId: value['senderId'] ?? '',
              timestamp: timestamp,
            ));
          });

          setState(() {
            _messages = messages;
          });

          // Scroll to the bottom of the list
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('Chat with Admin'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return ListTile(
      title: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: message.senderId == _auth.currentUser?.uid
              ? Colors.black
              : Colors.grey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
            bottomLeft: Radius.circular(
                message.senderId == _auth.currentUser?.uid ? 20.0 : 0),
            bottomRight: Radius.circular(
                message.senderId == _auth.currentUser?.uid ? 0 : 20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              message.timestamp,
              style: TextStyle(fontSize: 12.0, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Colors.black,
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      User? currentUser = _auth.currentUser;
      String currentUserId = currentUser?.uid ?? '';

      // Determine the chat path based on user and admin
      String chatPath = currentUserId.compareTo(adminUserId) < 0
          ? '$currentUserId/$adminUserId'
          : '$adminUserId/$currentUserId';

      String messageId = _chatRef.child(chatPath).push().key ?? '';

      ChatMessage message = ChatMessage(
        messageId: messageId,
        text: messageText,
        senderId: currentUserId,
        timestamp: _getCurrentTimestamp(),
      );

      _chatRef.child(chatPath).child(messageId).set(message.toJson());

      _messageController.clear();
    }
  }

  String _getCurrentTimestamp() {
    DateTime now = DateTime.now();
    String formattedDate = "${now.hour}:${now.minute}";
    return formattedDate;
  }
}

class ChatMessage {
  final String messageId;
  final String text;
  final String senderId;
  final String timestamp;

  ChatMessage({
    required this.messageId,
    required this.text,
    required this.senderId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'],
      text: json['text'],
      senderId: json['senderId'],
      timestamp: json['timestamp'],
    );
  }
}
