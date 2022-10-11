import 'package:json_model_builder/list.dart';
import 'package:json_model_builder/map.dart';
import 'package:json_model_builder/primitives.dart';
import 'package:json_model_builder/types.dart';

export './list.dart';
export './map.dart';
export './types.dart';
export './primitives.dart';

abstract class ModelBuilder implements JsonType {
  ModelBuilder([dynamic source]) {
    values.toList();
    setFromJson(source);
  }

  /// All entries values defined by model
  ///
  /// Example:
  /// ```dart
  /// class Person extends ModelBuilder {
  ///   @override
  ///   Iterable<JsonType> get values => [name, age];
  ///
  ///   JsonString get name => jsonString('name');
  ///   JsonInt get age => jsonInt('age');
  /// }
  ///
  /// ```
  Iterable<JsonType> get values;

  final _entries = <String, JsonType>{};

  /// Get all entries
  Iterable<MapEntry<String, JsonType>> get entries => _entries.entries;

  /// Get all model keys
  Iterable<String> get keys => _entries.keys;

  /// Fill model with data provided by json
  /// Example:
  /// ```dart
  /// void main() {
  ///   final me = Person()..setFromJson({'name': 'Tomás', 'age': 20});
  ///   print(me.name.value);
  /// }
  ///
  /// class Person extends ModelBuilder {
  ///   @override
  ///   Iterable<JsonType> get values => [name, age];
  ///
  ///   JsonString get name => jsonString('name');
  ///   JsonInt get age => jsonInt('age');
  /// }
  /// ```
  @override
  bool setFromJson(json) {
    values.toList();
    if (json is Map) {
      for (final entry in json.entries) {
        final value = json[entry.key] is JsonType ? (json[entry.key] as JsonType).toJson() : json[entry.key];
        _entries[entry.key]?.setFromJson(value);
      }
      return true;
    }
    return false;
  }

  @override
  toJson() {
    values.toList();
    final Map map = {};
    for (final entry in _entries.entries) {
      map[entry.key] = entry.value.toJson();
    }
    return map;
  }

  /// Add entry to json model. Entries are defined as getters
  ///
  /// Example
  /// ```dart
  /// class Player extends ModelBuilder {
  ///   @override
  ///   Iterable<JsonType> get values => [name, nick, score];
  ///
  ///   JsonString get name => jsonString('name');
  ///   // Use jsonString as a replacement for addEntry<jsonString>
  ///   JsonString get nick => addEntry<JsonString>('nickname', JsonString.new, () => 'player-' + id());
  ///   // Use jsonInt as a replacement for addEntry<jsonString>
  ///   JsonInt get score => addEntry<JsonInt>('score', jsonInt.new, 0);
  /// }
  /// ```
  T addEntry<T extends JsonType>(String name, T Function() creator, [dynamic defaultJsonValue]) {
    if (defaultJsonValue is Function) defaultJsonValue = defaultJsonValue.call();
    if (_entries[name] == null) {
      _entries[name] = creator()..setFromJson(defaultJsonValue);
    }
    return _entries[name]! as T;
  }

  /// Creates a entry of type `JsonString` with a given name
  JsonString jsonString(String name, [String? defaultJsonValue]) => addEntry<JsonString>(name, JsonString.new, defaultJsonValue);

  /// Creates a entry of type `JsonStringNullable` with a given name
  JsonStringNullable jsonStringNullable(String name, [String? defaultJsonValue]) =>
      addEntry<JsonStringNullable>(name, JsonStringNullable.new, defaultJsonValue);

  /// Creates a entry of type `JsonInt` with a given name
  JsonInt jsonInt(String name, [dynamic defaultJsonValue]) => addEntry<JsonInt>(name, JsonInt.new, defaultJsonValue);

  /// Creates a entry of type `JsonIntNullable` with a given name
  JsonIntNullable jsonIntNullable(String name, [int? defaultJsonValue]) =>
      addEntry<JsonIntNullable>(name, JsonIntNullable.new, defaultJsonValue);

