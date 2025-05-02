import 'package:parking_user/models/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonRepository {
  final String baseUrl = 'http://10.0.2.2:3000/api/persons';

  Future<void> add(Person person) async {
    final Uri url = Uri.parse(baseUrl);
    final String body = jsonEncode(person.toJson());

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        print('✅ Personen ${person.name} har lagts till.');
      } else if (response.statusCode == 409) {
        throw Exception(
          '❌ Personen med personnummer ${person.personalNumber} finns redan i systemet.',
        );
      } else if (response.statusCode == 400) {
        throw Exception(
          '❌ Ogiltiga data skickades. Kontrollera att alla fält är korrekt ifyllda.',
        );
      } else if (response.statusCode == 500) {
        throw Exception('❌ Serverfel, försök igen senare.');
      } else {
        throw Exception(
          '❌ Okänt fel: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      print('$e');
    }
  }

  Future<List<Person>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      return data.map((e) => Person.fromJson(e)).toList();
    } else {
      throw Exception('Misslyckades att hämta personer');
    }
  }

  Future<Person?> getPersonById(String personalNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/$personalNumber'));

    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Kunde inte hämta person. Felkod: ${response.statusCode}, Svar: ${response.body}',
      );
    }
  }

  Future<void> update(Person person) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${person.personalNumber}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Misslyckades att uppdatera person');
    }
  }

  Future<void> delete(String personalNumber) async {
    final response = await http.delete(Uri.parse('$baseUrl/$personalNumber'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final name = data['name'];
      print('✅ $name med personnummer $personalNumber har raderats.');
    } else if (response.statusCode == 404) {
      throw Exception(
        '❌ Personen med personnummer $personalNumber hittades inte.',
      );
    } else if (response.statusCode == 400) {
      throw Exception('❌ Ogiltigt personnummer: $personalNumber.');
    } else {
      throw Exception(
        '❌ Misslyckades att radera person. Felkod: ${response.statusCode}',
      );
    }
  }
}

class VehicleRepository {
  final String baseUrl = 'http://10.0.2.2:3000/api/vehicles';

  Future<void> add(Vehicle vehicle) async {
    final Uri url = Uri.parse(baseUrl);
    final String body = jsonEncode(vehicle.toJson());

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        print(
          '✅ Fordon av typen ${vehicle.vehicleType} med registreringsnummer ${vehicle.registrationNumber} har lagts till.',
        );
      } else if (response.statusCode == 409) {
        throw Exception(
          '❌ Fordon med registreringsnummer ${vehicle.registrationNumber} finns redan i systemet.',
        );
      } else if (response.statusCode == 400) {
        throw Exception(
          '❌ Ogiltiga data skickades. Kontrollera att alla fält är korrekt ifyllda.',
        );
      } else if (response.statusCode == 500) {
        throw Exception('❌ Serverfel, försök igen senare.');
      } else {
        throw Exception(
          '❌ Okänt fel: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Vehicle>> getAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List;
        return data.map((v) => Vehicle.fromJson(v)).toList();
      } else {
        throw Exception(
          'Misslyckades att hämta fordon. Statuskod: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Ett fel inträffade vid hämtning av fordon: $e');
    }
  }

  Future<Vehicle?> getVehicleByRegistrationN(String registrationNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/$registrationNumber'));

    if (response.statusCode == 200) {
      return Vehicle.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Kunde inte hämta fordon. Felkod: ${response.statusCode}, Svar: ${response.body}',
      );
    }
  }

  Future<void> update(Vehicle updatedVehicle) async {
    final Uri url = Uri.parse('$baseUrl/${updatedVehicle.registrationNumber}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedVehicle.toJson()),
    );

    if (response.statusCode == 200) {
      print(
        '✅ Fordonet med registreringsnummer ${updatedVehicle.registrationNumber} har uppdaterats.',
      );
    } else if (response.statusCode == 404) {
      print(
        '❌ Fordonet med registreringsnummer ${updatedVehicle.registrationNumber} hittades inte.',
      );
    } else {
      print(
        '❌ Misslyckades att uppdatera fordon. Felkod: ${response.statusCode}',
      );
    }
  }

  Future<String> delete(String registrationNumber) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$registrationNumber'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final vType = data['vehicleType'];
      final message =
          ('✅ $vType med registreringsnummer $registrationNumber har raderats.');
      return message;
    } else if (response.statusCode == 404) {
      throw Exception('❌ Fordon med regnr $registrationNumber hittades inte.');
    } else if (response.statusCode == 400) {
      throw Exception('❌ Ogiltigt regnr: $registrationNumber.');
    } else {
      throw Exception(
        '❌ Misslyckades att radera fordon. Felkod: ${response.statusCode}',
      );
    }
  }
}

