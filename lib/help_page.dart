// Importing all necessary packages 
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai;
import 'navigation_page.dart'; 
import 'package:dash_chat_2/dash_chat_2.dart';
import 'consts.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  late genai.GenerativeModel model;
  List<ChatMessage> messages = [];
  // Assigning users and names
  ChatUser currentUser = ChatUser(id: "0", firstName: "Me");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "GroceryGemini");

  // Initializing the model
  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  // Setting important pararameters, including temperature
  void _initializeModel() {
    final generationConfig = genai.GenerationConfig(
      temperature: 0.9,
      topP: 0.95,
      topK: 64,
      maxOutputTokens: 8192,
    );

    // Defining model and api key
    model = genai.GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: geminiApiKey,
      generationConfig: generationConfig,
    );
  }

  // Building the chat interface
  @override
  Widget build(BuildContext context) {
    return NavigationPage(
      currentIndex: 3, // Index of the "Help" tab
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color, // Use theme's icon color
          ),
          // Setting the title and background
          title: Text("GroceryGemini", style: TextStyle(color: Theme.of(context).appBarTheme.titleTextStyle?.color)),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Use theme's appBar background color
        ),
        body: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Use theme's scaffold background color
      child: DashChat(
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages,
      ),
    );
  }

  // Creating a list of the messages in the chat
  void _sendMessage(ChatMessage chatMessage) async {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      // Recognizing the prompt and content, and generating a response 
      final prompt = _buildPrompt(chatMessage.text);
      final content = [genai.Content.text(prompt)];
      final response = await model.generateContent(content);

      // Finding the time at which the chats were sent
      if (response.text != null) {
        final geminiMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response.text!,
        );

        setState(() {
          messages = [geminiMessage, ...messages];
        });
      }
      // Catching and displaying any errors that occured
    } catch (e) {
      debugPrint('Error generating response: $e');
    }
  }

  // Fine tuning the model to respond to prompts regarding myshopr specifically
  String _buildPrompt(String userInput) {
    return '''
    You are Grocery Gemini. you are a friendly personal assistant who is to help people with grocery and health related things, additionally, you can help with how to use the app. You are to respond in a friendly tone at all times, and make sure that the user's needs are fulfilled. Avoid using emojis in any responses. To navigate between pages, users should click on the icon in the bottom navigation bar for the corresponding page. There are3 pages in the app, the help page, settings page, and grocery/home page. If the user asks you how to navigate to another page, explain to them that it doesn't exist. Avoid greeting the user at the beginning of each sentence, and being overly friendly. Make sure to maintain a professional tone. Don't repeat everything exactly as I tell you, be more creative with it. You can only help with recipes and groceries and health. The user is currently on the help page. Don't assume the icons of the pages in the app.
    User input: $userInput
    GradeGemini's response:
    ''';
  }
}
