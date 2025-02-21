import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neyimeshur/bar.dart';
import 'package:neyimeshur/hesabim.dart';
import 'package:neyimeshur/main.dart';
import 'package:neyimeshur/rota.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

// ignore: must_be_immutable
class Gezinme extends StatefulWidget {
  final bool isBackButtonClick;
  int autoSelectedIndex;

  Gezinme(
      {required this.isBackButtonClick,
      required this.autoSelectedIndex,
      Key? key})
      : super(key: key);

  @override
  State<Gezinme> createState() =>
      _navigationPageState(isBackButtonClick, autoSelectedIndex);
}

class _navigationPageState extends State<Gezinme> {
  bool isBackButtonClick;
  int autoSelectedIndex;
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late StreamSubscription<bool> keyboardSubscription;
  bool isKeyboardVisible = false;

  _navigationPageState(this.isBackButtonClick, this.autoSelectedIndex);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      isBackButtonClick = true;

      _pages = [
        MyApp(),
        Rotam(),
        Rotam(),
        Rotam(),
        ProfilePage(),
      ];
    });
  }

  @override
  void initState() {
    super.initState();

    if (autoSelectedIndex == 0) {
      isBackButtonClick = isBackButtonClick;
      _selectedIndex = _selectedIndex;
      var keyboardVisibilityController = KeyboardVisibilityController();
      _pages = [
        MyApp(),
        Rotam(),
        Rotam(),
        Rotam(),
        ProfilePage(),
      ];
      keyboardSubscription =
          keyboardVisibilityController.onChange.listen((bool visible) {
        setState(() {
          isKeyboardVisible = visible;
        });
      });
    } else {
      _selectedIndex = autoSelectedIndex;

      var keyboardVisibilityController = KeyboardVisibilityController();
      _pages = [
        MyApp(),
        Rotam(),
        Rotam(),
        Rotam(),
        ProfilePage(),
      ];
      keyboardSubscription =
          keyboardVisibilityController.onChange.listen((bool visible) {
        setState(() {
          isKeyboardVisible = visible;
        });
      });
    }
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          if (_selectedIndex == 0) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Çıkış'),
                  content:
                      const Text('Uygulamadan çıkmak istediğine emin misin?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // User confirmed exit
                        SystemNavigator.pop();
                      },
                      child: Text('Evet'),
                    ),
                    TextButton(
                      onPressed: () {
                        // User canceled exit
                        Navigator.of(context).pop(false);
                      },
                      child: Text('Hayır'),
                    ),
                  ],
                );
              },
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Gezinme(
                        isBackButtonClick: true,
                        autoSelectedIndex: 0,
                      )),
            );
          }

          return false;
        },
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          body: _pages[_selectedIndex],
          bottomNavigationBar: Visibility(
            visible: !isKeyboardVisible,
            child: Bar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
