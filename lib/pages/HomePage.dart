import 'package:explore/models/user.dart';
import 'package:explore/pages/CreateAccountPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/pages/ActivityPage.dart';
import 'package:explore/pages/ProfilePage.dart';
import 'package:explore/pages/SearchPage.dart';
import 'package:explore/pages/UploadPage.dart';
import 'package:explore/pages/TimeLinePage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
final userReference = Firestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Posts Pictures");
final postsReference = Firestore.instance.collection("posts");
final commentsReference = Firestore.instance.collection("comments");
final activityFeedReference = Firestore.instance.collection("feed");
final followersReference = Firestore.instance.collection("followers");
final followingReference = Firestore.instance.collection("following");

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
      print("Error Message : " + gError);
    });

    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }).catchError((gError) {
      print("Error Message : " + gError);
    });
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
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  loginUser() {
    gSignIn.signIn();
  }

  logoutUser() {
    gSignIn.signOut();
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
      body: PageView(
        children: <Widget>[
          TimeLinePage(),
          SearchPage(),
          UploadPage(gCurrentUser: currentUser,),
          // RaisedButton.icon(onPressed: logoutUser, icon: Icon(Icons.close), label: Text("Sign Out")),
          ActivityPage(),
          ProfilePage(userProfileId: currentUser.id),
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
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover,
                  )
                ),
              ),
            )
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
