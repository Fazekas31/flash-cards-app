# 🧠 Alfa Study Cards (Supabase-First)

Um aplicativo de Flashcards moderno e inteligente construído com **Flutter** e **Supabase** (Sincronização em Nuvem e Autenticação).

O aplicativo adota a arquitetura **Feature-First** para escalabilidade, utilizando o `flutter_bloc` para todo o gerenciamento de estado e `go_router` para navegação inteligente e redirecionamentos seguros baseados no estado do usuário. Efetua cálculos e carregamentos de forma dinâmica em nuvem para garantir a persistência imediata dos seus estudos.

## ✨ Features

- ☁️ **Supabase-First:** O aplicativo se conecta diretamente ao banco de dados PostgreSQL na nuvem do Supabase, lendo e escrevendo categorias e flashcards em tempo real, garantindo que seu progresso jamais seja perdido.
- 🔐 **Autenticação Segura:** Criação de conta e login seguro pela infraestrutura nativa do `Supabase Auth`.
- 🔁 **Spaced Repetition (SM-2):** Algoritmo inteligente que ajusta dinamicamente a próxima data de revisão do cartão dependendo do progresso do usuário (Novamente, Difícil, Bom, Fácil).
- 🖼️ **Suporte a Imagens:** Anexe fotos da galeria ou câmera diretamente nos seus flashcards para uma experiência de estudo mais visual.
- 📄 **Suporte a Arquivos PDF:** Importe materiais de estudo em PDF diretamente no aplicativo via File Picker.
- 🔄 **Animações de Cartão (Flip):** Os flashcards possuem animações de virada (flip) fluidas para revelar as respostas com elegância.
- 📁 **Organização por Categorias:** Agrupe seus flashcards em "Decks" (baralhos) temáticos para facilitar o foco em determinadas matérias.
- 🤖 **Professor Particular de IA (Gemini):** Integração com o Google Gemini 2.5 Flash! É possível gerar centenas de cartões de uma vez anexando seus PDFs, e se você errar um cartão ou pedir uma explicação extra durante os estudos, a IA entra em ação fornecendo contexto didático, Markdown estruturado e até hiperlinks da internet.
- 🌍 **Internacionalização (i18n):** Suporte nativo completo a Inglês (EN) e Português do Brasil (PT-BR) rodando e reagindo em tempo real ao layout e interações da Inteligência Artificial.
- 🎨 **UI/UX Modernizado:** Customização completa de Tema, Paleta de Cores, Sombras (Elevation), App Icon nativo e Splash Screen de Bootup (Design System focado no estudante).
- 🚀 **Onboarding Interativo:** Tutorial na primeira execução para ajudar usuários a entenderem o fluxo do aplicativo.

## 🛠 Tech Stack

- **Framework:** Flutter
- **State Management:** `flutter_bloc`
- **Routing:** `go_router`
- **Backend/Auth/DB:** `supabase_flutter` 
- **AI Integration:** `google_generative_ai` (Gemini API)
- **Localizations:** `flutter_localizations`
- **Environment:** `flutter_dotenv`

## 📂 Arquitetura (Feature-First)

```text
lib/
├── core/                   # Serviços e configurações vitais e reutilizáveis
│   ├── constants/          # Constantes globais (ex: app_constants.dart lendo do .env)
│   ├── routes/             # App Router (`go_router`) e guards de redirecionamento (Supabase Auth)
│   └── services/           # Serviços base (Supabase client, GeminiAiService)
│
├── features/               # Domínios independentes de negócios
│   ├── auth/               # Responsável por Login, Registro e Controle de Sessão no BLoC
│   ├── onboarding/         # Tela inicial de apresentação
│   ├── decks/              # Gestão de categorias em DB remoto (Listar, Criar, Atualizar, Deletar)
│   └── study/              # Visualização de flashcards em memória e recálculo algorítimo SM-2 na nuvem
│
└── main.dart               # Bootstrap do Bloc, DotEnv, i18n e conector do Supabase.initialize()
```

---

## 🚀 Como Rodar o Projeto

Pronto para executar o aplicativo na sua máquina local ou emulador? 

### 1. Requisitos Prévios
Certifique-se de que a instalação do Flutter em sua máquina atenda aos requisitos da versão e você tenha um Emulator/Dispositivo Físico configurado (.

### 2. Configurando o Backend e Inteligência Artificial

1. Crie uma nova conta no [Supabase](https://supabase.com/).
2. Crie um novo projeto, e vá na engrenagem de configurações **(Project Settings) -> API**. Lá você encontrará a URL e a Anon Key.
3. Para ativar o professor da IA, pegue uma Chave Gratuita em [Google AI Studio](https://aistudio.google.com).
4. Volte na raiz do projeto Flutter e crie o arquivo `.env`:

```env
SUPABASE_URL=Sua_Project_URL
SUPABASE_ANON_KEY=Sua_Anon_Key
GEMINI_API_KEY=Sua_Key_AizaSy...
```

5. Vá no **SQL Editor** do Supabase e rode o script inicial padrão do projeto:

```sql
-- 1. Cria a Tabela de Decks (Categorias)
create table if not exists public.decks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  name text not null,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  is_deleted boolean default false not null
);

-- 2. Cria a Tabela de Flashcards
create table if not exists public.flashcards (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  deck_id uuid references public.decks on delete cascade not null,
  question text not null,
  answer text not null,
  image_path text,
  ease_factor double precision default 2.5 not null,
  interval_days integer default 0 not null,
  repetitions integer default 0 not null,
  due_date timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  is_deleted boolean default false not null
);

-- 3. Habilita Políticas RLS para Segurança de Dados Pessoais (Opcional/Recomendado)
alter table public.decks enable row level security;
alter table public.flashcards enable row level security;

-- (Crie as policies para seu RLS permitindo que auth.uid() = user_id)
```

### 3. Executando o Projeto

```sh
# Baixe todos os pacotes das features e plugins
flutter pub get

# Gere os arquivos de traduções automatizadas AppLocalizations (i18n)
flutter gen-l10n

# Execute no Device
flutter run
```

---

## 🧪 Testes

A estabilidade matemática do algoritmo de repetição passará por testes para nos assegurar de cálculos puros dentro do BlOC e dos repositórios:

```sh
# Teste o comportamento puro do algoritmo de estudo Spaced Repetition interagindo com a interface
flutter test test/scoring_test.dart
```
