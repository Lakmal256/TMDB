import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../router.dart';
import '../../services/services.dart';
import '../ui.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? email;
  String? userName;
  User? user;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    refreshUser();
    super.initState();
  }

  Future<void> refreshUser() async {
    user = FirebaseAuth.instance.currentUser;
    setState(() {
      email = user?.email;
      userName = user?.displayName;
    });
  }

  handleSignOut(BuildContext context) async {
    bool? ok = await showConfirmationDialog(
      context,
      title: 'SignOut?',
      content: "Are you sure you want to sign out?",
    );

    if (ok != null && ok) {
      final watchlistService = WatchlistService();
      watchlistService.dispose(); // Dispose before signing out to prevent Firestore access

      await FirebaseAuth.instance.signOut(); // Sign out
      refreshUser(); // Refresh the user state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).go("/launcher"); // Navigate to the launcher after signing out
      });
      _scaffoldKey.currentState?.openEndDrawer(); // Close the drawer if it's open
    }
  }

  Future<void> goToWatchlist(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      GoRouter.of(context).push("/watchlist");
    } else {
      bool? ok =
          await showConfirmationDialog(context, title: "Sign In?", content: "Please sign in to show your watchlist.");

      if (ok != null && ok) {
        if (context.mounted) {
          context.push(AppRoutes.auth);
        }
      }
    }
  }

  Future<void> goToProfile(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      GoRouter.of(context).push("/profile");
    } else {
      bool? ok =
          await showConfirmationDialog(context, title: "Sign In?", content: "Please sign in to show your profile.");

      if (ok != null && ok) {
        if (context.mounted) {
          context.push(AppRoutes.auth);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: AspectRatio(
                  aspectRatio: 5,
                  child: Row(
                    children: [
                      if (email != null)
                        AspectRatio(
                          aspectRatio: 1,
                          child: DrawerAvatar(userName: email!),
                        )
                      else
                        Container(
                          color: Colors.blue,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(
                                  userName ?? email ?? 'TMDB',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(
                  children: [
                    Column(
                      children: [
                        DrawerListItem(
                          path: "/launcher",
                          icon: Icon(
                            Icons.home_outlined,
                            color: GoRouter.of(context).location == "/launcher"
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF717579),
                          ),
                          title: "Dashboard",
                          onSelect: () => GoRouter.of(context).go("/launcher"),
                        ),
                        const SizedBox(height: 5),
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        const SizedBox(height: 15),
                        DrawerListItem(
                            path: "/watchlist",
                            icon: Icon(
                              Icons.movie_filter_outlined,
                              color: GoRouter.of(context).location == "/watchlist"
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF717579),
                            ),
                            title: "Watchlist",
                            onSelect: () => goToWatchlist(context)),
                        const SizedBox(height: 5),
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        const SizedBox(height: 15),
                        DrawerListItem(
                            path: "/profile",
                            icon: Icon(
                              Icons.person_2_outlined,
                              color: GoRouter.of(context).location == "/profile"
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF717579),
                            ),
                            title: "Profile",
                            onSelect: () => goToProfile(context)),
                        const SizedBox(height: 5),
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ToggleSwitch(
                            minWidth: 70.0,
                            minHeight: 50.0,
                            initialLabelIndex: themeManager.currentThemeMode.index,
                            cornerRadius: 20.0,
                            activeFgColor: Colors.white,
                            inactiveBgColor: Colors.grey,
                            inactiveFgColor: Colors.white,
                            totalSwitches: 3, // System, Light, Dark
                            icons: const [
                              FontAwesomeIcons.a, // System icon
                              FontAwesomeIcons.solidLightbulb, // Light icon
                              FontAwesomeIcons.moon, // Dark icon
                            ],
                            iconSize: 30.0,
                            activeBgColors: Theme.of(context).brightness == Brightness.light
                                ? const [
                                    [Colors.yellow, Colors.orange], // System
                                    [Colors.yellow, Colors.orange], // Light
                                    [Colors.blueGrey, Colors.black], // Dark
                                  ]
                                : [
                                    [Colors.blueGrey, Colors.black], // System
                                    [Colors.yellow, Colors.orange], // Light
                                    [Colors.blueGrey, Colors.black] // Dark
                                  ],
                            animate: true,
                            curve: Curves.bounceInOut,
                            onToggle: (index) {
                              switch (index) {
                                case 0:
                                  themeManager.setTheme(AppThemeMode.system);
                                  break;
                                case 1:
                                  themeManager.setTheme(AppThemeMode.light);
                                  break;
                                case 2:
                                  themeManager.setTheme(AppThemeMode.dark);
                                  break;
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Builder(builder: (BuildContext newContext) {
                          return FilledButton(
                            onPressed: email != null
                                ? () => handleSignOut(context)
                                : () {
                                    GoRouter.of(newContext).push("/auth");
                                    Scaffold.of(newContext).openEndDrawer();
                                  },
                            style: ButtonStyle(
                              visualDensity: VisualDensity.standard,
                              minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
                              backgroundColor: MaterialStateProperty.all(const Color(0xFF717579)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.open_in_new,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                email != null ? const Text("Sign Out") : const Text("Log In"),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [Expanded(child: widget.child), BottomNavigation(refreshUser: refreshUser)],
        ),
      ),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  final VoidCallback refreshUser;
  const BottomNavigation({Key? key, required this.refreshUser}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              BottomNavigationItem(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                  widget.refreshUser();
                },
                icon: const Icon(Icons.chevron_right),
              ),
              const Spacer(),
              BottomNavigationItem(
                onTap: () => GoRouter.of(context).push("/search"),
                icon: const Icon(Icons.search_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  const BottomNavigationItem({
    Key? key,
    required this.icon,
    required this.onTap,
    this.disabled = false,
  }) : super(key: key);

  final Widget icon;
  final Function() onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // Circular shape
        side: const BorderSide(color: Colors.deepPurple, width: 2), // Border color and width
      ),
      elevation: 10,
      child: IconButton(
        icon: icon,
        color: Colors.deepPurple,
        onPressed: onTap,
        padding: const EdgeInsets.all(15),
      ),
    );
  }
}

class DrawerAvatar extends StatelessWidget {
  final String userName;
  const DrawerAvatar({required this.userName, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage("https://ui-avatars.com/api/?background=random&name=$userName"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class DrawerListItem extends StatelessWidget {
  const DrawerListItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onSelect,
    required this.path,
  }) : super(key: key);
  final String title;
  final Icon icon;
  final void Function() onSelect;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GoRouter.of(context).location == path ? Colors.deepPurple[400] : Theme.of(context).colorScheme.background,
      child: InkWell(
        onTap: () {
          onSelect();
          Scaffold.of(context).openEndDrawer();
        },
        splashColor: Colors.deepPurple[400],
        overlayColor: MaterialStateProperty.all(Colors.deepPurple[400]),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: GoRouter.of(context).location == path
                          ? const Color(0xFFFFFFFF)
                          : Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFF616161)
                              : const Color(0xFFBDBDBD),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
