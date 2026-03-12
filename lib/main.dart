import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';

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

class AgroConnectApp extends ConsumerWidget {
  const AgroConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConfig.primaryColor),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
