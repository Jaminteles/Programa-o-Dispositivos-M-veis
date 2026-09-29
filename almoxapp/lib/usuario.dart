/// Usuario logado no aplicativo. Os dados chegam prontos do [Autenticador],
/// por isso a classe só guarda os valores e os expõe por getters.
class Usuario {
  final String _nome;
  final String _email;
  final String _perfil;

  Usuario(this._nome, this._email, this._perfil);

  String get nome => _nome;
  String get email => _email;
  String get perfil => _perfil;

  /// O almoxarife é quem aprova, recusa e entrega as requisições.
  bool get ehAlmoxarife => _perfil == 'almoxarife';
}
