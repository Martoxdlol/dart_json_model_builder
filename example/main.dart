import 'package:surrealize/fields.dart';
import 'package:surrealize/models.dart';

class Person extends ModelBuilder {
  Person(super.json);

  @override
  Iterable<Field> get fields => [age, name, address, props, nums];

  StringField get name => stringField('name');
  IntField get age => intField('age');
  ModelField<Address> get address => modelField('address');
  ModelField<ModelMap> get props => mapField('props');
  ModelField<ModelList> get nums => listField('nums');
}

class Address extends ModelBuilder {
  Address(super.json);

  @override
  Iterable<Field> get fields => [street, number, city, state, country];

  StringField get street => stringField('street');
  IntField get number => intField('number');
  StringField get city => stringField('city');
  StringField get state => stringField('state');
  StringField get country => stringField('country');
}

void main(List<String> args) {
  Model.register('person', (json) => Person(json));
  Model.register('address', (json) => Address(json));

  final address = Address({'street': 'Some Street'});
  address.number.set(123);
  address.city.set('Vicente López');
  address.state.set('Buenos Aires');
  address.country.set('Argentina');

  final tomas = Person({
    'name': 'Tomás',
    'age': 20,
    'address': address,
    'nums': [1, 2, 3, 4]
  });

  print(tomas.toJson());
  print(address.toJson());
  print(tomas.name.value);
}
