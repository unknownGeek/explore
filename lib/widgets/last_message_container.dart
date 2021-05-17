import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/models/message.dart';
import 'package:flutter/material.dart';

class LastMessageContainer extends StatelessWidget {
  final stream;

  LastMessageContainer({
    @required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      // builder: (context, snapshot) {
      //   if (snapshot.hasData) {
      //     var docList = snapshot.data;
      //
      //     if (docList.isNotEmpty) {
      //       Message message = Message.fromJson(docList.last.data);
      //       return SizedBox(
      //         width: MediaQuery.of(context).size.width * 0.6,
      //         child: Text(
      //           message.messageBody,
      //           maxLines: 1,
      //           overflow: TextOverflow.ellipsis,
      //           style: TextStyle(
      //             color: Colors.grey,
      //             fontSize: 14,
      //           ),
      //         ),
      //       );
      //     }
      //     return Text(
      //       "No Message",
      //       style: TextStyle(
      //         color: Colors.grey,
      //         fontSize: 14,
      //       ),
      //     );
      //   }
      //   return Text(
      //     "..",
      //     style: TextStyle(
      //       color: Colors.grey,
      //       fontSize: 14,
      //     ),
      //   );
      // },
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('..',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),);
          default:
            if (snapshot.hasError) {
              return Text('..',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),);
            } else {
              final messages = snapshot.data;

              if (messages.isEmpty) {
                return Text('No Message',
                    style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                ),);
              }

              Message message = messages[messages.length - 1];

              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  message.messageBody,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              );
            }
        }
      },
    );
  }
}
