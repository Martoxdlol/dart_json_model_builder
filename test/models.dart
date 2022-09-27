import 'package:surrealize/fields.dart';
import 'package:surrealize/models.dart';

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
