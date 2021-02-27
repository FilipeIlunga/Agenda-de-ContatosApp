import 'dart:io';
import 'package:agenda_de_contatos/helper/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;

  // A tela vai abrir e vai indicar que o usuário não alterou nada
  bool _userEdited = false;

  final _nameControler = TextEditingController();
  final _emailControler = TextEditingController();
  final _phoneControler = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    //o wiget serve pra acessar o elemento de outra classe
    // widget é o ContactPage e o contact é o nosso atributo
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      // transformando o contact que foi passado em um mapa e criando um novo contato
      // atraves desse mapa, ou seja, duplicando o contato e passado para o editedContact
      _editedContact = Contact.fromMap(widget.contact.toMap());

      //Quando a tela de edição de contato abrir para edição, os dados do contato
      // a serem editados já estarão nos respectivos compos para edição
      _nameControler.text = _editedContact.name;
      _emailControler.text = _editedContact.email;
      _phoneControler.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    // O WillPopScope chamará uma função antes do usuário
    //sair da tela quando clicar em voltar para a tela anterior
    // atraves do botação de voltar que fica no appBar
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          //Se não houver contato cadastrado aparecerá "Novo contado"
          // Se houver contato cadastrado aparecerá o nome do Contato
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                  child: Hero(
                    tag: _editedContact.id.toString(),
                    child: Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 2,
                            offset: Offset(1, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.grey, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(90),
                        child: Image(
                          image: _editedContact.image != null
                              ? FileImage(File(_editedContact.image))
                              : AssetImage("assets/image/profile.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: _photoContact,
              ),
              Card(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: _nameControler,
                    focusNode: _nameFocus,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: 'Nome'),
                    //Função
                    //Quando o texto mudar no nome será atualizado o nome no appBar
                    // e idicar para a pagina que o algo foi alterado no formulário
                    // Assim quando clicar em voltar para a pagina anterior
                    // o app mostrará a mensagem se o usuário quer descartar ou não
                    // as altrações feitas no formulário
                    onChanged: (text) {
                      // se o usuário mexer no formulário o app indicará que ele editou algo
                      _userEdited = true;
                      //O titulo do appBar será atualizado
                      setState(() {
                        _editedContact.name = text;
                      });
                    },
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: TextField(
                    controller: _emailControler,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (text) {
                      _userEdited = true;
                      _editedContact.email = text;
                    },
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.only(left: 20, right: 20),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextField(
                    controller: _phoneControler,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: 'Telefone'),
                    onChanged: (text) {
                      _userEdited = true;
                      _editedContact.phone = text;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          child: Icon(Icons.save),
          onPressed: () {
            // Caso o nome não esteja vazio (apenas o nome) e nulo
            if (_editedContact.name.isNotEmpty && _editedContact.name != null) {
              // Remover a tela e voltar a tela anterior
              // no pop podemos pasar um parâmetro/objeto para retornar para a tela anterior
              // esse objeto que irá retornar no await recContact na home page,
              //  no Navigator.push
              Navigator.pop(context, _editedContact);
            } else {
              //caso não tenha o nome preenchido será chamado um foco para poder preencher
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
        ),
      ),
    );
  }

  //Função que mostrar o AlertDialog quando o usuário alterar algo e quiser sair da tela sem salvar
  Future<bool> _requestPop() {
    //Se o usuário editu algo e não salvou
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Descartar Alterações?'),
            content: Text('Ao sair, as alterações serão perdidas.'),
            actions: [
              FlatButton(
                child: Text('Cancelar'),
                onPressed: () {
                  //Se cancelar, o AlertDialog sumirá, e o usuário ficara na pagina de edição
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Sim'),
                onPressed: () {
                  // Se apertar em SIM, o AlertDialog e a contactPage sumirão
                  // e o usuário voltará para homePage
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      //Se o usuário alterou algo, ele não sairá automatciamente da tela
      return Future.value(false);
    } else {
      // Se o usuário não alterou nada retornará um Future.value(true), ou seja
      // será permitido ele sair da tela
      //Sair automaticamente
      return Future.value(true);
    }
  }

  Future<bool> _photoContact() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            Row(
              children: [
                Icon(Icons.camera),
                FlatButton(
                  child: Text('Tirar foto nova'),
                  onPressed: () {
                    _userEdited = true;
                    ImagePicker.pickImage(source: ImageSource.camera)
                        .then((file) {
                      if (file == null) {
                        return;
                      } else {
                        setState(() {
                          _editedContact.image = file.path;
                        });
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.photo),
                FlatButton(
                  child: Text('Selecionar imagem da galeria'),
                  onPressed: () {
                    _userEdited = true;
                    ImagePicker.pickImage(source: ImageSource.gallery)
                        .then((file) {
                      if (file == null) {
                        return;
                      } else {
                        setState(() {
                          _editedContact.image = file.path;
                        });
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
    //Se o usuário alterou algo, ele não sairá automatciamente da tela
    return Future.value(false);
  }
}
