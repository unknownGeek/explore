
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:explore/widgets/HeaderWidget.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'ActivityPage.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postUrl;

  CommentsPage({
    this.postId,
    this.postOwnerId,
    this.postUrl,
});

  @override
  CommentsPageState createState() => CommentsPageState(
    postId: this.postId,
    postOwnerId: this.postOwnerId,
    postUrl: this.postUrl,
  );
}

class CommentsPageState extends State<CommentsPage> {
  final String postId;
  final String postOwnerId;
  final String postUrl;

  TextEditingController commentController = TextEditingController();

  CommentsPageState({
    this.postId,
    this.postOwnerId,
    this.postUrl,
  });

  buildComments() {
    return StreamBuilder(
      stream: commentsReference.document(postId).collection('comments')
        .orderBy("timestamp", descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(children: comments,);
      },
    );
  }

  addComment() {
    commentsReference
    .document(postId)
        .collection("comments")
        .add({
      "username": currentUser.username,
      "comment": commentController.text,
      "timestamp": DateTime.now(),
      "avatarUrl": currentUser.url,
      "userId": currentUser.id,
    });

    bool isNotPostOwner = postOwnerId != currentUser?.id;

    if (isNotPostOwner) {
      activityFeedReference
          .document(postOwnerId)
          .collection('feedItems')
          .add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": DateTime.now(),
        "postId": postId,
        "userId": currentUser?.id,
        "username": currentUser?.username,
        "userProfileImg": currentUser?.url,
        "url": postUrl,
      });
    }

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text(
                "Post",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16.0,
                ),),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: CircleAvatar(backgroundColor: Colors.black, backgroundImage: CachedNetworkImageProvider(avatarUrl),),
          ),
          title: Text(
            comment,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          trailing: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: Text("$username ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          ),
        ),
      ],
    );
  }
}

