import 'package:explore/pages/HomePage.dart';
import 'package:explore/widgets/HeaderWidget.dart';
import 'package:explore/widgets/PostWidget.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class PostScreenPage extends StatelessWidget {
  final String userId;
  final String postId;
  
  PostScreenPage({
    this.userId,
    this.postId,
});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsReference
          .document(userId)
      .collection('usersPosts')
      .document(postId)
      .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: "Photo"),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
