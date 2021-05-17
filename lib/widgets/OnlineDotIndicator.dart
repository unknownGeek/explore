import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/apis/FirebaseApi.dart';
import 'package:explore/enums/UserState.dart';
import 'package:explore/models/user.dart';
import 'package:explore/utils/Utils.dart';
import 'package:flutter/material.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String userId;

  OnlineDotIndicator({
    @required this.userId,
});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseApi.getUserStream(userId: userId),
      builder: (context, snapshot) {
        User user;

        if (snapshot.hasData) {
          user = User.fromDocument(snapshot.data);
        }

        return Container(
          height: 10,
          width: 10,
          margin: EdgeInsets.only(right: 8, top: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Utils.getColor(user?.state),
          ),
        );
      },
    );
  }

}