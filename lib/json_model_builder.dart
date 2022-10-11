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
    if (json is Map) {
      for (final entry in json.entries) {
        _entries[entry.key]?.setFromJson(json[entry.key]);
      }
      return true;
    }
    return false;
  }

  @override
  toJson() {
    final Map map = {};
    for (final entry in _entries.entries) {
      map[entry.key] = entry.value.toJson();
    }
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
  JsonString jsonString(String name, [String? defaultValue]) => addEntry<JsonString>(name, JsonString.new, defaultValue);

  /// Creates a entry of type `JsonStringNullable` with a given name
  JsonStringNullable jsonStringNullable(String name, [String? defaultValue]) =>
      addEntry<JsonStringNullable>(name, JsonStringNullable.new, defaultValue);

  /// Creates a entry of type `JsonInt` with a given name
  JsonInt jsonInt(String name, [int? defaultValue]) => addEntry<JsonInt>(name, JsonInt.new, defaultValue);

  /// Creates a entry of type `JsonIntNullable` with a given name
  JsonIntNullable jsonIntNullable(String name, [int? defaultValue]) => addEntry<JsonIntNullable>(name, JsonIntNullable.new, defaultValue);

  /// Creates a entry of type `JsonDouble` with a given name
  JsonDouble jsonDouble(String name, [int? defaultValue]) => addEntry<JsonDouble>(name, JsonDouble.new, defaultValue);

  /// Creates a entry of type `JsonDoubleNullable` with a given name
  JsonDoubleNullable jsonDoubleNullable(String name, [int? defaultValue]) =>
      addEntry<JsonDoubleNullable>(name, JsonDoubleNullable.new, defaultValue);

  /// Creates a entry of type `JsonBool` with a given name
  JsonBool jsonBool(String name, [int? defaultValue]) => addEntry<JsonBool>(name, JsonBool.new, defaultValue);

  /// Creates a entry of type `JsonBoolNullable` with a given name
  JsonBoolNullable jsonBoolNullable(String name, [int? defaultValue]) =>
      addEntry<JsonBoolNullable>(name, JsonBoolNullable.new, defaultValue);

  /// Creates a entry of type `JsonList` with a given name
  JsonList jsonList<T extends JsonType>(String name, T Function() childCreator, [int? defaultValue]) =>
      addEntry<JsonList>(name, () => JsonList(childCreator), defaultValue);

  /// Creates a entry of type `JsonListNullable` with a given name
  JsonListNullable jsonListNullable<T extends JsonType>(String name, T Function() childCreator, [int? defaultValue]) =>
      addEntry<JsonListNullable>(name, () => JsonListNullable(childCreator), defaultValue);

  /// Creates a entry of type `JsonMap` with a given name
  JsonMap jsonMap<T extends JsonType>(String name, T Function() childCreator, [int? defaultValue]) =>
      addEntry<JsonMap>(name, () => JsonMap(childCreator), defaultValue);

  /// Creates a entry of type `JsonMapNullable` with a given name
  JsonMapNullable jsonMapNullable<T extends JsonType>(String name, T Function() childCreator, [int? defaultValue]) =>
      addEntry<JsonMapNullable>(name, () => JsonMapNullable(childCreator), defaultValue);

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
