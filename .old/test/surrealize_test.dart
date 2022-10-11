import 'package:json_model_builder/models.dart';
import 'package:test/scaffolding.dart';

import 'models.dart';
import 'tests/test1_json_basic.dart';
import 'tests/test2_structure.dart';
import 'tests/test3_composed_model.dart';
import 'tests/test5_check_fields_names.dart';
import 'tests/test6_lists.dart';
import 'tests/test7_maps.dart';
import '../../example/main.dart' as example;

void main() {
  Model.register('person', (json) => Person(json));
  Model.register('user', (json) => User(json));
  Model.register('shopping_item', (json) => ShoppingItem(json));
  Model.register('shopping_cart', (json) => ShoppingCart(json));
  Model.register('backpack', (json) => BackPack(json));

  test('example code', (() => example.main([])));

  test1();
  test2();
  test3();
  test5();
  test6();
  test7();
}
