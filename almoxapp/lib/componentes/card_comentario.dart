import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Comentário feito em uma requisição.
class CardComentario extends StatelessWidget {
  final dynamic comentario;

  const CardComentario(this.comentario, {super.key});

  @override
  Widget build(BuildContext context) {
    DateTime data = DateTime.parse(comentario['datetime']);

    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  comentario['user']['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(data),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(comentario['content']),
          ],
        ),
      ),
    );
  }
}
