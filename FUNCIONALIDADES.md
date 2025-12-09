# 📱 Funcionalidades do App - Lista de Compras

## 🎯 Visão Geral
Aplicativo Flutter para gerenciamento de despesas e lista de compras, com controle financeiro completo, relatórios detalhados e suporte multilíngue.

---

## 📋 Funcionalidades Principais

### 1. **Gerenciamento de Produtos**

#### ➕ Adicionar Produtos
- Cadastro de produtos com nome, quantidade e categoria
- 10 categorias disponíveis:
  - 🍎 Alimentos
  - 🥤 Bebidas
  - 💻 Tecnologia
  - 🏠 Contas de Casa
  - 🧴 Higiene Pessoal
  - 🧹 Limpeza
  - 👕 Vestuário
  - 💊 Saúde
  - 🎮 Entretenimento
  - 📦 Outros

#### ✏️ Editar Produtos
- Atualização de informações de produtos existentes
- Modificação de nome, quantidade, categoria e preço
- Edição da loja (para produtos comprados)

#### 🗑️ Excluir Produtos
- Exclusão individual de produtos
- Exclusão em lote (modo de seleção múltipla)
- Confirmação antes de excluir

#### ✅ Marcar como Comprado
- Registro de compra com preço unitário
- Campo opcional para informar a loja
- Data e hora automática da compra
- Cálculo automático do valor total (preço × quantidade)

---

### 2. **Abas de Navegação**

#### 🛒 Aba "Comprar"
- Lista de produtos a comprar
- Botão flutuante para adicionar novos produtos
- Botão para importar produtos do mês anterior
- Botão para ativar modo de seleção múltipla
- Pressão longa em um item para iniciar seleção
- Marcar produtos como comprados com diálogo de preço

#### 🛍️ Aba "Comprados"
- Visualização de produtos já comprados
- Filtros disponíveis:
  - 📅 Todos
  - 📆 Hoje
  - 📊 Este Mês
  - 📈 Este Ano
  - 🗓️ Dia Específico (com seletor de data)
- Exibição de preço e data de compra
- Modo de seleção múltipla para exclusão

#### 📊 Aba "Relatórios"
- Visualização mensal ou diária de gastos
- Navegação entre meses/dias com setas
- Gráficos e estatísticas detalhadas

---

### 3. **Sistema de Relatórios**

#### 💰 Controle de Salário
- Definição de salário mensal
- Cálculo automático de:
  - Valor restante do salário
  - Percentual gasto (com código de cores)
    - 🟢 Verde: até 80% gasto
    - 🟠 Laranja: 80% a 100% gasto
    - 🔴 Vermelho: acima de 100% gasto

#### 📈 Gráfico de Evolução
- Gráfico de linha mostrando evolução dos gastos
- Últimos 6 meses de histórico
- Valores formatados por categoria
- Tooltip interativo com detalhes

#### 🥧 Gráfico de Pizza (Distribuição)
- Distribuição de gastos por categoria
- Percentuais calculados automaticamente
- Cores distintas para cada categoria
- Exibição do valor restante do salário (se definido)
- Legenda com valores em moeda local

#### 📋 Lista Detalhada por Categoria
- Agrupamento de produtos por categoria
- Total gasto por categoria
- Quantidade de itens por categoria
- Lista expansível de produtos individuais

---

### 4. **Importação de Dados**

#### 🔄 Importar do Mês Anterior
- Busca automática de produtos comprados no mês anterior
- Seleção múltipla de produtos para importar
- Importação como novos itens "a comprar"
- Contador de produtos importados

---

### 5. **Backup e Restauração**

#### 💾 Criar Backup
- Exportação de todos os dados em formato JSON
- Nome de arquivo com timestamp automático
- Salvamento em local escolhido pelo usuário
- Exibição do caminho do último backup

#### 📥 Importar Dados
- Importação de arquivos JSON
- Restauração completa de produtos e histórico
- Contador de itens importados
- Validação de formato

---

### 6. **Configurações**

#### 🌓 Tema
- **Modo Claro**: Interface clara e moderna
- **Modo Escuro**: Interface escura para reduzir cansaço visual
- Persistência da preferência do usuário
- Transição suave entre temas

#### 🌍 Idiomas Suportados
- 🇧🇷 Português (Brasil)
- 🇺🇸 Inglês
- 🇪🇸 Espanhol
- 🇫🇷 Francês
- 🇩🇪 Alemão
- 🇮🇹 Italiano
- 🇯🇵 Japonês
- 🇰🇷 Coreano
- 🇵🇱 Polonês
- 🇷🇺 Russo
- 🇨🇳 Chinês Simplificado
- 🇹🇼 Chinês Tradicional
- Opção de usar idioma do sistema

#### 💱 Moedas Automáticas
- Formatação automática baseada no idioma:
  - R$ (Real Brasileiro)
  - $ (Dólar)
  - € (Euro)
  - ¥ (Iene/Yuan)
  - ₩ (Won)
  - zł (Zloty)
  - ₽ (Rublo)
  - NT$ (Dólar de Taiwan)

---

### 7. **Interface e Experiência do Usuário**

#### 🎨 Design Moderno
- Material Design 3
- Animações suaves e fluidas
- Splash screen animada
- Transições de página com PageView
- Diálogos com animações customizadas

