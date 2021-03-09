import 'dart:io';
import 'package:agenda_de_contatos/helper/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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
      onWillPop: () {
        if (_userEdited) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.WARNING,
            borderSide: BorderSide(color: Colors.purple[100], width: 2),
            width: 300,
            buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
            headerAnimationLoop: false,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Descartar Alterações?',
            desc: 'Ao sair, as alterações serão perdidas.',
            showCloseIcon: true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              Navigator.pop(context);
            },
          )..show();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
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
                  padding: const EdgeInsets.only(top: 10, bottom: 15),
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
                        borderRadius: BorderRadius.circular(90.0),
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
                onTap: () {
                  AwesomeDialog(
                    context: context,
                    keyboardAware: true,
                    showCloseIcon: true,
                    headerAnimationLoop: false,
                    dismissOnBackKeyPress: true,
                    dialogType: DialogType.QUESTION,
                    animType: AnimType.BOTTOMSLIDE,
                    title: 'Upload da foto',
                    btnCancelText: "Galeria",
                    btnOkText: "Camera",
                    desc: 'Qual meio deseja carregar a foto?',
                    btnCancelColor: Colors.blue,
                    btnCancelIcon: Icons.photo,
                    btnOkIcon: Icons.camera,
                    padding: const EdgeInsets.all(16.0),
                    btnCancelOnPress: () {
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
                    },
                    btnOkOnPress: () {
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
                    },
                  ).show();
                },
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
}
