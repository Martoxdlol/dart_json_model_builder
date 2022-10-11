import 'package:json_model_builder/types.dart';

class JsonInt extends PrimitieveJson<int> {
  @override
  dynamic toJson() {
    return value;
  }

  @override
  int? tryParse(source) {
    return int.tryParse(source.toString());
  }
}

class JsonIntNullable extends PrimitiveJsonNullable<int> {
  @override
  dynamic toJson() {
    return value;
  }

  @override
  int? tryParse(source) {
    return int.tryParse(source.toString());
  }
}

class JsonDouble extends PrimitieveJson<double> {
  @override
  dynamic toJson() {
    return value;
  }

  @override
  double? tryParse(source) {
    return double.tryParse(source.toString());
  }
}

class JsonDoubleNullable extends PrimitiveJsonNullable<double> {
  @override
  dynamic toJson() {
    return value;
  }

  @override
  double? tryParse(source) {
    return double.tryParse(source.toString());
  }
}

class JsonString extends PrimitieveJson<String> {
  @override
  dynamic toJson() {
    return value;
  }

  @override
  String? tryParse(source) {
    return source?.toString();
  }
}

class JsonStringNullable extends PrimitiveJsonNullable<String> {
  @override
  dynamic toJson() {
    return value;
  }

  @override
  String? tryParse(source) {
    return source?.toString();
  }
}

class JsonBool extends PrimitieveJson<bool> {
  @override
  dynamic toJson() {
    return value;
  }

  @override
  bool? tryParse(source) {
    if (source == true || source.toString() == 'true') return true;
    if (source == false || source.toString() == 'false') return false;
    return null;
  }
}

class JsonBoolNullable extends PrimitiveJsonNullable<bool> {
  @override
  dynamic toJson() {
    return value;
  }

  @override
  bool? tryParse(source) {
    if (source == true || source.toString() == 'true') return true;
    if (source == false || source.toString() == 'false') return false;
    return null;
  }
}

DateTime? _tryParseDateTime(source) {
  if (source is DateTime) return source;
  if (source is num) return DateTime.fromMillisecondsSinceEpoch(source.toInt());
  return DateTime.tryParse(source.toString());
}

class JsonDateTime extends PrimitieveJson<DateTime> {
  @override
  dynamic toJson() {
    return value.toIso8601String();
  }

  @override
  DateTime? tryParse(source) {
    return _tryParseDateTime(source);
  }
}

class JsonDateTimeNullable extends PrimitiveJsonNullable<DateTime> {
  @override
  dynamic toJson() {
    return value;
  }

  @override
  DateTime? tryParse(source) {
    return _tryParseDateTime(source);
  }
}

// ignore: prefer_void_to_null
class JsonNull extends PrimitieveJson<Null> {
  @override
  dynamic toJson() {
    return null;
  }

  @override
  Null tryParse(source) {
    return null;
  }
}
