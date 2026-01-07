# shopping_list

App para gerenciar seus gastos mensais

# comandos apos clonar o repositorio

- flutter pub get
- flutter gen-l10n
- flutter run

# caso os icones não sejam carregados, use:
- flutter pub run flutter_launcher_icons 

# o ios 26.1 ta com bug, para rodar no ios use

- flutter run --profile

## Mudanças recentes

- Suporte a novos idiomas: Alemão (`de`), Italiano (`it`), Japonês (`ja`), Coreano (`ko`), Polonês (`pl`), Russo (`ru`), Chinês Simplificado (`zh_Hans`) e Chinês Tradicional (`zh_Hant`).
- Chinês com variantes de script: adicionados arquivos ARB `app_zh.arb` (fallback), `app_zh_Hans.arb` e `app_zh_Hant.arb`; tratamento de `Locale.fromSubtags` no gerenciador de tema.
- Seletor de idiomas atualizado: inclusão das novas opções e correção de overflow (conteúdo do `AlertDialog` agora é rolável).
- Geração de localizações atualizada (`flutter gen_l10n`) com todas as traduções.

### Observações

- Se a lista de idiomas exceder a altura do diálogo, a rolagem garante acesso a todas as opções sem erros de layout.
