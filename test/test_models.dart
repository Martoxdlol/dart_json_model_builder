// ignore_for_file: unused_shown_name

import 'package:json_model_builder/json_model_builder.dart';
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

  test('list items from intance', () {
    final addr1 = Address()
      ..setFromJson({
        'street': 'Some Street',
        'number': 123,
        'zip_code': '1000',
        'city': 'Some City',
        'state': 'Some State',
        'country': 'United Land'
      });

    final addr2 = Address()
      ..setFromJson({
        'street': 'Some Street 2',
        'number': 2123,
        'zip_code': '2000',
        'city': 'Some City 2',
        'state': 'Some State 2',
        'country': 'United Land 2'
      });

    final model = ModelWithAList()..addresses.setFromJson([addr1, addr2]);

    expect(model.toJson()['adresses'][0]['number'], 123);
    expect(model.toJson()['adresses'][1]['number'], 2123);
  });
}

class ModelWithAList extends ModelBuilder {
  @override
  Iterable<JsonType> get values => [addresses];

  JsonList<Address> get addresses => jsonList('adresses', Address.new);
}
