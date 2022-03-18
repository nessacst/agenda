import 'dart:io';
import 'package:contacts/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  ContactPage({this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _userEdited = false;
  Contact? _editedContact;

  @override // função chamada quando a page iniciar
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!
          .toMap()); // duplica contato e coloca no _editedContact

      _nameController.text = _editedContact!.name!;
      _emailController.text = _editedContact!.email!;
      _phoneController.text = _editedContact!.phone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return _requestPop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[800],
          title: Text(_editedContact!.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact!.name! != null &&
                _editedContact!.name!.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _editedContact!.img != null
                            ? FileImage(File(_editedContact!.img!))
                            : AssetImage("images/contactImg.png")
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () {
                    ImagePicker()
                        .pickImage(source: ImageSource.gallery)
                        .then((file) {
                      if (file == null) return;
                      setState(() {
                        _editedContact!.img = file.path;
                      });
                    });
                  },
                ),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact!.name = text;
                    });
                  },
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact!.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact!.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                ),
              ],
            )),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Deseja descartar alterações?"),
              content: Text("Se você voltar as alterações serão perdidas"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("Sim"),
                )
              ],
            );
          });
      return Future.value(false); // se modificou - não sai automaticamente
    } else {
      return Future.value(
          true); // se o usuário  não modificou nada na edição - sai automaticamente
    }
  }
}
