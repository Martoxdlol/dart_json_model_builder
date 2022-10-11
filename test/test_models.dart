import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../example/main.dart' show SocialNetwork, Post, Address, User;
import 'util.dart';

void testModels() {
  test('Model from pure JSON', () {
    final initialJson = {
      'name': 'Tomás',
      'email': 'tomas-123@facegram.com',
      'birthday': '2020-04-05T00:00:00.000',
      'address': {
        'street': 'Some Street',
        'number': 123,
        'zip_code': '1000',
        'city': 'Some City',
        'state': 'Some State',
        'country': 'United Land'
      }
    };

    final user = User();
    assert(user.setFromJson(initialJson));

    expect(user.name.value, 'Tomás');
    expect(user.email.value, 'tomas-123@facegram.com');
    expect(user.address.state.value, 'Some State');
    expect(user.address.number.value, 123);

    spectJsonNoChange(user, initialJson);
  });

  test('Model from mixed JSON', () {
    final addressJson = {
      'street': 'Some Street',
      'number': 123,
      'zip_code': '1000',
      'city': 'Some City',
      'state': 'Some State',
      'country': 'United Land'
    };

    final initialJson = {
      'name': 'Tomás',
      'email': 'tomas-123@facegram.com',
      'birthday': '2020-04-05T00:00:00.000',
      'address': Address()..setFromJson(addressJson)
    };

    final user = User();
    assert(user.setFromJson(initialJson));

    expect(user.name.value, 'Tomás');
    expect(user.email.value, 'tomas-123@facegram.com');
    expect(user.address.state.value, 'Some State');
    expect(user.address.number.value, 123);

    spectJsonNoChange(user.address, addressJson);
  });
}
