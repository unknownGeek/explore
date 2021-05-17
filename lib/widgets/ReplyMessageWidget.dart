import 'package:explore/apis/FirebaseApi.dart';
import 'package:explore/models/message.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

import 'message_widget.dart';


class ReplyMessageWidget extends StatelessWidget {
  final Message message;
  final VoidCallback onCancelReply;

  const ReplyMessageWidget({
    @required this.message,
    @required this.onCancelReply,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      children: [
        Container(
          color: Colors.green,
          width: 4,
        ),
        const SizedBox(width: 8,),
        Expanded(
          child: buildReplyMessage(),
        ),
        const SizedBox(height: 42,),
      ],
    ),
  );

  buildReplyMessage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              onCancelReply != null ?
              'replying to ${message.senderProfileName != null ? message.senderProfileName : message.senderUsername}'
               : 'replied to ${message.senderProfileName != null ? message.senderProfileName : message.senderUsername}',
              style: TextStyle(color: Colors.grey,),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onCancelReply != null)
            GestureDetector(
                child: Icon(Icons.close, size: 20, color: Colors.white,),
                onTap: onCancelReply,
            ),
        ],
      ),
      const SizedBox(height: 8,),
      Text(
        message.messageBody,
        style: TextStyle(color: Colors.white,),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),

    ],
  );
}
