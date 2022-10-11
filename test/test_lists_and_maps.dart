import 'package:json_model_builder/json_model_builder.dart';
import 'package:test/scaffolding.dart';

import 'util.dart';

void testListsAndMaps() {
  test('list', () {
    final initialJson = [1, 2, 3, 4];
    final jsonObj = JsonList<JsonInt>(JsonInt.new);
    assert(jsonObj.setFromJson(initialJson));
    spectJsonNoChange(jsonObj, initialJson);
  });

  test('list of lists', () {
    final initialJson = [
      [1],
      [2, 2],
      [3, 3, 3],
      [4, 4, 4, 4]
    ];
    final jsonObj = JsonList<JsonList<JsonInt>>(() => JsonList(JsonInt.new));
    assert(jsonObj.setFromJson(initialJson));
    spectJsonNoChange(jsonObj, initialJson);
  });

  test('map', () {
    final initialJson = {'one': 1, 'two': 2, 'three': 3};
    final jsonObj = JsonMap<JsonInt>(JsonInt.new);
    assert(jsonObj.setFromJson(initialJson));
    spectJsonNoChange(jsonObj, initialJson);
  });

  test('map of maps', () {
    final initialJson = {
      'one': {'first': 1},
      'two': {'first': 1, 'second': 2},
    };
    final jsonObj = JsonMap<JsonMap<JsonInt>>(() => JsonMap(JsonInt.new));
    assert(jsonObj.setFromJson(initialJson));
    spectJsonNoChange(jsonObj, initialJson);
  });

  test('list of maps', () {
    final initialJson = [
      {'one': 1, 'two': 2, 'three': 3},
      {'four': 4, 'five': 5, 'six': 6}
    ];

    final jsonObj = JsonList<JsonMap<JsonInt>>(() => JsonMap<JsonInt>(JsonInt.new));
    assert(jsonObj.setFromJson(initialJson));
    spectJsonNoChange(jsonObj, initialJson);
  });

  test('map of lists', () {
    final initialJson = {
      'one': [1],
      'two': [2, 2],
      'three': [3, 3, 3],
    };
    final jsonObj = JsonMap<JsonList<JsonInt>>(() => JsonList<JsonInt>(JsonInt.new));
    assert(jsonObj.setFromJson(initialJson));
    spectJsonNoChange(jsonObj, initialJson);
  });
}
