import 'package:flutter/material.dart';

/// Item pedido dentro de uma requisição: material, quantidade e unidade.
class CardItem extends StatelessWidget {
  final dynamic material;
  final dynamic quantidade;

  const CardItem(this.material, this.quantidade, {super.key});

  @override
  Widget build(BuildContext context) {
    String nome = material == null ? 'Material não identificado' : material['nome'];
    String unidade = material == null ? '' : material['unidade'];

    return ListTile(
      dense: true,
      leading: const Icon(Icons.chevron_right),
      title: Text(nome),
      trailing: Text(
        '$quantidade $unidade',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
