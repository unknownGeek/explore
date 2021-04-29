import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/EditProfilePage.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:explore/widgets/PostTileWidget.dart';
import 'package:explore/widgets/PostWidget.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import 'package:explore/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  bool loading = false;
  bool isFollowing;
  final String currentOnlineUserId = currentUser.id;
  int id = 0;
  int countPost = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> postsList = [];
  String postOrientation = "grid";
  User profileUser;

  @override
  void initState() {
    super.initState();
    getAllProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc =
    await followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowing() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(widget.userProfileId)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followingCount = querySnapshot.documents.length;
    });
  }

  getFollowers() async {
    QuerySnapshot querySnapshot = await followersReference
        .document(widget.userProfileId)
        .collection('userFollowers')
        .getDocuments();

    setState(() {
      followerCount = querySnapshot.documents.length;
    });
  }

  createProfileTopView() {
    return FutureBuilder(
      future: userReference.document(widget.userProfileId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return Container();
        }
        User user = User.fromDocument(dataSnapshot.data);
        return Padding(
          padding: EdgeInsets.all(17.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createColumns("Posts", countPost.toString()),
                            createColumns("Followers", followerCount.toString()),
                            createColumns("Following", followingCount.toString()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5.0),
                child: Text(
                  user.profileName,
                  style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 3.0),
                child: Text(
                  user.bio,
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Column createColumns(String title, String countStr) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          countStr.toString(),
          style: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  buildProfileButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(title: "Edit Profile", performFunction: editUserProfile,);
    } else if (isFollowing) {
      return createButtonTitleAndFunction(title: "Unfollow", performFunction: handleUnfollowUser,);
    } else if (!isFollowing) {
      return createButtonTitleAndFunction(title: "Follow", performFunction: handleFollowUser,);
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersReference
        .document(widget.userProfileId)
        .collection('userFollowers')
        .document(currentOnlineUserId)
        .get().then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
    });

    // remove following
    followingReference
        .document(currentOnlineUserId)
        .collection('userFollowing')
        .document(widget.userProfileId)
        .get().then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });

    // delete activity feed item for them
    activityFeedReference
        .document(widget.userProfileId)
        .collection('feedItems')
        .document(currentOnlineUserId)
        .get().then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
      });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers
    // collection)
    followersReference
    .document(widget.userProfileId)
    .collection('userFollowers')
    .document(currentOnlineUserId)
    .setData({});

    // Put THAT user on YOUR following collection (update your
    // following collection)
    followingReference
        .document(currentOnlineUserId)
        .collection('userFollowing')
        .document(widget.userProfileId)
        .setData({});

    // add activity feed item for THAT user to notify about new follower (us)
    activityFeedReference
    .document(widget.userProfileId)
    .collection('feedItems')
    .document(currentOnlineUserId)
    .setData({
      "type": "follow",
      "ownerId": widget.userProfileId,
      "username": currentUser?.username,
      "userId": currentOnlineUserId,
      "timestamp": DateTime.now(),
      "userProfileImg": currentUser?.url,
      "timestamp": DateTime.now(),
    });
  }

  createButtonTitleAndFunction({String title, Function performFunction}) {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 220.0,
          height: 26.0,
          child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ownProfile ? Colors.black : (isFollowing ? Colors.black : Colors.blueAccent),
            border: Border.all(color: ownProfile ? Colors.grey : (isFollowing ? Colors.grey : Colors.blueAccent),),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(currentOnlineUserId: currentOnlineUserId))).then(onGoBack);
  }

  /// Method to refresh data while going back to this page
  /// Here id is an example to update it
  void refreshData() {
    // id++;
  }

  FutureOr onGoBack(dynamic value) {
    refreshData();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
          context,
          strTitle: profileUser != null && profileUser.username != null ? profileUser.username : "Profile"),
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(height: 0.0,),
          displayProfilePost(),
        ],
      ),
    );
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(Icons.photo_library, color: Colors.grey, size: 200.0,),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text("No Posts", style: TextStyle(color: Colors.redAccent, fontSize: 40.0, fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTilesList = [];
      postsList.forEach((eachPost) {
        gridTilesList.add(GridTile(child: PostTile(eachPost)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postsList,
      );
    }
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot userPostQuerySnapshot = await postsReference.document(widget.userProfileId).collection("usersPosts").orderBy("timestamp", descending: true).getDocuments();

    DocumentSnapshot profileUserDocumentSnapshot = await userReference.document(widget.userProfileId).get();
    profileUser = User.fromDocument(profileUserDocumentSnapshot);

    setState(() {
      loading = false;
      countPost = userPostQuerySnapshot.documents.length;
      postsList = userPostQuerySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });
  }

  createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.grid_on),
            color: postOrientation == "grid" ? Theme.of(context).primaryColor : Colors.grey,
            onPressed: () => setOrientation("grid"),
        ),
        IconButton(
            icon: Icon(Icons.list),
            color: postOrientation == "list" ? Theme.of(context).primaryColor : Colors.grey,
            onPressed: () => setOrientation("list"),
        ),
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}