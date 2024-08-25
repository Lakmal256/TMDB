import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:the_movie_data_base/ui/theme.dart';
import 'blocs/blocs_exports.dart';
import 'router.dart';
import 'services/services.dart';
import 'ui/ui.dart';
import 'locator.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, snapshot) {
        return MultiBlocProvider(
          providers: _provideBlocs,
          child: ChangeNotifierProvider(
            create: (_) => ThemeManager(),
            child: Consumer<ThemeManager>(builder: (context, themeManager, child) {
              return MaterialApp.router(
                builder: (context, child) => Stack(
                  fit: StackFit.expand,
                  children: [
                    if (child != null) child,

                    /// Overlay elements
                    if (locate<ProgressIndicatorController>().value) const ProgressIndicatorPopup(),
                    ConnectivityIndicator(),
                    Align(
                      alignment: Alignment.topLeft,
                      child: PopupContainer(
                        children: locate<PopupController>().value,
                      ),
                    )
                  ],
                ),
                debugShowCheckedModeBanner: false,
                themeMode: themeManager.themeMode,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                routerConfig: baseRouter,
              );
            }),
          ),
        );
      },
    );
  }

  final List<SingleChildWidget> _provideBlocs = [
    BlocProvider(create: (context) => HomeBloc()),
  ];

  Listenable get listenable => Listenable.merge([
        locate<PopupController>(),
        locate<ProgressIndicatorController>(),
      ]);
}
