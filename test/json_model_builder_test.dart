import 'package:json_diff/json_diff.dart';
import 'package:json_model_builder/list.dart';
import 'package:json_model_builder/map.dart';
import 'package:json_model_builder/primitives.dart';
import 'package:json_model_builder/types.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void spectJsonNoChange(JsonType jsonOnj, dynamic initialJson) {
  expect(false, JsonDiffer.fromJson(initialJson, jsonOnj.toJson()).diff().hasChanged);
}

void main() {
  test('list', () {
    final initialJson = [1, 2, 3, 4];
    final jsonObj = JsonList<JsonInt>(JsonInt.new);
    assert(jsonObj.setFromJson(initialJson));
    spectJsonNoChange(jsonObj, initialJson);
  });
  test('map', () {
    final initialJson = {'one': 1, 'two': 2, 'three': 3};
    final jsonObj = JsonMap<JsonInt>(JsonInt.new);
    assert(jsonObj.setFromJson(initialJson));
    spectJsonNoChange(jsonObj, initialJson);
  });

  test('list of maps', () {
    final initialJson = [
      {'one': 1, 'two': 2, 'three': 3},
      {'four': 4, 'five': 5, 'six': 6}
    ];

    final jsonObj = JsonList<JsonMap<JsonInt>>(() => JsonMap<JsonInt>(JsonInt.new))..setFromJson(initialJson);
    spectJsonNoChange(jsonObj, initialJson);
  });
}
