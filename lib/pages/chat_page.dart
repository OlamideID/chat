import 'package:chat/components/chat_style.dart';
import 'package:chat/components/textfield.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/call_service.dart';

class ChatPage extends StatelessWidget {
  ChatPage(
      {super.key,
      required this.receiver,
      required this.receiverID,
      this.ontap});
  final String receiver;
  final String receiverID;
  final Function()? ontap;

  final TextEditingController _messagectrl = TextEditingController();
  final ChatService chat = ChatService();
  final Authservice auth = Authservice();
  final callService = CallService();

  _sendMessage() async {
    if (_messagectrl.text.isNotEmpty) {
      await chat.sendMessage(receiverID, _messagectrl.text);

      _messagectrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.video_call)),
          IconButton(
              onPressed: () {
                ;
              },
              icon: const Icon(Icons.call))
        ],
        title: Row(
          children: [
            CircleAvatar(
              // backgroundColor: Colors.white,
              child: Image.asset(
                'assets/defaultprofile.jpg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(
              width: 7,
            ),
            GestureDetector(onTap: ontap, child: Text(receiver)),
          ],
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildMessageList()),
          _buildUserInput(context)
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = auth.currentUser()!.uid;
    return StreamBuilder(
      stream: chat.getMessages(receiverID, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              Text('Loading'),
              SizedBox(
                height: 10,
              ),
              CircularProgressIndicator()
            ],
          );
        }

        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isUser = data['senderID'] == auth.currentUser()!.uid;

    var alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: Column(
          children: [
            ChatBubble(isCurrentUser: isUser, message: data['message']),
          ],
        ));
  }

  Widget _buildUserInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              hintText: 'Type a message',
              obscure: false,
              controller: _messagectrl,
              onTap: () {},
            ),
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.attach_file,
                size: 30,
              )),
          const SizedBox(
            width: 5,
          ),
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 20),
            decoration:
                BoxDecoration(color: Colors.blue[700], shape: BoxShape.circle),
            child: Center(
              child: IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(
                    Icons.send,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
