const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// https://firebase.google.com/docs/functions/firestore-events


// exports.onCreateFollower = functions.firestore
//    .document("/followers/{userId}/userFollowers/{followerId}")
//    .onCreate( (snapshot, context) => {
//      console.log("Follower Created", snapshot.id);
//      const userId = context.params.userId;
//      const followerId = context.params.followerId;
//
//      // 1) Create followed user's posts ref
//      const followedUserPostsRef = admin
//          .firestore()
//          .collection("posts")
//          .doc(userId)
//          .collection("usersPosts");
//
//      // 2) Create following user's timeline ref
//      const timelinePostsRef = admin
//          .firestore()
//          .collection("timeline")
//          .doc(followerId)
//          .collection("timelinePosts");
//
//      // 3) Get followed user's posts
//      const querySnapshot = followedUserPostsRef.get(); // TODO : Add await here
//
//      // 4) Add each user post to following user's timeline
//      querySnapshot.forEach((doc) => {
//        if (doc.exists) {
//          const postId = doc.id;
//          const postData = doc.data();
//          timelinePostsRef.doc(postId).set(postData);
//        }
//      });
//    });
