import 'package:explore/pages/HomePage.dart';

class PushNotificationService {

  void initialize() {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage notif called - ${message.toString()}');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch notif called - ${message.toString()}');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume notif called - ${message.toString()}');
      },
    );
  }

}