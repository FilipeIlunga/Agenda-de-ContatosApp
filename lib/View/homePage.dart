import 'dart:io';
import 'package:agenda_de_contatos/helper/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contactPage.dart';

//enum = conjunto de constantes
enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  int _lastRemovedPos;
  Contact _lastRemoved;

  //lista de contatos para a listView
  List<Contact> contacts = List();

  //Quando o app iniciar, primeiramente será carregado todos os contatos que já
  // estao salvos
  // Para isso chamaremos o iniState usado quando a tela inicia

  @override
  void initState() {
    super.initState();
    //then vai esperar a função(getAllContats) retornar os dados e quando a função retornar os
    // dados ela irá chamar a função de dentro(funcao anonima)
    // a nossa lista de contatos declarada em cima
    //será igual a lista inicializada do banco de dados
    _getAllContacts();
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      print(list);
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.purple,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de A-Z'),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de Z-A'),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Chamar o ContactPage sem nenhum parâmetro, pois estamos criando um contato
          // e não editando contato
          _showContactPage();
        },
        child: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.purple,
      ),
      body: contacts.isEmpty
          ? SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.purple[100], BlendMode.modulate),
                      child: Image(
                        image: AssetImage("assets/image/emptyState.png"),
                        colorBlendMode: BlendMode.difference,
                      ),
                    ),
                    SizedBox(height: 40),
                    Text("Não há contatos para mostrar",
                        style: TextStyle(
                            fontSize: 23,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                    Text(
                      "A sua lista de Contatos está vazia.",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    )
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return _contactCard(context, index);
              },
            ),
    );
  }

  // Essa função é responsável por criar o cartão dos contatos na ListView
  Widget _contactCard([BuildContext context, index]) {
    return GestureDetector(
      child: Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Hero(
                  tag: contacts[index].id.toString(),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2,
                          offset: Offset(1, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey, width: 1),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(90),
                      child: Image(
                        image: contacts[index].image != null
                            ? FileImage(File(contacts[index].image))
                            : AssetImage("assets/image/profile.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          contacts[index].name ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          contacts[index].email ?? "",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          contacts[index].phone ?? "",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        onDismissed: (direction) {
          setState(() {
            //primeiro precisamos copiar o conato a ser excluido para uma variavel
            // essa variavel retornará o contato caso o usuário queira desfazer a exclusão
            _lastRemoved = contacts[index];
            //deletamso o contato do banco de dados
            helper.deleContact(contacts[index].id);
            //deletamos o contato da lista
            contacts.removeAt(index);
            // e copiamos a sua posição, quando o usuário desfaça a eclusão, o contato
            // retornará para sua posição inicial
            _lastRemovedPos = index;
            final snack = SnackBar(
              content: Text(
                  '\"${_lastRemoved.name}\" foi removido da lista de contatos'),
              action: SnackBarAction(
                  label: 'Desfazer',
                  onPressed: () {
                    setState(() {
                      contacts.insert(_lastRemovedPos, _lastRemoved);
                      helper.saveContact(_lastRemoved);
                    });
                  }),
              duration: Duration(seconds: 1),
            );
            Scaffold.of(context).showSnackBar(snack);
          });
        },
      ),
      onTap: () {
        // _showContactPage(contact: contacts[index]);
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              color: Colors.purpleAccent,
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    child: Column(
                      //Serve para o BottoSheet ocupar o minimo de espaço possível
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.call,
                          color: Colors.green[900],
                        ),
                        Text('Ligar',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0)),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      launch("tel:${contacts[index].phone}");
                    },
                  ),
                  FlatButton(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 20),
                        Text('Editar',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0)),
                      ],
                    ),
                    onPressed: () {
                      //Colocar o Navigator para fechar o BottomSheet quando clicar na opção
                      // se não, ao voltar para a pagina home ele continuará
                      // a ordem importa, se colocar o Navigator depois não funciona
                      Navigator.pop(context);
                      _showContactPage(contact: contacts[index]);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Route _createRoute(Contact contact) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ContactPage(contact: contact),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1, 0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

// _showContactPage será usado tanto para editar quanto para adicionar um novo contato
//PARA EDITAR: será passado o parametro do contato que será editado
//PARA ADICIONAR: não será passado um parametro pq o contado ainda nao foi criado
// Quando apertar em salva o app volta para a tela inicial e armazene o contato novo
// por isso o uso do await -> pegar um dado vindo de outra tela
// quando for ADICIONAR o _showContactPage irá retornar o contato salvo
// e o recContact estará recebendo o contato salvo da contactPage
  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context, _createRoute(contact));
    //se foi retornado algum contato e se foi enviado algo contato, o app irá
    // atualizar o contato que foi enviado e e irá obter a lista de contato novamente atualizada
    if (recContact != null) {
      if (contact != null) {
        //upDateContact = atualizar contato
        await helper.upDateContact(recContact);
      } else {
        //Caso o app recebeu algum contato, mas não foi enviado nenhum contato
        // o app irá salvar como novo contato
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }
}
