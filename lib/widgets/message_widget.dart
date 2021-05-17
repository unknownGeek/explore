import 'package:cached_network_image/cached_network_image.dart';
import 'package:explore/models/message.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/ActivityPage.dart';
import 'package:explore/widgets/ReplyMessageWidget.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool isMe;
  final User friendUser;
  final Message nextMessage;

  const MessageWidget({
    @required this.message,
    @required this.isMe,
    @required this.friendUser,
    @required this.nextMessage,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(20);
    final borderRadius = BorderRadius.all(radius);
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          (nextMessage == message || (nextMessage.senderId != message.senderId)) ? GestureDetector(
            onTap: () => showProfile(context, profileId: friendUser.id),
            child: CircleAvatar(backgroundImage: CachedNetworkImageProvider(friendUser.url), backgroundColor: Colors.grey, radius: 16,),
          ) : CircleAvatar(backgroundColor: Colors.black, radius: 16,),
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(nextMessage.senderId == message.senderId ? 2 : 6),
          constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
          decoration: BoxDecoration(
            color: isMe ? Theme.of(context).primaryColor : Colors.blueGrey,
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() {
    final messageWidget =

    // Row(
    //   children: [
    //     Expanded(
    //       child: Text(
    //         message.messageBody,
    //         style: TextStyle(color: Colors.white),
    //         textAlign: TextAlign.start,
    //       ),
    //     ),
    //     Text(
    //       message.createdAt.toLocal().toIso8601String().split('T')[1].substring(0, 5),
    //       style: TextStyle(color: Colors.black.withOpacity(0.7)),
    //       // textAlign: TextAlign.start,
    //     ),
    //   ],
    // );

    Text(
      message.messageBody,
      style: TextStyle(color: Colors.white),
      textAlign: TextAlign.start,
    );

    if (message.replyMessage == null) {
      return messageWidget;
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildReplyMessage(),
          messageWidget,
        ],
      );
  }

  buildReplyMessage() {
    final replyMessage = message.replyMessage;
    final isReplying = replyMessage != null;

    if (!isReplying) {
      return Container();
    }
    final inputTopRadius = Radius.circular(10);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: inputTopRadius,
                topRight: inputTopRadius,
              )
          ),
          child: ReplyMessageWidget(message: replyMessage,),
          // color: Colors.,
        ),
        const SizedBox(height: 8,),
      ],
    );
  }

}
