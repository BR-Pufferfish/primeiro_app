import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:primeiro_app/models/tarefa_model.dart';
import 'package:primeiro_app/pages/tarefa_form_page.dart';
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

  bool isLoading = true;

  @override
  void initState() {
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
      var tarefa = Tarefa(
        id: data["id"],
        descricao: data['descricao'],
        titulo: data['titulo'],
      );
      tarefas.add(tarefa);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
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

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.task),
                  title: Text(tarefas[index].titulo),
                  subtitle: Text(tarefas[index].descricao),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_outlined),
                    onPressed: () => _onPressedDeleteButton(tarefas[index].id),
                  ),
                  onTap: () => _onTapEditarTarefa(tarefas[index].id),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarTarefa,
        tooltip: 'Adicionar Tarefa',
        child: Icon(Icons.add),
      ),
    );
  }

  void _adicionarTarefa() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) {
              return TarefaFormPage();
            },
          ),
        )
        .then((_) {
          tarefas.clear();
          _getTarefas();
        });
  }

  void _onPressedDeleteButton(String id) async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Deletar Registro"),
          content: Text("Deseja realmente deletar este registro?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                _excluirTarefa(id);
              },
              child: Text("Deletar"),
            ),
          ],
        );
      },
    );
  }

  void _excluirTarefa(String id) async {
    var dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        baseUrl: 'https://691266ae52a60f10c8218c11.mockapi.io/api/v1',
      ),
    );

    var response = await dio.delete('/tarefa/$id');
    if (response.statusCode == 200) {
    } else {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao deletar a tarefa.')));
    }
    Navigator.pop(context);
  }

  void _onTapEditarTarefa(String id) {
    // implemetar edição
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) {
              return TarefaFormPage(id: id);
            },
          ),
        )
        .then((_) {
          tarefas.clear();
          _getTarefas();
        });
  }
}
