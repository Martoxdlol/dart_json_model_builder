import 'package:json_diff/json_diff.dart';
import 'package:json_model_builder/fields.dart';
import 'package:json_model_builder/models.dart';
import 'package:test/test.dart';

import '../models.dart';

void test7() {
  test('generic map', () {
    final backpack = BackPack({
      'named': {
        'one': 1,
        'two': 'two',
        'someone': Person({'name': 'Tomás'}),
        'submap': {
          '1': 1,
          'other_me': Person({'name': 'Thomas'})
        }
      }
    });

    expect(backpack.named.value is ModelMap, true);
    expect((backpack.named.value as ModelMap).get('submap')!.value is ModelMap, true);

    final map = backpack.named.value as ModelMap;

    expect(map['one']!.value, 1);
    expect(map['one']!.name, 'one');
    expect(map['one']!.type, int);

    expect(map['two']!.value, 'two');
    expect(map['two']!.name, 'two');
    expect(map['two']!.type, String);

    print(backpack.toJson());
  });

  test('typed map', () {
    final usersCollection = UsersCollection({
      'users_by_id': {
        '1234': {'name': 'Tomás'},
        '2345': User({'name': 'Juan'})
      }
    });

    final map = usersCollection.usersById.value as ModelMap;
    expect(map['1234']!.type == User, true);
    expect(map['1234']!.value['name'].value, 'Tomás');
    expect(map['2345']!.type == User, true);
    expect(map['2345']!.value['name'].value, 'Juan');
  });
}
