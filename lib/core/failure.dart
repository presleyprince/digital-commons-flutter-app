import 'package:digital_shores/core/constants.dart';

abstract class Failure {
  final String title;
  final String message;
  Failure({
    required this.title,
    required this.message,
  });
}

class ConnectionFailure extends Failure {
  ConnectionFailure({
    super.title = kConnectionFailTitle,
    super.message = kConnectionFailMessage,
  });
}

class BadRequestFailure extends Failure {
  BadRequestFailure({
    required super.title,
    required super.message,
  });
}
