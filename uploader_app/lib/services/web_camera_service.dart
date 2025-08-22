// Platform-specific exports for conditional compilation
export 'web_camera_service_stub.dart'
    if (dart.library.html) 'web_camera_service_web.dart'
    if (dart.library.io) 'web_camera_service_mobile.dart';