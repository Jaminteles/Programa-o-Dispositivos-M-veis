import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toast/toast.dart';

import '../componentes/card_comentario.dart';
import '../componentes/card_item.dart';
import '../estilo_status.dart';
import '../gerenciador_estado.dart';

/// Detalhes de uma requisição: itens pedidos, justificativa, status e
/// comentários. Os botões que aparecem dependem de quem está logado.
class TelaDetalhes extends StatefulWidget {
  const TelaDetalhes({super.key});

  @override
  State<TelaDetalhes> createState() => _TelaDetalhesState();
}

class _TelaDetalhesState extends State<TelaDetalhes> {
  final TextEditingController _controladorComentario = TextEditingController();

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  @override
  void dispose() {
    _controladorComentario.dispose();
    super.dispose();
  }

  /// Monta o texto enviado pelo botão de compartilhar.
  String _resumo(dynamic requisicao, dynamic obra) {
    DateTime data = DateTime.parse(requisicao['data']);
    String texto = 'Requisição ${requisicao['numero']}\n';
    texto = '$texto Obra: ${obra == null ? '-' : obra['nome']}\n';
    texto = '$texto Solicitante: ${requisicao['solicitante']['nome']}\n';
    texto = '$texto Data: ${DateFormat('dd/MM/yyyy HH:mm').format(data)}\n';
    texto = '$texto Status: ${rotuloStatus(requisicao['status'])}\n';
    texto = '$texto Itens:\n';

    for (dynamic item in requisicao['itens']) {
      dynamic material = estadoApp.materialPorId(item['materialId']);
      String nome = material == null ? 'Material' : material['nome'];
      String unidade = material == null ? '' : material['unidade'];
      texto = '$texto - $nome: ${item['quantidade']} $unidade\n';
    }

    return '$texto\nEnviado pelo AlmoxApp.';
  }

  void _enviarComentario() {
    String texto = _controladorComentario.text.trim();

    if (texto.isEmpty) {
      Toast.show(
        'Escreva o comentário antes de enviar',
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
      );
      return;
    }

    estadoApp.adicionarComentario(estadoApp.idRequisicao, texto);
    _controladorComentario.clear();
    FocusScope.of(context).unfocus();
    Toast.show(
      'Comentário enviado',
      duration: Toast.lengthShort,
      gravity: Toast.bottom,
    );
  }

  /// Caixa de SIM/NÃO usada antes de apagar comentário e de cancelar.
  Future<bool> _confirmar(String pergunta) async {
    bool? resposta = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: Text(pergunta),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('NÃO'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('SIM'),
            ),
          ],
        );
      },
    );

    return resposta == true;
  }

  Future<void> _cancelarRequisicao() async {
    bool confirmado = await _confirmar('Deseja cancelar esta requisição?');

    if (!confirmado || !mounted) {
      return;
    }

    estadoApp.cancelarRequisicao(estadoApp.idRequisicao);
    Toast.show(
      'Requisição cancelada',
      duration: Toast.lengthShort,
      gravity: Toast.bottom,
    );
    estadoApp.exibirRequisicoes();
  }

  void _mudarStatus(String status) {
    estadoApp.alterarStatus(estadoApp.idRequisicao, status);
    Toast.show(
      'Requisição ${rotuloStatus(status).toLowerCase()}',
      duration: Toast.lengthShort,
      gravity: Toast.bottom,
    );
  }

  /// Botões do almoxarife, que mudam conforme o status atual.
  List<Widget> _botoesAlmoxarife(String status) {
    if (status == 'pendente') {
      return [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _mudarStatus('aprovada');
                },
                icon: const Icon(Icons.thumb_up),
                label: const Text('Aprovar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _mudarStatus('recusada');
                },
                icon: const Icon(Icons.block),
                label: const Text('Recusar'),
              ),
            ),
          ],
        ),
      ];
    }

    if (status == 'aprovada') {
      return [
        ElevatedButton.icon(
          onPressed: () {
            _mudarStatus('entregue');
          },
          icon: const Icon(Icons.local_shipping),
          label: const Text('Marcar como entregue'),
        ),
      ];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    // A própria tela observa o estado global: assim ela se reconstrói sozinha
    // quando o GerenciadorEstado avisa que algo mudou.
    estadoApp = context.watch<GerenciadorEstado>();
    dynamic requisicao = estadoApp.requisicaoPorId(estadoApp.idRequisicao);

    if (requisicao == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              estadoApp.exibirRequisicoes();
            },
          ),
          title: const Text('Detalhes'),
        ),
        body: const Center(child: Text('Requisição não encontrada.')),
      );
    }

    dynamic obra = estadoApp.obraPorId(requisicao['obraId']);
    String status = requisicao['status'];
    DateTime data = DateTime.parse(requisicao['data']);
    List<dynamic> comentarios =
        estadoApp.comentariosDaRequisicao(requisicao['_id']);
    bool ehMinha = estadoApp.logado &&
        requisicao['solicitante']['email'] == estadoApp.usuario!.email;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            estadoApp.exibirRequisicoes();
          },
        ),
        title: Text(requisicao['numero']),
        actions: [
          IconButton(
            tooltip: 'Compartilhar',
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(_resumo(requisicao, obra));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: corStatus(status),
                child: Icon(iconeStatus(status), color: Colors.white),
              ),
              title: Text(obra == null ? 'Obra não identificada' : obra['nome']),
              subtitle: Text(
                '${requisicao['solicitante']['nome']}\n'
                '${DateFormat('dd/MM/yyyy HH:mm').format(data)}',
              ),
              isThreeLine: true,
              trailing: Text(
                rotuloStatus(status),
                style: TextStyle(
                  color: corStatus(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Materiais solicitados',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Card(
            child: Column(
              children: [
                for (dynamic item in requisicao['itens'])
                  CardItem(
                    estadoApp.materialPorId(item['materialId']),
                    item['quantidade'],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Justificativa',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(requisicao['justificativa']),
            ),
          ),
          const SizedBox(height: 12),
          if (estadoApp.ehAlmoxarife) ..._botoesAlmoxarife(status),
          if (ehMinha && status == 'pendente')
            OutlinedButton.icon(
              onPressed: _cancelarRequisicao,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Cancelar requisição'),
            ),
          const SizedBox(height: 12),
          Text(
            'Comentários (${comentarios.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (comentarios.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Nenhum comentário ainda.'),
            ),
          for (dynamic comentario in comentarios)
            if (estadoApp.logado &&
                comentario['user']['email'] == estadoApp.usuario!.email)
              Dismissible(
                key: ValueKey(comentario['_id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direcao) {
                  return _confirmar('Deseja apagar este comentário?');
                },
                onDismissed: (direcao) {
                  estadoApp.removerComentario(comentario['_id']);
                  Toast.show(
                    'Comentário apagado',
                    duration: Toast.lengthShort,
                    gravity: Toast.bottom,
                  );
                },
                child: CardComentario(comentario),
              )
            else
              CardComentario(comentario),
          if (estadoApp.logado)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controladorComentario,
                      decoration: const InputDecoration(
                        labelText: 'Escreva um comentário',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Enviar',
                    icon: const Icon(Icons.send),
                    onPressed: _enviarComentario,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
