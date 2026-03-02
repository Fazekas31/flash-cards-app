# 🧠 Flashcards App (Offline-First)

Um aplicativo de Flashcards moderno construído com **Flutter**, **Isar Database** (Armazenamento Local) e **Supabase** (Sincronização em Nuvem e Autenticação).

O aplicativo adota a arquitetura **Feature-First** para escalabilidade, utilizando o `flutter_bloc` para todo o gerenciamento de estado e `go_router` para navegação inteligente e redirecionamentos seguros baseados no estado do usuário.

## ✨ Features

- 📶 **Offline-First:** O aplicativo usa o `Isar` como banco de dados principal de alta performance. Os usuários podem acessar decks, criar flashcards e realizar sessões de estudo sem nenhuma conexão com a internet.
- ☁️ **Sincronização em Nuvem:** Quando há conectividade, o app sincroniza as mudanças locais para o banco em nuvem PostgreSQL (`Supabase`), de forma invisível via `SyncService`.
- 🔐 **Autenticação Segura:** Criação de conta e login seguro pela infraestrutura do `Supabase Auth`.
- 🔁 **Spaced Repetition (SM-2):** Algoritmo inteligente que ajusta dinamicamente a próxima data de revisão do cartão dependendo do progresso do usuário (Novamente, Difícil, Bom, Fácil).
- 🎴 **FlipCards UI:** Interface interativa e responsiva para a revelação das respostas.
- 🚀 **Onboarding Interativo:** Tutorial na primeira execução para ajudar usuários a entenderem o fluxo do aplicativo.

## 🛠 Tech Stack

- **Framework:** Flutter
- **State Management:** `flutter_bloc`
- **Routing:** `go_router`
- **Local DB:** `isar` (Altíssima Performance / NoSQL)
- **Backend/Auth:** `supabase_flutter` 
- **Environment:** `flutter_dotenv`

## 📂 Arquitetura (Feature-First)

```text
lib/
├── core/                   # Serviços e configurações vitais e reutilizáveis
│   ├── constants/          # Constantes globais (ex: app_constants.dart lendo do .env)
│   ├── routes/             # App Router (`go_router`) e guards
│   └── services/           # Serviços Singleton como SyncService e LocalDbService (Isar)
│
├── features/               # Domínios independentes de negócios
│   ├── auth/               # Responsável por Login, Registro e Controle de Sessão
│   ├── onboarding/         # Tela inicial de apresentação
│   ├── decks/              # Gestão de categorias (Listar, Criar, Atualizar, Deletar)
│   └── study/              # Visualização de flashcards e lógica SM-2 (Repetição Espaçada)
│
└── main.dart               # Bootstrap do Bloc, Isar, DotEnv e Supabase
```
Cada detalhe da feature (`auth`, `decks`, `study`) é dividida na tríade:
- `data/` (Repositórios concretos)
- `domain/` (Repositórios abstratos e Models do Isar `.g.dart`)
- `presentation/` (Páginas de UI, Widgets e os arquivos `Bloc`/`Event`/`State`)

---

## 🚀 Como Rodar o Projeto

Pronto para executar o aplicativo na sua máquina local ou emulador? 

### 1. Requisitos Prévios
Certifique-se de que a instalação do Flutter em sua máquina atenda aos requisitos da versão atual configurada no `pubspec.yaml` e você tenha um Emulator/Dispositivo Físico pronto.

### 2. Configurando o Supabase (Seu Backend)

1. Crie uma nova conta no [Supabase](https://supabase.com/).
2. Crie um novo projeto, e vá na engrenagem de configurações **(Project Settings) -> API**. Lá você encontrará as duas chaves que precisamos.
3. Volte na raiz do projeto Flutter e crie o arquivo `.env`:

```env
SUPABASE_URL=Sua_Project_URL
SUPABASE_ANON_KEY=Sua_Anon_Key
```

4. Vá no **SQL Editor** do Supabase e rode o script abaixo para criar as estruturas exatas necessárias:

```sql
-- 1. Cria a tabela de Decks 
create table public.decks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  name text not null,
  description text,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Cria a Tabela de Flashcards
create table public.flashcards (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  deck_id uuid references public.decks on delete cascade not null,
  question text not null,
  answer text not null,
  ease_factor double precision default 2.5 not null,
  interval_days integer default 0 not null,
  repetitions integer default 0 not null,
  due_date timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Habilita Políticas RLS para Segurança de Dados Pessoais
alter table public.decks enable row level security;
alter table public.flashcards enable row level security;

-- (Crie as policies permitindo usuários logados manipularem APENAS dados correspondentes à coluna user_id)
create policy "Pode inserir cards próprios" on public.flashcards for insert with check ( auth.uid() = user_id );
```

### 3. Rodando o Projeto

```sh
# Baixe os pacotes
flutter pub get

# Gere os arquivos automatizados Isar (*.g.dart)
flutter pub run build_runner build --delete-conflicting-outputs

# Execute no Device
flutter run
```

---

## 🧪 Testes
Para confirmar a integridade e precisão estrita do algoritmo de Pontuação `SM-2` da Sessão de Estudos, os testes foram escritos na pasta `/test`:

```sh
flutter test test/scoring_test.dart
```
