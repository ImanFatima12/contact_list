import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsListView extends StatefulWidget {
  @override
  _ContactsListViewState createState() => _ContactsListViewState();
}

class _ContactsListViewState extends State<ContactsListView> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndFetchContacts();
    _searchController.addListener(() {
      _filterContacts(_searchController.text);
    });
  }

  // Request permission to access contacts
  Future<void> _requestPermissionAndFetchContacts() async {
    final permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      _fetchContacts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission denied to access contacts.")),
      );
    }
  }

  // Fetch contacts from the device
  Future<void> _fetchContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.toList();
      _filteredContacts = _contacts; // Initialize filtered contacts
    });
  }

  // Filter contacts based on search query
  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _contacts
          .where((contact) =>
              contact.displayName != null &&
              contact.displayName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search TextField
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Contacts',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 10),
            // ListView to display contacts
            Expanded(
              child: ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          contact.displayName != null && contact.displayName!.isNotEmpty
                              ? contact.displayName![0]
                              : '?',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      title: Text(contact.displayName ?? 'No Name'),
                      subtitle: Text(
                        contact.phones!.isNotEmpty
                            ? contact.phones!.first.value ?? 'No Number'
                            : 'No Number',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
