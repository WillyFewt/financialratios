class InvalidInputException implements Exception {
  final String msg;
  const InvalidInputException(this.msg);
  String toString() => 'InvalidInputException: $msg';
}