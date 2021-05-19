
import 'package:explore/apis/FirebaseApi.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:explore/todo_button/add_todo_button.dart';
import 'package:explore/widgets/HeaderWidget.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import 'package:explore/widgets/chat_body_widget.dart';
import 'package:explore/widgets/chat_header_widget.dart';
import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  final ScrollController scrollController = ScrollController();
  bool closeTopContainer = false;


  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 1500),
        child: StreamBuilder<List<User>>(
          stream: FirebaseApi.getUsers(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: circularProgress());
              default:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return buildText('Something Went Wrong, Try later!');
                } else {
                  var users = snapshot.data;
                  users = users.where((user) => user.id != currentUser?.id).toList();

                  if (users.isEmpty) {
                    return buildText('No Users Found!');
                  } else
                    return Column(
                      children: [
                        ChatHeaderWidget(users: users),
                        ChatBodyWidget(
                          users: users,
                          isFavChatWidgetView: false,
                        ),
                      ],
                    );
                }
            }
          },
        ),
        builder: (context, value, child) {
          return ShaderMask(shaderCallback: (rect) {
            return RadialGradient(
              radius: value * 5,
              colors: [Colors.white, Colors.white, Colors.transparent, Colors.transparent],
              stops: [0.00, 0.55, 0.60, 1.00],
              center: FractionalOffset(0.95, 0.05),
            ).createShader(rect);
          }, child: child);
        },
      ),
    ),
  );

  Widget buildText(String text) => Center(
    child: Text(
      text,
      style: TextStyle(fontSize: 24, color: Colors.white),
    ),
  );
}