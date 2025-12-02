import 'user.dart';
import 'auth_tokens.dart';

class CentralSession {
  final User user;
  final AuthTokens tokens;

  CentralSession({required this.user, required this.tokens});
}
