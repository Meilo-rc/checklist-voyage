import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../../core/sharing/share_invitation.dart';
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

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  late final HomeViewModel _homeViewModel;
  late final ImportViewModel _importViewModel;
  StreamSubscription<ShareJoinRequest>? _joinLinkSubscription;
  ShareJoinRequest? _pendingJoinRequest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    widget.dependencies.setDocumentSyncForeground(
      lifecycle == null || lifecycle == AppLifecycleState.resumed,
    );
    _homeViewModel = HomeViewModel()..addListener(_refresh);
    _importViewModel = ImportViewModel(widget.dependencies.importWebBackup);
    _joinLinkSubscription = widget
        .dependencies
        .shareInvitations
        .incomingRequests
        .listen(_routeJoinRequest);
    unawaited(_loadInitialJoinRequest());
  }

  Future<void> _loadInitialJoinRequest() async {
    try {
      final request = await widget.dependencies.shareInvitations
          .takeInitialRequest();
      if (request != null) _routeJoinRequest(request);
    } on Object {
      // Un lien Android invalide ou indisponible ne doit pas bloquer l'app.
    }
  }

  void _routeJoinRequest(ShareJoinRequest request) {
    if (!mounted) return;
    _homeViewModel.select(request.type == ShareableDocumentType.trip ? 0 : 2);
    setState(() => _pendingJoinRequest = request);
  }

  void _clearJoinRequest(ShareJoinRequest request) {
    if (identical(_pendingJoinRequest, request)) {
      setState(() => _pendingJoinRequest = null);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.dependencies.setDocumentSyncForeground(false);
    unawaited(_joinLinkSubscription?.cancel());
    _homeViewModel
      ..removeListener(_refresh)
      ..dispose();
    _importViewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.dependencies.setDocumentSyncForeground(
      state == AppLifecycleState.resumed,
    );
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      TripsScreen(
        watchTrips: widget.dependencies.watchTrips,
        useCases: widget.dependencies.trips,
        sharedDocuments: widget.dependencies.sharedDocuments,
        shareInvitations: widget.dependencies.shareInvitations,
        pendingJoinRequest:
            _pendingJoinRequest?.type == ShareableDocumentType.trip
            ? _pendingJoinRequest
            : null,
        onJoinRequestHandled: _clearJoinRequest,
        weather: widget.dependencies.weather,
      ),
      LibraryScreen(
        watchOwners: widget.dependencies.watchLibraryOwners,
        localData: widget.dependencies.localData,
        importViewModel: _importViewModel,
        useCases: widget.dependencies.library,
        contextUseCases: widget.dependencies.contexts,
        syncCoordinator: widget.dependencies.librarySync,
        safetyBackup: widget.dependencies.safetyBackup,
        safetyBackupFiles: widget.dependencies.safetyBackupFiles,
      ),
      QuickListsScreen(
        watchQuickLists: widget.dependencies.watchQuickLists,
        useCases: widget.dependencies.quickLists,
        sharedDocuments: widget.dependencies.sharedDocuments,
        shareInvitations: widget.dependencies.shareInvitations,
        pendingJoinRequest:
            _pendingJoinRequest?.type == ShareableDocumentType.quickList
            ? _pendingJoinRequest
            : null,
        onJoinRequestHandled: _clearJoinRequest,
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
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
