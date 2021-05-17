import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/enums/UserState.dart';
import 'package:flutter/material.dart';

class Utils {
  static StreamTransformer transformer<T>(
      T Function(Map<dynamic, dynamic> json) fromJson) =>
      StreamTransformer<QuerySnapshot, List<T>>.fromHandlers(
        handleData: (QuerySnapshot data, EventSink<List<T>> sink) {
          final snaps = data.documents.map((doc) => doc.data).toList();
          final users = snaps.map((json) => fromJson(json)).toList();

          sink.add(users);
        },
      );

  static DateTime toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.Offline :
        return 0;
      case UserState.Online :
        return 1;
      default :
        return 2;
    }
  }

  static UserState numToState(int num) {
    switch (num) {
      case 0 :
        return UserState.Offline;
      case 1 :
        return UserState.Online;
      default :
        return UserState.Waiting;
    }
  }

  static getColor(int state) {
    switch (Utils.numToState(state)) {
      case UserState.Offline :
        return Colors.red;
      case UserState.Online :
        return Colors.green;
      default :
        return Colors.orange;
    }
  }

}