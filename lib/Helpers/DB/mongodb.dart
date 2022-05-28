import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:projectcrm/Helpers/DB/Connection_Strings.dart';

class MongoDatabase {
  static var db, userCollection;
  static Connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);
    print('Connected to database');
    userCollection = db.collection(USER_COLLECTION);
  }
}