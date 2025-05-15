
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_and_eat/Services/restaurants_service.dart';
import 'package:sit_and_eat/Services/user_service.dart';
import 'package:flutter/cupertino.dart';

class ReservationService{
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RestaurantsService _restaurantsService = RestaurantsService(firestore: FirebaseFirestore.instance);

  Future<bool> reservationExists(Map<String,dynamic> reservationData) async {
    try {
      Timestamp dateTimestamp = (reservationData['date'] is Timestamp)
      ? reservationData['date']
      : Timestamp.fromDate(reservationData['date']);

      QuerySnapshot query = await _db.collection('Reservas')
          .where('empresa_uid', isEqualTo: reservationData['empresa_uid'])
          .where('date', isEqualTo: dateTimestamp)
          .where('time', isEqualTo: reservationData['time'])
          .where('cliente_uid', isEqualTo: reservationData['cliente_uid'])
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error verificando reservas existentes: $e');
      return false;
    }
  }

  Future<String> saveReservationData(Map<String, dynamic> reservationData) async{
    try{
      bool exists = await reservationExists(reservationData);
      if(exists){
        throw Exception('Ya existe una reserva para esta fecha y hora');
      }

        DocumentReference docRef=
        await _db.collection('Reservas').add(reservationData);
        debugPrint('Reserva guardada con éxito: ${docRef.id}');
        return docRef.id;

    }catch (e){
      debugPrint('Error al guardar reserva: $e');
      throw Exception('No se pudo guardar la reserva: $e');
    }
  }

  Future<List<Map<String,dynamic>>> getReservationsByLocal(String restaurantUid) async{
    try{
      QuerySnapshot query = await _db.collection('Reservas')
          .where('empresa_uid', isEqualTo: restaurantUid)
          .get();

      return query.docs.map((doc){
        var data = doc.data() as Map<String,dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    }catch (e){
      debugPrint('Error obteniendo reservas del local: $e');
      return [];
    }
  }

  Future<String> getFirstRestaurantUidByUser(String userUid) async{
    try{
      return userUid;
    }catch (e){
      debugPrint('Error obteniendo restaurant_uid desde empresass: $e');
      return'';
    }
  }

  Future<List<Map<String,dynamic>>> getReservationsByEmpresa(String restUid) async{
    try{
      QuerySnapshot query = await _db
          .collection('Reservas')
          .where('empresa_uid',isEqualTo: restUid)
          .orderBy('date')
          .orderBy('created_at')
          .get();

      return query.docs.map((doc){
        var data = doc.data() as Map<String,dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    }catch (e){
      debugPrint('Error obteniendo reservas del local: $e');
      return[];
    }
  }
  Future<List<Map<String,dynamic>>> getReservationsByClient(String userUid) async{
    try{
      QuerySnapshot query = await _db
          .collection('Reservas')
          .where('cliente_uid',isEqualTo: userUid)
          .orderBy('date')
          .orderBy('created_at')
          .get();

      List<Map<String,dynamic>> reservas = [];
      for(var doc in query.docs){
        var data = doc.data() as Map<String,dynamic>;
        data['id'] = doc.id;

        String empresaUid = data['empresa_uid'] ?? '';
        String nameRest = await _restaurantsService.getRestaurantName(empresaUid);
        data['name_rest'] = nameRest;

        reservas.add(data);
      }
      return reservas;
    }catch (e){
      debugPrint('Error obteniendo reservas del local: $e');
      return[];
    }
  }


  
  Future<Map<String, dynamic>> getUserWithReservation(String userUid) async{
    try{
      String userName = await UserService().getUserName(userUid);
      List<Map<String, dynamic>> reservas = await getReservationsByClient(userUid);

      return{
        'name_user': userName,
        'reservas': reservas,
      };

    }catch (e){
      debugPrint('Error obteniendo usuario con reservas: $e');
      return{};
    }
  }

  Future<void> updateReservationStatus(String reservaId,String newStatus) async{
    await _db.collection('Reservas')
        .doc(reservaId)
        .update({'status': newStatus});
  }

  Future<void> addMessageToReservation(String reservationId, Map<String,dynamic> msg) async{
    final isFromCliente = msg['sender'] == 'Cliente';
    final actChat = isFromCliente
    ? 'hasNewMessageForEmpresa'  : 'hasNewMessageForCliente';

    return _db.collection('Reservas')
        .doc(reservationId)
        .update({
          'messages': FieldValue.arrayUnion([msg]),
          actChat: true,
        });
  }

  Future<void> deleteReservations() async{
    try{
      final now = DateTime.now();
      final querySnapshot = await _db
      .collection('Reservas')
      .get();

      for (var doc in querySnapshot.docs){
        final data = doc.data();
        if( data['date'] == null || data['status']
            || data['created_at'] == null) continue;

        final reservaDate = (data['date'] as Timestamp).toDate();
        final reservaCreate = (data['created_at'] as Timestamp).toDate();
        final currentStatus = data['status'] as String;
        final passDaysDate = now.difference(reservaDate).inDays;
        final passDaysCreate = now.difference(reservaCreate).inDays;

        final bool shouldDelete =
        (currentStatus == 'canceled' && passDaysCreate >= 4) ||
        (currentStatus == 'approved' && passDaysDate >= 1);

        if(shouldDelete){
          await doc.reference.delete();
          print('Reserva eliminada ${doc.id}');
        }
      }

    }catch (e){
      print('Error al eliminar las reservas: $e');
      rethrow;
    }
  }

  // formato de data
  Stream<QuerySnapshot> streamReservationsByDateAndLocal(String localUid,DateTime date){
    Timestamp startOfDay = Timestamp.fromDate(DateTime(date.year,date.month,date.day));
    Timestamp endOfDay = Timestamp.fromDate(DateTime(date.year,date.month,date.day, 23, 59, 59));
    return _db.collection('Reservas')
        .where('empresa_uid', isEqualTo: localUid)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots();
  }

  Stream<QuerySnapshot> streamReservationsByLocal(String localUid){
    return _db.collection('Reservas')
        .where('empresa_uid', isEqualTo: localUid)
        .orderBy('date')
        .orderBy('created_at')
        .snapshots();
  }

  Stream<QuerySnapshot> streamPaginatedReservationsByLocal(String localUid, DocumentSnapshot? startAfter) {
    Query query= _db.collection('Reservas')
        .where('empresa_uid', isEqualTo: localUid)
        .limit(10);

    if(startAfter != null){
      query= query.startAfterDocument(startAfter);
    }
    return query.snapshots();
  }

  // SOLS PRESENTACIÓ
  Future<void> deletePresentation() async{
    try{
      final now = DateTime.now();
      final querySnapshot = await _db
          .collection('Reservas')
          .get();

      for (var doc in querySnapshot.docs){
        final data = doc.data();
        if( data['created_at'] == null) continue;

        final creationDate = (data['created_at'] as Timestamp).toDate();
        final currentStatus = data['status'] as String;
        final passedMinutes = now.difference(creationDate).inMinutes;

        if(currentStatus == 'canceled' && passedMinutes >= 15){
          await doc.reference.delete();
          print('Reserva eliminada ${doc.id}');
        }
      }
    }catch (e){
      print('Error al eliminar las reservas: $e');
      rethrow;
    }
  }

}


