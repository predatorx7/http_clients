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
