import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/ActivityPage.dart';
import 'package:explore/pages/CommentsPage.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;

  Post({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }
    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        ++counter;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    likes: this.likes,
    username: this.username,
    description: this.description,
    location: this.location,
    url: this.url,
    likeCount: getTotalNumberOfLikes(this.likes),
  );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.id;

  _PostState({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    isLiked = hasCurrentUserLikedThePost();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }



  createPostHead() {
    return FutureBuilder(
        future: userReference.document(ownerId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          bool isPostOwner = currentOnlineUserId == ownerId;

          return ListTile(
            leading: GestureDetector(
              onTap: () => showProfile(context, profileId: currentOnlineUserId),
              child: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url), backgroundColor: Colors.grey,),
            ),
            title: GestureDetector(
              onTap: () => showProfile(context, profileId: currentOnlineUserId),
              child: Text(
                user.username,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(location, style: TextStyle(color: Colors.white),),
            trailing: isPostOwner ? IconButton(
                icon: Icon(Icons.more_vert),
                color: Colors.white,
                onPressed: () => handleDeletePost(context),
            ) : Text(""),
          );
        }
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
    context: parentContext,
      builder: (context) {
      return SimpleDialog(
        title: Text("Delete this post?", style: TextStyle(color: Colors.white),),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              deletePost();
            },
            child: Text("Delete", style: TextStyle(color: Colors.red),),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white),),
          ),
        ],
      );
      }
    );
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so
  // they can be used interchangeably
  deletePost() async {
    // delete the post
    postsReference
      .document(ownerId)
        .collection('usersPosts')
        .document(postId)
        .get().then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });

    // delete uploaded image for the post
    storageReference
        .child("post_$postId.jpg")
          .delete();

    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedReference
      .document(ownerId)
        .collection("feedItems")
          .where('postId', isEqualTo: postId)
            .getDocuments();

    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //then delete all comments
    QuerySnapshot commentsSnapshot = await commentsReference
      .document(postId)
        .collection('comments')
          .getDocuments();

    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  hasCurrentUserLikedThePost() {
    return likes[currentOnlineUserId] == true;
  }

  handleLikePost() {
    // Fetching current user's like on the post
    // whether it's already liked or not
    bool _isLiked = hasCurrentUserLikedThePost();

    // Toggle current user's like on the post in the collection DB
    postsReference
        .document(ownerId)
        .collection("usersPosts")
        .document(postId)
        .updateData({'likes.$currentOnlineUserId': !_isLiked});

    if (_isLiked) {
      removeLikeFromActivityFeed();
    } else {
      addLikeToActivityFeed();
    }

    setState(() {
      // Toggle current user's like on the post
      likes[currentOnlineUserId] = isLiked = !_isLiked;

      // Update the likes count after toggling
      _isLiked ? --likeCount : ++likeCount;

      // If the post wasn't liked already and got liked now after toggling,
      // need to show a Heart on the post
      if (!_isLiked) {
        showHeart = true;
      }
    });

    // Set timer for showing the Heart on the post
    // And as part of its anonymous callback method, toggle
    // showHeart to get it disappeared
    Timer(Duration(milliseconds: 400), (){
      setState(() {
        showHeart = false;
      });
    });
  }


  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if
    // comment made by OTHER user (to avoid getting notification for
    // our own like)
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner){
      activityFeedReference
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser?.username,
        "userId": currentUser?.id,
        "userProfileImg": currentUser?.url,
        "postId": postId,
        "url": url,
        "timestamp": DateTime.now(),
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: 400.0,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: url,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
              placeholder: (context, url) => circularProgress(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          animateHeart(),
        ],
      ),
    );
  }


  animateHeart() {
    return showHeart ? Icon(
      FontAwesomeIcons.solidHeart,
      size: 100.0,
      color: Colors.redAccent,
    ) : Text("");

    // return showHeart ? getAnimatedHeart() : Text("");
  }

  // getAnimatedHeart() {
  //
  //   return Animator(
  //     // duration: Duration(milliseconds: 300),
  //     tween: Tween(begin: 0.8, end: 1.4),
  //     // curve: Curves.elasticOut,
  //     cycles: 0,
  //     builder: (context, animatorState, child) => Center(
  //       child: Container(
  //         margin: EdgeInsets.symmetric(vertical: 10),
  //         height: animatorState.value,
  //         width: animatorState.value,
  //         child: Icon(
  //           Icons.favorite,
  //           size: 80.0,
  //           color: Colors.pink,
  //         ),
  //       ),
  //     ),
  //   );
  // }


  showComments(BuildContext context, {String postId, String ownerId, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentsPage(
          postId: postId,
          postOwnerId: ownerId,
          postUrl: url
      );
    }));
  }

  createPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? FontAwesomeIcons.heartbeat : FontAwesomeIcons.heartBroken,
                color: isLiked ? Colors.red : Colors.white,
                size: 20.0,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                url: url,
              ),
              child: Icon(
                FontAwesomeIcons.comments,
                size: 20.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text("$username ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            ),
            Expanded(
              child: Text(description, style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ],
    );
  }
}
