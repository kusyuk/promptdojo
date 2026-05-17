import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/watsonx_config.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/title_screen.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Verify configuration
  if (!WatsonxConfig.isConfigured) {
    debugPrint('WARNING: ${WatsonxConfig.configStatus}');
  } else {
    debugPrint('✅ watsonx.ai configured successfully');
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PromptDojo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const TitleScreen(),
    );
  }
}
