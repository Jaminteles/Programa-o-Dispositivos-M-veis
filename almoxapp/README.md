# AlmoxApp

Trabalho da disciplina de Programação para Dispositivos Móveis (IFBA).

## Tema

O AlmoxApp simula o **almoxarifado de uma construtora**. Os funcionários solicitam
materiais para as obras e acompanham o andamento do pedido; o almoxarife aprova,
recusa ou marca a requisição como entregue.

Cada requisição tem um número, a obra de destino, o solicitante, a data, uma
justificativa, a lista de materiais com as quantidades e um dos quatro status:

| Status | Significado |
| --- | --- |
| Pendente | Aguardando a análise do almoxarife |
| Aprovada | Liberada, aguardando a entrega na obra |
| Recusada | Negada pelo almoxarife |
| Entregue | Material já retirado/entregue |

O aplicativo é **apenas front-end**: não existe servidor. Os dados iniciais são
lidos de arquivos JSON em `recursos/jsons/` e todas as alterações feitas durante
o uso (novas requisições, comentários, mudanças de status) ficam guardadas em
memória, no `GerenciadorEstado`. Ao fechar o aplicativo, tudo volta ao estado
original dos arquivos.

## Telas

1. **Requisições** (tela inicial) — lista das requisições com número, obra,
   solicitante, data e status (cada status tem cor e ícone próprios). Tem filtro
   na AppBar por número ou por nome da obra, atalho para o Estoque e o botão de
   entrar/sair. O botão flutuante "Nova requisição" só aparece para quem está
   logado. Puxar a lista para baixo recarrega os dados.
2. **Detalhes** — materiais pedidos, justificativa, status e comentários.
   Traz o botão de compartilhar o resumo (share_plus). Quem está logado pode
   comentar e apagar os próprios comentários (arrastando para a esquerda, com
   confirmação SIM/NÃO); o dono da requisição pode cancelá-la enquanto estiver
   pendente; o almoxarife vê os botões Aprovar, Recusar e Marcar como entregue.
3. **Nova requisição** — só para quem está logado: escolhe a obra, inclui os
   materiais com as quantidades, escreve a justificativa e envia.
4. **Estoque** — materiais do almoxarifado com unidade e saldo, em grade, com
   filtro por nome. Pode ser consultado sem login.

A troca de telas é feita pelo estado global (`enum EmExibicao`), sem
`Navigator.push` e sem rotas nomeadas.

## Usuários de teste

Não existe tela de login: toque no ícone de entrar (canto direito da AppBar da
tela de Requisições) e escolha o perfil. Não há senha.

| Perfil | Nome | E-mail | O que pode fazer |
| --- | --- | --- | --- |
| Funcionário | Ana Ribeiro | ana.ribeiro@construtora.com.br | Criar requisição, comentar, apagar os próprios comentários, cancelar as próprias requisições pendentes |
| Almoxarife | Marcos Andrade | marcos.andrade@construtora.com.br | Tudo o que o funcionário faz, mais aprovar, recusar e marcar como entregue |

Sem login, o visitante ainda consegue consultar a lista de requisições, filtrar
pelo número ou pela obra, abrir os detalhes e ver o estoque.

Dicas para testar:

- **Cancelar a própria requisição**: entre como Ana Ribeiro e abra a
  REQ-2026-003 (pendente e dela).
- **Apagar o próprio comentário**: os comentários de Ana Ribeiro estão nas
  requisições 1, 3 e 7; os de Marcos Andrade, nas requisições 1, 2, 4 e 8.
  Arraste o comentário da direita para a esquerda.
- **Aprovar/recusar**: entre como Marcos Andrade e abra qualquer requisição
  pendente (REQ-2026-003, REQ-2026-005 ou REQ-2026-008).

## Como executar

Pré-requisito: Flutter instalado (`flutter doctor` sem erros) e um emulador
Android aberto (ou um aparelho conectado com a depuração USB ligada).

Dentro da pasta `almoxapp/`:

```bash
flutter pub get
```

```bash
flutter run
```

Para conferir se não há erros ou avisos de análise:

```bash
flutter analyze
```

> **Atenção:** mantenha o projeto em um caminho **sem acentos e sem espaços
> acentuados** (por exemplo `C:\dev\...`). O Android Gradle Plugin recusa
> caminhos com caracteres não-ASCII (`Your project path contains non-ASCII
> characters`) e o analysis server do Flutter também quebra neles.

Se a pasta `android/` for perdida, ela pode ser gerada de novo com
`flutter create . --platforms=android --project-name almoxapp`, que não altera
`lib/`, `recursos/` nem `pubspec.yaml`.

## Estrutura

```
almoxapp/
├── lib/
│   ├── main.dart                  # ChangeNotifierProvider + TelaPrincipal
│   ├── gerenciador_estado.dart    # EmExibicao, GerenciadorEstado, estadoApp
│   ├── autenticador.dart          # login/logout simulados
│   ├── usuario.dart               # dados do usuário logado
│   ├── estilo_status.dart         # rótulo, cor e ícone de cada status
│   ├── telas/
│   │   ├── tela_requisicoes.dart
│   │   ├── tela_detalhes.dart
│   │   ├── tela_nova_requisicao.dart
│   │   └── tela_estoque.dart
│   └── componentes/
│       ├── card_requisicao.dart
│       ├── card_material.dart
│       ├── card_item.dart
│       └── card_comentario.dart
└── recursos/
    ├── jsons/
    │   ├── materiais.json         # 15 materiais (nome, unidade, saldo)
    │   ├── obras.json             # 3 obras
    │   ├── requisicoes.json       # 8 requisições em status variados
    │   └── comentarios.json       # 10 comentários
    └── imagens/
        └── logo.png
```

## Pacotes usados

`provider` (estado global), `toast` (mensagens rápidas), `share_plus`
(compartilhar o resumo da requisição), `intl` (datas no formato
`dd/MM/yyyy HH:mm`) e `cupertino_icons`.
