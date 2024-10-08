import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<Message?> getCID({required String cid}) async {
  try {
    final result = await http.get(path: '/v1/ipfs/$cid');
    if (result == null || result == '') {
      return null;
    }
    return Message.fromJson(result);
  } catch (e) {
    throw Exception('[Push SDK] - API getCID: $e');
  }
}
