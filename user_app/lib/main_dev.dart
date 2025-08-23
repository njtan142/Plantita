import 'package:flutter/material.dart';
import 'package:user_app/main.dart' as app;
import 'package:user_app/config/environment_config.dart';

void main() {
  app.startApp(EnvironmentConfig.development());
}
