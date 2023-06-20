## 0.3.3

- Update `benchmarks/`

## 0.3.2+1

- Update documentation
- Add missing `content-type: application/json` header in RestService

## 0.3.2

- Add [RestClient.multipart] for making multipart rest requests

## 0.3.1

- Update package:http version constraint

## 0.3.0

- Upgrade package:http to 1.0.0

## 0.2.0

- Replace `PathJoinCallback onJoinPath` with `PathJoinStrategyCallback? pathJoinStrategy` in [RequestClient]
- Remove unused `JsonModelSerializer? serializer` from [HttpService]
- Change [ServiceConfig] to [HttpServiceConfig] and use [RestServiceConfig] as [config] in [RestService]
- Change [PathJoinStrategy] from a function class to an abstract class interface
- Add test for path join strategies
- Update [TodoService] in tests to extends [RestService]

## 0.1.0

- Initial version.
