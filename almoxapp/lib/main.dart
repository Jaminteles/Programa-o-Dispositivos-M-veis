import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gerenciador_estado.dart';
import 'telas/tela_detalhes.dart';
import 'telas/tela_estoque.dart';
import 'telas/tela_nova_requisicao.dart';
import 'telas/tela_requisicoes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GerenciadorEstado(),
      child: const AlmoxApp(),
    ),
  );
}

class AlmoxApp extends StatelessWidget {
  const AlmoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlmoxApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const TelaPrincipal(),
    );
  }
}

/// Única tela do MaterialApp: observa o estado global e decide qual das
/// telas do aplicativo deve aparecer.
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  @override
  Widget build(BuildContext context) {
    estadoApp = context.watch<GerenciadorEstado>();

    if (estadoApp.exibicao == EmExibicao.telaDetalhes) {
      return const TelaDetalhes();
    } else if (estadoApp.exibicao == EmExibicao.telaNovaRequisicao) {
      return const TelaNovaRequisicao();
    } else if (estadoApp.exibicao == EmExibicao.telaEstoque) {
      return const TelaEstoque();
    } else {
      return const TelaRequisicoes();
    }
  }
}
