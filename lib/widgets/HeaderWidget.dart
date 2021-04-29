import 'package:flutter/material.dart';

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
  );
}
