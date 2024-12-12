import 'dart:convert';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:example/chopper/chopper_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  ChuckerFlutter.showOnRelease = true;
  ChuckerFlutter.showNotification = false;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [ChuckerFlutter.navigatorObserver],
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xFF13B9FF),
        ),
      ),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _baseUrl = 'https://jsonplaceholder.typicode.com';
  final _clientType = _Client.dio;
  final TextEditingController _controller = TextEditingController(text: '500');
  int _totalRequests = 500;
  String _elapsedTime = '';
  bool enableInterceptor = true;

  late final _dio = Dio(
    BaseOptions(
        sendTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': '*',
        }),
  );

  void addInterceptor() {
    _dio.interceptors.add(ChuckerDioInterceptor());
  }

  void removeInterceptor() {
    _dio.interceptors.clear();
  }

  Future<void> get({bool error = false}) async {
    try {
      //To produce an error response just adding random string to path
      final path = '/post${error ? 'temp' : ''}s/1';

      switch (_clientType) {
        case _Client.dio:
          _dio.get('$_baseUrl$path');
          break;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getPerCheckMultiple(int totalRequests, {bool error = false}) async {
    final stopwatch = Stopwatch();
    int completedRequests = 0;

    try {
      for (int i = 0; i < totalRequests; i++) {
        stopwatch.start();
        await get(error: error);
        stopwatch.stop();
        completedRequests++;

        // Delay for 1 second after the request
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _elapsedTime = 'Request called ${i + 1} total duration ${stopwatch.elapsedMilliseconds}ms (excluding delays)';
        });
        debugPrint('Request ${i + 1} duration: ${stopwatch.elapsedMilliseconds} ms');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      stopwatch.stop();
      debugPrint(
          'Total duration for $completedRequests requests: ${stopwatch.elapsedMilliseconds} ms (excluding delays)');
    }
  }

  Future<void> getWithParam() async {
    try {
      const path = '/posts';

      switch (_clientType) {
        case _Client.dio:
          _dio.get('$_baseUrl$path', queryParameters: {'userId': '1'});
          break;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> post() async {
    try {
      const path = '/posts';
      final request = {
        'title': 'foo',
        'body': 'bar',
        'userId': '101010',
      };
      switch (_clientType) {
        case _Client.dio:
          await _dio.post('$_baseUrl$path', data: request);
          break;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> put() async {
    try {
      const path = '/posts/1';
      final request = {
        'title': 'PUT foo',
        'body': 'PUT bar',
        'userId': '101010',
      };
      switch (_clientType) {
        case _Client.dio:
          await _dio.put('$_baseUrl$path', data: request);
          break;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> delete() async {
    try {
      const path = '/posts/1';

      switch (_clientType) {
        case _Client.dio:
          await _dio.delete('$_baseUrl$path');
          break;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> patch() async {
    try {
      const path = '/posts/1';
      final request = {'title': 'PATCH foo'};
      switch (_clientType) {
        case _Client.dio:
          await _dio.patch('$_baseUrl$path', data: request);
          break;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> uploadImage() async {
    try {
      switch (_clientType) {
        case _Client.dio:
          try {
            final formData = FormData.fromMap(
              {
                "key": "6d207e02198a847aa98d0a2a901485a5",
                "source": await MultipartFile.fromFile('assets/logo.png'),
              },
            );
            _dio.post(
              'https://freeimage.host/api/1/upload',
              data: formData,
            );
          } catch (e) {
            debugPrint(e.toString());
          }
          break;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _dio.interceptors.add(ChuckerDioInterceptor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chucker Flutter Example'),
      ),
      persistentFooterButtons: [
        Text('Using ${_clientType.name} library ${enableInterceptor ? 'with' : 'without'} ChuckerDioInterceptor'),
        const SizedBox(width: 16),
        Switch(
          value: enableInterceptor,
          onChanged: (value) {
            setState(() {
              enableInterceptor = value;
              if (enableInterceptor) {
                addInterceptor();
              } else {
                removeInterceptor();
              }
            });
          },
        )
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Client type: Dio"),
            const SizedBox(height: 16),
            ChuckerFlutter.chuckerButton,
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await getPerCheckMultiple(_totalRequests);
                    },
                    child: const Text('RUN PERFORMANCE CHECK'),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Number of Requests',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _totalRequests = int.tryParse(value) ?? 500;
                      });
                    },
                  ),
                  Text(_elapsedTime)
                ],
              ),
            ),
            ElevatedButton(
              onPressed: get,
              child: const Text('GET'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: getWithParam,
              child: const Text('GET WITH PARAMS'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: post,
              child: const Text('POST'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: put,
              child: const Text('PUT'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: delete,
              child: const Text('DELETE'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: patch,
              child: const Text('PATCH'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => get(error: true),
              child: const Text('ERROR'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

enum _Client {
  dio
}
