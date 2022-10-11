import 'package:json_model_builder/types.dart';

/// JsonType for primitive int
class JsonInt extends PrimitieveJson<int> {
  @override
  dynamic toJson() {
    return valueOrNull;
  }

  @override
  int? tryParse(source) {
    return int.tryParse(source.toString());
  }
}

/// JsonTypeNullable for primitive int
class JsonIntNullable extends PrimitiveJsonNullable<int> {
  @override
  dynamic toJson() {
    return valueOrNull;
  }

  @override
  int? tryParse(source) {
    return int.tryParse(source.toString());
  }
}

/// JsonType for primitive double
class JsonDouble extends PrimitieveJson<double> {
  @override
  dynamic toJson() {
    return valueOrNull;
  }

  @override
  double? tryParse(source) {
    return double.tryParse(source.toString());
  }
}

/// JsonTypeNullable for primitive double
class JsonDoubleNullable extends PrimitiveJsonNullable<double> {
  @override
  dynamic toJson() {
    return valueOrNull;
  }

  @override
  double? tryParse(source) {
    return double.tryParse(source.toString());
  }
}

/// JsonType for primitive String
class JsonString extends PrimitieveJson<String> {
  @override
  dynamic toJson() {
    return valueOrNull;
  }

  @override
  String? tryParse(source) {
    return source?.toString();
  }
}

/// JsonTypeNullable for primitive String
class JsonStringNullable extends PrimitiveJsonNullable<String> {
  @override
  dynamic toJson() {
    return valueOrNull;
  }

  @override
  String? tryParse(source) {
    return source?.toString();
  }
}

/// JsonType for primitive bool
class JsonBool extends PrimitieveJson<bool> {
  @override
  dynamic toJson() {
    return valueOrNull;
  }

  @override
  bool? tryParse(source) {
    if (source == true || source.toString() == 'true') return true;
    if (source == false || source.toString() == 'false') return false;
    return null;
  }
}

/// JsonTypeNullable for primitive bool
class JsonBoolNullable extends PrimitiveJsonNullable<bool> {
  @override
  dynamic toJson() {
    return valueOrNull;
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

/// JsonType for DateTime
class JsonDateTime extends PrimitieveJson<DateTime> {
  @override
  dynamic toJson() {
    return valueOrNull?.toIso8601String();
  }

  @override
  DateTime? tryParse(source) {
    return _tryParseDateTime(source);
  }
}

/// JsonTypeNullable for DateTime
class JsonDateTimeNullable extends PrimitiveJsonNullable<DateTime> {
  @override
  dynamic toJson() {
    return valueOrNull;
  }

  @override
  DateTime? tryParse(source) {
    return _tryParseDateTime(source);
  }
}

/// JsonType null
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
