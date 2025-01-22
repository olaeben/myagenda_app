import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myagenda_app/data/myagenda_db.dart';
import 'package:myagenda_app/util/dialogue_box.dart';
import 'package:myagenda_app/util/myagenda_tile.dart';
import 'package:myagenda_app/util/mybutton.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();

  MyagendaDb db = MyagendaDb();
  final _myAgenda = Hive.box('myAgenda');

  @override
  void initState() {
    super.initState();
    if (_myAgenda.isEmpty) {
      db.createInitialAgendaDB();
    } else {
      db.loadAgendaDB();
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
          db.myAgendaList.insert(0, {'title': value, 'status': false});
        });
        db.updateAgendaDB();
      }
    });
  }

  void editAgenda(int index) {
    _controller.text = db.myAgendaList[index]['title'];
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
          db.myAgendaList[index] = {
            'title': value,
            'status': db.myAgendaList[index]['status']
          };
        });
        db.updateAgendaDB();
      }
    });
  }

  void confirmDelete(int index) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to delete this Agenda?',
            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
          ),
          actions: [
            MyButton(
              text: 'Cancel',
              textColor: isLightMode ? Colors.black : Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            MyButton(
              text: 'Yes',
              textColor: isLightMode ? Colors.black : Colors.white,
              onPressed: () {
                setState(() {
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
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
                  onChanged: (value) {
                    widget.onToggleTheme();
                  },
                ),
              ],
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            'M Y  A G E N D A',
            style: TextStyle(
              color: isLightMode ? Colors.black : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          var agenda = db.myAgendaList[index];
          return MyAgendaTile(
            myAgendaTitle: agenda['title'],
            myAgendaStatus: agenda['status'],
            myAgendaStatusChanged: (bool? value) {
              setState(() {
                db.myAgendaList[index] = {
                  'title': agenda['title'],
                  'status': value!
                };
              });
              db.updateAgendaDB();
            },
            edit: (BuildContext context) {
              editAgenda(index);
            },
            delete: (BuildContext context) {
              confirmDelete(index);
            },
          );
        },
        itemCount: db.myAgendaList.length,
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
