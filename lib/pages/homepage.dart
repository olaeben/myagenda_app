import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_text.dart';
import '../models/agenda_model.dart';
import '../services/notification_service.dart';
import '../util/dialogue_box.dart';
import '../widgets/agenda_search_delegate.dart';
import '../widgets/agenda_tile.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/stats_card.dart';
import '../widgets/filter_bar.dart';
import 'dart:async';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import '../widgets/category_dialog.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

final _categoriesBox = Hive.box('categories');

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _myAgenda = Hive.box('myAgenda');
  List<AgendaModel> _agendas = [];
  List<AgendaModel> _filteredAgendas = [];
  bool _isMultiSelectMode = false;
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  String? _selectedStatus;
  Set<String> _categories = {'Default'};
  Timer? _refreshTimer;
  bool _isSpeedDialOpen = false;
  Set<String> _allCategories = {'Default'};
  String? _searchFilter;
  List<String> _selectedStatusFilters = [];
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAgendas();
    _notificationService = NotificationService();
    _notificationService.initNotification();
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkExpiredAgendas();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAgendas() async {
    final savedAgendas = _myAgenda.get('myAgenda');
    if (savedAgendas != null) {
      setState(() {
        try {
          _agendas = (savedAgendas as List)
              .map((agendaMap) {
                try {
                  return AgendaModel(
                    title: agendaMap['title'] ?? 'Untitled',
                    category: agendaMap['category'],
                    status: agendaMap['status'] ?? false,
                    deadline: agendaMap['deadline'] != null
                        ? DateTime.parse(agendaMap['deadline'])
                        : DateTime.now(),
                    description: agendaMap['description'],
                    createdAt: agendaMap['createdAt'] != null
                        ? DateTime.parse(agendaMap['createdAt'])
                        : DateTime.now(),
                    updatedAt: agendaMap['updatedAt'] != null
                        ? DateTime.parse(agendaMap['updatedAt'])
                        : DateTime.now(),
                    notificationFrequency:
                        agendaMap['notificationFrequency'] ?? 'Daily',
                  );
                } catch (e) {
                  debugPrint('Error parsing agenda: $e');
                  return null;
                }
              })
              .where((agenda) => agenda != null)
              .cast<AgendaModel>()
              .toList();
          _updateFilteredAgendas();
        } catch (e) {
          debugPrint('Error loading agendas: $e');
          _agendas = [];
        }
      });
    }
  }

  void _loadCategories() {
    final savedCategories =
        _categoriesBox.get('categories')?.cast<String>() ?? ['Default'];
    setState(() {
      _categories = Set<String>.from(savedCategories);
    });
  }

  Future<void> _saveCategories() async {
    await _categoriesBox.put('categories', _categories.toList());
  }

  void _updateCategories() {
    Set<String> agendaCategories = {'Default'};
    for (var agenda in _agendas) {
      if (agenda.category != null && agenda.category!.isNotEmpty) {
        agendaCategories.add(agenda.category!);
      }
    }

    setState(() {
      _categories.addAll(agendaCategories);
      _saveCategories();
    });
  }

  void _clearSearchFilter() {
    setState(() {
      _searchFilter = null;
      _updateFilteredAgendas();
    });
  }

  void _showSearch() async {
    final AgendaModel? selectedAgenda = await showSearch(
      context: context,
      delegate: AgendaSearchDelegate(
        agendas: _agendas,
        onSearch: (query) {
          setState(() {
            _searchFilter = query.isEmpty ? null : query;
            _updateFilteredAgendas();
          });
        },
      ),
    );

    if (selectedAgenda == null) {
      setState(() {
        _searchFilter = null;
        _searchController.clear();
        _updateFilteredAgendas();
      });
    } else if (selectedAgenda.title.isNotEmpty) {
      setState(() {
        _searchFilter = selectedAgenda.title;
        _updateFilteredAgendas();
      });
    }
  }

  void _updateFilteredAgendas() {
    if (!mounted) return;
    setState(() {
      _filteredAgendas = List.from(_agendas);
      final searchQuery =
          _searchFilter?.toLowerCase() ?? _searchController.text.toLowerCase();
      if (searchQuery.isNotEmpty) {
        _filteredAgendas = _filteredAgendas.where((agenda) {
          return agenda.title.toLowerCase().contains(searchQuery);
        }).toList();
      }

      if (_selectedCategory != null && _selectedCategory != 'All') {
        _filteredAgendas = _filteredAgendas
            .where((agenda) => agenda.category == _selectedCategory)
            .toList();
      }

      if (_selectedDateRange != null) {
        final startDate = DateTime(_selectedDateRange!.start.year,
            _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final endDate = DateTime(
            _selectedDateRange!.end.year,
            _selectedDateRange!.end.month,
            _selectedDateRange!.end.day,
            23,
            59,
            59);

        _filteredAgendas = _filteredAgendas.where((agenda) {
          return agenda.deadline
                  .isAfter(startDate.subtract(Duration(seconds: 1))) &&
              agenda.deadline.isBefore(endDate.add(Duration(seconds: 1)));
        }).toList();
      }

      if (_selectedStatus != null || _selectedStatusFilters.isNotEmpty) {
        final now = DateTime.now();
        _filteredAgendas = _filteredAgendas.where((agenda) {
          if (_selectedStatusFilters.isNotEmpty) {
            if (_selectedStatusFilters.contains('completed') && agenda.status) {
              return true;
            }
            if (_selectedStatusFilters.contains('pending') &&
                !agenda.status &&
                !now.isAfter(agenda.deadline)) {
              return true;
            }
            if (_selectedStatusFilters.contains('expired') &&
                !agenda.status &&
                now.isAfter(agenda.deadline)) {
              return true;
            }
            return false;
          } else {
            switch (_selectedStatus?.toLowerCase()) {
              case 'completed':
                return agenda.status;
              case 'pending':
                return !agenda.status && !now.isAfter(agenda.deadline);
              case 'expired':
                return !agenda.status && now.isAfter(agenda.deadline);
              default:
                return true;
            }
          }
        }).toList();
      }
      _filteredAgendas.sort((a, b) {
        DateTime aLatest =
            a.updatedAt.isAfter(a.createdAt) ? a.updatedAt : a.createdAt;
        DateTime bLatest =
            b.updatedAt.isAfter(b.createdAt) ? b.updatedAt : b.createdAt;
        return bLatest.compareTo(aLatest);
      });
    });
  }

  void _handleStatusFilterChange(List<String> selectedStatuses) {
    setState(() {
      _selectedStatusFilters = selectedStatuses;
      if (_selectedStatusFilters.isNotEmpty) {
        _selectedStatus = null;
      }
      _updateFilteredAgendas();
    });
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

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    String? _errorMessage;
    bool _showSuccess = false;

    setState(() {
      _isSpeedDialOpen = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isLightMode =
                Theme.of(context).brightness == Brightness.light;

            return Material(
              type: MaterialType.transparency,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: isLightMode ? Colors.white : Colors.grey[850],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _showSuccess
                          ? Column(
                              children: [
                                RiveAnimatedIcon(
                                  riveIcon: RiveIcon.check,
                                  width: 60,
                                  height: 60,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Category Added',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isLightMode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Category',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: isLightMode
                                        ? Colors.black45
                                        : Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 16),
                                TextField(
                                  controller: controller,
                                  maxLength: 14,
                                  decoration: InputDecoration(
                                    hintText: 'Enter category name',
                                    hintStyle: TextStyle(
                                      color: isLightMode
                                          ? Colors.black26
                                          : Colors.grey[100],
                                    ),
                                    errorText: _errorMessage,
                                    filled: true,
                                    fillColor: isLightMode
                                        ? Colors.grey[100]
                                        : Colors.grey[800],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _errorMessage = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                    ),
                    if (!_showSuccess)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              final categoryName = controller.text.trim();
                              if (categoryName.isEmpty) {
                                setState(() {
                                  _errorMessage =
                                      "Ooops... name cannot be empty";
                                });
                              } else if (_categories.any((category) =>
                                  category.toLowerCase() ==
                                  categoryName.toLowerCase())) {
                                setState(() {
                                  _errorMessage =
                                      "Ooops... category already exists";
                                });
                              } else {
                                setState(() {
                                  _showSuccess = true;
                                  _categories.add(categoryName);
                                  _saveCategories();
                                });

                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.pop(context);
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isLightMode ? Colors.black : Colors.white,
                              foregroundColor:
                                  isLightMode ? Colors.white : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Create',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                )),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _isSpeedDialOpen = false;
      });
    });
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
          agenda.updatedAt = DateTime.now();
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

      setState(() {
        _agendas.removeWhere((agenda) => selectedAgendas.contains(agenda));
        _filteredAgendas
            .removeWhere((agenda) => selectedAgendas.contains(agenda));
        _isMultiSelectMode = false;
        _updateCategories();
      });

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
    try {
      final List<Map<String, dynamic>> agendaData =
          _agendas.map((agenda) => agenda.toJson()).toList();

      await _myAgenda.clear();
      await _myAgenda.put('myAgenda', agendaData);

      if (mounted) {
        setState(() {
          _updateFilteredAgendas();
          _updateCategories();
        });
      }
    } catch (e) {
      debugPrint('Error saving agendas: $e');
      if (mounted) {
        setState(() {
          _updateFilteredAgendas();
        });
      }
    }
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
    final hasAgendas = _agendas.isNotEmpty;
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: () {
        if (_isSpeedDialOpen) {
          setState(() {
            _isSpeedDialOpen = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: _isSpeedDialOpen,
                  child: Column(
                    children: [
                      if (_isMultiSelectMode)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _filteredAgendas.every((a) => a.selected)
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                ),
                                onPressed: () {
                                  setState(() {
                                    bool allSelected = _filteredAgendas
                                        .every((a) => a.selected);
                                    for (var agenda in _filteredAgendas) {
                                      agenda.selected = !allSelected;
                                    }
                                    if (!allSelected &&
                                        _filteredAgendas.isNotEmpty) {
                                      _isMultiSelectMode = true;
                                    } else if (allSelected) {
                                      _isMultiSelectMode = false;
                                    }
                                  });
                                },
                              ),
                              CustomText('$selectedCount selected'),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    for (var agenda in _filteredAgendas) {
                                      agenda.selected = false;
                                    }
                                    _isMultiSelectMode = false;
                                  });
                                },
                                child: CustomText('Cancel'),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat('EEEE')
                                                    .format(DateTime.now()),
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w800,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('MMM dd, yyyy')
                                                    .format(DateTime.now()),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(0.1),
                                                  child: IconButton(
                                                      icon: Icon(
                                                        Icons.search,
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? Colors.white
                                                            : Colors.black,
                                                        size: 23,
                                                      ),
                                                      onPressed: () {
                                                        showSearch(
                                                          context: context,
                                                          delegate:
                                                              AgendaSearchDelegate(
                                                            agendas: _agendas,
                                                            onSearch: (query) {
                                                              setState(() {
                                                                _searchFilter =
                                                                    query.isNotEmpty
                                                                        ? query
                                                                        : null;
                                                                _updateFilteredAgendas();
                                                              });
                                                            },
                                                          ),
                                                        ).then(
                                                            (selectedAgenda) {
                                                          if (mounted) {
                                                            setState(() {
                                                              _searchController
                                                                  .clear();
                                                              if (_searchFilter
                                                                      ?.isEmpty ??
                                                                  false) {
                                                                _searchFilter =
                                                                    null;
                                                              }
                                                              if (selectedAgenda !=
                                                                      null &&
                                                                  selectedAgenda
                                                                      .title
                                                                      .isNotEmpty) {
                                                                _searchFilter =
                                                                    selectedAgenda
                                                                        .title;
                                                              }
                                                              _updateFilteredAgendas();
                                                            });
                                                          }
                                                        });
                                                      }),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(0.1),
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Icons.dark_mode
                                                          : Icons.light_mode,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.white
                                                          : Colors.black,
                                                      size: 23,
                                                    ),
                                                    onPressed:
                                                        widget.onToggleTheme,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    StatsCard(
                                      totalAgendas: _agendas.length,
                                      completedPercentage: stats['completed']!,
                                      pendingPercentage: stats['pending']!,
                                      expiredPercentage: stats['expired']!,
                                      selectedStatuses: _selectedStatusFilters,
                                      onStatusFilterChanged:
                                          _handleStatusFilterChange,
                                    ),
                                    SizedBox(height: 16),
                                    if (hasAgendas)
                                      FilterBar(
                                        categories: _categories.toList(),
                                        selectedCategory: _selectedCategory,
                                        selectedDateRange: _selectedDateRange,
                                        selectedStatus: _selectedStatus,
                                        searchFilter: _searchFilter,
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
                                            _selectedStatusFilters = [];
                                            _updateFilteredAgendas();
                                          });
                                        },
                                        onClearFilters: () {
                                          setState(() {
                                            _selectedCategory = null;
                                            _selectedDateRange = null;
                                            _selectedStatus = null;
                                            _selectedStatusFilters = [];
                                            _searchFilter = null;
                                            _searchController.clear();
                                            _updateFilteredAgendas();
                                          });
                                        },
                                        onCategoryDeleted: (deletedCategory) {
                                          setState(() {
                                            if (deletedCategory != 'Default') {
                                              _categories
                                                  .remove(deletedCategory);
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
                                        onCategoryEdited:
                                            (oldCategory, newCategory) {
                                          setState(() {
                                            if (oldCategory != 'Default') {
                                              _categories.remove(oldCategory);
                                              _categories.add(newCategory);

                                              for (var agenda in _agendas) {
                                                if (agenda.category ==
                                                    oldCategory) {
                                                  agenda.category = newCategory;
                                                }
                                              }
                                              if (_selectedCategory ==
                                                  oldCategory) {
                                                _selectedCategory = newCategory;
                                              }

                                              _saveAgendas();
                                              _updateFilteredAgendas();
                                            }
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                              if (_filteredAgendas.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        _searchFilter != null
                                            ? 'No results found for "${_searchFilter}"'
                                            : _searchController.text.isNotEmpty
                                                ? 'No results found for "${_searchController.text}"'
                                                : 'No agendas yet, click + to add',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (_searchFilter != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: TextButton(
                                            onPressed: _clearSearchFilter,
                                            child: Text('Clear Search Filter'),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _filteredAgendas.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: index ==
                                                  _filteredAgendas.length - 1
                                              ? 80
                                              : 0),
                                      child: AgendaTile(
                                        agenda: _filteredAgendas[index],
                                        onStatusChanged: (value) {
                                          Future.microtask(() {
                                            if (mounted) {
                                              setState(() {
                                                _filteredAgendas[index].status =
                                                    value ?? false;
                                                _filteredAgendas[index]
                                                    .updatedAt = DateTime.now();
                                                _saveAgendas();
                                                _calculateStats();
                                              });
                                            }
                                          });
                                        },
                                        onLongPress: () => _toggleMultiSelect(
                                            _filteredAgendas[index]),
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
                                          final agenda =
                                              _filteredAgendas[index];
                                          _notificationService
                                              .cancelNotifications(
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
                ),
                if (_isSpeedDialOpen)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSpeedDialOpen = false;
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSpeedDialOpen) ...[
                  FloatingActionButton.extended(
                    heroTag: 'addCategory',
                    onPressed: () => _showAddCategoryDialog(context),
                    label: Text('Add Category'),
                    icon: Icon(Icons.category),
                  ),
                  SizedBox(height: 8),
                  FloatingActionButton.extended(
                    heroTag: 'addAgenda',
                    onPressed: () => _showAddAgendaDialog(context),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.black,
                    label: Text('Add Agenda'),
                    icon: Icon(Icons.event),
                  ),
                  SizedBox(height: 8),
                ],
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isSpeedDialOpen = !_isSpeedDialOpen;
                    });
                  },
                  shape: CircleBorder(),
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                  child: Icon(_isSpeedDialOpen ? Icons.close : Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAgendaDialog(BuildContext context, {AgendaModel? agenda}) async {
    bool _showSuccess = false;
    Map<String, dynamic>? _formResult;
    bool _dialogActive = true;

    setState(() {
      _isSpeedDialOpen = false;
    });

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isLightMode =
                Theme.of(context).brightness == Brightness.light;

            if (_showSuccess) {
              return Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: isLightMode ? Colors.white : Colors.grey[850],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Success content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            RiveAnimatedIcon(
                              riveIcon: RiveIcon.check,
                              width: 60,
                              height: 60,
                              color: Colors.green,
                            ),
                            SizedBox(height: 16),
                            Text(
                              agenda != null
                                  ? 'Agenda Updated'
                                  : 'Agenda Added',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isLightMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return DialogueBox(
              controller: agenda != null
                  ? TextEditingController(text: agenda.title)
                  : null,
              initialDeadline: agenda?.deadline,
              initialCategory: agenda?.category,
              initialDescription: agenda?.description,
              initialNotificationFrequency: agenda?.notificationFrequency,
              categories: _categories.toList(),
              isEditing: agenda != null,
              onCategoryDeleted: (category) {
                if (mounted) {
                  setState(() {
                    _categories.remove(category);
                    _saveAgendas();
                  });
                }
              },
              onAddCategory: () async {
                final newCategory = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CategoryDialog(
                    categories: _categories.toList(),
                    selectedCategory: null,
                    onCategorySelected: (category) {},
                  ),
                );

                if (newCategory != null && newCategory is String) {
                  setState(() {
                    _categories.add(newCategory);
                    _saveCategories();
                  });
                }

                return false;
              },
              onSave: (result) {
                _formResult = result;
                Future.delayed(Duration(milliseconds: 700), () {
                  if (mounted) {
                    setState(() {
                      _showSuccess = true;
                    });
                  }
                });

                Future.delayed(Duration(seconds: 1), () {
                  Navigator.pop(context, result);
                });

                return false;
              },
            );
          },
        );
      },
    );

    if (!mounted) return;

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (agenda != null) {
          _notificationService.cancelNotifications(agenda.title.hashCode);
          agenda.title = result['title'];
          agenda.deadline = result['deadline'];
          agenda.category = result['category'];
          agenda.description = result['description'];
          agenda.notificationFrequency = result['notificationFrequency'];
          agenda.status = result['status'] ?? false;
          agenda.updatedAt = DateTime.now();
          if (!agenda.status) {
            _notificationService.scheduleDeadlineNotifications(
              id: agenda.title.hashCode,
              title: agenda.title,
              deadline: agenda.deadline,
            );
          }
        } else {
          final newAgenda = AgendaModel(
            status: false,
            title: result['title'],
            deadline: result['deadline'],
            category: result['category'],
            description: result['description'],
            notificationFrequency: result['notificationFrequency'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          _agendas.add(newAgenda);
          _notificationService.scheduleDeadlineNotifications(
            id: newAgenda.title.hashCode,
            title: newAgenda.title,
            deadline: newAgenda.deadline,
          );
        }
      });

      Future.microtask(() {
        if (mounted) {
          _saveAgendas();
          _updateFilteredAgendas();
        }
      });
    }
  }

  void _handleDialogResult(dynamic result, AgendaModel? agenda) {
    if (!mounted) return;

    if (result != null && result is Map<String, dynamic>) {
      Future.microtask(() {
        if (!mounted) return;

        setState(() {
          if (agenda != null) {
            _notificationService.cancelNotifications(agenda.title.hashCode);
            agenda.title = result['title'];
            agenda.deadline = result['deadline'];
            agenda.category = result['category'];
            agenda.description = result['description'];
            agenda.notificationFrequency = result['notificationFrequency'];
            agenda.status = result['status'] ?? agenda.status;
            agenda.updatedAt = DateTime.now();
            if (!agenda.status) {
              _notificationService.scheduleDeadlineNotifications(
                id: agenda.title.hashCode,
                title: agenda.title,
                deadline: agenda.deadline,
              );
            }
          } else {
            final newAgenda = AgendaModel(
              status: false,
              title: result['title'],
              deadline: result['deadline'],
              category: result['category'],
              description: result['description'],
            );
            _agendas.add(newAgenda);
            _notificationService.scheduleDeadlineNotifications(
              id: newAgenda.title.hashCode,
              title: newAgenda.title,
              deadline: newAgenda.deadline,
            );
          }
        });

        if (mounted) {
          _saveAgendas();
          _updateFilteredAgendas();
        }
      });
    }
  }

  void _showCategoryFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        onCategoryEdited: (oldCategory, newCategory) {
          setState(() {
            if (oldCategory != 'Default') {
              _categories.remove(oldCategory);
              _categories.add(newCategory);

              for (var agenda in _agendas) {
                if (agenda.category == oldCategory) {
                  agenda.category = newCategory;
                }
              }

              if (_selectedCategory == oldCategory) {
                _selectedCategory = newCategory;
              }

              _saveAgendas();
              _updateFilteredAgendas();
            }
          });
        },
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
