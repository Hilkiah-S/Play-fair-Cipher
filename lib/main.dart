import 'package:flutter/material.dart';
import 'package:playfair/column.dart';
void main() => runApp(MaterialApp(home:PlayfairPage(),
theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
));
class PlayfairPage extends StatefulWidget {
  @override
  _PlayfairPageState createState() => _PlayfairPageState();
}

class _PlayfairPageState extends State<PlayfairPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _keyEditingController = TextEditingController();
  final TextEditingController _encryptedTextEditingController = TextEditingController();

  late List<List<String>> _matrix;
  final int _dimension = 5;

  String _encryptedText = "";
  String _decryptedText = "";

  @override
  void dispose() {
    _textEditingController.dispose();
    _keyEditingController.dispose();
    _encryptedTextEditingController.dispose();
    super.dispose();
  }

  void _generateMatrix(String key) {
    // Remove non-alphabetic characters
    key = key.replaceAll(RegExp(r'[^a-z]'), '');
    // Remove 'j' and replace with 'i'
    key = key.replaceAll('j', 'i');
    // Add remaining alphabetic characters to key
    String remainingChars = "abcdefghiklmnopqrstuvwxyz";
    for (int i = 0; i < remainingChars.length; i++) {
      if (!key.contains(remainingChars[i])) {
        key += remainingChars[i];
      }
    }
    // Fill matrix with key
    int index = 0;
    for (int row = 0; row < _dimension; row++) {
      for (int col = 0; col < _dimension; col++) {
        _matrix[row][col] = key[index];
        index++;
      }
    }
  }

  void _encryptText() {
    String text = _textEditingController.text.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    String key = _keyEditingController.text.toLowerCase();
    // Generate matrix
    _matrix = List.generate(_dimension, (_) => List<String>.filled(_dimension, ""));
    _generateMatrix(key);
    // Perform encryption
    String encryptedText = "";
    for (int i = 0; i < text.length; i += 2) {
      String pair;
      if (i + 1 < text.length && text[i] != text[i + 1]) {
        pair = text.substring(i, i + 2);
      } else {
        pair = text.substring(i, i + 1) + 'x';
      }
      String encryptedPair = _encryptPair(pair);
      encryptedText += encryptedPair;
    }
    setState(() {
      _encryptedText = encryptedText;
    });
  }

  String _encryptPair(String pair) {
    late int row1, col1, row2, col2;
    // Find positions of pair in matrix
    for (int row = 0; row < _dimension; row++) {
      for (int col = 0; col < _dimension; col++) {
        if (_matrix[row][col] == pair[0]) {
          row1 = row;
          col1 = col;
        } else if (_matrix[row][col] == pair[1]) {
          row2 = row;
          col2 = col;
        }
      }
    }
    String encryptedPair;
    // If pair is in same row, shift to the right
    if (row1 == row2) {
      int newCol1 = (col1 + 1) % _dimension;
      int newCol2 = (col2 + 1) % _dimension;
      encryptedPair = _matrix[row1][newCol1] + _matrix[row2][newCol2];
    }
    // If pair is in same column, shift downwards
        else if (col1 == col2) {
      int newRow1 = (row1 + 1) % _dimension;
      int newRow2 = (row2 + 1) % _dimension;
      encryptedPair = _matrix[newRow1][col1] + _matrix[newRow2][col2];
    }
    // Otherwise, create rectangle and take opposite corners
    else {
      encryptedPair = _matrix[row1][col2] + _matrix[row2][col1];
    }
    return encryptedPair;
  }

  void _decryptText() {
    String text = _encryptedText.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    String key = _keyEditingController.text.toLowerCase();
    // Generate matrix
    _matrix = List.generate(_dimension, (_) => List<String>.filled(_dimension, ""));
    _generateMatrix(key);
    // Perform decryption
    String decryptedText = "";
    for (int i = 0; i < text.length; i += 2) {
      String pair = text.substring(i, i + 2);
      String decryptedPair = _decryptPair(pair);
      decryptedText += decryptedPair;
    }
    setState(() {
      _decryptedText = decryptedText;
    });
  }

  String _decryptPair(String pair) {
    late int row1, col1, row2, col2;
    // Find positions of pair in matrix
    for (int row = 0; row < _dimension; row++) {
      for (int col = 0; col < _dimension; col++) {
        if (_matrix[row][col] == pair[0]) {
          row1 = row;
          col1 = col;
        } else if (_matrix[row][col] == pair[1]) {
          row2 = row;
          col2 = col;
        }
      }
    }
    String decryptedPair;
    // If pair is in same row, shift to the left
    if (row1 == row2) {
      int newCol1 = (col1 - 1 + _dimension) % _dimension;
      int newCol2 = (col2 - 1 + _dimension) % _dimension;
      decryptedPair = _matrix[row1][newCol1] + _matrix[row2][newCol2];
    }
    // If pair is in same column, shift upwards
    else if (col1 == col2) {
      int newRow1 = (row1 - 1 + _dimension) % _dimension;
      int newRow2 = (row2 - 1 + _dimension) % _dimension;
      decryptedPair = _matrix[newRow1][col1] + _matrix[newRow2][col2];
    }
    // Otherwise, create rectangle and take opposite corners
    else {
      decryptedPair = _matrix[row1][col2] + _matrix[row2][col1];
    }
    return decryptedPair;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playfair",style: TextStyle(color: Colors.white,fontSize: 15),),
        actions: <Widget>[
        TextButton(
          child: Text("Column-wise",style: TextStyle(color: Colors.white,fontSize: 15)),
          onPressed: () {
           Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayfairColumnPage()),
              );
          },
        )
      ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  labelText: "Enter text to encrypt",
                ),
              ),
              TextFormField(
                controller: _keyEditingController,
                decoration: InputDecoration(
                  labelText: "Enter encryption key",
                ),
              ),
              SizedBox(height: 16.0),
                         ElevatedButton(
                onPressed: _encryptText,
                child: Text("Encrypt"),
              ),
              SizedBox(height: 16.0),
              Text("Encrypted text:"),
              Text(
                _encryptedText.isNotEmpty ? _encryptedText : "",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32.0),
              TextFormField(
                controller: _encryptedTextEditingController,
                decoration: InputDecoration(
                  labelText: "Enter text to decrypt",
                ),
              ),

              
              TextFormField(
                controller: _keyEditingController,
                decoration: InputDecoration(
                  labelText: "Enter decryption key",
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _decryptText,
                child: Text("Decrypt"),
              ),
              SizedBox(height: 16.0),
              Text("Decrypted text:"),
              Text(
                _decryptedText.isNotEmpty ? _decryptedText : "",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


