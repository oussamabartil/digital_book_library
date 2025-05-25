import 'package:flutter/material.dart';
import 'package:flutter_digital_book_library/models/book.dart';
import 'package:flutter_digital_book_library/services/api_service.dart';
import 'package:flutter_digital_book_library/services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchPage(),
      routes: {
        '/favorites': (context) => FavoritesPage(),
      },
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _books = [];
  bool _isLoading = false;

  Future<void> _searchBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await ApiService.searchBooks(_searchController.text);
      setState(() {
        _books = books;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Search'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search books',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchBooks,
                ),
              ],
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      return _buildBookCard(book);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return FutureBuilder<bool>(
      future: DatabaseService.instance.isFavorite(book.id),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return Card(
          child: Column(
            children: [
              Expanded(
                child: book.imageUrl != null
                    ? Image.network(
                        book.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.book, size: 50),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (book.author != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    book.author!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () async {
                  if (isFavorite) {
                    await DatabaseService.instance.deleteItem(book.id);
                  } else {
                    await DatabaseService.instance.insertItem(book);
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Book>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = DatabaseService.instance.getItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Books'),
      ),
      body: FutureBuilder<List<Book>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorite books yet'));
          } else {
            final books = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return _buildFavoriteBookCard(book);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildFavoriteBookCard(Book book) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: book.imageUrl != null
                ? Image.network(
                    book.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.book, size: 50),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (book.author != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                book.author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await DatabaseService.instance.deleteItem(book.id);
              _refreshFavorites();
            },
          ),
        ],
      ),
    );
  }
}