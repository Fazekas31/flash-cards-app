import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:typed_data';

class GeminiAiService {
  late GenerativeModel _model;

  GeminiAiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY não localizada. Verifique o arquivo .env',
      );
    }

    // TENTATIVA 1: Use 'gemini-1.5-pro' (mais estável)
    // TENTATIVA 2: Se o erro persistir, mude para 'gemini-pro'
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<String> explainFlashcardTheme(
    String question,
    String answer, {
    bool isError = false,
  }) async {
    final contextPrompt = isError
        ? "O aluno acabou de INFORMAR QUE ERROU este flashcard. Dê um incentivo rápido e amigável e explique o conceito de forma simples para que ele compreenda o erro e acerte na próxima vez."
        : "O aluno quer saber um pouco mais sobre o contexto dessa resposta. Vá um pouco além da simples resposta.";

    final prompt =
        '''
    Aja como um professor particular altamente prestativo que está ensinando um estudante por meio de Flashcards do método de repetição espaçada.

    Abaixo, temos o conteúdo de um cartão de estudo de um aluno que acabou de revelar a resposta:
    Pergunta: "$question"
    Resposta associada: "$answer"

    Contexto da requisição: $contextPrompt

    Sua tarefa: Fornecer uma breve explicação super didática. Explique **POR QUE** essa é a resposta para a pergunta, fornecendo uma pequena curiosidade, fórmula ou fato atrelado para ajudar a "cimentar" o aprendizado na memória de longo prazo do aluno.
    
    Orientações de Formatação:
    * Mantenha seu texto em menos de 200 palavras.
    * Use texto **Markdown** (negritos, itálicos, bullet points). 
    * Não use tags HTML.
    * Pule introduções extensas e seja direto.
    * **OBRIGATÓRIO:** Pule uma linha no final da explicação e forneça pelo menos 1 (um) link de fonte confiável da internet onde o usuário pode ler mais sobre a sua explicação. Formate o link exatamente assim: `[Nome do Artigo/Site](https://www....)`
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        return 'Nenhuma resposta elaborada pela IA no momento.';
      }

      return response.text!;
    } catch (e) {
      return 'Erro técnico: O modelo selecionado não foi reconhecido ou há um problema na Key. Detalhes: $e';
    }
  }

  Future<List<Map<String, String>>> generateFlashcards({
    String? contextText,
    Uint8List? fileBytes,
    String? mimeType,
  }) async {
    final prompt =
        '''
    Aja como um criador e especialista de flashcards de repetição espaçada. O usuário fornecerá um texto, arquivo ou imagem com anotações.
    Sua tarefa é extrair as informações e conceitos mais importantes do material fornecido e transformá-los em até 15 cartões de pergunta e resposta diretas para memorização.
    
    ${contextText != null && contextText.isNotEmpty ? 'O texto base de estudo acompanhando é:\n"{ $contextText }"' : ''}
    
    **CRÍTICO:** Sua resposta OBRIGATORIAMENTE deve ser um "array" JSON limpo estruturando objetos com as chaves exatas "question" e "answer".
    Não utilize introduções de diálogo nem markdown (` ```json `), apenas retorne a lista pronta para os parsers do Dart lerem.
    
    Exemplo Escrito Exato para você seguir:
    [
      {"question": "Qual a capital do Brasil?", "answer": "Brasília"},
      {"question": "Quem formulou a Teoria da Relatividade?", "answer": "Albert Einstein"}
    ]
    ''';

    try {
      final parts = <Part>[TextPart(prompt)];

      if (fileBytes != null && mimeType != null) {
        parts.add(DataPart(mimeType, fileBytes));
      }

      final content = [Content.multi(parts)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('Sem resposta do Gemini.');
      }

      // Evita vazamento se o Gemini insistir no markdown apesar das instruções
      final cleanText = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final List<dynamic> decodedList = jsonDecode(cleanText);

      return decodedList
          .map(
            (item) => {
              "question": item["question"].toString(),
              "answer": item["answer"].toString(),
            },
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Não foi possível gerar os cartões. O texto enviado pode estar muito confuso ou houve falha na formatação. Detalhes: $e',
      );
    }
  }
}
