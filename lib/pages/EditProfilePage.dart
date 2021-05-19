import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/apis/FirebaseApi.dart';
import 'package:explore/enums/UserState.dart';
import 'package:explore/main.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:explore/widgets/OnlineDotIndicator.dart';
import 'package:explore/widgets/ProgressWidget.dart';
import "package:flutter/material.dart";

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;

  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  TextEditingController profileNameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _bioValid = true;
  bool _profileNameValid = true;

  void initState() {
    super.initState();
    getAndDisplayUserInfo();
  }


  getAndDisplayUserInfo() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot = await userReference.document(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  updateUserData() {

    setState(() {
      _profileNameValid = profileNameTextEditingController.text.isNotEmpty &&
          profileNameTextEditingController.text.trim().length > 4;
      _bioValid = bioTextEditingController.text.isNotEmpty &&
          bioTextEditingController.text.trim().length <= 500;
    });

    if (_bioValid && _profileNameValid) {
      userReference.document(widget.currentOnlineUserId).updateData({
        "profileName": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text,
      });

      SnackBar successSnackBar = SnackBar(content: Text("Updated"));
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);

      Navigator.pop(context);
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userProfileId: widget.currentOnlineUserId,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        brightness: Brightness.dark, // status bar brightness
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: updateUserData,
          ),
        ],
      ),
      body: loading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 52.0,
                              backgroundImage: CachedNetworkImageProvider(user.url),
                            ),
                            OnlineDotIndicator(userId: user.id,),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            createProfileNameTextFormField(),
                            createBioTextFormField()
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, left: 50.0, right: 50.0),
                        child: RaisedButton(
                          color: Colors.deepPurple,
                          onPressed: setCurrentUserOnlineOrOffline,
                          child: Text(
                            "Go Online/Offline",
                            style: TextStyle(color: Colors.black, fontSize: 14.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 50.0, right: 50.0),
                        child: RaisedButton(
                          color: Colors.red,
                          onPressed: logoutUser,
                          child: Text(
                            "Logout",
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  setCurrentUserOnlineOrOffline() async {
    UserState userState = await FirebaseApi.getUserState();
    UserState newUserState = UserState.Online;
    if (userState == UserState.Online) {
      newUserState = UserState.Offline;
    }
    FirebaseApi.setUserState(
      userId: widget.currentOnlineUserId,
      userState: newUserState,
    );
  }

  logoutUser() async {
    await gSignIn.signOut();
    this.setState(() {
      loading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  Column createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Profile Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: "Write profile name here...",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _profileNameValid ? null : "Profile name too short.",
          ),
        ),
      ],
    );
  }

  Column createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: bioTextEditingController,
          decoration: InputDecoration(
            hintText: "Write Bio here...",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _bioValid
                ? null
                : (bioTextEditingController.text.isEmpty
                    ? "Bio too short."
                    : "Bio too long."),
          ),
        ),
      ],
    );
  }
}
