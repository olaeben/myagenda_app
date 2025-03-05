import 'package:flutter/material.dart';
import '../models/agenda_model.dart';

class AgendaSearchDelegate extends SearchDelegate<String> {
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
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container(); // Results will be shown in the main list
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return Container();

    final suggestions = agendas.where((agenda) {
      return agenda.title.toLowerCase().contains(query.toLowerCase()) ||
          (agenda.category?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final agenda = suggestions[index];
        return ListTile(
          title: Text(agenda.title),
          subtitle: Text(agenda.category ?? 'Default'),
          onTap: () {
            query = agenda.title;
            onSearch(query);
            close(context, query);
          },
        );
      },
    );
  }
}