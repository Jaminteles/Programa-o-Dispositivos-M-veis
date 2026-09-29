import 'package:flutter/material.dart';

/// Quadro do estoque com o nome do material, o saldo e a unidade.
class CardMaterial extends StatelessWidget {
  final dynamic material;

  const CardMaterial(this.material, {super.key});

  @override
  Widget build(BuildContext context) {
    int saldo = material['saldo'];
    Color cor = saldo <= 20 ? Colors.red : Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.inventory_2, color: cor),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                material['nome'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Saldo: $saldo ${material['unidade']}',
              style: TextStyle(color: cor),
            ),
          ],
        ),
      ),
    );
  }
}
