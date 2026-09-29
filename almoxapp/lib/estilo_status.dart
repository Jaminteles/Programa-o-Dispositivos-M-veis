import 'package:flutter/material.dart';

/// Texto, cor e ícone de cada status de requisição, usados nas telas
/// e nos componentes para manter a aparência igual em todo o aplicativo.
String rotuloStatus(String status) {
  if (status == 'aprovada') {
    return 'Aprovada';
  } else if (status == 'recusada') {
    return 'Recusada';
  } else if (status == 'entregue') {
    return 'Entregue';
  }
  return 'Pendente';
}

Color corStatus(String status) {
  if (status == 'aprovada') {
    return Colors.blue;
  } else if (status == 'recusada') {
    return Colors.red;
  } else if (status == 'entregue') {
    return Colors.green;
  }
  return Colors.orange;
}

IconData iconeStatus(String status) {
  if (status == 'aprovada') {
    return Icons.thumb_up;
  } else if (status == 'recusada') {
    return Icons.block;
  } else if (status == 'entregue') {
    return Icons.local_shipping;
  }
  return Icons.hourglass_bottom;
}
