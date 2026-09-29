import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../autenticador.dart';
import '../componentes/card_requisicao.dart';
import '../gerenciador_estado.dart';
import '../usuario.dart';

/// Tela inicial: lista das requisições de material, com filtro por número ou
/// por obra. Pode ser consultada sem login; só quem está logado cria uma nova.
class TelaRequisicoes extends StatefulWidget {
  const TelaRequisicoes({super.key});

  @override
  State<TelaRequisicoes> createState() => _TelaRequisicoesState();
}

class _TelaRequisicoesState extends State<TelaRequisicoes> {
  bool _carregandoRequisicoes = false;
  bool _filtrando = false;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _carregarRequisicoes();
  }

  Future<void> _carregarRequisicoes({bool recarregar = false}) async {
    setState(() {
      _carregandoRequisicoes = true;
    });

    await estadoApp.carregarDados(recarregar: recarregar);

    if (!mounted) {
      return;
    }
    setState(() {
      _carregandoRequisicoes = false;
    });
  }

  /// Aplica o filtro digitado na AppBar sobre o número e o nome da obra.
  List<dynamic> _requisicoesFiltradas() {
    List<dynamic> lista = [];
    String procurado = _filtro.toLowerCase().trim();

    for (dynamic requisicao in estadoApp.requisicoes) {
      dynamic obra = estadoApp.obraPorId(requisicao['obraId']);
      String numero = requisicao['numero'].toString().toLowerCase();
      String nomeObra =
          obra == null ? '' : obra['nome'].toString().toLowerCase();

      if (procurado.isEmpty ||
          numero.contains(procurado) ||
          nomeObra.contains(procurado)) {
        lista.add(requisicao);
      }
    }

    lista.sort((a, b) => b['data'].compareTo(a['data']));
    return lista;
  }

  /// Pergunta o perfil e pede o usuário fixo ao Autenticador.
  void _abrirDialogoLogin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Entrar como'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('recursos/imagens/logo.png', height: 70),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.engineering),
                title: const Text('Funcionário'),
                subtitle: const Text('Solicita materiais para a obra'),
                onTap: () {
                  Navigator.pop(context);
                  _entrar('funcionario');
                },
              ),
              ListTile(
                leading: const Icon(Icons.warehouse),
                title: const Text('Almoxarife'),
                subtitle: const Text('Aprova, recusa e entrega'),
                onTap: () {
                  Navigator.pop(context);
                  _entrar('almoxarife');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCELAR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _entrar(String perfil) async {
    setState(() {
      _carregandoRequisicoes = true;
    });

    Usuario usuario = await Autenticador.login(perfil);

    if (!mounted) {
      return;
    }
    setState(() {
      _carregandoRequisicoes = false;
    });
    estadoApp.login(usuario);
    Toast.show(
      'Bem-vindo(a), ${usuario.nome}',
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
    );
  }

  Future<void> _sair() async {
    await Autenticador.logout();

    if (!mounted) {
      return;
    }
    estadoApp.logout();
    Toast.show(
      'Você saiu do aplicativo',
      duration: Toast.lengthShort,
      gravity: Toast.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    // A própria tela observa o estado global: assim ela se reconstrói sozinha
    // quando o GerenciadorEstado avisa que algo mudou.
    estadoApp = context.watch<GerenciadorEstado>();
    List<dynamic> requisicoes = _requisicoesFiltradas();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: _filtrando
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Número ou obra...',
                  border: InputBorder.none,
                ),
                onSubmitted: (texto) {
                  setState(() {
                    _filtro = texto;
                  });
                },
              )
            : const Text('Requisições'),
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
          IconButton(
            tooltip: 'Estoque',
            icon: const Icon(Icons.inventory_2),
            onPressed: () {
              estadoApp.exibirEstoque();
            },
          ),
          IconButton(
            tooltip: estadoApp.logado ? 'Sair' : 'Entrar',
            icon: Icon(estadoApp.logado ? Icons.logout : Icons.login),
            onPressed: () {
              if (estadoApp.logado) {
                _sair();
              } else {
                _abrirDialogoLogin();
              }
            },
          ),
        ],
      ),
      body: _carregandoRequisicoes
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _carregarRequisicoes(recarregar: true);
              },
              child: requisicoes.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Nenhuma requisição encontrada.')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: requisicoes.length,
                      itemBuilder: (context, indice) {
                        dynamic requisicao = requisicoes[indice];
                        return CardRequisicao(
                          requisicao,
                          estadoApp.obraPorId(requisicao['obraId']),
                        );
                      },
                    ),
            ),
      floatingActionButton: estadoApp.logado
          ? FloatingActionButton.extended(
              onPressed: () {
                estadoApp.exibirNovaRequisicao();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova requisição'),
            )
          : null,
    );
  }
}
