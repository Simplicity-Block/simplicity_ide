// lib/main.dart
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/services.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/python.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Contract IDE',
      theme: ThemeData.dark(),
      home: const IDEScreen(),
    );
  }
}

class IDEScreen extends StatefulWidget {
  const IDEScreen({Key? key}) : super(key: key);

  @override
  _IDEScreenState createState() => _IDEScreenState();
}

class _IDEScreenState extends State<IDEScreen> {
  late CodeController _codeController;
  final TextEditingController _privateKeyController = TextEditingController();
  final TextEditingController _contractNameController = TextEditingController();
  final TextEditingController _functionNameController = TextEditingController();
  final TextEditingController _parametersController = TextEditingController();
    final TextEditingController _contractAddressController = TextEditingController();  // New controller

  String _deployedContractAddress = '';
  String _resultOutput = '';
  bool _isDeploying = false;
  bool _isCalling = false;
  String _publicKey = '';
  final String _ecdsaServerUrl = 'https://ecdsa-server.onrender.com';

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: _getDefaultContractCode(),
      language: python,
    );
  }

  Future<void> _updatePublicKey() async {
    if (_privateKeyController.text.isEmpty) {
      setState(() {
        _resultOutput = 'Please enter a private key';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_ecdsaServerUrl/private_to_public'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'private_key': _privateKeyController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _publicKey = data['public_key'];
          _resultOutput = 'Public key retrieved successfully';
        });
      } else {
        setState(() {
          _resultOutput = 'Error getting public key: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _resultOutput = 'Error getting public key: $e';
      });
    }
  }

  Future<Map<String, dynamic>?> _signTransaction(Map<String, dynamic> transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$_ecdsaServerUrl/sign_transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'private_key': _privateKeyController.text,
          'recipient': transaction['recipient'] ?? transaction['contract_address'],
          'amount': transaction['amount'] ?? 0,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        setState(() {
          _resultOutput = 'Error signing transaction: ${response.body}';
        });
        return null;
      }
    } catch (e) {
      setState(() {
        _resultOutput = 'Error signing transaction: $e';
      });
      return null;
    }
  }

  String _getDefaultContractCode() {
    return '''contract wallet with amount, address does
    deposit takes amount does
        save balance is balance + amount
        return balance
    .
    
    withdraw takes amount does
        if balance > amount then
            balance is balance - amount
            return balance
        otherwise             
            return "Insufficient balance"
        .
    .
    
    transfer_to takes amount, address does
        transfer amount to address
        return "Success"
    .
.''';
  }
  Future<String?> _signPayload(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$_ecdsaServerUrl/sign_payload'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'private_key': _privateKeyController.text,
          'payload': payload,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['signed_payload'];
      } else {
        setState(() {
          _resultOutput = 'Error signing payload from server: ${response.body}';
        });
        return null;
      }
    } catch (e) {
      setState(() {
        _resultOutput = 'Error signing payload: $e';
      });
      return null;
    }
  }

  Future<void> _deployContract() async {
    if (_privateKeyController.text.isEmpty || _contractNameController.text.isEmpty) {
      setState(() {
        _resultOutput = 'Please enter both private key and contract name';
      });
      return;
    }

    setState(() {
      _isDeploying = true;
      _resultOutput = 'Deploying contract...';
    });

    try {
      await _updatePublicKey();

      final deploymentPayload = {
        'sender': _publicKey,
        'contract_name': _contractNameController.text,
        'code': _codeController.text,
        'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
        'public_key': _publicKey,
      };

      final signature = await _signPayload(deploymentPayload);
      if (signature == null) return;

      final deploymentData = {
        ...deploymentPayload,
        'digital_signature': signature,
      };

      final response = await http.post(
        Uri.parse('https://simplicity-server.onrender.com/contracts/new'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(deploymentData),
      );

      
  if (response.statusCode == 201) {
    final data = json.decode(response.body);
    final contractAddress = data['contract_address'] ?? '';
    setState(() {
      _deployedContractAddress = contractAddress;
      _resultOutput = 'Contract deployed successfully!\nContract address is $contractAddress';
    });
  }else {
        setState(() {
          _resultOutput = 'Error deploying contract: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _resultOutput = 'Error deploying contract: $e';
      });
    } finally {
      setState(() {
        _isDeploying = false;
      });
    }
  }

  Future<void> _callContract() async {
    if (_privateKeyController.text.isEmpty || 
        ( _contractAddressController.text.isEmpty)) {
      setState(() {
        _resultOutput = 'Please enter private key and contract address';
      });
      return;
    }
    setState(() {
      _isCalling = true;
      _resultOutput = 'Calling contract...';
    });

    try {
      await _updatePublicKey();

      Map<String, dynamic> parameters = {};
      if (_parametersController.text.isNotEmpty) {
        parameters = json.decode(_parametersController.text);
      }

      final callPayload = {
        'sender' : _publicKey,
        'contract_address': _contractAddressController.text,
        'function': _functionNameController.text,
        'parameters': parameters,
        'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
        'public_key': _publicKey,
      };

      final signature = await _signPayload(callPayload);
      if (signature == null) return;

      final callData = {
        ...callPayload,
        'digital_signature': signature,
      };

      final response = await http.post(
        Uri.parse('https://simplicity-server.onrender.com/contracts/call'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(callData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _resultOutput = 'Contract call successful!\nResult: ${json.encode(data)}';
        });
      } else {
        setState(() {
          _resultOutput = 'Error calling contract: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _resultOutput = 'Error calling contract: $e';
      });
    } finally {
      setState(() {
        _isCalling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Contract IDE'),
      ),
      body: Row(
        children: [
          // Left panel - Contract Editor
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Contract Code Editor', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: CodeField(
                        controller: _codeController,
                        textStyle: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right panel - Controls and Output
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _privateKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Private Key',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your private key (64 hex characters)',
                    ),
                    onChanged: (_) => _updatePublicKey(),
                  ),
                  const SizedBox(height: 16),
                  if (_publicKey.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text('Public Key: $_publicKey', 
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  TextField(
                    controller: _contractNameController,
                    decoration: const InputDecoration(
                      labelText: 'Contract Name',
                      border: OutlineInputBorder(),
                      hintText: 'Enter name for new contract',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isDeploying ? null : _deployContract,
                    child: Text(_isDeploying ? 'Deploying...' : 'Deploy Contract'),
                  ),
                  const SizedBox(height: 24),
                  // New Contract Address Field
                  TextField(
                    controller: _contractAddressController,
                    decoration: InputDecoration(
                      labelText: 'Contract Address',
                      border: const OutlineInputBorder(),
                      hintText: _deployedContractAddress.isNotEmpty 
                          ? 'Using deployed contract: $_deployedContractAddress'
                          : 'Enter contract address (64 hex characters)',
                    ),
                    enabled: _deployedContractAddress.isEmpty,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _functionNameController,
                    decoration: const InputDecoration(
                      labelText: 'Function Name',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., deposit, withdraw, transfer_to',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _parametersController,
                    decoration: const InputDecoration(
                      labelText: 'Parameters (JSON)',
                      border: OutlineInputBorder(),
                      hintText: '''Example formats:
For deposit: {"amount": 100}
For withdraw: {"amount": 50}
For transfer: {"amount": 75, "address": "recipient_address"}''',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isCalling ? null : 
                      // Enable button if there's either a deployed address or manual address
                      ( _contractAddressController.text.isNotEmpty) ? 
                      _callContract : null,
                    child: Text(_isCalling ? 'Calling...' : 'Call Contract'),
                  ),
                  const SizedBox(height: 24),
                  const Text('Output:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        child: OutputDisplay(text: _resultOutput),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _privateKeyController.dispose();
    _contractNameController.dispose();
    _functionNameController.dispose();
    _parametersController.dispose();
    super.dispose();
  }
}

class OutputDisplay extends StatelessWidget {
  final String text;
  
  const OutputDisplay({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the text contains a contract address
    final RegExp contractAddressRegex = RegExp(r'Contract address is ([a-fA-F0-9]+)');
    final match = contractAddressRegex.firstMatch(text);

    if (match != null) {
      final beforeAddress = text.substring(0, match.start);
      final address = match.group(1) ?? '';
      final afterAddress = text.substring(match.end);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (beforeAddress.isNotEmpty)
            SelectableText(beforeAddress),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    address,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: address));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contract address copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (afterAddress.isNotEmpty)
            SelectableText(afterAddress),
        ],
      );
    }

    // If no contract address is found, just show selectable text
    return SelectableText(text);
  }
}
