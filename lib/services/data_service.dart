import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/topic_model.dart';

class DataService {
  static final DataService instance = DataService._();
  DataService._();

  final Map<int, List<TopicIndex>> _topicIndexes = {};
  final Map<String, Topic> _topicCache = {};

  Future<List<TopicIndex>> getTopicIndex(int kelas) async {
    if (_topicIndexes.containsKey(kelas)) {
      return _topicIndexes[kelas]!;
    }
    final data = await rootBundle.loadString(
        'lib/data/curriculum/kelas-$kelas/index.json');
    final List<dynamic> jsonList = json.decode(data);
    final topics =
        jsonList.map((e) => TopicIndex.fromJson(e)).toList();
    _topicIndexes[kelas] = topics;
    return topics;
  }

  Future<Topic> getTopic(String topikId) async {
    if (_topicCache.containsKey(topikId)) {
      return _topicCache[topikId]!;
    }
    final kelas = int.parse(topikId.substring(1, 2));
    final data = await rootBundle
        .loadString('lib/data/curriculum/kelas-$kelas/$topikId.json');
    final jsonMap = json.decode(data);
    final topic = Topic.fromJson(jsonMap);
    _topicCache[topikId] = topic;
    return topic;
  }
}
