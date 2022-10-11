/// Basic interface that all types must have. All other json types implement this.
///
/// You can use this class to create yout own type.
///
/// It need to be able to be setted from json and converted to json
abstract class JsonType {
  /// Convert object to json compatible types
  dynamic toJson();

  /// Convert any given json to correspondig types and store it. If fails, it returns false.
  bool setFromJson(dynamic json);
}

/// It adds a `isNull` flag, so you can define model entries as nullables or values as null.
abstract class JsonTypeNullable {
  /// Returns whether or not current type value is null.
  /// Example:
  /// ```dart
  /// final myNum = JsonIntNullable()..set(null);
  /// assert(myNum.isNull);
  /// ```
  bool get isNull;
}

/// JsonTypes that doesn't have sub types.
///
/// Primitives: `int, dobule, String, bool, null, DateTime`
///
/// Non-Primirives: `List, Map, Model`
abstract class PrimitieveJson<T> implements JsonType {
  T? _value;

  /// Returns if value is set. If is not setted and you call `value` getter it will throw a exception.
  bool get isSet => _value != null;

  /// Set current primitive value of type [T]
  void set(T value) {
    _value = value;
  }

  /// delete current value and set it to null
  void delete() {
    _value = null;
  }

  /// Return current primitive value of type [T]
  T get value {
    if (_value is T && _value != null) return _value!;
    throw Exception('Value of type ${T.toString()} is not set');
  }

  /// Set current primitive value of type [T]
  set value(T value) {
    set(value);
  }

  /// Returns its value or null if it is not defined yet
  T? get valueOrNull => _value;

  /// Try to convert to value from any given json
  T? tryParse(dynamic source);

  @override
  bool setFromJson(json) {
    final parsed = tryParse(json);
    if (parsed is T) {
      set(parsed);
      return true;
    } else {
      _value = null;
      return false;
    }
  }

  @override
  operator ==(other) {
    if (other is PrimitieveJson) return other._value == _value;
    if (other is PrimitiveJsonNullable) return other._value == _value;
    return false;
  }

  @override
  int get hashCode => _value.hashCode;
}

/// Adds `isNull` getter to all nullable primirives
abstract class PrimitiveJsonNullable<T> extends PrimitieveJson<T?>
    implements JsonTypeNullable {
  @override
  bool get isNull => value == null;

  /// Return current primitive value of type [T] or null
  @override
  T? get value {
    if (_value is T && _value != null) return _value!;
    return null;
  }

  @override
  operator ==(other) {
    if (other is PrimitieveJson) return other._value == _value;
    if (other is PrimitiveJsonNullable) return other._value == _value;
    return false;
  }

  @override
  int get hashCode => _value.hashCode;
}
