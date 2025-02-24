import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neyimeshur/giris.dart';
import 'package:neyimeshur/kayit.dart';
import 'package:neyimeshur/rota.dart';
import 'package:neyimeshur/sifremiunuttum.dart';
import 'package:neyimeshur/gezinme.dart';
import 'package:neyimeshur/class/rota_bloc.dart';
import 'firebase_options.dart';

//4800773014923
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<tripBloc>(
          create: (context) => tripBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Neyi Meşhur',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/kayit',
        routes: {
          '/': (context) => MyHomePage(),
          '/kayit': (context) => KayitSayfasi(),
          '/giris': (context) => GirisSayfasi(),
          '/sifremi-unuttum': (context) => SifremiUnuttum(),
          '/rota': (context) => Rotam(),
          '/ana': (context) =>
              Gezinme(isBackButtonClick: false, autoSelectedIndex: 0),
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Neyi Meşhur', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(text: 'KAYIT OL', routeName: '/kayit'),
            CustomButton(text: 'GİRİŞ YAP', routeName: '/giris'),
            CustomButton(
                text: 'ŞİFREMİ UNUTTUM', routeName: '/sifremi-unuttum'),
            CustomButton(text: 'ROTA', routeName: '/rota'),
            CustomButton(text: 'ANA SAYFA', routeName: '/ana'),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final String routeName;

  const CustomButton({Key? key, required this.text, required this.routeName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
