import 'package:flutter/material.dart';
import 'package:following_practices/front/lib/app.dart';
import 'package:following_practices/front/services/app_initializer_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializerService.initialize();
  runApp(const FollowingPracticesApp());
}
