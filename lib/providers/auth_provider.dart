import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  String? userPersonalNumber;
  String? userName;

  bool get isAuthenticated => userPersonalNumber != null;

  Future<void> login(String personalNumber) async {
    final response =
        await _supabase
            .from('persons')
            .select()
            .eq('personal_number', personalNumber)
            .maybeSingle();

    if (response == null || (response.isEmpty)) {
      throw Exception("Användare hittades inte");
    }
    userPersonalNumber = response['personal_number'] as String;
    userName = response['name'] as String;
    notifyListeners();
  }

  void logout() {
    userPersonalNumber = null;
    userName = null;
    notifyListeners();
  }
}
