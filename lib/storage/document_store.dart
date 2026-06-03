export 'document_store_base.dart';
export 'document_store_stub.dart'
    if (dart.library.html) 'document_store_web.dart'
    if (dart.library.io) 'document_store_io.dart'
    show createDocumentStore;
