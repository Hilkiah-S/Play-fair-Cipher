import 'package:flutter/material.dart';

class PlayfairColumnPage extends StatefulWidget {
  const PlayfairColumnPage({Key? key}) : super(key: key);

  @override
  _PlayfairColumnPageState createState() => _PlayfairColumnPageState();
}

class _PlayfairColumnPageState extends State<PlayfairColumnPage> {
  final TextEditingController _keyEncryptEditingController = TextEditingController();
  final TextEditingController _textEncryptEditingController = TextEditingController();
  final TextEditingController _cipherTextEditingController = TextEditingController();
  final TextEditingController _keyDecryptEditingController = TextEditingController();
  final TextEditingController _textDecryptEditingController = TextEditingController();
  final TextEditingController _plainTextEditingController = TextEditingController();
   final _keyController = TextEditingController();
  final _originalController = TextEditingController();
  final _encryptedController = TextEditingController();
  final _decryptedController = TextEditingController();

  void _encrypt() {
    String plaintext = _textEncryptEditingController.text;
    String key = _keyEncryptEditingController.text.toUpperCase();


    // Remove whitespace and non-alphabetic characters from plaintext
    plaintext = plaintext.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    // Split plaintext into columns
    final List<String> columns = _splitIntoColumns(plaintext, key.length);

    // Rearrange columns based on key
    final List<String> reorderedColumns = _reorderColumns(columns, key);

    // Encrypt columns using Playfair cipher
    final String ciphertext = _encryptColumns(reorderedColumns);
print (ciphertext);
    // Display ciphertext
    setState(() {
      _cipherTextEditingController.text = ciphertext;
    });
  }

  void _decrypt() {
    String ciphertext =  _cipherTextEditingController.text;
    String key = _keyDecryptEditingController.text.toUpperCase();

    // Split ciphertext into columns
    final List<String> columns = _splitIntoColumns(ciphertext, key.length);

    // Rearrange columns based on key
    final List<String> reorderedColumns = _reorderColumns(columns, key);

    // Decrypt columns using Playfair cipher
    final String plaintext = _decryptColumns(reorderedColumns);
  print (plaintext);
    // Display plaintext
    setState(() {
      _plainTextEditingController.text = plaintext;
    });
  }

  List<String> _splitIntoColumns(String plaintext, int columnLength) {
    final List<String> columns = [];
    for (int i = 0; i < plaintext.length; i += columnLength) {
      int endIndex = i + columnLength;
      if (endIndex > plaintext.length) {
        endIndex = plaintext.length;
      }
      columns.add(plaintext.substring(i, endIndex));
    }
    return columns;
  }

  List<String> _reorderColumns(List<String> columns, String key) {
    final List<String> reorderedColumns = [];
    final List<String> orderedKeys = key.split('').toList()..sort();
    final List<int> columnIndices = [];
    for (String letter in orderedKeys) {
      columnIndices.add(key.indexOf(letter));
    }
    for (int index in columnIndices) {
      try {
  reorderedColumns.add(columns[index]);
} catch (e) {
  if (e is RangeError) {
    print ("Error");// Handle the error here, e.g. log an error message and return from the method
  } }
    }
    return reorderedColumns;
  }

  String _encryptColumns(List<String> columns) {
    // Initialize Playfair matrix with key
    final String key = _keyEncryptEditingController.text.toUpperCase();
    final List<String> matrix = _initializeMatrix(key);

    // Encrypt columns using Playfair cipher
    final List<String> encryptedColumns = [];
    for (String column in columns) {
      final String encryptedColumn = _encryptColumn(column, matrix);
      encryptedColumns.add(encryptedColumn);
    }

    // Combine encrypted columns into ciphertext
    final String ciphertext = encryptedColumns.join('');
    return ciphertext;
  }

  String _decryptColumns(List<String> columns) {
    // Initialize Playfair matrix with key
        final String key = _keyDecryptEditingController.text.toUpperCase();
    final List<String> matrix = _initializeMatrix(key);

    // Decrypt columns using Playfair cipher
    final List<String> decryptedColumns = [];
    for (String column in columns) {
      final String decryptedColumn = _decryptColumn(column, matrix);
      decryptedColumns.add(decryptedColumn);
    }

    // Combine decrypted columns into plaintext
    final String plaintext = decryptedColumns.join('');
    return plaintext;
  }

  List<String> _initializeMatrix(String key) {
    final List<String> alphabet = 'ABCDEFGHIKLMNOPQRSTUVWXYZ'.split('');
    final List<String> keyLetters = key.split('');
    final List<String> matrix = [];
    for (String letter in keyLetters) {
      if (!matrix.contains(letter)) {
        matrix.add(letter);
        alphabet.remove(letter);
      }
    }
    matrix.addAll(alphabet);
    return matrix;
  }

