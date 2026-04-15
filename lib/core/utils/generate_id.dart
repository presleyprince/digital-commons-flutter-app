import 'package:uuid/uuid.dart';

class GenerateId {
  static String generateNewId() {
    return Uuid().v4();
  }
}
