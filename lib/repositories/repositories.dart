import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:parking_user/models/models.dart';

class PersonRepository {
  final FirebaseFirestore _firestore;

  PersonRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Referens till samlingen "persons" i Firestore
  CollectionReference<Map<String, dynamic>> get _personsCol =>
      _firestore.collection('persons');

  /// Lägger till en ny person. Använder personnummer som dokument-ID
  /// för att upprätthålla unikhet.
  Future<void> add(Person person) async {
    final docRef = _personsCol.doc(person.personalNumber);

    try {
      // Kontrollera om dokumentet redan finns
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        throw Exception(
          '❌ Personen med personnummer ${person.personalNumber} finns redan i systemet.',
        );
      }

      // Skriv in datan
      await docRef.set(person.toJson());
      print('✅ Personen ${person.name} har lagts till.');
    } on FirebaseException catch (e) {
      // Hantera eventuella Firestore-fel
      throw Exception('❌ Firestore error: ${e.message}');
    } catch (e) {
      // Fallback för övriga fel
      throw Exception('❌ Okänt fel vid registrering av person: $e');
    }
  }

  Future<List<Person>> getAll() async {
    try {
      final snapshot = await _personsCol.get();
      return snapshot.docs.map((doc) => Person.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('❌ Misslyckades att hämta personer: $e');
    }
  }

  Future<Person?> getByPersonalNumber(String personalNumber) async {
    try {
      final doc = await _personsCol.doc(personalNumber).get();
      if (!doc.exists) return null;
      return Person.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('❌ Misslyckades att hämta person: $e');
    }
  }

  Future<void> update(Person person) async {
    final docRef = _personsCol.doc(person.personalNumber);
    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception(
          '❌ Ingen person hittades med personnummer ${person.personalNumber}.',
        );
      }
      await docRef.update({'name': person.name});
      print('✅ Personen ${person.personalNumber} har uppdaterats.');
    } on FirebaseException catch (e) {
      throw Exception('❌ Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('❌ Okänt fel vid uppdatering av person: $e');
    }
  }

  Future<void> delete(String personalNumber) async {
    final docRef = _personsCol.doc(personalNumber);
    try {
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception(
          '❌ Personen med personnummer $personalNumber hittades inte.',
        );
      }
      await docRef.delete();
      print('✅ Personen med personnummer $personalNumber har raderats.');
    } on FirebaseException catch (e) {
      throw Exception('❌ Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('❌ Okänt fel vid radering av person: $e');
    }
  }
}

class VehicleRepository {
  /// Instans av Firestore
  final FirebaseFirestore _firestore;

  VehicleRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Referens till samlingen 'vehicles'
  CollectionReference<Map<String, dynamic>> get _vehiclesCol =>
      _firestore.collection('vehicles');

  /// Lägg till ett nytt fordon. Använder registrationNumber som dokument‐ID.
  Future<void> add(Vehicle vehicle) async {
    final docRef = _vehiclesCol.doc(vehicle.registrationNumber);

    final exists = (await docRef.get()).exists;
    if (exists) {
      throw Exception(
        'Ett fordon med regnr ${vehicle.registrationNumber} finns redan.',
      );
    }

    final data = {
      'registration_number': vehicle.registrationNumber,
      'vehicle_type': vehicle.vehicleType,
      // Spara ägarens personnummer (kan användas för filtrering)
      'ownerID': vehicle.owner?.personalNumber,
    };

    await docRef.set(data);
  }

