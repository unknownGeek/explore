import 'package:explore/pages/ChatsPage.dart';
import 'package:flutter/material.dart';

import 'chat_body_widget.dart';

AppBar header(context, {bool isAppTitle = false, String strTitle, disappearedBackButton=false}) {
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
    actions: <Widget>[
      if (isAppTitle)
        IconButton(
          icon: Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
          ),
          onPressed: () => navigateToChats(context),
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
