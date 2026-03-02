import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<String> explainFlashcardTheme(String question, String answer) async {
    final prompt =
        '''
    Aja como um professor particular altamente prestativo que está ensinando um estudante por meio de Flashcards do método de repetição espaçada.

    Abaixo, temos o conteúdo de um cartão de estudo de um aluno que acabou de revelar a resposta:
    Pergunta: "$question"
    Resposta associada: "$answer"

    Sua tarefa: Fornecer uma breve explicação de contextualização super didática que vá um pouco além da simples resposta. Explique **POR QUE** essa é a resposta para a pergunta, fornecendo uma pequena curiosidade, fórmula ou fato atrelado para ajudar a "cimentar" o aprendizado na memória de longo prazo do aluno.
    
    Orientações de Formatação:
    * Mantenha seu texto em menos de 200 palavras.
    * Use texto **Markdown** (negritos, itálicos, bullet points). 
    * Não use tags HTML.
    * Pule introduções extensas e seja direto.
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
}
