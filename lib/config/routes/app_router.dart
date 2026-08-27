import 'package:flutter/material.dart';
import 'route_names.dart';
import 'user_routes.dart';
import 'admin_routes.dart';

/// Centralized Router setup for Skillora
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final userRouteMap = UserRoutes.routes;
    final adminRouteMap = AdminRoutes.routes;

    if (userRouteMap.containsKey(settings.name)) {
      return MaterialPageRoute(
        builder: userRouteMap[settings.name]!,
        settings: settings,
      );
    }

    if (adminRouteMap.containsKey(settings.name)) {
      return MaterialPageRoute(
        builder: adminRouteMap[settings.name]!,
        settings: settings,
      );
    }

    // Default fallback route
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
      settings: settings,
    );
  }

  static RouterConfig<Object> get router {
    return RouterConfig<Object>(
      routerDelegate: SkilloraRouterDelegate(),
    );
  }
}

class SkilloraRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _currentRoute = RouteNames.initial;

  void push(String routeName) {
    _currentRoute = routeName;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: _currentRoute,
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
