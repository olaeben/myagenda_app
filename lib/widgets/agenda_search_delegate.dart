import 'package:flutter/material.dart';
import '../models/agenda_model.dart';

class AgendaSearchDelegate extends SearchDelegate<AgendaModel> {
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
        // Clear the search filter and return an empty agenda
        onSearch('');
        close(context, AgendaModel(
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
            // Apply the search filter immediately instead of just updating the query
            onSearch(agenda.title);
            close(context, agenda);
          },
        );
      },
    );
  }
}
