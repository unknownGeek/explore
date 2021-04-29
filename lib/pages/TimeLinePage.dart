import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/widgets/PostWidget.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import 'package:explore/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

import 'package:explore/pages/HomePage.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {

  bool loading = false;
  List<Post> postsList = [];

  void initState() {
    getAllProfilePosts();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: ListView(
        children: <Widget>[
          displayProfilePost(),
        ],
      ),
    );
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postsReference.document(currentUser?.id).collection("usersPosts").orderBy("timestamp", descending: true).getDocuments();

    setState(() {
      loading = false;
      postsList = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });
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
    }
    return Column(
      children: postsList,
    );
  }

}
