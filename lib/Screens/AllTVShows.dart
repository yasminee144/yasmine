import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AllTvItems(),
    );
  }
}

class AllTvItems extends StatefulWidget {
  const AllTvItems({super.key});

  @override
  State<AllTvItems> createState() => _AllTvItemsState();
}

class _AllTvItemsState extends State<AllTvItems> {
  List<TvItem> tvShows = [];
  bool isLoading = false;
  int currentPage = 1;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadTvShows();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadTvShows();
    }
  }

  Future<void> loadTvShows() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final newTvShows = await fetchTvShows(currentPage);
      setState(() {
        tvShows.addAll(newTvShows);
        currentPage++;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading TV shows: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Popular TV Shows',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: tvShows.isEmpty && isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: tvShows.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == tvShows.length) {
                  return Center(child: CircularProgressIndicator());
                }
                final tvShow = tvShows[index];
                return GestureDetector(
                  onTap: () => _showTvDetails(context, tvShow),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${tvShow.posterPath}',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showTvDetails(BuildContext context, TvItem tvShow) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.34,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 20, 20, 20),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${tvShow.posterPath}',
                        width: 95,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            tvShow.name,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            tvShow.firstAirDate ?? 'N/A',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            tvShow.overview ?? 'No overview available.',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: ElevatedButton.icon(
                      icon: Icon(Icons.play_arrow),
                      label: Text(
                        'Play',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )),
                    SizedBox(width: 30),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.download,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        Transform.translate(
                          offset: Offset(0, -4.0),
                          child: Text(
                            "Download",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 30),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.slow_motion_video,
                              color: Colors.white),
                          onPressed: () {},
                        ),
                        Transform.translate(
                          offset: Offset(0, -4.0),
                          child: Text(
                            "Preview",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 30),
                  ],
                ),
              ),
              Divider(
                thickness: 0.5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TvDetailsPage(tvShow: tvShow),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Details & More',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TvDetailsPage extends StatelessWidget {
  final TvItem tvShow;

  const TvDetailsPage({Key? key, required this.tvShow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(''),
              background: Image.network(
                'https://image.tmdb.org/t/p/w500${tvShow.posterPath}',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    tvShow.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${tvShow.firstAirDate?.split('-')[0] ?? 'N/A'} | HD | ★ ${tvShow.voteAverage}',
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              size: 30,
                              Icons.play_arrow,
                              color: Colors.black,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Play',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Download',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(tvShow.overview ?? 'No overview available.',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildIconButton(Icons.add, 'My List'),
                          SizedBox(width: 10),
                          _buildIconButton(Icons.thumb_up_off_alt, 'Rate'),
                          SizedBox(width: 10),
                          _buildIconButton(Icons.share, 'Share'),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('MORE LIKE THIS',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}

Future<List<TvItem>> fetchTvShows(int page) async {
  final apiKey = '8f78d38fb24129522724f8f66f81c75c';
  final url =
      'https://api.themoviedb.org/3/tv/popular?api_key=$apiKey&page=$page';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final results = jsonResponse['results'] as List<dynamic>;
    return results.map((item) => TvItem.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load TV shows');
  }
}

class TvItem {
  final String name;
  final String? firstAirDate;
  final String? overview;
  final String posterPath;
  final double voteAverage;

  TvItem({
    required this.name,
    this.firstAirDate,
    this.overview,
    required this.posterPath,
    required this.voteAverage,
  });

  factory TvItem.fromJson(Map<String, dynamic> json) {
    return TvItem(
      name: json['name'] ?? 'No name',
      firstAirDate: json['first_air_date'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
    );
  }
}
