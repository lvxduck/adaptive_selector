import 'package:faker/faker.dart';

class PersonRepository {
  List<Person> getList({
    required int page,
    required String keyword,
  }) {
    return List.generate(10, (index) => faker.person);
  }
}
