import 'dart:io';
import 'package:contacts/helpers/contact_helper.dart';
import 'package:contacts/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];

  Gradient g1 = const LinearGradient(
    colors: [
      Color(0xFF7F00FF),
      Color(0xFFE100FF),
    ],
  );

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          // comparando os nomes de A-Z
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          // comparando os nomes de Z-A
          return b.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de A a Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de Z a A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null
                        ? FileImage(File(contacts[index].img!))
                        : AssetImage("images/contactImg.png") as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contacts[index].name ?? "",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        contacts[index].email ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        contacts[index].phone ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index); // pode editar o contato na tela
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
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green),
                            ),
                            onPressed: () {
                              launch("tel:${contacts[index].phone}");
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Ligar",
                              style: TextStyle(fontSize: 20),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.green)),
                            onPressed: () {
                              Navigator.pop(context);
                              _showContactPage(
                                  contact: contacts[
                                      index]); // chama tela de contatos
                            },
                            child: const Text(
                              "Editar",
                              style: TextStyle(fontSize: 20),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.green)),
                            onPressed: () {
                              helper.deleteContact(contacts[index].id!);
                              setState(() {
                                contacts.removeAt(index);
                                Navigator.pop(context);
                              });
                            },
                            child: const Text(
                              "Excluir",
                              style: TextStyle(fontSize: 20),
                            )),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
        context, // quando salvar retorna o novco contato pra tela
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    // Quando abrir a tela pode ou atualizar um contato existente ou adicionar um novo
    if (recContact != null) {
      // se retornou algum contato
      if (contact != null) {
        // se eu tinha enviado algum contato
        await helper.updateContact(recContact); // atualiza
        _getAllContacts();

        /// me retorna atualizado
      } else {
        // se recebeu um contato mas não foi enviado
        await helper.saveContact(recContact); // salva como novo contato
      }
      _getAllContacts();
    }
  }

  _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list as List<Contact>;
      });
    });
  }
}
