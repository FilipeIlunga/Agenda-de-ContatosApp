import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String image;

  Contact();
  //Construtor que pega o mapa e constroi o contado
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    image = map[imageColumn];
  }

  //função que retorna o mapa
  // Transfoormando os dados do contato em um mapa
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: image,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contatc(id: $id, name: $name, email: $email, phone: $phone, image: $image)";
  }
}

// ----------------------CONFIGURAÇÃO DO BANCO DE DADOS -----------------------

//Variáveis para o banco de dados
//Nome da tabela
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imageColumn = "imageColumn";

class ContactHelper {
  //ContactHelper poderá possuir apenas 1 único objeto com 1 banco de dados
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  //Essa variável é o banco de dados
  Database _db;

  //Inicializar o banco de dados
  // Se o banco de dados não for nulo retornar ele
  // caso for nulo, ou seja não exista
  // a função initDb será chamada, essa função que criará o banco de daos
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  //CRIAR O BANCO DE DADOS
  Future<Database> initDb() async {
    //get retorna o local onde será armazenado o banco de dados
    final databasesPath = await getDatabasesPath();

    //pegar o arquivo
    final path = join(databasesPath, "contactsnew3.db");

    //abrir o banco de dados
    // informar o local, a versão e uma função que criará o banco de dados
    // na primeira vez que será aberto
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      // aqui será executado um codigo responsável por criar a tabela de dados
      // o códico pedira para o banco de dados criar uma tabela que conterá
      // as colunas criadas lá em cima
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
          "$phoneColumn TEXT, $imageColumn TEXT)");
    });
  }

  // 1
  //Essa função irá receber o contato a ser SALVO
  // 1° Chamar o saveContact para salvar um contato
  // 2° Passar o contato a ser salvo
  // 3° Obter o banco de dados
  //4° Pedir para inserir o contato na tabela do banco de dados, vou obter o id
  // de onde foi salvo
  // 5° Retornar o contato no Futuro
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  //2
  // OBTER OS  DADOS DO CONTATO
  Future<Contact> getContact(int id) async {
    //Obter o banco de dados
    Database dbContact = await db;

    //query é uma forma de obter os dados, mas apenas os dados que você quiser
    // 1° Fazendo uma query na tabela de contatos
    // 2° Quero obter todas as colunas citadas a baixo
    // com o "where" quero obter apenas o contado onde a idColumn é exatamente
    // igual ao id que foi passado como parâmetro
    // O where passa a regra do contado que será obtido
    List<Map> maps = await dbContact.query(contactTable,
        columns: [
          idColumn,
          nameColumn,
          emailColumn,
          phoneColumn,
          imageColumn,
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);

    // Depois que o contato foi procurado, verificamos se realmente foi retornado
    // um contado
    // se a lista tiver mais de 1 elemento a função vai retornar um Contado
    // atravez de um mapa e será pego o primeiro elemento desse mapa
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // 3° DELETAR
  // Deletar um contato da tabela de contatos onde o id da coluna é igual ao
  // id passado como parâmetro
  // o delete  retorna o número inteiro indicando que a remoção ocorreu com sucesso ou nao
  Future<int> deleContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  // 4° ATUALIZAR
  Future<int> upDateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }

  //Retorna a quantidade de contados da tabela
  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
      await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"),
    );
  }

  //Fechar o banco de dados
  Future close() async {
    Database dbContact = await db;
    await dbContact.close();
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();

    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }
}
