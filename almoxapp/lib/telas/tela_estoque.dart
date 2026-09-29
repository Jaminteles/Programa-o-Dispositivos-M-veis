import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../componentes/card_material.dart';
import '../gerenciador_estado.dart';

/// Consulta do estoque do almoxarifado, aberta a qualquer pessoa, com filtro
/// pelo nome do material.
class TelaEstoque extends StatefulWidget {
  const TelaEstoque({super.key});

  @override
  State<TelaEstoque> createState() => _TelaEstoqueState();
}

class _TelaEstoqueState extends State<TelaEstoque> {
  bool _carregandoMateriais = false;
  bool _filtrando = false;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _carregarMateriais();
  }

  Future<void> _carregarMateriais({bool recarregar = false}) async {
    setState(() {
      _carregandoMateriais = true;
    });

    await estadoApp.carregarDados(recarregar: recarregar);

    if (!mounted) {
      return;
    }
    setState(() {
      _carregandoMateriais = false;
    });
  }

  List<dynamic> _materiaisFiltrados() {
    List<dynamic> lista = [];
    String procurado = _filtro.toLowerCase().trim();

    for (dynamic material in estadoApp.materiais) {
      String nome = material['nome'].toString().toLowerCase();
      if (procurado.isEmpty || nome.contains(procurado)) {
        lista.add(material);
      }
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    // A própria tela observa o estado global: assim ela se reconstrói sozinha
    // quando o GerenciadorEstado avisa que algo mudou.
    estadoApp = context.watch<GerenciadorEstado>();
    List<dynamic> materiais = _materiaisFiltrados();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            estadoApp.exibirRequisicoes();
          },
        ),
        title: _filtrando
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Nome do material...',
                  border: InputBorder.none,
                ),
                onSubmitted: (texto) {
                  setState(() {
                    _filtro = texto;
                  });
                },
              )
            : const Text('Estoque'),
        actions: [
          IconButton(
            tooltip: _filtrando ? 'Limpar filtro' : 'Filtrar',
            icon: Icon(_filtrando ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _filtrando = !_filtrando;
                _filtro = '';
              });
            },
          ),
        ],
      ),
      body: _carregandoMateriais
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _carregarMateriais(recarregar: true);
              },
              child: materiais.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Nenhum material encontrado.')),
                      ],
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: materiais.length,
                      itemBuilder: (context, indice) {
                        return CardMaterial(materiais[indice]);
                      },
                    ),
            ),
    );
  }
}