  Future<List<Vehicle>> getAll() async {
    try {
      final snapshot = await _vehiclesCol.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();

        final ownerPersonalNumber = data['ownerID'];

        Person? owner;
        if (ownerPersonalNumber != null) {
          owner = Person('', ownerPersonalNumber as String);
        }

        return Vehicle(
          data['registration_number'] as String,
          data['vehicle_type'] as String,
          owner,
        );
      }).toList();
    } catch (e) {
      throw Exception('Ett fel inträffade vid hämtning av fordon: $e');
    }
  }

  Future<Vehicle?> getVehicleByRegistrationN(String registrationNumber) async {
    try {
      final doc = await _vehiclesCol.doc(registrationNumber).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;

      final json = {
        'registration_number': doc.id,
        'vehicle_type': data['vehicle_type'] as String,
        'owner': {
          'name': data['owner_name'] as String? ?? '',
          'personal_number': data['owner_personal_number'] as String,
        },
      };

      return Vehicle.fromJson(json);
    } catch (e) {
      throw Exception('Kunde inte hämta fordon: $e');
    }
  }

  Future<String> update(Vehicle updatedVehicle) async {
    try {
      await _vehiclesCol.doc(updatedVehicle.registrationNumber).update({
        // Hitta de fält du vill uppdatera:
        'vehicle_type': updatedVehicle.vehicleType,
        'owner_name': updatedVehicle.owner?.name,
        'owner_personal_number': updatedVehicle.owner?.personalNumber,
      });
      return '✅ Fordonet med registreringsnummer '
          '${updatedVehicle.registrationNumber} har uppdaterats.';
    } catch (e) {
      throw Exception(
        '❌ Misslyckades att uppdatera fordon ${updatedVehicle.registrationNumber}: $e',
      );
    }
  }

  Future<String> delete(String registrationNumber) async {
    try {
      // Hämta gärna fordonstypen innan du raderar, om du vill använda det i meddelandet:
      final doc = await _vehiclesCol.doc(registrationNumber).get();
      String type =
          (doc.data() as Map<String, dynamic>)['vehicle_type'] as String;

      await _vehiclesCol.doc(registrationNumber).delete();
      return '✅ $type med registreringsnummer $registrationNumber har raderats.';
    } catch (e) {
      throw Exception(
        '❌ Misslyckades att radera fordon $registrationNumber: $e',
      );
    }
  }
}

class ParkingSpaceRepository {
  final _spacesCol = FirebaseFirestore.instance.collection('parking_spaces');

  /// Lägger till en ny parkeringsplats och returnerar ett bekräftelse-meddelande.
  Future<String> add(ParkingSpace space) async {
    try {
      await _spacesCol.doc(space.id).set(space.toJson());
      return '✅ Parkeringsplats på "${space.address}" har lagts till.';
    } catch (e) {
      throw Exception('❌ Fel vid tillägg av parkeringsplats: $e');
    }
  }

  /// Hämtar alla parkeringsplatser.
  Future<List<ParkingSpace>> getAll() async {
    try {
      final snap = await _spacesCol.get();
      return snap.docs.map((doc) {
        final data = doc.data();
        // Skicka med doc.id om modellen behöver det
        return ParkingSpace.fromJson({
          'id': doc.id,
          'address': data['address'] as String,
          'pph': data['pph'] as num,
        });
      }).toList();
    } catch (e) {
      throw Exception('❌ Misslyckades att hämta parkeringsplatser: $e');
    }
  }

  /// Hämtar en enskild parkeringsplats via dess ID, eller null om den inte finns.
  Future<ParkingSpace?> getSpaceById(String id) async {
    try {
      final doc = await _spacesCol.doc(id).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return ParkingSpace.fromJson({
        'id': doc.id,
        'address': data['address'] as String,
        'pph': data['pph'] as num,
      });
    } catch (e) {
      throw Exception('❌ Fel vid hämtning av parkeringsplats: $e');
    }
  }

  /// Uppdaterar en parkeringsplats och returnerar ett bekräftelse-meddelande.
  Future<String> update(ParkingSpace space) async {
    try {
      await _spacesCol.doc(space.id).update({
        'address': space.address,
        'pph': space.pph,
      });
      return '✅ Parkeringsplats "${space.id}" uppdaterad.';
    } catch (e) {
      throw Exception(
        '❌ Misslyckades att uppdatera parkeringsplats ${space.id}: $e',
      );
    }
  }

