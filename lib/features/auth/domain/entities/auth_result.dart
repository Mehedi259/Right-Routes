class AuthResult {
  final bool success;
  final String? message;
  final String? nextStep;
  final bool? isRegistered;
  final dynamic data;

  AuthResult({
    required this.success,
    this.message,
    this.nextStep,
    this.isRegistered,
    this.data,
  });
}
