import 'package:hive_flutter/hive_flutter.dart';

class MyagendaDb {
  List myAgendaList = [];
  final _myAgenda = Hive.box('myAgenda');

  void createInitialAgendaDB() {
    myAgendaList = [
      {
        'title': "Your Default Agenda",
        'status': false,
        'deadline': DateTime.now().add(Duration(days: 7)).toIso8601String(),
      }
    ];
  }

  void updateAgendaDB() {
    _myAgenda.put('myAgenda', myAgendaList);
  }

  void loadAgendaDB() {
    myAgendaList = _myAgenda.get('myAgenda');
  }

  DateTime? getDeadline(int index) {
    final deadline = myAgendaList[index]['deadline'];
    return deadline != null ? DateTime.parse(deadline) : null;
  }
}
