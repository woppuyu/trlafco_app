import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/app/router.dart';
import 'package:trlafco_app/app/theme.dart';
import 'package:trlafco_app/services/local_storage_service.dart';
import 'package:trlafco_app/state/app_state.dart';

class TrlafcoAppRoot extends StatefulWidget {
  const TrlafcoAppRoot({super.key});

  @override
  State<TrlafcoAppRoot> createState() => _TrlafcoAppRootState();
}

class _TrlafcoAppRootState extends State<TrlafcoAppRoot> {
  late final AppState _appState;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appState = AppState(storage: LocalStorageService());
    _router = createRouter(_appState);
    _appState.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appState,
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp.router(
            title: 'TRLAFCO Supply Mobile',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: appState.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