class ParkingSpaceRepository {
  final String baseUrl = 'http://10.0.2.2:3000/api/parking_spaces';

  Future<void> add(ParkingSpace space) async {
    final Uri url = Uri.parse(baseUrl);
    final String body = jsonEncode(space.toJson());

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        print('✅ Parkeringsplats på ${space.address} har lagts till.');
      } else if (response.statusCode == 409) {
        throw Exception('❌ Parkeringsplats med ID ${space.id} finns redan.');
      } else {
        throw Exception(
          '❌ Okänt fel: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      print('🚨 Fel vid tillägg av parkeringsplats: $e');
    }
  }

  Future<List<ParkingSpace>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((s) => ParkingSpace.fromJson(s)).toList();
    } else {
      throw Exception('❌ Misslyckades att hämta parkeringsplatser.');
    }
  }

  Future<ParkingSpace?> getSpaceById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return ParkingSpace.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        '❌ Misslyckades att hämta parkeringsplats. Felkod: ${response.statusCode}',
      );
    }
  }

  Future<void> update(ParkingSpace updatedSpace) async {
    final Uri url = Uri.parse('$baseUrl/${updatedSpace.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedSpace.toJson()),
    );

    if (response.statusCode == 200) {
      print('✅ Parkeringsplats ${updatedSpace.id} uppdaterad.');
    } else if (response.statusCode == 404) {
      print('❌ Parkeringsplatsen hittades inte.');
    } else {
      print(
        '❌ Misslyckades att uppdatera parkeringsplats. Felkod: ${response.statusCode}',
      );
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      print('✅ Parkeringsplats med ID $id har raderats.');
    } else if (response.statusCode == 404) {
      throw Exception('❌ Parkeringsplatsen hittades inte.');
    } else {
      throw Exception(
        '❌ Misslyckades att radera parkeringsplats. Felkod: ${response.statusCode}',
      );
    }
  }
}

class ParkingSessionRepository {
  final String baseUrl = 'http://10.0.2.2:3000/api/parking_sessions';

   Future<void> add(ParkingSession parking) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );

    if (response.statusCode == 201) {
      return;
    }
    final Map<String, dynamic> errorData = jsonDecode(response.body);
    final msg = errorData['error'] as String? ?? 'Okänt fel från servern';
    throw Exception(msg);
  }


  Future<List<ParkingSession>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((p) => ParkingSession.fromJson(p)).toList();
    } else {
      throw Exception('❌ Misslyckades att hämta parkeringar.');
    }
  }

  Future<ParkingSession?> getParkingByRegistrationN(
    String registrationNumber,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/$registrationNumber'));

    if (response.statusCode == 200) {
      return ParkingSession.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        '❌ Misslyckades att hämta parkering. Felkod: ${response.statusCode}, Svar: ${response.body}',
      );
    }
  }

  Future<void> update(String regNum, {DateTime? newEndTime}) async {
    final payload = <String, dynamic>{};
    if (newEndTime != null) {
      payload['end_time'] = newEndTime.toIso8601String();
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$regNum'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('❌ Misslyckades att uppdatera parkering.Statuskod: ${response.statusCode}, svar: ${response.body}');
    }
  }

  Future<void> delete(String regNum) async {
    final response = await http.delete(Uri.parse('$baseUrl/$regNum'));

    if (response.statusCode == 200) {
      print('✅ Parkering för $regNum har raderats.');
    } else if (response.statusCode == 404) {
      throw Exception('❌ Ingen parkering hittades för $regNum.');
    } else {
      throw Exception('❌ Misslyckades att radera parkering.');
    }
  }
}
