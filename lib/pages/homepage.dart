import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myagenda_app/widgets/custom_text.dart';
import '../models/agenda_model.dart';
import '../util/dialogue_box.dart';
import '../widgets/agenda_tile.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/search_bar.dart';
import '../widgets/stats_card.dart';
import '../widgets/filter_bar.dart';
import '../services/notification_service.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

final _categoriesBox = Hive.box('categories');

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  final _myAgenda = Hive.box('myAgenda');
  List<AgendaModel> _agendas = [];
  List<AgendaModel> _filteredAgendas = [];
  bool _isMultiSelectMode = false;
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  String? _selectedStatus;
  Set<String> _categories = {'Default'};
  Timer? _refreshTimer;

  Set<String> _allCategories = {'Default'};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAgendas();
    _notificationService.initNotification();

    _checkExpiredAgendas();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkExpiredAgendas();
    });
  }

  void _loadCategories() {
    final savedCategories =
        _categoriesBox.get('categories')?.cast<String>() ?? ['Default'];
    setState(() {
      _categories = Set<String>.from(savedCategories);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadAgendas() {
    final List<dynamic> agendaData = _myAgenda.get('myAgenda') ?? [];
    _agendas = agendaData.map((data) {
      final Map<String, dynamic> jsonData = Map<String, dynamic>.from(data);
      return AgendaModel.fromJson(jsonData);
    }).toList();
    _updateFilteredAgendas();
    _updateCategories();
  }

  void _updateCategories() {
    _categories = _allCategories;
    for (var agenda in _agendas) {
      if (agenda.category != null && agenda.category!.isNotEmpty) {
        _categories.add(agenda.category!);
      }
    }
  }

  Future<void> _saveCategories() async {
    await _categoriesBox.put('categories', _categories.toList());
  }

  void _updateFilteredAgendas() {
    _filteredAgendas = _agendas.where((agenda) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        if (!agenda.title.toLowerCase().contains(searchTerm) &&
            !(agenda.category?.toLowerCase().contains(searchTerm) ?? false)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && _selectedCategory != 'Default') {
        if (agenda.category != _selectedCategory) {
          return false;
        }
      }

      // Date range filter
      if (_selectedDateRange != null) {
        if (agenda.deadline.isBefore(_selectedDateRange!.start) ||
            agenda.deadline.isAfter(_selectedDateRange!.end)) {
          return false;
        }
      }

      // Status filter
      if (_selectedStatus != null) {
        final now = DateTime.now();
        final isExpired = !agenda.status && now.isAfter(agenda.deadline);

        switch (_selectedStatus) {
          case 'Expired':
            if (!isExpired) return false;
            break;
          case 'Completed':
            if (!agenda.status) return false;
            break;
          case 'Pending':
            if (agenda.status || isExpired) return false;
            break;
        }
      }

      return true;
    }).toList();

    setState(() {});
  }

  Map<String, double> _calculateStats() {
    if (_agendas.isEmpty) {
      return {
        'completed': 0,
        'pending': 0,
        'expired': 0,
      };
    }

    final now = DateTime.now();
    int completed = 0;
    int pending = 0;
    int expired = 0;

    for (var agenda in _agendas) {
      if (agenda.status) {
        completed++;
      } else if (now.isAfter(agenda.deadline)) {
        expired++;
      } else {
        pending++;
      }
    }

    final total = _agendas.length.toDouble();
    return {
      'completed': (completed / total) * 100,
      'pending': (pending / total) * 100,
      'expired': (expired / total) * 100,
    };
  }

  void _toggleMultiSelect(AgendaModel agenda) {
    setState(() {
      if (!_isMultiSelectMode) {
        _isMultiSelectMode = true;
        agenda.selected = true;
      } else {
        agenda.selected = !agenda.selected;
        if (_filteredAgendas.every((a) => !a.selected)) {
          _isMultiSelectMode = false;
        }
      }
    });
  }

  void _bulkComplete() {
    setState(() {
      for (var agenda in _filteredAgendas) {
        if (agenda.selected) {
          agenda.status = true;
          agenda.selected = false;
        }
      }
      _isMultiSelectMode = false;
      _saveAgendas();
    });
  }

  void _bulkDelete() async {
    try {
      final selectedAgendas =
          _filteredAgendas.where((a) => a.selected).toList();

      for (var agenda in selectedAgendas) {
        await _notificationService.cancelNotifications(agenda.title.hashCode);
      }

      // Update lists
      setState(() {
        _agendas.removeWhere((agenda) => selectedAgendas.contains(agenda));
        _filteredAgendas
            .removeWhere((agenda) => selectedAgendas.contains(agenda));
        _isMultiSelectMode = false;
      });

      // Save to Hive
      final agendaData = _agendas.map((a) => a.toJson()).toList();
      await _myAgenda.delete('myAgenda');
      await _myAgenda.put('myAgenda', agendaData);

      setState(() {
        _updateCategories();
        _updateFilteredAgendas();
      });
    } catch (e) {
      debugPrint('Error during bulk delete: $e');
    }
  }

  Future<void> _saveAgendasToHive() async {
    final List<Map<String, dynamic>> agendaData =
        _agendas.map((agenda) => agenda.toJson()).toList();

    await _myAgenda.clear();
    await _myAgenda.put('myAgenda', agendaData);

    // Update UI after save
    setState(() {
      _updateFilteredAgendas();
      _updateCategories();
    });
  }

  void _saveAgendas() async {
    await _saveAgendasToHive();
  }

  void _checkExpiredAgendas() {
    final now = DateTime.now();
    bool needsUpdate = false;

    for (var agenda in _agendas) {
      if (!agenda.status && now.isAfter(agenda.deadline)) {
        needsUpdate = true;
        _notificationService.cancelNotifications(agenda.title.hashCode);
      }
    }

    if (needsUpdate) {
      setState(() {
        _updateFilteredAgendas();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final selectedCount = _filteredAgendas.where((a) => a.selected).length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: _isMultiSelectMode
            ? IconButton(
                icon: Icon(
                  _filteredAgendas.every((a) => a.selected)
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                ),
                onPressed: () {
                  setState(() {
                    bool allSelected =
                        _filteredAgendas.every((a) => a.selected);
                    for (var agenda in _filteredAgendas) {
                      agenda.selected = !allSelected;
                    }
                    if (!allSelected && _filteredAgendas.isNotEmpty) {
                      _isMultiSelectMode = true;
                    } else if (allSelected) {
                      _isMultiSelectMode = false;
                    }
                  });
                },
              )
            : null,
        title: _isMultiSelectMode
            ? CustomText('$selectedCount selected')
            : CustomText('M Y  A G E N D A', fontSize: 20),
        actions: [
          if (_isMultiSelectMode)
            TextButton(
                onPressed: () {
                  setState(() {
                    for (var agenda in _filteredAgendas) {
                      agenda.selected = false;
                    }
                    _isMultiSelectMode = false;
                  });
                },
                child: CustomText('Cancel'))
          else
            IconButton(
              icon: Icon(Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode),
              onPressed: widget.onToggleTheme,
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              AgendaSearchBar(
                                controller: _searchController,
                                onChanged: (value) => _updateFilteredAgendas(),
                                onClear: () {
                                  _searchController.clear();
                                  _updateFilteredAgendas();
                                },
                              ),
                              SizedBox(height: 16),
                              StatsCard(
                                totalAgendas: _agendas.length,
                                completedPercentage: stats['completed']!,
                                pendingPercentage: stats['pending']!,
                                expiredPercentage: stats['expired']!,
                              ),
                              SizedBox(height: 16),
                              FilterBar(
                                categories: _categories.toList(),
                                selectedCategory: _selectedCategory,
                                selectedDateRange: _selectedDateRange,
                                selectedStatus: _selectedStatus,
                                onCategorySelected: (category) {
                                  setState(() {
                                    _selectedCategory = category;
                                    _updateFilteredAgendas();
                                  });
                                },
                                onDateRangeSelected: (dateRange) {
                                  setState(() {
                                    _selectedDateRange = dateRange;
                                    _updateFilteredAgendas();
                                  });
                                },
                                onStatusSelected: (status) {
                                  setState(() {
                                    _selectedStatus = status;
                                    _updateFilteredAgendas();
                                  });
                                },
                                onClearFilters: () {
                                  setState(() {
                                    _selectedCategory = null;
                                    _selectedDateRange = null;
                                    _selectedStatus = null;
                                    _updateFilteredAgendas();
                                  });
                                },
                                onCategoryDeleted: (deletedCategory) {
                                  setState(() {
                                    if (deletedCategory != 'Default') {
                                      _categories.remove(deletedCategory);
                                      for (var agenda in _agendas) {
                                        if (agenda.category ==
                                            deletedCategory) {
                                          agenda.category = 'Default';
                                        }
                                      }
                                      if (_selectedCategory ==
                                          deletedCategory) {
                                        _selectedCategory = 'Default';
                                      }
                                      _saveAgendas();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredAgendas.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: index == _filteredAgendas.length - 1
                                      ? 80
                                      : 0),
                              child: AgendaTile(
                                agenda: _filteredAgendas[index],
                                onStatusChanged: (value) {
                                  setState(() {
                                    _filteredAgendas[index].status =
                                        value ?? false;
                                    _saveAgendas();
                                  });
                                },
                                onLongPress: () =>
                                    _toggleMultiSelect(_filteredAgendas[index]),
                                onTap: _isMultiSelectMode
                                    ? () => _toggleMultiSelect(
                                        _filteredAgendas[index])
                                    : null,
                                showCheckbox: _isMultiSelectMode,
                                onEdit: () => _showAddAgendaDialog(
                                  context,
                                  agenda: _filteredAgendas[index],
                                ),
                                onDelete: () {
                                  final agenda = _filteredAgendas[index];
                                  _notificationService.cancelNotifications(
                                      agenda.title.hashCode);
                                  setState(() {
                                    _agendas.remove(agenda);
                                    _filteredAgendas.remove(agenda);
                                    _saveAgendasToHive();
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isMultiSelectMode)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: _bulkComplete,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: _bulkDelete,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _isMultiSelectMode ? 72 : 0),
        child: FloatingActionButton(
          onPressed: () => _showAddAgendaDialog(context),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddAgendaDialog(BuildContext context, {AgendaModel? agenda}) {
    final controller = TextEditingController(text: agenda?.title);
    String? initialCategory =
        agenda?.category ?? _selectedCategory ?? 'Default';

    showDialog(
      context: context,
      builder: (context) => DialogueBox(
        controller: controller,
        initialCategory: initialCategory,
        initialDeadline: agenda?.deadline,
        categories: _categories.toList(),
        onNewCategoryAdded: (newCategory) {
          setState(() {
            _categories.add(newCategory);
            _saveCategories();
          });
        },
        onCategoryDeleted: (deletedCategory) {
          setState(() {
            if (deletedCategory != 'Default') {
              _categories.remove(deletedCategory);
              for (var agenda in _agendas) {
                if (agenda.category == deletedCategory) {
                  agenda.category = 'Default';
                }
              }
              if (_selectedCategory == deletedCategory) {
                _selectedCategory = 'Default';
              }
              _saveCategories();
              _saveAgendas();
            }
          });
        },
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          if (agenda != null) {
            // Cancel existing notifications for this agenda
            _notificationService.cancelNotifications(agenda.title.hashCode);

            // Edit existing agenda
            agenda.title = value['text'];
            agenda.category = value['category'];
            agenda.deadline = value['deadline'];

            // Reset status if agenda was completed and new deadline is in future
            if (agenda.status && agenda.deadline.isAfter(DateTime.now())) {
              agenda.status = false;
            }

            // Schedule new notifications
            _notificationService.scheduleDeadlineNotifications(
              id: agenda.title.hashCode,
              title: agenda.title,
              deadline: agenda.deadline,
            );
          } else {
            // Add new agenda
            final newAgenda = AgendaModel(
              title: value['text'],
              category: value['category'],
              status: false,
              deadline: value['deadline'],
            );
            _agendas.insert(0, newAgenda);

            // Schedule notifications for new agenda
            _notificationService.scheduleDeadlineNotifications(
              id: newAgenda.title.hashCode,
              title: newAgenda.title,
              deadline: newAgenda.deadline,
            );
          }
          _saveAgendas();
        });
      }
    });
  }

  void _showCategoryFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        options: _categories.toList(),
        selectedOption: _selectedCategory,
        onOptionSelected: (category) {
          setState(() {
            _selectedCategory = category;
            _updateFilteredAgendas();
          });
        },
        onCategoryDeleted: (deletedCategory) {
          setState(() {
            if (deletedCategory != 'Default') {
              _categories.remove(deletedCategory);
              for (var agenda in _agendas) {
                if (agenda.category == deletedCategory) {
                  agenda.category = 'Default';
                }
              }
              if (_selectedCategory == deletedCategory) {
                _selectedCategory = 'Default';
              }
              _saveAgendas();
            }
          });
        },
      ),
    );
  }
}
