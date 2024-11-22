import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/channel_provider.dart';
import 'channel_list_tile.dart';

class ChannelSearchDelegate extends SearchDelegate<String> {

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Close the search
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {

    final channels = context.select((ChannelProvider value) => value.allChannels);
    final results = channels.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();

    return GridView.builder(
      itemBuilder: (context, index) {
        final item = results[index];
        return ChannelListTile(item: item);
      },
      itemCount: results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          crossAxisCount: 4, childAspectRatio: 1.2),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final channels = context.select((ChannelProvider value) => value.allChannels);
    final suggestions = channels.where((item) => item.name.toLowerCase().startsWith(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].name),
          onTap: () {
            query = suggestions[index].name; // Update the query
            showResults(context); // Show search results
          },
        );
      },
    );
  }
}