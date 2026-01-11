import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MyAppState())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: App(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  bool isFavorite() {
    return favorites.contains(current);
  }

  void toggleFavorite() {
    if (isFavorite()) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class NavigationState extends ChangeNotifier {
  var destinationIndex = 0;

  void goToDestination(int index) {
    destinationIndex = index;
    notifyListeners();
  }
}

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var destinationIndex = 0;

  void handleDestinationSelected(int index) =>
      setState(() {
        destinationIndex = index;
      });

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (destinationIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw new UnimplementedError("no widget for $destinationIndex");
    }

    // The container for the current page, with its background color and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Column(
            children: [
              Expanded(child: mainArea),
              SafeArea(child:
              BottomNavigationBar(items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: "Favorites"),
              ],
              onTap: handleDestinationSelected,
              currentIndex: destinationIndex))
            ],
          );
        } else {
          return Row(
            children: [
              SafeArea(child: NavigationRail(destinations: [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text("Home"),),
                NavigationRailDestination(icon: Icon(Icons.favorite), label: Text("Favorites"),),
              ], selectedIndex: destinationIndex, onDestinationSelected: handleDestinationSelected,)),
              Expanded(child: mainArea)
            ],
          );
        }
      }),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: .center,
            spacing: 16,
            children: [
              TextButton(
                onPressed: appState.toggleFavorite,
                child: Row(
                  spacing: 8,
                  children: [
                    if (appState.isFavorite()) ...[
                      Icon(Icons.favorite_border),
                      Text("Unlike"),
                    ] else
                      ...[
                        Icon(Icons.favorite),
                        Text("Like"),
                      ],
                  ],
                ),
              ),
              ElevatedButton(onPressed: appState.getNext, child: Text('Next')),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var title =
        "You have ${appState.favorites.length} favorite${appState.favorites
        .length != 1 ? "s" : ""}:";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: .start,
          spacing: 16,
          children: [
            Text(title, textAlign: .left),
            for (var favorite in appState.favorites)
              Row(
                spacing: 20,
                children: [
                  Icon(Icons.favorite),
                  Text(favorite.asLowerCase, textAlign: .left),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontStyle: FontStyle.italic,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
