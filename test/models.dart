import 'package:json_model_builder/fields.dart';
import 'package:json_model_builder/models.dart';

class Person extends ModelBuilder {
  Person(super.json);

  @override
  Iterable<Field> get fields => [age, name, address];

  StringField get name => stringField('name');
  StringField get address => stringField('address');
  IntField get age => intField('age');
}

class User extends ModelBuilder {
  User(super.json);

  @override
  Iterable<Field> get fields => [name, username, person];

  StringField get name => stringField('name');
  StringField get username => stringField('username');
  ModelField<Person> get person => modelField('person');
}

class ShoppingItem extends ModelBuilder {
  ShoppingItem(super.json);

  @override
  Iterable<Field> get fields => [name, id];

  StringField get name => stringField('name');
  IntField get id => intField('id');
}

class ShoppingCart extends ModelBuilder {
  ShoppingCart(super.json);

  @override
  Iterable<Field> get fields => [owner, items];

  StringField get owner => stringField('owner_name');
  ListField get items => listField('items', type: ShoppingItem);
}

class BackPack extends ModelBuilder {
  BackPack(super.json);

  @override
  Iterable<Field> get fields => [named, generic];

  MapField get named => mapField('named');
  ListField get generic => listField('generic');
}

class UsersCollection extends ModelBuilder {
  UsersCollection(super.json);

  @override
  Iterable<Field> get fields => [usersById];

  MapField get usersById => mapField('users_by_id', type: User);
}
