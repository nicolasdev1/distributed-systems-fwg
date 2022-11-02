import 'package:aps_2022_2/api.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  const String title = 'APS 2022.2';
  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(),
      link: HttpLink(Api.graphUrl),
    ),
  );
  final MyMaterialApp app = MyMaterialApp(title: title, client: client);
  runApp(app);
}

class MyMaterialApp extends StatelessWidget {
  final String title;
  final ValueNotifier<GraphQLClient> client;

  const MyMaterialApp({
    Key? key,
    required this.title,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: title,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomePage(title: title),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String queryString = """
    query PostsQuery {
      posts {
        nodes {
          title
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        fetchPolicy: FetchPolicy.cacheAndNetwork,
        document: gql(queryString),
      ),
      builder: (
        QueryResult result, {
        VoidCallback? refetch,
        FetchMore? fetchMore,
      }) {
        if (result.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: const Center(
              child: Text(
                'Carregando...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        if (result.hasException) {
          // Add scaffold with pretty error message
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: Center(
              child: Text(result.exception.toString()),
            ),
          );
        }

        // Get result
        final response = result.data!['posts']['nodes'];

        // Create a simple Scaffold
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: ListView.builder(
            itemCount: response.length,
            itemBuilder: (BuildContext context, int index) {
              final String title = response[index]['title'];
              return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedCard(title: title));
            },
          ),
        );
      },
    );
  }
}

class OutlinedCard extends StatelessWidget {
  final String title;

  const OutlinedCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0.3,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
