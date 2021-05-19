

import 'package:cached_network_image/cached_network_image.dart';
import 'package:explore/apis/FirebaseApi.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/ActivityPage.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:explore/pages/chatPage.dart';
import 'package:flutter/material.dart';

import 'OnlineDotIndicator.dart';
import 'last_message_container.dart';

class ChatBodyWidget extends StatefulWidget {
  final List<User> users;
  final bool isFavChatWidgetView;

  const ChatBodyWidget({
    @required this.users,
    @required this.isFavChatWidgetView,
    Key key,
  }) : super(key: key);


  @override
  _ChatBodyWidgetState createState() {
    return _ChatBodyWidgetState();
  }
}

class _ChatBodyWidgetState extends State<ChatBodyWidget> {
  double topContainer = 0;
  final ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(25),//25
        //   topRight: Radius.circular(25),//25
        // ),
      ),
      child: buildChats(),
    ),
  );

  Widget buildChats() => ListView.builder(
    controller: scrollController,
    physics: BouncingScrollPhysics(),
    itemBuilder: (context, index) {
      final user = widget.users[index];
      double scale = 1.0;
      if (topContainer > 0.5) {
        scale = index + 0.5 - topContainer;
        if (scale < 0) {
          scale = 0;
        } else if (scale > 1) {
          scale = 1;
        }
      }
      return Opacity(
        opacity: scale,
        child: Transform(
          transform: Matrix4.identity()..scale(scale, scale),
          alignment: Alignment.bottomCenter,
          child: Align(
            heightFactor: 0.7,
            alignment: Alignment.topCenter,
            child: Container(
                height: 80,
                margin: widget.isFavChatWidgetView ? const EdgeInsets.symmetric(horizontal: 150, vertical: 10)
                    : const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.deepPurple,
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0)],
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatPage(friendUser: user),
                    ));
                  },
                  leading: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => showProfile(context, profileId: user.id),
                        child: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url), backgroundColor: Colors.grey, radius: 25,),
                      ),
                      OnlineDotIndicator(userId: user.id,),
                    ],
                  ),
                  title: widget.isFavChatWidgetView ? Text('') : Text(
                    user.profileName,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // subtitle: LastMessageContainer(
                  //   stream: FirebaseApi.listenToLastMessagesInRealTime(user.id, currentUser?.id),
                  // ),
                )
            ),
          ),
        ),
      );
    },
    itemCount: widget.users.length,
  );

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {

      double value = scrollController.offset/70;

      setState(() {
        topContainer = value;
      });
    });
  }

}



