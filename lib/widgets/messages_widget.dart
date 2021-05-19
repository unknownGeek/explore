import 'package:explore/apis/FirebaseApi.dart';
import 'package:explore/models/message.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

import 'ProgressWidget.dart';
import 'message_widget.dart';


class MessagesWidget extends StatelessWidget {
  final User friendUser;
  final ValueChanged<Message> onSwipedMessage;

  const MessagesWidget({
    @required this.friendUser,
    @required this.onSwipedMessage,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Message>>(
        stream: FirebaseApi.listenToMessagesInRealTime(friendUser.id, currentUser?.id),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: circularProgress());
            default:
              if (snapshot.hasError) {
                return buildText('Something Went Wrong Try later');
              } else {
                final messages = snapshot.data;

                return messages.isEmpty
                    ? buildText('Say Hi..')
                    : ListView.builder(
                        physics: BouncingScrollPhysics(),
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];

                          return SwipeTo(
                            onRightSwipe: () => onSwipedMessage(message),
                            iconColor: Colors.white,
                            child: MessageWidget(
                              message: message,
                              isMe: message.senderId == currentUser?.id,
                              friendUser: friendUser,
                              // since messages[] is reversed already, so (index-1) will give next message
                              nextMessage: messages[index == 0 ? index : (index - 1)],
                            ),
                          );
                        },
                      );
              }
          }
        },
      );

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.deepPurple),
        ),
      );
}
