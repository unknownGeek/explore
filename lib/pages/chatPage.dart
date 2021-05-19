import 'package:explore/models/message.dart';
import 'package:explore/models/user.dart';
import 'package:explore/widgets/messages_widget.dart';
import 'package:explore/widgets/new_message_widget.dart';
import 'package:explore/widgets/profile_header_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final User friendUser;

  const ChatPage({
    @required this.friendUser,
    Key key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final focusNode = FocusNode();
  Message replyMessage;

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    body: SafeArea(
      child: Column(
        children: [
          ProfileHeaderWidget(user: widget.friendUser),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: MessagesWidget(
                  friendUser: widget.friendUser,
                  onSwipedMessage: (message) {
                    replyToMessage(message);
                    focusNode.requestFocus();
                  }
              ),
            ),
          ),
          NewMessageWidget(
              focusNode: focusNode,
              receiverUser: widget.friendUser,
              replyMessage: replyMessage,
              onCancelReply: onCancelReply,
          ),
        ],
      ),
    ),
  );

  replyToMessage(message) {
    setState(() {
      replyMessage = message;
    });
  }

  onCancelReply() {
    setState(() {
      replyMessage = null;
    });
  }

}