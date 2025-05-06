
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sit_and_eat/Model/reservas_model.dart';

class ReservasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _reservasCollection => _firestore.collection('Reservas');

  Future<void> crearReserva(ReservasModel reserva) async{
    try{
      await _reservasCollection.add(reserva.toMap());
    }catch (e){
      throw Exception('Error al crear la reserva: $e');
    }
  }

  Future<List<ReservasModel>> obtenerReservas(String empresaUid) async{
    try{
      QuerySnapshot querySnapshot = await _reservasCollection
          .where('restaurant_uid', isEqualTo: empresaUid)
          .get();

      return querySnapshot.docs
          .map((doc) => ReservasModel.fromFirestore(
        doc.data() as Map<String,dynamic>))
          .toList();

    }catch (e){
      throw Exception('Error al obtener las reservas: $e');
    }
  }


  Future<ReservasModel?> obtenerReservaById(String reservaId) async{
    try{
      DocumentSnapshot docSnapshot = await _reservasCollection.doc(reservaId).get();

      if(docSnapshot.exists){
        return ReservasModel.fromFirestore(
            docSnapshot.data() as Map<String,dynamic>);
      }else {
        return null;
      }

    }catch (e){
      throw Exception('Error al obtener la reserva: $e');
    }
  }

  Future<void> actualizarReserva(String reservaId, ReservasModel reserva) async{
    try{
      await _reservasCollection.doc(reservaId).delete();
    }catch (e){
      throw Exception('Error al eliminar la reserva: $e');
    }
  }

}

