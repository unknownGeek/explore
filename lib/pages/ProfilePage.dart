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
  final String currentOnlineUserId = currentUser.id;
  int id = 0;
  int countPost = 0;
  List<Post> postsList = [];
  String postOrientation = "grid";

  void initState() {
    getAllProfilePosts();
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
                            createColumns("Followers", "19M"),
                            createColumns("Following", "4"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Container(
              //   alignment: Alignment.centerLeft,
              //   padding: EdgeInsets.only(top: 13.0),
              //   child: Text(
              //     user.username,
              //     style: TextStyle(fontSize: 14.0, color: Colors.white),
              //   ),
              // ),
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

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(title: "Edit Profile", performFunction: editUserProfile,);
    } else {

    }
  }

  createButtonTitleAndFunction({String title, Function performFunction}) {
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
            color: Colors.black,
            border: Border.all(color: Colors.grey),
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
          strTitle: currentUser != null && currentUser.username != null ? currentUser.username : "Profile"),
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

    QuerySnapshot querySnapshot = await postsReference.document(widget.userProfileId).collection("usersPosts").orderBy("timestamp", descending: true).getDocuments();

    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postsList = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
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