import 'package:explore/utils/Utils.dart';
import 'package:flutter/material.dart';

class MessageField {
  static final String createdAt = 'createdAt';
}

class Message {
  final String receiverId;
  final String senderId;
  final String receiverProfileName;
  final String receiverUsername;
  final String senderUsername;
  final String senderProfileName;
  final String messageBody;
  final Message replyMessage;
  final DateTime createdAt;

  const Message({
    @required this.receiverId,
    @required this.senderId,
    @required this.receiverUsername,
    @required this.senderUsername,
    @required this.messageBody,
    @required this.senderProfileName,
    @required this.receiverProfileName,
    @required this.replyMessage,
    @required this.createdAt,
  });

  static Message fromJson(Map<dynamic, dynamic> json) => Message(
    receiverId: json['receiverId'],
    senderId: json['senderId'],
    receiverUsername: json['receiverUsername'],
    senderUsername: json['senderUsername'],
    messageBody: json['messageBody'],
    createdAt: Utils.toDateTime(json['createdAt']),
    receiverProfileName: json['receiverProfileName'],
    senderProfileName: json['senderProfileName'],
    replyMessage: json['replyMessage'] == null ? null : Message.fromJson(json['replyMessage']),
  );

  Map<String, dynamic> toJson() => {
    'receiverId': receiverId,
    'senderId': senderId,
    'receiverUsername': receiverUsername,
    'senderUsername': senderUsername,
    'messageBody': messageBody,
    'createdAt': Utils.fromDateTimeToJson(createdAt),
    'receiverProfileName': receiverProfileName,
    'senderProfileName': senderProfileName,
    'replyMessage': replyMessage == null ? null : replyMessage.toJson(),
  };
}