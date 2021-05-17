
import 'package:explore/models/token.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/CreateAccountPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/pages/ActivityPage.dart';
import 'package:explore/pages/ProfilePage.dart';
import 'package:explore/pages/SearchPage.dart';
import 'package:explore/pages/UploadPage.dart';
import 'package:explore/pages/TimeLinePage.dart';
import 'package:explore/services/PushNotificationService.dart';
import 'package:explore/todo_button/add_todo_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'FollowRequestsPage.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final userReference = Firestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Posts Pictures");
final postsReference = Firestore.instance.collection("posts");
final commentsReference = Firestore.instance.collection("comments");
final activityFeedReference = Firestore.instance.collection("feed");
final followersReference = Firestore.instance.collection("followers");
final followingReference = Firestore.instance.collection("following");
final requestsReceivedReference = Firestore.instance.collection("requestsReceived");
final requestsSentReference = Firestore.instance.collection("requestsSent");
final FirebaseMessaging fcm = FirebaseMessaging();

final DateTime timestamp = DateTime.now();

User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isSignedIn = false;

  PageController pageController;

  int getPageIndex = 0;

  void initState() {
    super.initState();
    pageController = PageController();
    int pageIndex = 0;


    gSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }, onError: (gError) {
      print("Error Message : ");
      print(gError);
    });

    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }).catchError((gError) {
      print("Error Message : ");
      print(gError);
    });
    // handlePushNotificationService();
  }

  controlSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      await saveUserInfoToFireStore();
      setState(() {
        isSignedIn = true;
      });
    } else {
      setState(() {
        isSignedIn = false;
      });
    }
  }

  handlePushNotificationService() {
    PushNotificationService _pushNotificationService = PushNotificationService();
    _pushNotificationService.initialize();
  }

  generateFcmToken(currentUser) async {
    final fcmToken = await fcm.getToken();
    print('currentUserId = ${currentUser?.id}');
    print('token generated = ${fcmToken.toString()}');
    final tokenRef = userReference
        .document(currentUser?.id)
        .collection('tokens')
        .document(fcmToken);
    
    await tokenRef
        .setData(
          Token(token: fcmToken, createdAt: DateTime.now())
            .toJson()
      );
  }

  void saveUserInfoToFireStore() async {
    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot = await userReference.document(gCurrentUser.id).get();

    if (!documentSnapshot.exists) {
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));

      userReference.document(gCurrentUser.id).setData({
        "id": gCurrentUser.id,
        "profileName": gCurrentUser.displayName,
        "username": username,
        "url": gCurrentUser.photoUrl,
        "email": gCurrentUser.email,
        "bio": "",
        "timestamp": timestamp
      });
      documentSnapshot = await userReference.document(gCurrentUser.id).get();
    }

    currentUser = User.fromDocument(documentSnapshot);
    // await generateFcmToken(currentUser);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  loginUser() {
    gSignIn.signIn();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  void onTapChangePage(int pageIndex) {
    pageController.jumpToPage(pageIndex);
    // pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
  }

  Widget buildHomeScreen() {
    return Scaffold(
      // floatingActionButton: RaisedButton.icon(onPressed: logoutUser, icon: Icon(Icons.close), label: Text("Sign Out")),
      body:
      PageView(
        children: <Widget>[
          TimeLinePage(),
          SearchPage(),
          UploadPage(gCurrentUser: currentUser,),
          ActivityPage(),
          ProfilePage(userProfileId: currentUser.id),
          Stack(
            children: [
              FollowRequestsPage(),
              const Align(
                alignment: Alignment.bottomRight,
                child: AddTodoButton(),
              ),
            ],
          ),
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.deepPurple,
        inactiveColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.monochrome_photos, size:  37.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
          BottomNavigationBarItem(icon: Icon(Icons.person_add)),
        ],
      ),
    );
    // return RaisedButton.icon(onPressed: logoutUser, icon: Icon(Icons.close), label: Text("Sign Out"));
  }

  Scaffold buildSignInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor]
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Explore",
              style: TextStyle(fontSize: 92.0, color: Colors.white, fontFamily: "Signatra"),
            ),
            Divider(),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 200.0,
                height: 40.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover,
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return isSignedIn ? buildHomeScreen() : buildSignInScreen();
  }
}
