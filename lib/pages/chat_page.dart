import 'dart:async';

import 'package:chat/components/chat_style.dart';
import 'package:chat/components/user_input.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.receiver,
    required this.receiverID,
    this.receiverProfilePicUrl, // Add profile picture URL
    required this.ontap,
  });

  final String receiver;
  final String receiverID;
  final String? receiverProfilePicUrl; // Nullable profile picture URL
  final Function()? ontap;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ChatService chat = ChatService();
  final Authservice auth = Authservice();
  StreamSubscription? _messageSubscription;
  bool _isChatPageActive = false;

  @override
  void initState() {
    super.initState();
    _isChatPageActive = true; // Mark the page as active

    // Start listening for unread messages as soon as the page is opened
    _startMessageListener();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // When focus is gained, scroll down
        Future.delayed(const Duration(milliseconds: 500), scrollDown);
      }
    });
  }

  @override
  void dispose() {
    _isChatPageActive = false; // Mark the page as inactive when disposed
    _messageSubscription?.cancel(); // Cancel the subscription
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Method to mark messages as read
  Future<void> markMessagesAsRead(
      String currentUserId, String receiverId) async {
    final messagesRef = FirebaseFirestore.instance.collection('messages');
    final unreadMessages = await messagesRef
        .where('receiverID', isEqualTo: currentUserId)
        .where('senderID', isEqualTo: receiverId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      await messagesRef.doc(doc.id).update({'isRead': true}).catchError((e) {
        print("Error updating received message ${doc.id}: $e");
      });
    }
  }

  /// Marks messages as read automatically once a message is sent.
  Future<void> markMessageAsReadOnSend(String receiverId) async {
    String currentUserId = auth.currentUser()!.uid;

    final messagesRef = FirebaseFirestore.instance.collection('messages');
    final unreadMessages = await messagesRef
        .where('receiverID', isEqualTo: currentUserId)
        .where('senderID', isEqualTo: receiverId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      await messagesRef.doc(doc.id).update({'isRead': true}).catchError((e) {
        print("Error updating received message ${doc.id}: $e");
      });
    }
  }

  /// Starts the listener to detect new messages and automatically marks them as read.
  void _startMessageListener() {
    String currentUserId = auth.currentUser()!.uid;
    String receiverId = widget.receiverID;

    // Listen for unread messages in Firestore and automatically mark them as read
    _messageSubscription = FirebaseFirestore.instance
        .collection('messages')
        .where('receiverID', isEqualTo: currentUserId)
        .where('senderID', isEqualTo: receiverId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (_isChatPageActive) {
        for (var doc in snapshot.docs) {
          // Mark message as read when the page is active
          FirebaseFirestore.instance
              .collection('messages')
              .doc(doc.id)
              .update({'isRead': true}).catchError((e) {
            print("Error updating received message ${doc.id}: $e");
          });
        }
      }
    });

    // Mark all messages as read when the page is opened
    markMessagesAsRead(currentUserId, receiverId);
  }

  /// Scrolls to the bottom of the message list.
  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  /// Generates a consistent color based on the receiver's name.
  Color _getAvatarColor(String name) {
    int hash = name.hashCode;
    return Color((hash & 0xFFFFFF) | 0xFF000000).withOpacity(0.7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Display receiver profile picture or initials in avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.receiverProfilePicUrl == null ||
                      widget.receiverProfilePicUrl!.isEmpty
                  ? _getAvatarColor(widget.receiver)
                  : Theme.of(context).colorScheme.secondary,
              backgroundImage: widget.receiverProfilePicUrl != null &&
                      widget.receiverProfilePicUrl!.isNotEmpty
                  ? NetworkImage(widget.receiverProfilePicUrl!)
                  : null,
              child: widget.receiverProfilePicUrl == null ||
                      widget.receiverProfilePicUrl!.isEmpty
                  ? Text(
                      widget.receiver[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8.0),
            GestureDetector(
              onTap: widget.ontap,
              child: Text(
                widget.receiver,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildMessageList()),
          UserInputField(
            onSendImage: (imageFile) async {
              await chat.sendImageMessage(widget.receiverID, imageFile);
              // Mark messages as read when an image is sent
              await markMessageAsReadOnSend(widget.receiverID);
              scrollDown();
            },
            onSendMessage: (message) async {
              await chat.sendMessage(widget.receiverID, message: message);
              // Mark messages as read when a text message is sent
              await markMessageAsReadOnSend(widget.receiverID);
              scrollDown();
            },
          ),
        ],
      ),
    );
  }

  /// Builds the list of messages between the current user and the receiver.
  Widget _buildMessageList() {
    String senderId = auth.currentUser()!.uid;

    return StreamBuilder(
      stream: chat.getMessages(widget.receiverID, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading messages.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              children: [
                const Text('Loading...'),
                const SizedBox(height: 10),
                Lottie.asset(
                  'assets/Animation - 1730069741511.json',
                  height: 150,
                  width: 150,
                  frameRate: const FrameRate(60),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }

        // Scroll down when data is available
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

  /// Builds a single message item.
  Widget _buildMessageItem(
      DocumentSnapshot doc, AsyncSnapshot<QuerySnapshot> snapshot) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isUser = data['senderID'] == auth.currentUser()!.uid;
    bool isRead = data['isRead'] ?? false;
    Timestamp timestamp = data['timestamp'];
    String? imageUrl = data['imageUrl'];

    bool hasReceiverSentNewMessage = false;
    DateTime currentMessageTime = timestamp.toDate();

    for (var message in snapshot.data!.docs) {
      Map<String, dynamic> messageData = message.data() as Map<String, dynamic>;
      Timestamp messageTimestamp = messageData['timestamp'];
      DateTime messageTime = messageTimestamp.toDate();

      if (messageData['senderID'] == widget.receiverID &&
          messageTime.isAfter(currentMessageTime)) {
        hasReceiverSentNewMessage = true;
        break;
      }
    }

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ChatBubble(
        isCurrentUser: isUser,
        message: data['message'] ?? '',
        messageID: doc.id,
        userID: data['senderID'],
        isRead: isRead,
        timestamp: timestamp,
        isReceiverNewMessage: hasReceiverSentNewMessage,
        imageUrl: imageUrl,
      ),
    );
  }
}
