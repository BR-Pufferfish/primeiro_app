import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:primeiro_app/models/tarefa_model.dart'; // Added import

class TarefaFormPage extends StatefulWidget {
  final String? id; // Added id parameter
  const TarefaFormPage({super.key, this.id});

  @override
  State<TarefaFormPage> createState() => _TarefaFormPageState();
}

class _TarefaFormPageState extends State<TarefaFormPage> {
  late TextEditingController controllerDescricao;
  late TextEditingController controllerTitulo;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Tarefa? _tarefa; // Added Tarefa object

  @override
  void initState() {
    controllerDescricao = TextEditingController();
    controllerTitulo = TextEditingController();
    if (widget.id != null) {
      _loadTarefa(widget.id!); // Load task if id is provided
    }
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
      appBar: AppBar(
        title: Text(widget.id == null ? 'Cadastrar Tarefa' : 'Editar Tarefa'),
      ),
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

      if (widget.id == null) {
        // Create new task
        await dio.post(
          '/tarefa',
          data: {'titulo': tituloTarefa, 'descricao': descricaoTarefa},
        );
      } else {
        // Update existing task
        await dio.put(
          '/tarefa/${widget.id}',
          data: {'titulo': tituloTarefa, 'descricao': descricaoTarefa},
        );
      }

      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _loadTarefa(String id) async {
    var dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        baseUrl: 'https://691266ae52a60f10c8218c11.mockapi.io/api/v1',
      ),
    );

    var response = await dio.get('/tarefa/$id');
    if (response.statusCode == 200) {
      setState(() {
        _tarefa = Tarefa.fromJson(response.data);
        controllerTitulo.text = _tarefa!.titulo;
        controllerDescricao.text = _tarefa!.descricao;
      });
    } else {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar a tarefa.')));
    }
  }
}
