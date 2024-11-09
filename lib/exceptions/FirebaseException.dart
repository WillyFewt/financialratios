class FirebaseException implements Exception {
  final String msg;
  const FirebaseException(this.msg);
  String toString() => 'FirebaseException: $msg';
}
