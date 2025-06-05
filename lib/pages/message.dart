import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(defaultActionName: 'Open notification');

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'com.sanbei.school_forum',
      '校园集市',
      channelDescription: '校园集市app通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: '通知',
    );

const LinuxNotificationDetails linuxPlatformChannelSpecifics =
    LinuxNotificationDetails(defaultActionName: '打开通知');

const InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  linux: initializationSettingsLinux,
);

const NotificationDetails platformChannelSpecifics = NotificationDetails(
  android: androidPlatformChannelSpecifics,
  linux: linuxPlatformChannelSpecifics,
);

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() async {
    super.initState();
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification() async {
    await flutterLocalNotificationsPlugin.show(
      0,
      '系统通知标题',
      '这是一条系统通知内容',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _showNotification,
        child: const Text('发送系统通知'),
      ),
    );
  }
}
