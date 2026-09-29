import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../estilo_status.dart';
import '../gerenciador_estado.dart';

/// Linha da lista de requisições. Recebe a requisição e a obra já localizada
/// pela tela, e ao ser tocada abre os detalhes.
class CardRequisicao extends StatelessWidget {
  final dynamic requisicao;
  final dynamic obra;

  const CardRequisicao(this.requisicao, this.obra, {super.key});

  @override
  Widget build(BuildContext context) {
    String status = requisicao['status'];
    DateTime data = DateTime.parse(requisicao['data']);
    String nomeObra = obra == null ? 'Obra não identificada' : obra['nome'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: corStatus(status),
          child: Icon(iconeStatus(status), color: Colors.white),
        ),
        title: Text(
          requisicao['numero'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$nomeObra\n'
          '${requisicao['solicitante']['nome']}\n'
          '${DateFormat('dd/MM/yyyy HH:mm').format(data)}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rotuloStatus(status),
              style: TextStyle(
                color: corStatus(status),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('${requisicao['itens'].length} item(ns)'),
          ],
        ),
        onTap: () {
          estadoApp.exibirDetalhes(requisicao['_id']);
        },
      ),
    );
  }
}
