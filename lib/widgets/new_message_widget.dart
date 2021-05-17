import 'package:explore/apis/FirebaseApi.dart';
import 'package:explore/models/message.dart';
import 'package:explore/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ReplyMessageWidget.dart';

class NewMessageWidget extends StatefulWidget {
  final User receiverUser;
  final FocusNode focusNode;
  final Message replyMessage;
  final VoidCallback onCancelReply;

  const NewMessageWidget({
    @required this.receiverUser,
    @required this.focusNode,
    @required this.replyMessage,
    @required this.onCancelReply,
    Key key,
  }) : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message =  '';
  bool isUserWriting = false;

  static final inputTopRadius = Radius.circular(12);
  static final inputBottomRadius = Radius.circular(24);

  void sendMessage() async {
    // FocusScope.of(context).unfocus();
    widget.onCancelReply();

    await FirebaseApi.sendMessage(
      message,
      widget.receiverUser.username,
      widget.receiverUser.id,
      widget.receiverUser.profileName,
      widget.replyMessage,
    );
    _controller.clear();
    setState(() {
      message = '';
      isUserWriting = false;
    });
  }

  Widget buildReply() => Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.deepPurple.withOpacity(0.2),
      borderRadius: BorderRadius.only(
        topLeft: inputTopRadius,
        topRight: inputTopRadius,
      )
    ),
    child: ReplyMessageWidget(
      message: widget.replyMessage,
      onCancelReply: widget.onCancelReply,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isReplying = widget.replyMessage != null;
    return Container(
        color: Colors.black,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  if (isReplying) buildReply(),
                  TextField(
                    focusNode: widget.focusNode,
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    style: TextStyle(color: Colors.white,),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueGrey,
                      hintText: isReplying ? 'Reply...' : 'Message...',
                      prefixIcon: GestureDetector(
                        onTap: () => print('insert_emoticon Tapped!'),
                        child: Icon(Icons.insert_emoticon, size: 28,),
                      ),
                      suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.end, // added line
                        mainAxisSize: MainAxisSize.min, // added line
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => print('attach_file Tapped!'),
                            child: Icon(Icons.attach_file, size: 25,),
                          ),
                          isUserWriting ? Container() : GestureDetector(
                            onTap: () => print('camera_alt Tapped!'),
                            child: Icon(Icons.camera_alt, size: 28,),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.only(
                          topLeft: isReplying ? Radius.zero : inputBottomRadius,
                          topRight: isReplying ? Radius.zero : inputBottomRadius,
                          bottomRight: inputBottomRadius,
                          bottomLeft: inputBottomRadius,
                        ),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() {
                          message = value;
                          isUserWriting = value.length > 0 && value.trim().isNotEmpty;
                        }),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5),
            GestureDetector(
              onTap: message
                  .trim()
                  .isEmpty ? null : sendMessage,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                ),
                child: isUserWriting ? Icon(Icons.send, color: Colors.white,) : Icon(Icons.mic, color: Colors.white,),
              ),
            ),
          ],
        ),
      );
  }
}