#### 📱 Responsividade
- Suporte para Android e iOS
- Taxa de atualização alta (high refresh rate) no Android
- Interface adaptativa para diferentes tamanhos de tela

#### ✨ Modo de Seleção
- Ativação por pressão longa ou botão
- Seleção múltipla de itens
- Botão "Selecionar Todos"
- Contador de itens selecionados
- Barra de ação contextual
- Exclusão em lote

#### 🎯 Navegação Intuitiva
- Bottom Navigation Bar com 3 abas
- Ícones claros e descritivos
- Indicador visual da aba selecionada
- Menu de opções no AppBar

---

### 8. **Armazenamento de Dados**

#### 💾 Banco de Dados Local
- SQLite para persistência de dados
- Tabelas:
  - **products**: Produtos e compras
  - **salaries**: Salários mensais
- Operações CRUD completas
- Queries otimizadas com filtros

#### 📊 Estrutura de Dados
- **Product**:
  - ID único
  - Nome
  - Quantidade
  - Categoria
  - Preço
  - Status de compra
  - Data de criação
  - Data de compra

---

### 9. **Recursos Adicionais**

#### 🎨 Fundo Personalizado
- Fundo decorativo com ícones de compras
- Adaptação automática ao tema (claro/escuro)
- Efeito visual agradável

#### 🔔 Notificações
- SnackBars informativos para ações
- Feedback visual de sucesso/erro
- Mensagens localizadas

#### 📅 Formatação de Datas
- Formato adaptado ao idioma selecionado
- Suporte a diferentes calendários
- Exibição amigável de datas

---

## 🛠️ Tecnologias Utilizadas

### Framework e Linguagem
- **Flutter** 3.7.2+
- **Dart** 3.7.2+

### Principais Dependências
- `provider` - Gerenciamento de estado
- `sqflite` - Banco de dados local
- `fl_chart` - Gráficos e visualizações
- `intl` - Internacionalização e formatação
- `file_picker` - Seleção de arquivos
- `flutter_file_dialog` - Diálogos de arquivo
- `shared_preferences` - Preferências do usuário
- `flutter_displaymode` - Controle de taxa de atualização

---

## 📦 Estrutura do Projeto

```
lib/
├── database/
│   └── database_helper.dart          # Gerenciamento do SQLite
├── models/
│   └── product.dart                  # Modelo de dados Product
├── providers/
│   ├── product_provider.dart         # Estado dos produtos
│   ├── selection_provider.dart       # Estado da seleção múltipla
│   └── theme_provider.dart           # Estado do tema e idioma
├── screens/
│   ├── to_buy_tab.dart              # Aba de produtos a comprar
│   ├── purchased_tab.dart           # Aba de produtos comprados
│   ├── reports_tab.dart             # Aba de relatórios
│   └── settings_screen.dart         # Tela de configurações
├── widgets/
│   ├── add_product_dialog.dart      # Diálogo de adicionar/editar
│   ├── purchase_dialog.dart         # Diálogo de compra
│   ├── salary_dialog.dart           # Diálogo de salário
│   ├── import_previous_month_dialog.dart  # Diálogo de importação
│   ├── product_card.dart            # Card de produto
│   └── shopping_background.dart     # Fundo decorativo
└── main.dart                         # Ponto de entrada
```

---

## 🎯 Casos de Uso Principais

### Fluxo 1: Adicionar e Comprar Produto
1. Usuário abre a aba "Comprar"
2. Clica no botão "+" flutuante
3. Preenche nome, quantidade e categoria
4. Produto aparece na lista
5. Ao comprar, clica no botão de confirmação
6. Informa o preço unitário
7. Produto move para aba "Comprados"

### Fluxo 2: Controle Mensal de Gastos
1. Usuário define salário do mês na aba "Relatórios"
2. Compra produtos ao longo do mês
3. Visualiza em tempo real:
   - Total gasto
   - Valor restante
   - Percentual gasto
4. Analisa gráficos de distribuição por categoria

### Fluxo 3: Importar Lista do Mês Anterior
1. Usuário abre aba "Comprar"
2. Clica no botão de histórico (se disponível)
3. Seleciona produtos do mês anterior
4. Confirma importação
5. Produtos aparecem como "a comprar"

### Fluxo 4: Backup e Restauração
1. Usuário acessa Configurações
2. Cria backup (exporta JSON)
3. Em outro momento/dispositivo
4. Importa o arquivo JSON
5. Todos os dados são restaurados

---

## 🌟 Diferenciais

✅ **Completamente Offline** - Funciona sem internet  
✅ **Multilíngue** - 12 idiomas suportados  
✅ **Controle Financeiro** - Gestão de salário e gastos  
✅ **Relatórios Visuais** - Gráficos interativos  
✅ **Backup Completo** - Exportação/Importação de dados  
✅ **Interface Moderna** - Material Design 3  
✅ **Modo Escuro** - Conforto visual  
✅ **Seleção Múltipla** - Operações em lote  
✅ **Importação Inteligente** - Reutilização de listas anteriores  

---

## 📝 Notas Técnicas

- Persistência de dados com SQLite
- Arquitetura Provider para gerenciamento de estado
- Internacionalização completa com flutter_localizations
- Formatação de moeda e data adaptativa
- Animações customizadas para melhor UX
- Suporte a high refresh rate no Android
- Validação de dados em todas as operações
