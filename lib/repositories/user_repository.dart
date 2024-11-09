import 'package:financialratios/models/finance_entry.dart';
import 'package:financialratios/models/user.dart';
import 'package:financialratios/repositories/finance_entry_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;

class UserRepository {
  static UserRepository _instance;

  UserRepository._init();

  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._init();
    }
    return _instance;
  }

  Future<User> createFromFirebase(FirebaseUser firebaseUser) async {
    User user = User.fromFirebase(firebaseUser);
    List<FinanceEntry> feList = await FinanceEntryRepo.instance
        .getUserFinanceEntries(firebaseUser.email);
    user.financeEntries = feList;
    return user;
  }
}
