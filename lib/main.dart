import 'package:flutter/material.dart';
import 'app/app.dart';
import 'utils/config_service.dart';

void main() async {
  // 确保 WidgetsBinding 初始化完成
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化配置服务
  await ConfigService().init();
  
  runApp(const NovelGeneratorApp());
}
