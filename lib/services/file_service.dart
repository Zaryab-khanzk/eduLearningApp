// lib/services/file_service.dart

// This is the stub that the main app will see.
export 'file_service_stub.dart'
  if (dart.library.html) 'file_service_web.dart'
  if (dart.library.io) 'file_service_mobile.dart';