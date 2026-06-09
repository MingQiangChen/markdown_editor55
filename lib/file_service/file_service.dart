export 'file_service_base.dart';
export 'file_service_stub.dart'
    if (dart.library.html) 'file_service_web.dart'
    if (dart.library.io) 'file_service_io.dart'
    show createFileService;
