import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/common/shared_preference.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/page/home_page.dart';
import 'provider/channel_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FFmpegKitConfig.enableLogCallback((log) {
    logger.i('ffmpeg: ${log.getMessage()}');
  });
  sharedPreferences = await SharedPreferences.getInstance();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChannelProvider()),
      ],
      child: MaterialApp(
        title: 'IPTV Player',
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}


