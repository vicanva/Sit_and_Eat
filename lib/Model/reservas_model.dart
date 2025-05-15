
import 'package:cloud_firestore/cloud_firestore.dart';

enum EstateReserve{
  processing,
  canceled,
  approved,
  pending,
}
extension EstateReserveExtension on EstateReserve{
  String get displayName{
    switch(this){
      case EstateReserve.processing:
        return "Procesando";
      case EstateReserve.canceled:
        return "Cancelado";
      case EstateReserve.approved:
        return "Aprobado";
      case EstateReserve.pending:
        return "Pendiente";
    }
  }
}

class ReservasModel{
  final DateTime createdAt;
  final DateTime date;
  final int people;
  final String time;
  final String clienteUid;
  final String empresaUid;
  final EstateReserve status;
  final List<Map<String,dynamic>> messages;
  final bool hasNewMessageForCliente;
  final bool hasNewMessageForEmpresa;

  static const List<String> times = [
    '10:00', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '20:00', '20:30', '21:00', '21:30', '22:00', '22:30',
  ];

  ReservasModel({
    required this.createdAt,
    required this.date,
    required this.people,
    required this.time,
    required this.clienteUid,
    required this.empresaUid,
    required this.status,
    required this.messages,
    this.hasNewMessageForCliente = false,
    this.hasNewMessageForEmpresa = false,
  }){
    if(!times.contains(time)){
      throw ArgumentError('El tiempo $time no es válido.'
      'Los horarios son: $times');
    }
    if(people <= 0){
      throw ArgumentError('El número de personas debe ser mayor que 0');
    }
  }

  factory ReservasModel.fromFirestore(Map<String,dynamic> data){
    try {
      return ReservasModel(
        createdAt: (data['created_at'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        people: data['people'] as int? ?? 1,
        time: data['time'] as String? ?? '13:00',
        clienteUid: data['cliente_uid'] as String? ?? '',
        empresaUid: data['empresa_uid'] as String? ?? '',
        status: EstateReserve.values.firstWhere(
            (e) => e.name == data['status'],
          orElse: () => EstateReserve.processing,
        ),
        messages: (data['messages'] as List<dynamic>? ?? [])
          .map((e) => Map<String,dynamic>.from(e as Map))
          .toList(),
        hasNewMessageForCliente: data['hasNewMessageForCliente'] as bool? ?? false,
          hasNewMessageForEmpresa: data['hasNewMessageForEmpresa'] as bool? ?? false,
      );
    } catch (e) {
      throw ArgumentError('Error al convertir ReservasModel: $e');
    }
  }

  Map<String,dynamic> toMap(){
    return{
      'date': Timestamp.fromDate(date),
      'people': people,
      'time': time,
      'cliente_uid': clienteUid,
      'empresa_uid': empresaUid,
      'created_at': Timestamp.fromDate(createdAt),
      'status': status.name,
      'messages': messages,
      'hasNewMessageForCliente': hasNewMessageForCliente,
      'hasNewMessageForEmpresa': hasNewMessageForEmpresa,
    };
  }

  ReservasModel copyWith({
    DateTime? createdAt,
    DateTime? date,
    int? people,
    String? time,
    String? clienteUid,
    String? empresaUid,
    EstateReserve? status,
    List<Map<String,dynamic>>? messages,
    bool? hasNewMessageForCliente,
    bool? hasNewMessageForEmpresa,
}){
    return ReservasModel(
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      people: people ?? this.people,
      time: time ?? this.time,
      clienteUid: clienteUid ?? this.clienteUid,
      empresaUid: empresaUid ?? this.empresaUid,
      status: status ?? this.status,
      messages: messages ?? this.messages,
    );
  }

  @override
  String toString(){
    return 'ReservasModel( createdAt: $createdAt, date: $date, people: $people,'
        'time: $time, clienteUid: $clienteUid, empresaUid: $empresaUid, status: ${status.displayName})';
  }
}

