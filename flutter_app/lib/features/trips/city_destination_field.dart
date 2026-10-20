import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/weather/weather_models.dart';

/// One city picker for creation, editing and duplication. Typing always clears
/// the previous selection; a late response cannot replace a newer search.
class CityDestinationField extends StatefulWidget {
  const CityDestinationField({
    super.key,
    required this.controller,
    required this.search,
    required this.onSelected,
    this.fieldKey = const Key('trip-destination'),
    this.initialLocation,
  });

  final TextEditingController controller;
  final Future<List<WeatherLocation>> Function(String) search;
  final ValueChanged<WeatherLocation?> onSelected;
  final Key fieldKey;
  final WeatherLocation? initialLocation;

  @override
  State<CityDestinationField> createState() => _CityDestinationFieldState();
}

class _CityDestinationFieldState extends State<CityDestinationField> {
  Timer? _debounce;
  int _searchId = 0;
  bool _loading = false;
  List<WeatherLocation> _suggestions = const [];
  WeatherLocation? _selected;
  String? _message;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed(String text) {
    _debounce?.cancel();
    final id = ++_searchId;
    final query = text.trim();
    widget.onSelected(null);
    setState(() {
      _selected = null;
      _suggestions = const [];
      _message = null;
      _loading = query.length >= 2;
    });
    if (query.length < 2) return;
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final suggestions = await widget.search(query);
        if (!mounted || id != _searchId) return;
        setState(() {
          _loading = false;
          _suggestions = suggestions;
          _message = suggestions.isEmpty ? 'Aucune ville trouvée.' : null;
        });
      } on Object catch (error) {
        if (!mounted || id != _searchId) return;
        setState(() {
          _loading = false;
          _message = error is WeatherUnavailable
              ? error.message
              : 'Recherche de villes indisponible. Réessaie.';
        });
      }
    });
  }

  void _select(WeatherLocation location) {
    _debounce?.cancel();
    ++_searchId;
    widget.controller.text = location.name;
    widget.onSelected(location);
    setState(() {
      _selected = location;
      _suggestions = const [];
      _loading = false;
      _message = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        key: widget.fieldKey,
        controller: widget.controller,
        textCapitalization: TextCapitalization.words,
        onChanged: _changed,
        decoration: InputDecoration(
          labelText: 'Destination',
          hintText: 'Ex. Annecy',
          helperText: _selected?.detailLabel.isNotEmpty == true
              ? _selected!.detailLabel
              : 'Saisis une ville puis sélectionne une suggestion.',
          helperMaxLines: 2,
        ),
      ),
      if (_loading)
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Recherche de villes…'),
        ),
      if (_message != null)
        Padding(padding: const EdgeInsets.all(8), child: Text(_message!)),
      for (var i = 0; i < _suggestions.length; i++)
        ListTile(
          key: Key('city-suggestion-$i'),
          title: Text(_suggestions[i].name),
          subtitle: Text(_suggestions[i].detailLabel),
          onTap: () => _select(_suggestions[i]),
        ),
    ],
  );
}
