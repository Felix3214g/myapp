import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Shopping List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ShoppingListScreen(),
    );
  }
}

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> _shoppingList = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = 'Groceries';
  bool _showOnlyUnchecked = false;
  String _searchQuery = '';

  final List<String> _categories = [
    'Groceries',
    'Household',
    'Electronics',
    'Clothing',
    'Other'
  ];

  void _addItem(String name, String quantity, String category) {
    if (name.isEmpty || quantity.isEmpty) {
      _showErrorDialog('Please enter both name and quantity.');
      return;
    }

    setState(() {
      _shoppingList.add(ShoppingItem(
        name: name,
        quantity: quantity,
        category: category,
        isPurchased: false,
      ));
      _sortItems();
    });
  }

  void _togglePurchased(int index) {
    setState(() {
      _shoppingList[index].isPurchased = !_shoppingList[index].isPurchased;
      _sortItems();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _shoppingList.removeAt(index);
    });
  }

  void _sortItems() {
    _shoppingList.sort((a, b) {
      if (a.isPurchased == b.isPurchased) {
        return a.category.compareTo(b.category);
      }
      return a.isPurchased ? 1 : -1;
    });
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(labelText: 'Enter item name'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _textController.clear();
                    _quantityController.clear();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (_textController.text.isNotEmpty && _quantityController.text.isNotEmpty) {
                      _addItem(_textController.text, _quantityController.text, _selectedCategory);
                      Navigator.of(context).pop();
                      _textController.clear();
                      _quantityController.clear();
                    } else {
                      _showErrorDialog('Please enter both name and quantity.');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditItemDialog(ShoppingItem item) {
    final TextEditingController nameController = TextEditingController(text: item.name);
    final TextEditingController quantityController = TextEditingController(text: item.quantity);
    String selectedCategory = item.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Item name'),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButton<String>(
                    value: selectedCategory,
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (nameController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                      setState(() {
                        item.name = nameController.text;
                        item.quantity = quantityController.text;
                        item.category = selectedCategory;
                      });
                      Navigator.of(context).pop();
                    } else {
                      _showErrorDialog('Please enter both name and quantity.');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _shoppingList
        .where((item) => !_showOnlyUnchecked || !item.isPurchased)
        .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Shopping List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_showOnlyUnchecked ? Icons.check_box_outline_blank : Icons.check_box),
            onPressed: () {
              setState(() {
                _showOnlyUnchecked = !_showOnlyUnchecked;
              });
            },
            tooltip: 'Toggle show only unchecked',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search items',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return Dismissible(
                  key: Key(item.name),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure you want to delete this item?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        );
                      },
                    ) ?? false;
                  },
                  onDismissed: (direction) {
                    _removeItem(_shoppingList.indexOf(item));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.name} removed')),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: item.isPurchased,
                        onChanged: (_) => _togglePurchased(_shoppingList.indexOf(item)),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text('${item.quantity} - ${item.category}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditItemDialog(item),
                      ),
                    ),
                  ),
                );
              },
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final ShoppingItem item = filteredList.removeAt(oldIndex);
                  filteredList.insert(newIndex, item);
                  _shoppingList = List.from(filteredList);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: ${filteredList.length} items (${filteredList.where((item) => item.isPurchased).length} purchased)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ShoppingItem {
  String name;
  String quantity;
  String category;
  bool isPurchased;

  ShoppingItem({
    required this.name,
    required this.quantity,
    required this.category,
    required this.isPurchased,
  });
}