import 'package:flutter/material.dart';
import 'package:anotacoesbd/helper/AnotacaoHelper.dart';
import 'model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Criando os controladores
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  var _db = AnotacaoHelper();

  //Lista de anotações
  List<Anotacao?> _anotacoes = []; //List<Anotacao>();

  //Criando os menus do sistema. Passando parâmetro opcional para Editar
  _exibirTelaCadastro({Anotacao? anotacao}) {
    String textoSalvarAtualizar = "";

    //Caso seja vazio estou adicionando. Caso contrário Alterando
    if (anotacao == null) {
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";
    } else {
      _tituloController.text = anotacao.titulo!;
      _descricaoController.text = anotacao.descricao!;
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("$textoSalvarAtualizar"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _tituloController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: "Título",
                      hintText: "Digite título...",
                    ),
                  ),
                  TextField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a descrição",
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text("Cancelar"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  onPressed: () {
                    //Salvar
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                    Navigator.pop(context);
                  },
                  child: Text(textoSalvarAtualizar),
                ),
              ]);
        });
  }

  //Método para recuperar as anotações
  _recuperarAnotacoes() async {
    //_anotacoes.clear();
    List anotacoesrecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao>? listaTemporaria = [];
    //List<Anotacao> listaTemporaria = List<Anotacao>();

    for (var item in anotacoesrecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);

      listaTemporaria.add(anotacao);
    }
    setState(() {
      _anotacoes = listaTemporaria!;
    });

    listaTemporaria = null;

    print("Lista Anotacoes: " + anotacoesrecuperadas.toString());
  }

  //Método remover anotação
  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);

    //Atualizar as anotações
    _recuperarAnotacoes();
  }

  //Método Salvar Anotação
  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    //print("data atual: "+DateTime.now().toString());

    if (anotacaoSelecionada == null) {
      //Salvar
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      int? resultado = await _db.salvarAnotacao(anotacao);
    } else {
      //Atualizando

      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();

      int? resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }
    //print("salvar anotação: " + resultado.toString());

    //Limpando os textos
    _tituloController.clear();
    _descricaoController.clear();

    //Método para recuperar anotações quando faz o salvamento
    _recuperarAnotacoes();
  }

  //Método para formatar Data em Português
  _formatarData(String data) {
    initializeDateFormatting("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);

    var formatador = DateFormat("d/M/y kk:mm:ss aaa");
    // var formatador = DateFormat.yMMMd("pt_BR");
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  /* Método para exibir um alert Dialog
  _confirmaExclusao(BuildContext context){
  Widget cancelButton =
  TextButton(onPressed: ()=> Navigator.pop(context),
      child: Text("Cancelar")
  );

  Widget continueButton =
  TextButton(onPressed: (){},
      child: Text("Excluir")
  );
  AlertDialog alert = AlertDialog(
    title: Text("Exclusão"),
    content: Text("Tem certeza que deseja excluir ?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  showDialog(context: context,
      builder: (BuildContext context){
    return alert;
  },
  );
  }
*/
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    //Testando a recuperação dos dados
    //_recuperarAnotacoes();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anotações com Banco de Dados"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _anotacoes.length,
                  itemBuilder: (context, index) {
                    final item = _anotacoes[index];
                    return Card(
                      elevation: 5,
                      child: ListTile(
                        title: Text(item!.titulo.toString()),
                        subtitle: Text(
                            "${_formatarData(item.data.toString())} - ${item.descricao}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            //Editar
                            GestureDetector(
                              onTap: () {
                                _exibirTelaCadastro(anotacao: item);
                              },
                              child: const Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                  )),
                            ),
                            //Botão de Delete
                            GestureDetector(
                              onTap: () {
                                // _confirmaExclusao(this.context);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return  AlertDialog(
                                      title: const Text("Confirmação"),
                                      content: const Text(
                                        "Tem certeza que deseja Excluir ? ",
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Não"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _removerAnotacao(item.id!);
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Sim"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Padding(
                                  padding: EdgeInsets.only(right: 0),
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    );
  }
}
