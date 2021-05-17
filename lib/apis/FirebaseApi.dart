import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/enums/UserState.dart';
import 'package:explore/models/message.dart';
import 'package:explore/models/user.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:explore/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


class FirebaseApi {

  static final chatsRef = Firestore.instance.collection('chats');

  static final _chatController = StreamController<List<Message>>.broadcast();


  static Stream<List<User>> getUsers() =>
  userReference
      .snapshots()
      .transform(Utils.transformer(User.fromJson));

  static Stream<List<User>> getFollowingsUsers() {
    var ref = followingReference
        .document(currentUser?.id)
        .collection('userFollowing')
        .snapshots()
        .transform(Utils.transformer(User.fromJson));

  }

  static Future uploadMessage(Message message) async {
    try {
      // print('message.toJson() = ${message.toJson()}');
      await chatsRef.document().setData(message.toJson());
    } catch (ex) {
      return ex is PlatformException ? ex.message : ex.toString();
    }
  }

  static Future sendMessage(String messageBody, String receiverUserName, String receiverId, String receiverProfileName, Message replyMessage) async {
    String currentUserId = currentUser?.id;
    String currentUsername = currentUser?.username;
    String currentUserProfileName = currentUser?.profileName;

    final Message message = Message(
        receiverId: receiverId,
        senderId: currentUserId,
        receiverUsername: receiverUserName,
        senderUsername: currentUsername,
        messageBody: messageBody,
        createdAt: DateTime.now(),
        receiverProfileName: receiverProfileName,
        senderProfileName: currentUserProfileName,
        replyMessage: replyMessage,
    );
    // print('sending message - ${message.messageBody} with reply - ${message.replyMessage != null ? message.replyMessage.messageBody : 'no reply'}');

    await uploadMessage(message);
  }

  static Stream listenToMessagesInRealTime(String friendId, String currentUserId) {
    _requestMessage(friendId, currentUserId);
    return _chatController.stream;
  }

  static void _requestMessage(String friendId, String currentUserId) {
    var messageQuerySnapshot = chatsRef
        .orderBy('createdAt', descending: true);

    messageQuerySnapshot.snapshots().listen((messageEvent) {
      if (messageEvent.documents.isNotEmpty) {
        var messages = messageEvent.documents.map((doc) =>
            Message.fromJson(doc.data))
              .where((message) =>
                (message.receiverId == friendId && message.senderId == currentUserId) ||
                  (message.receiverId == currentUserId && message.senderId == friendId))
                    .toList();
        _chatController.add(messages);
      }
    });
  }

  static void setUserState({@required String userId, @required UserState userState}) {
    print('Updating user $userId to state $userState');
    int stateNum = Utils.stateToNum(userState);
    userReference.document(userId).updateData({
      'state': stateNum,
    });
  }

  static getUserState() async {
    print("Getting current user's current state");
    DocumentSnapshot documentSnapshot = await userReference.document(currentUser?.id).get();
    currentUser = User.fromDocument(documentSnapshot);
    return Utils.numToState(currentUser.state);
  }

  static Stream<DocumentSnapshot> getUserStream({@required String userId}) {
    return userReference.document(userId).snapshots();
  }
  
  
  
  // static Future addRandomUsers(List<User> users) async {
  //   final refUsers = Firestore.instance.collection('users');
  //
  //   final allUsers = await refUsers.get();
  //   if (allUsers.size != 0) {
  //     return;
  //   } else {
  //     for (final user in users) {
  //       final userDoc = refUsers.doc();
  //       final newUser = user.copyWith(idUser: userDoc.id);
  //
  //       await userDoc.set(newUser.toJson());
  //     }
  //   }
  // }
}