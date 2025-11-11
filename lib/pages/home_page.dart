import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:primeiro_app/models/tarefa_model.dart';
import 'package:primeiro_app/widgets/subtitulo_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.subtitulo});

  final String title;
  final String subtitulo;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Tarefa> tarefas = [];

  late TextEditingController controllerDescricao;
  late TextEditingController controllerTitulo;

  bool isLoading = true;

  @override
  void initState() {
    controllerDescricao = TextEditingController();
    controllerTitulo = TextEditingController();

    _getTarefas();

    super.initState();
  }

  Future<void> _getTarefas() async {
    setState(() {
      isLoading = true;
    });

    var dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        baseUrl: 'https://691266ae52a60f10c8218c11.mockapi.io/api/v1',
      ),
    );

    var response = await dio.get('/tarefa');

    var listaData = response.data as List;

    for (var data in listaData) {
      var tarefa = Tarefa(descricao: data['descricao'], titulo: data['titulo']);
      tarefas.add(tarefa);
    }
    setState(() {});
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Text(widget.title),
            SizedBox(width: 8),
            SubtituloWidget(label: widget.subtitulo),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: controllerTitulo,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Digite o Título',
              ),
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
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.task),
                  title: Text(tarefas[index].titulo),
                  subtitle: Text(tarefas[index].descricao),
                  trailing: Icon(Icons.arrow_right_alt_outlined),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarTarefa,
        tooltip: 'Adicionar Tarefa',
        child: Icon(Icons.add),
      ),
    );
  }

  void _adicionarTarefa() {
    var tituloTarefa = controllerTitulo.text;
    var descricaoTarefa = controllerDescricao.text;
    if (tituloTarefa.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Por favor, digite um titulo.')));
      return;
    }

    if (descricaoTarefa.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, digite uma descrição.')),
      );
      return;
    }

    var tarefa = Tarefa(descricao: descricaoTarefa, titulo: tituloTarefa);

    setState(() {
      tarefas.add(tarefa);
    });

    controllerDescricao.clear();
    controllerTitulo.clear();
  }
}
