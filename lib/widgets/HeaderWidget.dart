import 'package:explore/pages/ChatsPage.dart';
import 'package:explore/pages/FollowRequestsPage.dart';
import 'package:explore/todo_button/add_todo_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'StaggeredGridWidget.dart';

AppBar header(context, {bool isAppTitle = false, String strTitle, disappearedBackButton=false, bool isActivityPage = false}) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    automaticallyImplyLeading: !disappearedBackButton,
    title: Text(
      isAppTitle ? "Explore" : strTitle,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 45.0 : 22.0,
        fontWeight: isAppTitle ? FontWeight.normal : FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: isAppTitle,
    backgroundColor: Theme.of(context).accentColor,
    brightness: Brightness.dark, // status bar brightness
    actions: <Widget>[
      if (isAppTitle)
        IconButton(
          icon: Icon(
            FontAwesomeIcons.rocketchat,
            size: 20.0,
            color: Colors.white,
          ),
          onPressed: () => navigateToChats(context),
        ),
      if (isActivityPage)
        IconButton(
          icon: Icon(
            FontAwesomeIcons.userPlus,
            size: 20.0,
            color: Colors.white,
          ),
          onPressed: () => navigateToFollowRequests(context),
        ),
      if (isActivityPage)
        IconButton(
          icon: Icon(
            FontAwesomeIcons.photoVideo,
            size: 20.0,
            color: Colors.white,
          ),
          onPressed: () => navigateToExperiment(context),
        )
    ],
  );
}

navigateToChats(context) {
  Navigator.of(context).push(
      PageRouteBuilder(
          pageBuilder: (context, animation, _) {
            return ChatsPage();
          }, opaque: false,
      )
  );
}

navigateToFollowRequests(context) {
  Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            FollowRequestsPage(),
            const Align(
              alignment: Alignment.bottomRight,
              child: AddTodoButton(),
            ),
          ],
        ),
      )
  );
}


navigateToExperiment(context) {
  Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Stack(
          children: [
            StaggeredGridWidget(),
            const Align(
              alignment: Alignment.bottomRight,
              child: AddTodoButton(),
            ),
          ],
        ),
      )
  );
}
