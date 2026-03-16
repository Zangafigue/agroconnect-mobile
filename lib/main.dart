import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config.dart';
import 'core/theme_provider.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'features/shared/widgets/offline_indicator_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser les intercepteurs Dio (Injection du JWT)
  DioClient.init();

  runApp(
    const ProviderScope(
      child: AgroConnectApp(),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AgroConnectApp extends ConsumerWidget {
  const AgroConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return OfflineIndicatorWidget(child: child);
      },
    );
  }
}
