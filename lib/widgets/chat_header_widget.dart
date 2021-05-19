
import 'package:cached_network_image/cached_network_image.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/chatPage.dart';
import 'package:explore/todo_button/add_todo_button.dart';
import 'package:explore/utils/Utils.dart';
import 'package:flutter/material.dart';

import 'OnlineDotIndicator.dart';

class ChatHeaderWidget extends StatelessWidget {
  final List<User> users;

  const ChatHeaderWidget({
    @required this.users,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),//25
            bottomRight: Radius.circular(25),
            topRight: Radius.circular(25),//25
            topLeft: Radius.circular(25),//25
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        width: double.infinity,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    'Chats',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Signatra',
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: 60,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: users.length+1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return GestureDetector(
                          onTap: () => print('Chat Search Tapped!'),
                          child: Container(
                            margin: EdgeInsets.only(right: 12),
                            child: CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.search, color: Colors.white, size: 30,),
                            ),
                          ),
                        );
                      } else {
                        final user = users[index-1];
                        return Container(
                          margin: const EdgeInsets.only(right: 20),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ChatPage(friendUser: user),
                                  ));
                                },
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url), backgroundColor: Colors.grey, radius: 30,),
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: new Border.all(
                                      color: Utils.getColor(user?.state),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                              // OnlineDotIndicator(userId: user.id,),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.topRight,
              child: AddTodoButton(),
            ),
          ],
        ),
      );
}
