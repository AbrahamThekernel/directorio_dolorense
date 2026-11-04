import 'dart:convert';

import 'package:directorio_dolorense/datos/negocios_api.dart';
import 'package:directorio_dolorense/presentacion/negocios_viewmodel.dart';
import 'package:directorio_dolorense/presentacion/pantalla_negocios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget pantallaCon(MockClient cliente) => MaterialApp(
      home: PantallaNegocios(
        vm: NegociosViewModel(NegociosApi(cliente, 'http://prueba')),
      ),
    );

void main() {
  testWidgets('muestra la lista cuando la carga termina', (tester) async {
    final cliente = MockClient((_) async => http.Response(
        jsonEncode([
          {
            'id': 1,
            'nombre': 'Nieves de la Plaza',
            'categoria': 'Nevería',
            'telefono': '418-100-0001',
            'favorito': true,
          }
        ]),
        200));

    await tester.pumpWidget(pantallaCon(cliente));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Nieves de la Plaza'), findsOneWidget);
    expect(find.text('Nevería · 418-100-0001'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('muestra el estado vacío', (tester) async {
    final cliente = MockClient((_) async => http.Response('[]', 200));

    await tester.pumpWidget(pantallaCon(cliente));
    await tester.pumpAndSettle();

    expect(
        find.text('Aún no hay negocios. ¡Agrega el primero!'), findsOneWidget);
  });

  testWidgets('muestra el error y Reintentar recupera la lista',
      (tester) async {
    var llamadas = 0;
    final cliente = MockClient((_) async {
      llamadas++;
      if (llamadas == 1) return http.Response('', 500);
      return http.Response(
          jsonEncode([
            {'id': 1, 'nombre': 'Tacos Don Chema', 'categoria': 'Comida'}
          ]),
          200);
    });

    await tester.pumpWidget(pantallaCon(cliente));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.textContaining('500'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Tacos Don Chema'), findsOneWidget);
  });

  testWidgets('tocar la estrella alterna el favorito con PUT', (tester) async {
    final cliente = MockClient((req) async {
      if (req.method == 'PUT') {
        return http.Response(
            jsonEncode(
                {'id': 1, 'nombre': 'A', 'categoria': 'X', 'favorito': true}),
            200);
      }
      return http.Response(
          jsonEncode([
            {'id': 1, 'nombre': 'A', 'categoria': 'X'}
          ]),
          200);
    });

    await tester.pumpWidget(pantallaCon(cliente));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
