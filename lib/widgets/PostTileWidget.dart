import 'package:explore/pages/PostScreenPage.dart';
import 'package:explore/utils/AppConstants.dart';
import 'package:explore/widgets/PostWidget.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {

  final Post post;

  PostTile(this.post);

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreenPage(
              postId: post.postId,
              userId: post.ownerId,
            )));
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child:
      loadFireStoreImages ? Image.network(post.url)
        : Container(
          height: 200.0,
          width: 350.0,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text("Couldn't load image.", style: TextStyle(color: Colors.white, fontSize: 7.0, fontWeight: FontWeight.normal),),
              ),
            ],
          ),
        ),
      onTap: () => showPost(context),
    );
  }
}