  /// Raderar en parkeringsplats och returnerar ett bekräftelse-meddelande.
  Future<String> delete(String id) async {
    try {
      await _spacesCol.doc(id).delete();
      return '✅ Parkeringsplats med ID "$id" har raderats.';
    } catch (e) {
      throw Exception('❌ Misslyckades att radera parkeringsplats $id: $e');
    }
  }
}

class ParkingSessionRepository {
  final _col = FirebaseFirestore.instance.collection('parking_sessions');

  /// Starta en ny parkering (lägg till en session).
  /// Returnerar ett bekräftelsemeddelande vid lyckat anrop.
  Future<String> add(ParkingSession session) async {
  try {
    // Använd registreringsnumret som dokument-ID
    final docRef = _col.doc(session.vehicle.registrationNumber);

    // Spara hela parkeringsplats-objektet så att address finns med direkt
    await docRef.set({
      'vehicle': session.vehicle.toJson(),
      'parking_space': session.parkingSpace.toJson(),
      'start_time': session.startTime.toIso8601String(),
      if (session.endTime != null)
        'end_time': session.endTime!.toIso8601String(),
    });

    return '✅ Parkering startad för ${session.vehicle.registrationNumber}.';
  } catch (e, st) {
    print('❌ Fel i ParkingSessionRepository.add(): $e\n$st');
    throw Exception('❌ Misslyckades att starta parkering: $e');
  }
}

  Future<List<ParkingSession>> getAll() async {
  try {
    final snap = await _col.get();
    return snap.docs.map((doc) {
      final data = doc.data(); // Map<String, dynamic>

      return ParkingSession.fromJson({
        'vehicle': data['vehicle'] as Map<String, dynamic>,
        'parking_space': data['parking_space'] as Map<String, dynamic>,
        'start_time': data['start_time'] as String,
        'end_time': data['end_time'] as String?,
      });
    }).toList();
  } catch (e, st) {
    print('❌ Fel i ParkingSessionRepository.getAll(): $e\n$st');
    throw Exception('❌ Misslyckades att hämta parkeringssessioner: $e');
  }
}

  Future<ParkingSession?> getParkingByRegistrationN(
    String registrationNumber,
  ) async {
    try {
      // Vi antar att dokumenten sparar hela vehicle-map: { registration_number, vehicle_type, owner: {…} }
      final query =
          await _col
              .where(
                'vehicle.registration_number',
                isEqualTo: registrationNumber,
              )
              .where('end_time', isNull: true)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        return null;
      }

      final data = query.docs.first.data();
      // Bygg upp en JSON-struktur som din ParkingSession.fromJson klarar av:
      final json = {
        'vehicle': data['vehicle'], // måste vara en Map<String, dynamic>
        'parking_space': data['parking_space'], // också en Map<String, dynamic>
        'start_time': data['start_time'], // ISO-sträng eller Timestamp
        'end_time': data['end_time'], // null för aktiv
      };
      return ParkingSession.fromJson(json);
    } catch (e) {
      throw Exception('❌ Misslyckades att hämta parkering: $e');
    }
  }

  Future<String> update(
    String registrationNumber, {
    DateTime? newEndTime,
  }) async {
    try {
      final docRef = _col.doc(registrationNumber);
      final updateData = <String, dynamic>{};

      if (newEndTime != null) {
        // Spara som ISO-sträng i Firestore
        updateData['end_time'] = newEndTime.toIso8601String();
      }

      await docRef.update(updateData);

      // Formatera tiden för meddelandet
      final formatted =
          newEndTime != null
              ? DateFormat('HH:mm').format(newEndTime)
              : DateFormat('HH:mm').format(DateTime.now());

      return '✅ Parkering avslutad kl $formatted.';
    } catch (e) {
      throw Exception('❌ Misslyckades att uppdatera parkering: $e');
    }
  }

  Future<String> delete(String uuid) async {
    try {
      await _col.doc(uuid).delete();
      return '✅ Parkeringssession raderad.';
    } catch (e) {
      throw Exception('❌ Misslyckades att radera parkering: $e');
    }
  }
}
