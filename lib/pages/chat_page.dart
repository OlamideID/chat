import 'package:chat/components/chat_style.dart';
import 'package:chat/components/textfield.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.receiver,
      required this.receiverID,
      this.ontap});
  final String receiver;
  final String receiverID;
  final Function()? ontap;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messagectrl = TextEditingController();
  final ChatService chat = ChatService();
  final Authservice auth = Authservice();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messagectrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            GestureDetector(onTap: widget.ontap, child: Text(widget.receiver)),
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
          UserInputField(
            onSendMessage: (message) async {
              await chat.sendMessage(widget.receiverID, message);
              scrollDown();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = auth.currentUser()!.uid;
    return StreamBuilder(
      stream: chat.getMessages(widget.receiverID, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              children: [
                const Text('Loading'),
                const SizedBox(
                  height: 10,
                ),
                Lottie.asset('assets/Animation - 1730069741511.json',
                    height: 150, width: 150, frameRate: const FrameRate(60))
              ],
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages yet'),
          );
        }

        // Scroll down when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollDown();
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc, snapshot))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(
      DocumentSnapshot doc, AsyncSnapshot<QuerySnapshot> snapshot) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isUser = data['senderID'] == auth.currentUser()!.uid;
    bool isRead = data['isRead'] ?? false;
    Timestamp timestamp = data['timestamp'];

    // Check if the receiver has sent another message after this one
    bool hasReceiverSentNewMessage = false;

    // Convert the current message's timestamp to DateTime
    DateTime currentMessageTime = timestamp.toDate();

    // Iterate over the messages in the snapshot to check if the receiver sent a message after this one
    for (var message in snapshot.data!.docs) {
      Map<String, dynamic> messageData = message.data() as Map<String, dynamic>;
      // Extract the timestamp for each message
      Timestamp messageTimestamp = messageData['timestamp'];
      DateTime messageTime = messageTimestamp.toDate();

      // Compare the timestamp to see if the receiver has sent a new message after this one
      if (messageData['senderID'] == widget.receiverID &&
          messageTime.isAfter(currentMessageTime)) {
        hasReceiverSentNewMessage = true;
        break; // Exit loop once we find a new message from the receiver
      }
    }

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ChatBubble(
        isCurrentUser: isUser,
        message: data['message'],
        messageID: doc.id,
        userID: data['senderID'],
        isRead: isRead,
        timestamp: timestamp,
        isReceiverNewMessage:
            hasReceiverSentNewMessage, // Pass this flag to the ChatBubble
      ),
    );
  }
}

class UserInputField extends StatefulWidget {
  final Function(String message) onSendMessage;

  const UserInputField({super.key, required this.onSendMessage});

  @override
  State<UserInputField> createState() => _UserInputFieldState();
}

class _UserInputFieldState extends State<UserInputField> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      widget.onSendMessage(_messageController.text.trim());
      _messageController.clear();
      setState(() {}); // Update to hide the send button
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              focusNode: _focusNode,
              hintText: 'Type a message',
              obscure: false,
              controller: _messageController,
              keyboardtype: TextInputType.multiline, // Allow multi-line input
              maxLines: null, // Expand to accommodate new lines
              onChanged: (text) {
                setState(() {}); // Trigger rebuild to show/hide send button
              },
              onTap: () {},
              // onSubmitted: (_) {}, // Override onSubmitted to prevent submission
            ),
          ),
          if (_messageController.text.trim().isNotEmpty)
            Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                  color: Colors.blue[700], shape: BoxShape.circle),
              child: Center(
                child: IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(
                    Icons.arrow_upward_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
