import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'rest.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  MockClient();
}
