import 'package:json_diff/json_diff.dart';
import 'package:json_model_builder/fields.dart';
import 'package:json_model_builder/models.dart';
import 'package:test/test.dart';

import '../models.dart';

class ListIntTest extends ModelBuilder {
  ListIntTest(super.json);

  @override
  Iterable<Field> get fields => [numbers];

  ListField get numbers => listField('numbers', type: int);
}

void testCart(ShoppingCart cart) {
  expect(cart.owner.value, 'Tomás');
  expect(cart.items.current?.length, 3);
  expect((cart.items.current?[0]?.value as ShoppingItem).fields.length, 2);
  expect((cart.items.current?[1]?.value as ShoppingItem).fields.length, 2);
  expect((cart.items.current?[2]?.value as ShoppingItem).fields.length, 2);

  expect(
    (cart.items.current?[0]?.value as ShoppingItem).name.value,
    'sauce',
  );
  expect(
    (cart.items.current?[1]?.value as ShoppingItem).id.value,
    20,
  );
  expect(
    (cart.items.current?[2]?.value as ShoppingItem).name.value,
    'cheese',
  );
  expect(
    (cart.items.current?[2]?.value as ShoppingItem).id.value,
    30,
  );
}

void test6() {
  Model.register('ints', ((json) => ListIntTest(json)));

  test('lists with models', () {
    final cart = ShoppingCart({
      'owner_name': 'Tomás',
      'items': [
        ShoppingItem({'name': 'sauce', 'id': 10}),
        ShoppingItem({'name': 'tomatoes', 'id': 20}),
        ShoppingItem({'name': 'cheese', 'id': 30}),
      ]
    });

    testCart(cart);
  });

  test('lists with json to model', () {
    final cart = ShoppingCart({
      'owner_name': 'Tomás',
      'items': [
        {'name': 'sauce', 'id': 10},
        {'name': 'tomatoes', 'id': 20},
        {'name': 'cheese', 'id': 30},
      ]
    });

    testCart(cart);
  });

  test('lists with primitive type', () {
    final cleanJson = {
      'numbers': [1, 2, 3, 4]
    };
    final numbers = ListIntTest(cleanJson);
    expect(JsonDiffer.fromJson(numbers.toJson(), cleanJson).diff().hasChanged, false);

    final numbers2 = ListIntTest({
      'numbers': [1, 2, '3', 4.3, 'false', null]
    });
    expect(JsonDiffer.fromJson(numbers2.toJson(), cleanJson).diff().hasChanged, false);
  });

  test('lists with combined input', () {
    final cart = ShoppingCart({
      'owner_name': 'Tomás',
      'items': [
        ShoppingItem({'name': 'sauce', 'id': 10}),
        {'name': 'tomatoes', 'id': 20},
        {'name': 'cheese', 'id': 30},
      ]
    });

    testCart(cart);
  });

  test('list with dynamic fields', () {
    final cart = ShoppingCart({
      'owner_name': 'Tomás',
      'items': [
        ShoppingItem({'name': 'sauce', 'id': 10}),
        {'name': 'tomatoes', 'id': 20},
        {'name': 'cheese', 'id': 30},
      ]
    });

    final backpack = BackPack({
      'generic': [1, 2, 3, 'four', cart]
    });

    final expectedJson = {
      'named': null,
      'generic': [
        1,
        2,
        3,
        'four',
        {
          'owner_name': 'Tomás',
          'items': [
            {'name': 'sauce', 'id': 10},
            {'name': 'tomatoes', 'id': 20},
            {'name': 'cheese', 'id': 30}
          ]
        }
      ]
    };

    expect(backpack.generic.current![1]!.value, 2);
    expect(backpack.generic.current![2]!.value, 3);
    expect(backpack.generic.current![3]!.value, 'four');
    testCart(backpack.generic.current![4]!.value);

    expect(JsonDiffer.fromJson(expectedJson, backpack.toJson()).diff().hasChanged, false);
  });
}
