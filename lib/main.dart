import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=78a88a23";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        // border: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      ),
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(
      request); // solicitando respontar no servidor, e espera os dados chegar
  // print(json.decode(response.body));
  return json.decode(response.body); // retorna os dados em map
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String texto) {
    if (texto.isEmpty) {
      _clearAll();
      return;
    } else {
      double real = double.parse(texto);
      dolarController.text = (real / dolar).toStringAsFixed(2);
      euroController.text = (real / euro).toStringAsFixed(2);
    }
  }

  void _dolarChanged(String texto) {
    if (texto.isEmpty) {
      _clearAll();
      return;
    } else {
      double dolar = double.parse(texto);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    }
  }

  void _euroChanged(String texto) {
    if (texto.isEmpty) {
      _clearAll();
      return;
    } else {
      double euro = double.parse(texto);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    }
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FlatButton(color: Colors.amber,
        onPressed: _clearAll,
        child: Icon(Icons.refresh,),
      ),
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: Text('\$ Conversor \$'),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando dados...',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar dados :(',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          'Real', 'R\$', realController, _realChanged),
                      Divider(),
                      buildTextField(
                          'Dólar', 'US\$', dolarController, _dolarChanged),
                      Divider(),
                      buildTextField('Euro', '€', euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController control, Function function) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    controller: control,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.amber,
        ),
        border: OutlineInputBorder(),
        prefixText: prefix,
        prefixStyle: TextStyle(
          color: Colors.amber,
        )),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: function,
  );
}
