import '../../../core/utils/app_logger.dart';
import '../domain/custom_request_model.dart';

abstract class CustomRequestRepository {
  Future<List<CustomServiceRequest>> getCustomRequests();
  Future<CustomServiceRequest> createCustomRequest(CustomServiceRequest request);
}

class CustomRequestRepositoryImpl implements CustomRequestRepository {
  final List<CustomServiceRequest> _requests = [];

  @override
  Future<List<CustomServiceRequest>> getCustomRequests() async {
    AppLogger.debug('CustomRequestRepo', 'Fetching custom requests from store');
    return _requests;
  }

  @override
  Future<CustomServiceRequest> createCustomRequest(CustomServiceRequest request) async {
    AppLogger.info('CustomRequestRepo', 'Created live custom request', {'title': request.title});
    _requests.insert(0, request);
    return request;
  }
}
