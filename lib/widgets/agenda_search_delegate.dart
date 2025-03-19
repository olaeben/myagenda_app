import 'package:flutter/material.dart';
import '../models/agenda_model.dart';

class AgendaSearchDelegate extends SearchDelegate<AgendaModel> {
  @override
  TextStyle? get searchFieldStyle => const TextStyle(color: Colors.grey);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  final List<AgendaModel> agendas;
  final Function(String) onSearch;

  AgendaSearchDelegate({
    required this.agendas,
    required this.onSearch,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        onSearch('');
        close(
            context,
            AgendaModel(
              title: '',
              description: '',
              deadline: DateTime.now(),
              category: '',
              status: false,
              selected: false,
            ));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }

    final suggestions = agendas.where((agenda) {
      return agenda.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (suggestions.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final agenda = suggestions[index];
        return ListTile(
          title: Text(agenda.title),
          onTap: () {
            onSearch(query);
            close(context, agenda);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }

    final suggestions = agendas.where((agenda) {
      return agenda.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (suggestions.isEmpty) {
      return Center(
        child: Text(
          'No suggestions found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final agenda = suggestions[index];
        return ListTile(
          title: Text(
            agenda.title,
            style: TextStyle(
              fontWeight: agenda.title.toLowerCase() == query.toLowerCase()
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          onTap: () {
            onSearch(agenda.title);
            close(context, agenda);
          },
        );
      },
    );
  }
}
