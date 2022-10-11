import 'dart:collection';

import 'package:json_model_builder/types.dart';

/// JsonType map compatible to Map
class JsonMap<T extends JsonType> extends MapBase<String, T> implements JsonType {
  JsonMap(this.childCreator);

  final T Function() childCreator;

  final Map<String, T> _map = <String, T>{};

  @override
  bool setFromJson(json) {
    if (json is Map) {
      for (final entry in json.entries) {
        this[entry.key] = childCreator()..setFromJson(json[entry.key]);
      }
      return true;
    }
    return false;
  }

  @override
  dynamic toJson() {
    final json = <String, dynamic>{};
    for (final entry in entries) {
      json[entry.key] = entry.value.toJson();
    }
    return json;
  }

  @override
  T? operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, T value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  T? remove(Object? key) => _map.remove(key);
}

/// JsonTypeNullable map compatible to Map
class JsonMapNullable<T extends JsonType> extends JsonMap<T> implements JsonTypeNullable {
  JsonMapNullable(super.childCreator);

  bool _isNull = true;

  @override
  bool get isNull => _isNull;

  set isNull(bool isNull) {
    if (isNull) _map.clear();
    _isNull = isNull;
  }

  @override
  bool setFromJson(json) {
    final result = super.setFromJson(json);
    if (result == true) {
      isNull = false;
    } else {
      isNull = true;
      _map.clear();
    }
    return true;
  }

  @override
  toJson() => isNull ? null : super.toJson();

  @override
  T? operator [](Object? key) => !isNull ? _map[key] : throw Exception('Cannot get key of null Map');

  @override
  void operator []=(String key, T value) => !isNull ? super[key] = value : throw Exception('Cannot set key of null Map');

  @override
  void clear() => !isNull ? super.clear() : throw Exception('Cannot clear null Map');

  @override
  Iterable<String> get keys => !isNull ? super.keys : throw Exception('Cannot get keys of null map');

  @override
  T? remove(Object? key) => !isNull ? super.remove(key) : throw Exception('Cannot remove key of null Map');
}
