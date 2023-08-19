import 'package:http/http.dart' show BaseRequest, BaseResponse;

const usedHandleHeaderName = 'used-handle';

BaseRequest markHandleUsageInRequestHeaders(BaseRequest request) {
  request.headers[usedHandleHeaderName] = 'true';
  return request;
}

bool didUseHandle(BaseResponse response) {
  return response.request?.headers[usedHandleHeaderName] == 'true';
}
