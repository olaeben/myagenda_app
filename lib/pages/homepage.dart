import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myagenda_app/data/myagenda_db.dart';
import 'package:myagenda_app/services/notification_service.dart';
import 'package:myagenda_app/util/dialogue_box.dart';
import 'package:myagenda_app/util/myagenda_tile.dart';
import 'package:myagenda_app/util/mybutton.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  final MyagendaDb db = MyagendaDb();
  final _myAgenda = Hive.box('myAgenda');
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    if (_myAgenda.isEmpty) {
      db.createInitialAgendaDB();
    } else {
      db.loadAgendaDB();
    }
    _notificationService.initNotification();
    _checkExpiredAgendas();

    // Add periodic check for expired agendas
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkExpiredAgendas();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _checkExpiredAgendas() {
    final now = DateTime.now();
    bool needsUpdate = false;

    for (int i = 0; i < db.myAgendaList.length; i++) {
      final agenda = db.myAgendaList[i];
      if (!agenda['status'] && agenda['deadline'] != null) {
        try {
          final deadline = DateTime.parse(agenda['deadline']);
          if (now.isAfter(deadline)) {
            db.myAgendaList[i]['status'] = true;
            needsUpdate = true;
            _notificationService.cancelNotifications(i);
          }
        } catch (e) {
          db.myAgendaList[i]['deadline'] =
              DateTime.now().add(const Duration(days: 7)).toIso8601String();
          needsUpdate = true;
        }
      }
    }

    if (needsUpdate) {
      setState(() {});
      db.updateAgendaDB();
    }
  }

  // Update the _scheduleNotification method
  void _scheduleNotification(int index) {
    final agenda = db.myAgendaList[index];
    if (agenda['deadline'] == null) {
      agenda['deadline'] =
          DateTime.now().add(const Duration(days: 7)).toIso8601String();
      db.updateAgendaDB();
    }

    final deadline = DateTime.parse(agenda['deadline']);
    final title = agenda['title'].toString().split(' ').take(2).join(' ');

    if (DateTime.now().isAfter(deadline)) {
      setState(() {
        db.myAgendaList[index]['status'] = true;
      });
      db.updateAgendaDB();
      return;
    }

    _notificationService.cancelNotifications(index);
    if (!agenda['status']) {
      _notificationService.scheduleDeadlineNotifications(
        id: index,
        title: title,
        deadline: deadline,
      );
    }
  }

  void createNewAgenda() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) {
        return DialogueBox(
          key: UniqueKey(),
          controller: _controller,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          final newAgenda = {
            'title': value['text'],
            'status': false,
            'deadline': (value['deadline'] ??
                    DateTime.now().add(const Duration(days: 7)))
                .toIso8601String(),
          };
          db.myAgendaList.insert(0, newAgenda);
        });
        db.updateAgendaDB();
        _scheduleNotification(0);
      }
    });
  }

  void editAgenda(int index) {
    final agenda = db.myAgendaList[index];
    _controller.text = agenda['title'];
    showDialog(
      context: context,
      builder: (context) {
        return DialogueBox(
          key: UniqueKey(),
          controller: _controller,
          initialDeadline: agenda['deadline'] != null
              ? DateTime.parse(agenda['deadline'])
              : DateTime.now().add(const Duration(days: 7)),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          db.myAgendaList[index] = {
            'title': value['text'],
            'status': false, // Reset status to unchecked
            'deadline': value['deadline'].toIso8601String(),
          };
        });
        db.updateAgendaDB();
        _scheduleNotification(index);
      }
    });
  }

  void confirmDelete(int index) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Are you sure you want to delete this Agenda?',
            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
          ),
          actions: [
            MyButton(
              text: 'Cancel',
              textColor: isLightMode ? Colors.black : Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
            MyButton(
              text: 'Yes',
              textColor: isLightMode ? Colors.black : Colors.white,
              onPressed: () {
                setState(() {
                  _notificationService.cancelNotifications(index);
                  db.myAgendaList.removeAt(index);
                });
                db.updateAgendaDB();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        centerTitle: false,
        systemOverlayStyle: isLightMode
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Row(
              children: [
                Icon(
                  isLightMode ? Icons.light_mode : Icons.dark_mode,
                  color: isLightMode ? Colors.black : Colors.white,
                ),
                const SizedBox(width: 8),
                CupertinoSwitch(
                  value: isLightMode,
                  activeTrackColor: Colors.grey,
                  onChanged: (value) => widget.onToggleTheme(),
                ),
              ],
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            'M Y  A G E N D A',
            style: TextStyle(
              color: isLightMode ? Colors.black : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                physics: const BouncingScrollPhysics(),
                itemCount: db.myAgendaList.length,
                itemBuilder: (context, index) {
                  final agenda = db.myAgendaList[index];
                  return MyAgendaTile(
                    myAgendaTitle: agenda['title'],
                    myAgendaStatus: agenda['status'],
                    deadline: agenda['deadline'] != null
                        ? DateTime.parse(agenda['deadline'])
                        : DateTime.now().add(const Duration(
                            days: 7)), // Default deadline: 7 days from now
                    myAgendaStatusChanged: (value) {
                      setState(() {
                        db.myAgendaList[index]['status'] = value;
                      });
                      db.updateAgendaDB();
                      if (value == true) {
                        _notificationService.cancelNotifications(index);
                      } else {
                        _scheduleNotification(index);
                      }
                    },
                    edit: (context) => editAgenda(index),
                    delete: (context) => confirmDelete(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewAgenda,
        backgroundColor: isLightMode ? Colors.black : Colors.white,
        child: Icon(
          Icons.add,
          color: isLightMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
