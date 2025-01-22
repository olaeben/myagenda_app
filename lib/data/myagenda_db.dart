import 'package:hive_flutter/hive_flutter.dart';

class MyagendaDb {
  List myAgendaList = [];

  final _myAgenda = Hive.box('myAgenda');

  void createInitialAgendaDB() {
    myAgendaList = [
      {'title': "Your Default Agenda", 'status': false}
    ];
  }

  void updateAgendaDB() {
    _myAgenda.put('myAgenda', myAgendaList);
  }

  void loadAgendaDB() {
    myAgendaList = _myAgenda.get('myAgenda');
  }
}
