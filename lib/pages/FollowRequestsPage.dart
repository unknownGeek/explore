import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:explore/pages/ProfilePage.dart';
import 'package:explore/widgets/HeaderWidget.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;


class FollowRequestsPage extends StatefulWidget {
  @override
  _FollowRequestsPageState createState() => _FollowRequestsPageState();
}

class _FollowRequestsPageState extends State<FollowRequestsPage> {

  getReceivedFollowRequests() async {
    QuerySnapshot querySnapshot = await requestsReceivedReference
        .document(currentUser?.id)
        .collection('receivedFollowRequests')
        .getDocuments();

    List<FollowRequest> followRequests = [];
    querySnapshot.documents.forEach((doc) {
      followRequests.add(FollowRequest.fromDocument(doc));
    });
    return followRequests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Follow Requests"),
      body: Container(
        child: FutureBuilder(
          future: getReceivedFollowRequests(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return snapshot.data.length > 0 ?
            ListView(
              children: snapshot.data,
            )
            : Center(
              child: Text(
                'No Pending Requests!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FollowRequest extends StatelessWidget {
  final String username;
  final String userId;
  final String profileName;
  final String url;
  final Timestamp createdDate;

  FollowRequest({
    this.username,
    this.userId,
    this.profileName,
    this.url,
    this.createdDate,
  });

  factory FollowRequest.fromDocument(DocumentSnapshot doc) {
    return FollowRequest(
      username: doc['username'],
      userId: doc['userId'],
      profileName: doc['profileName'],
      url: doc['url'],
      createdDate: doc['createdDate'],
    );
  }


  @override
  Widget build(BuildContext context) {
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
                    text: ' wants to follow you.',
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
              backgroundImage: CachedNetworkImageProvider(url),
            ),
          ),
          subtitle: Column(
            children: [
              Row(
                children: [
                  Text(
                    timeago.format(createdDate.toDate()),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(icon: Icon(Icons.done, color: Colors.green,), onPressed: acceptFollowRequest),
                  IconButton(icon: Icon(Icons.cancel, color: Colors.red), onPressed: cancelFollowRequest),
                ],
              ),
            ],
          ),
          // trailing:
          //     Text(
          //       timeago.format(createdDate.toDate()),
          //       overflow: TextOverflow.ellipsis,
          //       style: TextStyle(
          //         color: Colors.grey,
          //       ),
          //     ),
        ),
      ),
    );
  }

  cancelFollowRequest() {
    // remove sent request
    requestsSentReference
        .document(userId)
        .collection('sentFollowRequests')
        .document(currentUser?.id)
        .get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // remove received request
    requestsReceivedReference
        .document(currentUser?.id)
        .collection('receivedFollowRequests')
        .document(userId)
        .get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  acceptFollowRequest() {
    cancelFollowRequest();

    followersReference
        .document(currentUser?.id)
        .collection('userFollowers')
        .document(userId)
        .setData({});

    followingReference
        .document(userId)
        .collection('userFollowing')
        .document(currentUser?.id)
        .setData({});

    // add activity feed item for THAT user to notify about new follower (us)
    activityFeedReference
        .document(currentUser?.id)
        .collection('feedItems')
        .document(userId)
        .setData({
      "type": "follow",
      "ownerId": currentUser?.id,
      "username": username,
      "userId": userId,
      "timestamp": DateTime.now(),
      "userProfileImg": url,
      "timestamp": DateTime.now(),
    });
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
}

