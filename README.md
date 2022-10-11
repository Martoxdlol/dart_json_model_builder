# Build JSON serializable classes without code gen or mirrors

This library provides a way to create modeles easily usable from code that can be serialized into/from JSON.

Instead of directly using variables of the corresponding types we use 'JsonType'. 
A 'JsonType' can convert a given type from and to json. 

### Models

Models are custom JsonTypes with custom entries and types.
A model can
 - Be serialized to JSON
 - Be instanciated from parsed JSON
 - Have entries with a type of Model
 - Be able to correctly create it sub model entries from JSON

If you have a Model that has some entry with type of other model, this will work fine. 
Instanciating the parent from json will also instanciate the child correctly.

## Example
```dart

class SocialNetwork extends ModelBuilder {
  @override
  Iterable<JsonType> get values => [users, posts, likes];

  JsonList<User> get users => jsonList<User>('users', User.new);

  JsonList<Post> get posts => jsonList<Post>('posts', () => Post({}));

  JsonMap<JsonInt> get likes => jsonMap<JsonInt>('likes_by_post_id', JsonInt.new);

  JsonMap<JsonList<Post>> get collections => jsonMap('collections', () => JsonList(() => Post({})));
}

class Post extends ModelBuilder {
  // Add this lines to instanciate from json source directly
  Post(super.source);

  @override
  Iterable<JsonType> get values => [id, title, content, creator];

  // Functions passed as default value are called when instanciating the model
  JsonInt get id => jsonInt('id', nextId);

  JsonString get title => jsonString('title');

  JsonString get content => jsonString('content');

  JsonString get creator => jsonString('creator_email');
}

class User extends ModelBuilder {
  @override
  Iterable<JsonType> get values => [name, email, birthday, address];

  JsonString get name => jsonString('name');

  JsonString get email => jsonString('email');

  JsonDateTime get birthday => jsonDateTime('birthday');

  Address get address => jsonModel<Address>('address', Address.new);
}

class Address extends ModelBuilderNullable {
  @override
  Iterable<JsonType> get values => [street, number, street, city, state, country];

  JsonString get street => jsonString('street');

  JsonIntNullable get number => jsonIntNullable('number');

  JsonString get zip => jsonString('zip_code');

  JsonStringNullable get city => jsonStringNullable('city');

  JsonString get state => jsonString('state');

  JsonString get country => jsonString('country');
}

void main(List<String> args) {
  final faceGram = SocialNetwork();

  final user = User();
  user.setFromJson({
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
  });

  faceGram.users.add(user);

  assert(faceGram.users[0] == user);
  assert(!user.address.isNull);
  assert(user.address.state.value == 'Some State');

  faceGram.posts.add(Post({'title': 'Dart is awesome', 'content': 'Lorem ipsum ...', 'creator_email': user.email}));
  final post = faceGram.posts[0];
  assert(post.creator.value == 'tomas-123@facegram.com');

  final y2020 = Post({
    'title': JsonString()..setFromJson(2020),
    'content': JsonString()..set('Year 2020, ...'),
  });

  y2020.creator.set(user.email.value);
  y2020.title.value += ', the pandemic';

  faceGram.posts.add(y2020);
  assert(faceGram.posts[1].title.value == '2020, the pandemic');

  faceGram.collections['code'] = JsonList<Post>(() => Post({}));

  faceGram.collections['code']!.add(Post({'title': 'I HATE SOFTWARE'}));
  faceGram.collections['code']!.add(Post({'title': 'I LOVE SOFTWARE'}));

  faceGram.collections['history'] = JsonList<Post>(() => Post({}));

  faceGram.collections['history']!.add(Post({'title': 'Year 2020 pandemic'}));
}

int id = 0;

int nextId() => id++;

```


