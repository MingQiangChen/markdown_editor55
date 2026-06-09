export 'recent_store_base.dart';
export 'recent_store_stub.dart'
    if (dart.library.html) 'recent_store_web.dart'
    if (dart.library.io) 'recent_store_io.dart'
    show createRecentStore;
