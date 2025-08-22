import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'utils/env_config.dart';
import 'utils/responsive_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  await EnvConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: EnvConfig.isDebug,

      // Responsive framework configuration
      builder: (context, child) => ResponsiveConfig.getResponsiveWrapper(
        child: child!,
        context: context,
      ),

      theme: ThemeData(
        // Modern Material 3 theme with web-first design
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),

        // Typography improvements for web
        typography: Typography.material2021(),

        // Component themes
        cardTheme: const CardThemeData(
          elevation: 2,
        ),

        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        typography: Typography.material2021(),
        cardTheme: const CardThemeData(
          elevation: 2,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),

      themeMode: ThemeMode.system,

      home: const MyHomePage(title: AppConstants.appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ResponsiveConfig.getResponsiveWrapper(
        child: Center(
          child: Padding(
            padding: ResponsiveConfig.getResponsivePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.cloud_upload,
                  size: ResponsiveConfig.getResponsiveFontSize(context, 80),
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: ResponsiveConfig.getResponsiveSpacing(context)),
                Text(
                  'Welcome to Plantita Uploader',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: ResponsiveConfig.getResponsiveFontSize(context, 28),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConfig.getResponsiveSpacing(context) / 2),
                Text(
                  'A web-first media management application',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: ResponsiveConfig.getResponsiveFontSize(context, 16),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConfig.getResponsiveSpacing(context)),
                Card(
                  child: Padding(
                    padding: ResponsiveConfig.getResponsivePadding(context),
                    child: Column(
                      children: [
                        Text(
                          'Environment: ${EnvConfig.isDebug ? 'Development' : 'Production'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'API: ${EnvConfig.apiBaseUrl}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        context: context,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Upload Media',
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