  /// Creates a entry of type `JsonDouble` with a given name
  JsonDouble jsonDouble(String name, [dynamic defaultJsonValue]) => addEntry<JsonDouble>(name, JsonDouble.new, defaultJsonValue);

  /// Creates a entry of type `JsonDoubleNullable` with a given name
  JsonDoubleNullable jsonDoubleNullable(String name, [dynamic defaultJsonValue]) =>
      addEntry<JsonDoubleNullable>(name, JsonDoubleNullable.new, defaultJsonValue);

  /// Creates a entry of type `JsonBool` with a given name
  JsonBool jsonBool(String name, [dynamic defaultJsonValue]) => addEntry<JsonBool>(name, JsonBool.new, defaultJsonValue);

  /// Creates a entry of type `JsonBoolNullable` with a given name
  JsonBoolNullable jsonBoolNullable(String name, [dynamic defaultJsonValue]) =>
      addEntry<JsonBoolNullable>(name, JsonBoolNullable.new, defaultJsonValue);

  /// Creates a entry of type `JsonDateTime` with a given name
  JsonDateTime jsonDateTime(String name, [dynamic defaultJsonValue]) => addEntry<JsonDateTime>(name, JsonDateTime.new, defaultJsonValue);

  /// Creates a entry of type `JsonDateTimeNullable` with a given name
  JsonDateTimeNullable jsonDateTimeNullable(String name, [dynamic defaultJsonValue]) =>
      addEntry<JsonDateTimeNullable>(name, JsonDateTimeNullable.new, defaultJsonValue);

  /// Creates a entry of type `JsonList` with a given name
  JsonList<T> jsonList<T extends JsonType>(String name, T Function() childCreator, [dynamic defaultJsonValue]) =>
      addEntry<JsonList<T>>(name, () => JsonList(childCreator), defaultJsonValue);

  /// Creates a entry of type `JsonListNullable` with a given name
  JsonListNullable jsonListNullable<T extends JsonType>(String name, T Function() childCreator, [dynamic defaultJsonValue]) =>
      addEntry<JsonListNullable>(name, () => JsonListNullable(childCreator), defaultJsonValue);

  /// Creates a entry of type `JsonMap` with a given name
  JsonMap<T> jsonMap<T extends JsonType>(String name, T Function() childCreator, [int? defaultJsonValue]) =>
      addEntry<JsonMap<T>>(name, () => JsonMap(childCreator), defaultJsonValue);

  /// Creates a entry of type `JsonMapNullable` with a given name
  JsonMapNullable jsonMapNullable<T extends JsonType>(String name, T Function() childCreator, [dynamic defaultJsonValue]) =>
      addEntry<JsonMapNullable>(name, () => JsonMapNullable(childCreator), defaultJsonValue);

  T jsonModel<T extends ModelBuilder>(String name, T Function() creator, [dynamic defaultJsonValue]) =>
      addEntry<T>(name, creator, defaultJsonValue);
}

abstract class ModelBuilderNullable extends ModelBuilder implements JsonTypeNullable {
  bool _isNull = true;

  @override
  bool get isNull => _isNull;

  set isNull(bool isNull) {
    if (isNull) _entries.clear();
    _isNull = isNull;
  }

  @override
  bool setFromJson(json) {
    final result = super.setFromJson(json);
    if (result == true) {
      isNull = false;
    } else {
      isNull = true;
      _entries.clear();
    }
    return true;
  }

  @override
  T addEntry<T extends JsonType>(String name, T Function() creator, [dynamic defaultJsonValue]) {
    if (isNull) isNull = false;
    return super.addEntry(name, creator);
  }
}

/// class Player extends ModelBuilder {
///   @override
///   Iterable<JsonType> get values => [name, nick, score];
///
///   JsonString get name => jsonString('name');
///
///   // Use jsonString as a replacement for addEntry<jsonString>
///   JsonString get nick => addEntry<JsonString>('nickname', JsonString.new, () => 'player-' + id());
///
///   // Use jsonInt as a replacement for addEntry<jsonString>
///   JsonInt get score => addEntry<JsonInt>('score', jsonInt.new, 0);
/// }
