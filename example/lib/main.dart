import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitchat_flutter/bitchat_flutter.dart';

void main() {
  runApp(const BitChatApp());
}

class BitChatApp extends StatelessWidget {
  const BitChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BitChatProvider(),
      child: MaterialApp(
        title: 'BitChat Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const BitChatHomePage(),
      ),
    );
  }
}

class BitChatProvider extends ChangeNotifier {
  late final BitChatClient _client;
  
  BitChatClient get client => _client;
  bool get isConnected => _client.isConnected;
  List<BitChatMessage> get messages => _client.messageHistory;
  List<BitChatPeer> get peers => _client.peers;
  
  Future<void> initialize() async {
    _client = BitChatClient();
    await _client.initialize();
    
    // Listen for changes
    _client.addListener(notifyListeners);
  }
  
  Future<void> connect() async {
    await _client.connect();
  }
  
  Future<void> sendMessage(String content) async {
    await _client.sendMessage(content);
  }
  
  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }
}

class BitChatHomePage extends StatefulWidget {
  const BitChatHomePage({super.key});

  @override
  State<BitChatHomePage> createState() => _BitChatHomePageState();
}

class _BitChatHomePageState extends State<BitChatHomePage> {
  final TextEditingController _messageController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BitChatProvider>().initialize();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BitChat Example'),
        actions: [
          Consumer<BitChatProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                ),
                onPressed: () {
                  if (provider.isConnected) {
                    // Disconnect logic here
                  } else {
                    provider.connect();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          Consumer<BitChatProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                color: provider.isConnected ? Colors.green : Colors.red,
                child: Row(
                  children: [
                    Icon(
                      provider.isConnected ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.isConnected ? 'Connected' : 'Disconnected',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Messages
          Expanded(
            child: Consumer<BitChatProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return ListTile(
                      title: Text(message.content),
                      subtitle: Text('${message.senderId} - ${_formatTime(message.timestamp)}'),
                      leading: CircleAvatar(
                        child: Text(message.senderId.substring(0, 1).toUpperCase()),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Message input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<BitChatProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.isConnected ? _sendMessage : null,
                      child: const Text('Send'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      context.read<BitChatProvider>().sendMessage(content);
      _messageController.clear();
    }
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
