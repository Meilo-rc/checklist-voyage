import 'package:flutter/material.dart';

import '../../domain/models/destination_summaries.dart';
import '../../domain/usecases/watch_destinations.dart';
import '../shared/destination_scaffold.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key, required this.watchTrips});

  final WatchTrips watchTrips;

  @override
  Widget build(BuildContext context) {
    return DestinationScaffold(
      title: 'Voyages',
      child: StreamBuilder<List<TripSummary>>(
        stream: watchTrips(),
        builder: (context, snapshot) {
          final trips = snapshot.data ?? const [];
          if (trips.isEmpty) {
            return const EmptyDestination(
              icon: Icons.luggage_outlined,
              title: 'Aucun voyage local',
              message:
                  'Les voyages importés apparaîtront ici, même hors connexion.',
            );
          }
          return Column(
            children: trips
                .map(
                  (trip) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.luggage_outlined),
                      title: Text(trip.name),
                      subtitle: Text(trip.shared ? 'Partagé' : 'Local'),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}
