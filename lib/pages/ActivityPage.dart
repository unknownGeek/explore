import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:explore/pages/PostScreenPage.dart';
import 'package:explore/pages/ProfilePage.dart';
import 'package:explore/widgets/HeaderWidget.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {

  getActivityFeed() async {
    QuerySnapshot querySnapshot = await activityFeedReference
        .document(currentUser?.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();

    List<ActivityItem> feedItems = [];
    querySnapshot.documents.forEach((doc) {
      feedItems.add(ActivityItem.fromDocument(doc));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Activity"),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  final String url;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityItem({
    this.username,
    this.userId,
    this.type,
    this.url,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  });

  factory ActivityItem.fromDocument(DocumentSnapshot doc) {
    return ActivityItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      url: doc['url'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreenPage(
              postId: postId,
              userId: currentUser?.id,
            )
        ));
  }

  configureMediaPreview(context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(url),
                  ),
                ),
              ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'like') {
      activityItemText = "liked your post.";
    } else if (type == 'follow') {
      activityItemText = "started following you.";
    } else if (type == 'comment') {
      activityItemText = "commented: $commentData";
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.black,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: ' $activityItemText',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

 showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ProfilePage(
                userProfileId: profileId,
              )
      ));
 }
