import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TarefaFormPage extends StatefulWidget {
  const TarefaFormPage({super.key});

  @override
  State<TarefaFormPage> createState() => _TarefaFormPageState();
}

class _TarefaFormPageState extends State<TarefaFormPage> {
  late TextEditingController controllerDescricao;
  late TextEditingController controllerTitulo;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controllerDescricao = TextEditingController();
    controllerTitulo = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controllerDescricao.dispose();
    controllerTitulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Tarefa')),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllerTitulo,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite o Título',
                ),
                validator: (value) => _validaCampoTitulo(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controllerDescricao,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite a Descrição',
                ),
                validator: (value) => _validaCampoDescricao(),
              ),
            ),

            ElevatedButton.icon(
              onPressed: _salvarTarefa,
              label: Text("Salvar Tarefa"),
              icon: Icon(Icons.save_alt_outlined),
            ),
          ],
        ),
      ),
    );
  }

  String? _validaCampoDescricao() {
    var descricaoTarefa = controllerDescricao.text;
    if (descricaoTarefa.trim().isEmpty) {
      return 'Por favor, digite uma descrição.';
    }
    return null;
  }

  String? _validaCampoTitulo() {
    var tituloTarefa = controllerTitulo.text;
    if (tituloTarefa.trim().isEmpty) {
      return 'Por favor, digite um título.';
    }
    return null;
  }

  Future<void> _salvarTarefa() async {
    var tituloTarefa = controllerTitulo.text;
    var descricaoTarefa = controllerDescricao.text;

    if (formKey.currentState?.validate() == true) {
      var dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          baseUrl: 'https://691266ae52a60f10c8218c11.mockapi.io/api/v1',
        ),
      );

      var response = await dio.post(
        '/tarefa',
        data: {'titulo': tituloTarefa, 'descricao': descricaoTarefa},
      );
    }
  }
}
