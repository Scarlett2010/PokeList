import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tus canciones y pokemons favoritos',
      theme: ThemeData(
        primaryColor: Colors.yellow,
        scaffoldBackgroundColor: Colors.yellow[50],
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    Color appBarColor;
    Color navigationRailColor;

    switch (selectedIndex) {
      case 0:
        page = const PokemonSearchPage();
        appBarColor = Colors.blue[300]!;
        navigationRailColor = Colors.yellow[100]!;
        break;
      case 1:
        page = const LyricsSearchPage();
        appBarColor = Colors.purple[700]!;
        navigationRailColor = Colors.white;
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus canciones y pokemons favoritos'),
        backgroundColor: appBarColor,
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: navigationRailColor,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.search,
                    color: Color.fromARGB(255, 94, 143, 233)),
                label: Text('Pokémon'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.music_note, color: Colors.white),
                label: Text('Letras'),
              ),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
          Expanded(child: page),
        ],
      ),
    );
  }
}

class PokemonSearchPage extends StatefulWidget {
  const PokemonSearchPage({super.key});

  @override
  _PokemonSearchPageState createState() => _PokemonSearchPageState();
}

class _PokemonSearchPageState extends State<PokemonSearchPage> {
  final TextEditingController _pokemonController = TextEditingController();
  Map<String, dynamic>? pokemonData;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchPokemon(String name) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
      );

      if (response.statusCode == 200) {
        setState(() {
          pokemonData = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = 'Pokémon no encontrado.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al buscar el Pokémon.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _pokemonController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Pokémon',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Botón azul
            ),
            onPressed: () {
              final name = _pokemonController.text.toLowerCase();
              fetchPokemon(name); // Se elimina la validación aquí
            },
            child: const Text('Buscar Pokémon'),
          ),
          const SizedBox(height: 20),
          if (isLoading) const CircularProgressIndicator(),
          if (errorMessage.isNotEmpty)
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
          if (pokemonData != null)
            Expanded(
              // Use Expanded here for the container
              child: SingleChildScrollView(
                // Wrap the column in a scrollable view
                child: Center(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow[800]!, width: 4),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.yellow[100],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pokemonData!['name'].toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Image.network(
                            pokemonData!['sprites']['front_default'],
                            width: 250,
                            height: 250,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(Icons.catching_pokemon, color: Colors.red),
                            SizedBox(width: 5),
                            Text('Peso:'),
                          ],
                        ),
                        Text('${pokemonData!['weight']}'),
                        Row(
                          children: const [
                            Icon(Icons.catching_pokemon, color: Colors.red),
                            SizedBox(width: 5),
                            Text('Altura:'),
                          ],
                        ),
                        Text('${pokemonData!['height']}'),
                        const SizedBox(height: 10),
                        // Habilidades sin el ícono
                        const Text(
                          'Habilidades:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...pokemonData!['abilities'].map<Widget>((ability) {
                          return Text(ability['ability']['name']);
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LyricsSearchPage extends StatefulWidget {
  const LyricsSearchPage({super.key});

  @override
  _LyricsSearchPageState createState() => _LyricsSearchPageState();
}

class _LyricsSearchPageState extends State<LyricsSearchPage> {
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _songController = TextEditingController();
  String lyrics = '';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchLyrics(String artist, String song) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.lyrics.ovh/v1/$artist/$song'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          lyrics = data['lyrics'];
        });
      } else {
        setState(() {
          errorMessage = 'No se encontraron letras para esta canción.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al buscar la letra.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE6E6FA),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _artistController,
              decoration: const InputDecoration(
                labelText: 'Artista',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _songController,
              decoration: const InputDecoration(
                labelText: 'Canción',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final artist = _artistController.text.trim();
                final song = _songController.text.trim();
                if (artist.isNotEmpty && song.isNotEmpty) {
                  fetchLyrics(artist, song);
                }
              },
              child: const Text('Buscar Letra'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            if (lyrics.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFFE6E6FA),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_songController.text}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lyrics,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
