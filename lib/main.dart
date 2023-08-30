import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Implement an application which works as follows

// 1. Splash Screen
// 2. enter numbers m & n which indirectly indicates m rows and n column of a 2D grid.
// 3. the user should enter alphabets such that one alphabet occupies one position in the grid. Here we will need m*n number of alphabets.
// 4. grid creation done
// 5. Display the grid. Now The user can provide a text which needs to be searched in the grid.
// 6. If the text is available in the grid, then those alphabets should be highlighted if the text in the grid is readable in left to right direction (east), or top to bottom direction (south) or diagonal (south-east).
// 7. User can change the text provided in step 5 and check for the occurance of the word in the grid.

// Note -
// 1. At anytime, the user should be able to reset the setup and the application starts again from step 2.
// 2. APK and the Source code should be shared via dropbox, google drive etc... to hr@mobigic.com

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _mTextEditingController;
  late TextEditingController _nTextEditingController;
  late TextEditingController _alphabetsTextEditingController;
  late TextEditingController _searchTextEditingController;

  int numberOfAlphabets = 0;
  bool showGrid = false;

  List<bool> highlightBox = [];

  @override
  void initState() {
    _mTextEditingController = TextEditingController();
    _nTextEditingController = TextEditingController();
    _alphabetsTextEditingController = TextEditingController();
    _searchTextEditingController = TextEditingController();
    _mTextEditingController.addListener(calculateAlphabetCount);
    _nTextEditingController.addListener(calculateAlphabetCount);
    _alphabetsTextEditingController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void calculateAlphabetCount() {
    if (_mTextEditingController.text.isNotEmpty &&
        _nTextEditingController.text.isNotEmpty) {
      int mValue = int.parse(_mTextEditingController.text);
      int nValue = int.parse(_nTextEditingController.text);
      setState(() {
        numberOfAlphabets = mValue * nValue;
      });
    }
  }

  @override
  void dispose() {
    _mTextEditingController.dispose();
    _nTextEditingController.dispose();
    _alphabetsTextEditingController.dispose();
    _searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Mobigic"),
          backgroundColor: Colors.grey[350],
          actions: [
            true
                ? TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      _reset();
                    },
                    child: const Text(
                      "reset",
                      //style: TextStyle(color: Colors.black),
                    ),
                  )
                : Container()
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: showGrid ? showGridView() : showInputWidget(),
          ),
        ),
      ),
    );
  }

  Column showGridView() {
    final characters = _alphabetsTextEditingController.text.characters.toList();
    return Column(
      children: [
        TextField(
          controller: _searchTextEditingController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
          ],
          decoration: InputDecoration(
            fillColor: Colors.grey[350],
            filled: true,
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.circular(40),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.circular(40),
            ),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchTextEditingController.clear();
              },
            ),
            hintText: 'Search...',
          ),
          onSubmitted: (value) {
            searchInGrid(value);
          },
          keyboardType: TextInputType.text,
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _nTextEditingController.text.isNotEmpty
                  ? int.parse(_nTextEditingController.text)
                  : 0,
            ),
            itemCount: characters.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                color:
                    highlightBox[index] ? Colors.grey[800] : Colors.grey[350],
                child: Center(
                  child: Text(
                    characters[index],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Column showInputWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _mTextEditingController,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter number m value",
          ),
        ),
        TextField(
          controller: _nTextEditingController,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter number n value",
          ),
        ),
        Visibility(
          visible: numberOfAlphabets != 0,
          child: TextField(
            controller: _alphabetsTextEditingController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
            ],
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Enter $numberOfAlphabets alphabets",
            ),
          ),
        ),
        Visibility(
          visible: numberOfAlphabets != 0 &&
              _alphabetsTextEditingController.text.length == numberOfAlphabets,
          child: TextButton(
            onPressed: () {
              setState(
                () {
                  final characters =
                      _alphabetsTextEditingController.text.characters.toList();
                  List.generate(characters.length,
                      (index) => highlightBox.insert(index, false));

                  showGrid = true;
                },
              );
            },
            child: const Text("Create Grid"),
          ),
        )
      ],
    );
  }

  void _reset() {
    _mTextEditingController.clear();
    _nTextEditingController.clear();
    _alphabetsTextEditingController.clear();
    _searchTextEditingController.clear();
    numberOfAlphabets = 0;
    showGrid = false;
  }

  void searchInGrid(String searchText) {
    final characters = _alphabetsTextEditingController.text.characters.toList();
    List.generate(
        characters.length, (index) => highlightBox.insert(index, false));

    if (searchText.isEmpty) return;

    int mValue = int.parse(_mTextEditingController.text);
    int nValue = int.parse(_nTextEditingController.text);

    // top to bottom
    for (int col = 0; col < nValue; col++) {
      String text = "";
      for (int row = col; row < nValue * mValue; row += nValue) {
        text = text + characters[row];
        log(text);
      }

      if (searchText == text) {
        for (int row = col; row < nValue * mValue; row += nValue) {
          highlightBox[row] = true;
        }
      }
    }

    //left to right
    for (int col = 0; col < mValue * nValue; col += nValue) {
      String text = "";
      for (int row = col; row < col + mValue; row++) {
        text = text + characters[row];
      }

      if (searchText == text) {
        for (int row = col; row < col + mValue; row++) {
          highlightBox[row] = true;
        }
      }
    }

    if (mValue == nValue) {
      String text = "";

      for (int col = 0; col < mValue * nValue; col += (nValue + 1)) {
        text = text + characters[col];
      }
      if (searchText == text || searchText == text.split('').reversed.join()) {
        for (int col = 0; col < mValue * nValue; col += (nValue + 1)) {
          highlightBox[col] = true;
        }
      }
      text = "";

      for (int col = nValue - 1;
          col < mValue * nValue - 1;
          col += (nValue - 1)) {
        text = text + characters[col];
      }
      if (searchText == text || searchText == text.split('').reversed.join()) {
        for (int col = nValue - 1;
            col < mValue * nValue - 1;
            col += (nValue - 1)) {
          highlightBox[col] = true;
        }
      }
    }

    setState(() {});
  }
}
