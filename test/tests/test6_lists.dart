import 'package:json_diff/json_diff.dart';
import 'package:surrealize/fields.dart';
import 'package:surrealize/models.dart';
import 'package:test/test.dart';

import '../models.dart';

void testCart(ShoppingCart cart) {
  expect(cart.owner.value, 'Tomás');
  expect(cart.items.values?.length, 3);
  expect((cart.items.values?[0]?.value as ShoppingItem).fields.length, 2);
  expect((cart.items.values?[1]?.value as ShoppingItem).fields.length, 2);
  expect((cart.items.values?[2]?.value as ShoppingItem).fields.length, 2);

  expect(
    (cart.items.values?[0]?.value as ShoppingItem).name.value,
    'sauce',
  );
  expect(
    (cart.items.values?[1]?.value as ShoppingItem).id.value,
    20,
  );
  expect(
    (cart.items.values?[2]?.value as ShoppingItem).name.value,
    'cheese',
  );
  expect(
    (cart.items.values?[2]?.value as ShoppingItem).id.value,
    30,
  );
}

void test6() {
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

  test('lists with combined imput', () {
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

    expect(backpack.generic.values![1]!.value, 2);
    expect(backpack.generic.values![2]!.value, 3);
    expect(backpack.generic.values![3]!.value, 'four');
    testCart(backpack.generic.values![4]!.value);

    expect(JsonDiffer.fromJson(expectedJson, backpack.toJson()).diff().hasChanged, false);
  });
}
