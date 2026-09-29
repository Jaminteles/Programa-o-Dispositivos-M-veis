import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'usuario.dart';

/// Telas que o aplicativo sabe exibir. A troca de tela é feita trocando
/// este valor, e não com Navigator.
enum EmExibicao {
  telaRequisicoes,
  telaDetalhes,
  telaNovaRequisicao,
  telaEstoque,
}

/// Estado global do aplicativo: tela em exibição, usuário logado e os dados
/// carregados dos arquivos JSON. Como não há servidor, toda alteração feita
/// pelo usuário fica guardada aqui, em memória, e sobrevive a troca de telas.
class GerenciadorEstado extends ChangeNotifier {
  EmExibicao _exibicao = EmExibicao.telaRequisicoes;
  int _idRequisicao = 0;
  Usuario? _usuario;

  List<dynamic> _requisicoes = [];
  List<dynamic> _comentarios = [];
  List<dynamic> _materiais = [];
  List<dynamic> _obras = [];

  bool _dadosCarregados = false;
  int _proximoIdRequisicao = 1;
  int _proximoIdComentario = 1;

  EmExibicao get exibicao => _exibicao;
  int get idRequisicao => _idRequisicao;
  Usuario? get usuario => _usuario;

  bool get logado => _usuario != null;
  bool get ehAlmoxarife => _usuario != null && _usuario!.ehAlmoxarife;

  List<dynamic> get requisicoes => _requisicoes;
  List<dynamic> get materiais => _materiais;
  List<dynamic> get obras => _obras;

  // ---------------------------------------------------------------- navegação

  void exibirRequisicoes() {
    _exibicao = EmExibicao.telaRequisicoes;
    notifyListeners();
  }

  void exibirDetalhes(int id) {
    _idRequisicao = id;
    _exibicao = EmExibicao.telaDetalhes;
    notifyListeners();
  }

  void exibirNovaRequisicao() {
    _exibicao = EmExibicao.telaNovaRequisicao;
    notifyListeners();
  }

  void exibirEstoque() {
    _exibicao = EmExibicao.telaEstoque;
    notifyListeners();
  }

  // ---------------------------------------------------------------- acesso

  void login(Usuario usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  void logout() {
    _usuario = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------- dados

  /// Lê os quatro arquivos JSON de recursos/jsons. Roda uma única vez, a não
  /// ser que [recarregar] seja verdadeiro (usado pelo RefreshIndicator), e por
  /// isso não avisa os ouvintes: quem chama já está dentro de um setState.
  Future<void> carregarDados({bool recarregar = false}) async {
    if (_dadosCarregados && !recarregar) {
      return;
    }

    String textoMateriais =
        await rootBundle.loadString('recursos/jsons/materiais.json');
    String textoObras = await rootBundle.loadString('recursos/jsons/obras.json');
    String textoRequisicoes =
        await rootBundle.loadString('recursos/jsons/requisicoes.json');
    String textoComentarios =
        await rootBundle.loadString('recursos/jsons/comentarios.json');

    _materiais = json.decode(textoMateriais)['materiais'];
    _obras = json.decode(textoObras)['obras'];
    _requisicoes = json.decode(textoRequisicoes)['requisicoes'];
    _comentarios = json.decode(textoComentarios)['comentarios'];

    _proximoIdRequisicao = _maiorId(_requisicoes) + 1;
    _proximoIdComentario = _maiorId(_comentarios) + 1;
    _dadosCarregados = true;
  }

  int _maiorId(List<dynamic> lista) {
    int maior = 0;
    for (dynamic item in lista) {
      if (item['_id'] > maior) {
        maior = item['_id'];
      }
    }
    return maior;
  }

  dynamic obraPorId(int id) {
    for (dynamic obra in _obras) {
      if (obra['_id'] == id) {
        return obra;
      }
    }
    return null;
  }

  dynamic materialPorId(int id) {
    for (dynamic material in _materiais) {
      if (material['_id'] == id) {
        return material;
      }
    }
    return null;
  }

  dynamic requisicaoPorId(int id) {
    for (dynamic requisicao in _requisicoes) {
      if (requisicao['_id'] == id) {
        return requisicao;
      }
    }
    return null;
  }

  /// Comentários de uma requisição, do mais antigo para o mais novo.
  List<dynamic> comentariosDaRequisicao(int id) {
    List<dynamic> lista = [];
    for (dynamic comentario in _comentarios) {
      if (comentario['requisicaoId'] == id) {
        lista.add(comentario);
      }
    }
    lista.sort((a, b) => a['datetime'].compareTo(b['datetime']));
    return lista;
  }

  // ---------------------------------------------------------------- alterações

  /// Cria a requisição em nome do usuário logado e devolve o número gerado.
  String adicionarRequisicao(
    int obraId,
    List<dynamic> itens,
    String justificativa,
  ) {
    DateTime agora = DateTime.now();
    String numero = 'REQ-${agora.year}-'
        '${_proximoIdRequisicao.toString().padLeft(3, '0')}';

    _requisicoes.add({
      '_id': _proximoIdRequisicao,
      'numero': numero,
      'obraId': obraId,
      'solicitante': {
        'nome': _usuario!.nome,
        'email': _usuario!.email,
      },
      'data': agora.toIso8601String(),
      'status': 'pendente',
      'justificativa': justificativa,
      'itens': itens,
    });

    _proximoIdRequisicao = _proximoIdRequisicao + 1;
    notifyListeners();
    return numero;
  }

  void adicionarComentario(int requisicaoId, String texto) {
    _comentarios.add({
      '_id': _proximoIdComentario,
      'requisicaoId': requisicaoId,
      'user': {
        'email': _usuario!.email,
        'name': _usuario!.nome,
      },
      'datetime': DateTime.now().toIso8601String(),
      'content': texto,
    });

    _proximoIdComentario = _proximoIdComentario + 1;
    notifyListeners();
  }

  void removerComentario(int idComentario) {
    _comentarios.removeWhere((comentario) => comentario['_id'] == idComentario);
    notifyListeners();
  }

  void alterarStatus(int idRequisicao, String status) {
    dynamic requisicao = requisicaoPorId(idRequisicao);
    if (requisicao != null) {
      requisicao['status'] = status;
      notifyListeners();
    }
  }

  /// Cancelar apaga a requisição e os comentários ligados a ela.
  void cancelarRequisicao(int idRequisicao) {
    _requisicoes.removeWhere((requisicao) => requisicao['_id'] == idRequisicao);
    _comentarios
        .removeWhere((comentario) => comentario['requisicaoId'] == idRequisicao);
    notifyListeners();
  }
}

/// Instância única do estado, preenchida pela TelaPrincipal a cada build.
late GerenciadorEstado estadoApp;
