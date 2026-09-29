import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

import '../gerenciador_estado.dart';

/// Formulário de uma nova requisição, disponível apenas para quem está logado:
/// escolhe a obra, monta a lista de materiais e escreve a justificativa.
class TelaNovaRequisicao extends StatefulWidget {
  const TelaNovaRequisicao({super.key});

  @override
  State<TelaNovaRequisicao> createState() => _TelaNovaRequisicaoState();
}

class _TelaNovaRequisicaoState extends State<TelaNovaRequisicao> {
  final TextEditingController _controladorQuantidade = TextEditingController();
  final TextEditingController _controladorJustificativa =
      TextEditingController();

  int? _obraEscolhida;
  int? _materialEscolhido;
  final List<dynamic> _itens = [];
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  @override
  void dispose() {
    _controladorQuantidade.dispose();
    _controladorJustificativa.dispose();
    super.dispose();
  }

  void _avisar(String mensagem) {
    Toast.show(
      mensagem,
      duration: Toast.lengthShort,
      gravity: Toast.bottom,
    );
  }

  /// Acrescenta o material escolhido à lista de itens da requisição.
  void _adicionarItem() {
    if (_materialEscolhido == null) {
      _avisar('Escolha um material');
      return;
    }

    int quantidade = int.tryParse(_controladorQuantidade.text.trim()) ?? 0;
    if (quantidade <= 0) {
      _avisar('Informe uma quantidade maior que zero');
      return;
    }

    for (dynamic item in _itens) {
      if (item['materialId'] == _materialEscolhido) {
        _avisar('Esse material já está na lista');
        return;
      }
    }

    setState(() {
      _itens.add({
        'materialId': _materialEscolhido,
        'quantidade': quantidade,
      });
      _materialEscolhido = null;
      _controladorQuantidade.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _removerItem(int indice) {
    setState(() {
      _itens.removeAt(indice);
    });
  }

  Future<void> _enviar() async {
    if (_obraEscolhida == null) {
      _avisar('Escolha a obra');
      return;
    }

    if (_itens.isEmpty) {
      _avisar('Acrescente pelo menos um material');
      return;
    }

    String justificativa = _controladorJustificativa.text.trim();
    if (justificativa.isEmpty) {
      _avisar('Escreva a justificativa');
      return;
    }

    setState(() {
      _enviando = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) {
      return;
    }

    String numero =
        estadoApp.adicionarRequisicao(_obraEscolhida!, _itens, justificativa);
    _avisar('Requisição $numero enviada');
    estadoApp.exibirRequisicoes();
  }

  @override
  Widget build(BuildContext context) {
    // A própria tela observa o estado global: assim ela se reconstrói sozinha
    // quando o GerenciadorEstado avisa que algo mudou.
    estadoApp = context.watch<GerenciadorEstado>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            estadoApp.exibirRequisicoes();
          },
        ),
        title: const Text('Nova requisição'),
      ),
      body: _enviando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Obra',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                DropdownButton<int>(
                  value: _obraEscolhida,
                  isExpanded: true,
                  hint: const Text('Escolha a obra'),
                  items: [
                    for (dynamic obra in estadoApp.obras)
                      DropdownMenuItem<int>(
                        value: obra['_id'],
                        child: Text(
                          obra['nome'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      _obraEscolhida = valor;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Materiais',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  value: _materialEscolhido,
                  isExpanded: true,
                  hint: const Text('Escolha o material'),
                  items: [
                    for (dynamic material in estadoApp.materiais)
                      DropdownMenuItem<int>(
                        value: material['_id'],
                        child: Text(
                          '${material['nome']} (${material['unidade']})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      _materialEscolhido = valor;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controladorQuantidade,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Quantidade',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _adicionarItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Incluir'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_itens.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Nenhum material incluído.'),
                  ),
                for (int indice = 0; indice < _itens.length; indice = indice + 1)
                  Card(
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.inventory_2),
                      title: Text(
                        estadoApp.materialPorId(
                          _itens[indice]['materialId'],
                        )['nome'],
                      ),
                      subtitle: Text(
                        'Quantidade: ${_itens[indice]['quantidade']} '
                        '${estadoApp.materialPorId(_itens[indice]['materialId'])['unidade']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          _removerItem(indice);
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controladorJustificativa,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Justificativa',
                    hintText: 'Para que o material será usado?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _enviar,
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar requisição'),
                ),
              ],
            ),
    );
  }
}
