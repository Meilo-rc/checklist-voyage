import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../import_data/import_view_model.dart';
import '../library/library_screen.dart';
import '../quick_lists/quick_lists_screen.dart';
import '../trips/trips_screen.dart';
import 'home_view_model.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final HomeViewModel _homeViewModel;
  late final ImportViewModel _importViewModel;

  @override
  void initState() {
    super.initState();
    _homeViewModel = HomeViewModel()..addListener(_refresh);
    _importViewModel = ImportViewModel(widget.dependencies.importWebBackup);
  }

  @override
  void dispose() {
    _homeViewModel
      ..removeListener(_refresh)
      ..dispose();
    _importViewModel.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      TripsScreen(
        watchTrips: widget.dependencies.watchTrips,
        useCases: widget.dependencies.trips,
      ),
      LibraryScreen(
        watchOwners: widget.dependencies.watchLibraryOwners,
        localData: widget.dependencies.localData,
        importViewModel: _importViewModel,
        useCases: widget.dependencies.library,
        contextUseCases: widget.dependencies.contexts,
        syncCoordinator: widget.dependencies.librarySync,
      ),
      QuickListsScreen(
        watchQuickLists: widget.dependencies.watchQuickLists,
        useCases: widget.dependencies.quickLists,
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _homeViewModel.selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _homeViewModel.selectedIndex,
        onDestinationSelected: _homeViewModel.select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage),
            label: 'Voyages',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Bibliothèque',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Listes rapides',
          ),
        ],
      ),
    );
  }
}
