import 'usuario.dart';

/// Autenticação simulada: não existe servidor, os usuários são fixos.
/// O atraso serve apenas para o aplicativo mostrar o indicador de progresso.
class Autenticador {
  static Future<Usuario> login(String perfil) async {
    await Future.delayed(const Duration(seconds: 1));

    if (perfil == 'almoxarife') {
      return Usuario(
        'Marcos Andrade',
        'marcos.andrade@construtora.com.br',
        'almoxarife',
      );
    }

    return Usuario(
      'Ana Ribeiro',
      'ana.ribeiro@construtora.com.br',
      'funcionario',
    );
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