  String _encryptColumn(String column, List<String> matrix) {
    final List<String> pairs = _splitIntoPairs(column);
    final List<String> encryptedPairs = [];
    for (String pair in pairs) {
      final String encryptedPair = _encryptPair(pair, matrix);
      encryptedPairs.add(encryptedPair);
    }
    final String encryptedColumn = encryptedPairs.join('');
    return encryptedColumn;
  }

  String _decryptColumn(String column, List<String> matrix) {
    final List<String> pairs = _splitIntoPairs(column);
    final List<String> decryptedPairs = [];
    for (String pair in pairs) {
      final String decryptedPair = _decryptPair(pair, matrix);
      decryptedPairs.add(decryptedPair);
    }
    final String decryptedColumn = decryptedPairs.join('');
    return decryptedColumn;
  }

  List<String> _splitIntoPairs(String column) {
    final List<String> pairs = [];
    for (int i = 0; i < column.length; i += 2) {
      if (i + 1 < column.length && column[i] != column[i + 1]) {
        pairs.add(column.substring(i, i + 2));
      } else {
        pairs.add(column.substring(i, i + 1) + 'X');
        i--;
      }
    }
    return pairs;
  }

  String _encryptPair(String pair, List<String> matrix) {
    final int row1 = matrix.indexOf(pair[0]) ~/ 5;
    final int col1 = matrix.indexOf(pair[0]) % 5;
    final int row2 = matrix.indexOf(pair[1]) ~/ 5;
    final int col2 = matrix.indexOf(pair[1]) % 5;
    if (row1 == row2) {
      final int newCol1 = (col1 + 1) % 5;
      final int newCol2 = (col2 + 1) % 5;
      final String encryptedPair = matrix[row1 * 5 + newCol1] + matrix[row2 * 5 + newCol2];
      return encryptedPair;
    } else if (col1 == col2) {
      final int newRow1 = (row1 + 1) % 5;
      final int newRow2 = (row2 + 1) % 5;
      final String encryptedPair = matrix[newRow1 * 5 + col1] + matrix[newRow2 * 5 + col2];
      return encryptedPair;
    } else {
      final String encryptedPair = matrix[row1 * 5 + col2] + matrix[row2 * 5 + col1];
      return encryptedPair;
    }
  }

  String _decryptPair(String pair, List<String> matrix)
  {
    final int row1 = matrix.indexOf(pair[0]) ~/ 5;
    final int col1 = matrix.indexOf(pair[0]) % 5;
    final int row2 = matrix.indexOf(pair[1]) ~/ 5;
    final int col2 = matrix.indexOf(pair[1]) % 5;
    if (row1 == row2) {
      final int newCol1 = (col1 - 1) % 5;
      final int newCol2 = (col2 - 1) % 5;
      final String decryptedPair = matrix[row1 * 5 + newCol1] + matrix[row2 * 5 + newCol2];
      return decryptedPair;
    } else if (col1 == col2) {
      final int newRow1 = (row1 - 1) % 5;
      final int newRow2 = (row2 - 1) % 5;
      final String decryptedPair = matrix[newRow1 * 5 + col1] + matrix[newRow2 * 5 + col2];
      return decryptedPair;
    } else {
      final String decryptedPair = matrix[row1 * 5 + col2] + matrix[row2 * 5 + col1];
      return decryptedPair;
    }
  }

@override
Widget build(BuildContext context) {
  final _keyController = TextEditingController();
  final _originalController = TextEditingController();
  final _encryptedController = TextEditingController();
  final _decryptedController = TextEditingController();


  return Scaffold(
    appBar: AppBar(
      title: Text('Column-wise Playfair Cipher'),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller:_keyEncryptEditingController,
            decoration: InputDecoration(labelText: 'Enter Key'),
          ),
          TextField(
            controller: _textEncryptEditingController,
            decoration: InputDecoration(labelText: 'Enter Text'),
          ),
          ElevatedButton(
            onPressed: _encrypt,
            child: Text('Encrypt'),
          ),
          TextField(
            controller:  _cipherTextEditingController,
            decoration: InputDecoration(labelText: 'Encrypted Text'),
            readOnly: true,
          ),
          ElevatedButton(
            onPressed: _decrypt,
            child: Text('Decrypt'),
          ),
          TextField(
            controller: _plainTextEditingController,
            decoration: InputDecoration(labelText: 'Decrypted Text'),
            readOnly: true,
          ),
        ],
      ),
    ),
  );
}

}