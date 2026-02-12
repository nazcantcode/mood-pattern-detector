import 'package:flutter/material.dart';
//hghfyitf
//test for person 2
void main() {
  runApp(const MoodPatternApp());
}

class MoodPatternApp extends StatelessWidget {
  const MoodPatternApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Pattern Detector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MoodTrackerHome(title: '🧠 Mood Pattern Detective'),
    );
  }
}

class MoodTrackerHome extends StatefulWidget {
  const MoodTrackerHome({super.key, required this.title});

  final String title;

  @override
  State<MoodTrackerHome> createState() => _MoodTrackerHomeState();
}

class MoodEntry {
  DateTime timestamp;
  String mood;
  int intensity;
  List<String> tags;
  String note;
  Map<String, int> factors;

  MoodEntry({
    required this.mood,
    required this.intensity,
    this.tags = const [],
    this.note = '',
    this.factors = const {},
  }) : timestamp = DateTime.now();
}

class _MoodTrackerHomeState extends State<MoodTrackerHome> {
  List<MoodEntry> moodHistory = [];
  Map<String, int> moodFrequency = {};
  Map<String, dynamic> patternInsights = {};
  String currentPattern = "";
  bool analysisMode = false;
  int totalEntries = 0;
  double averageMood = 0.0;

  String selectedMood = "Neutral";
  int selectedIntensity = 5;
  List<String> selectedTags = [];
  String currentNote = "";
  List<String> insightsList = [];

  void _addMoodEntry() {
    Map<String, int> factors = {
      'sleep': (selectedIntensity * 0.3).round(),
      'social': (selectedIntensity * 0.2).round(),
      'work': (selectedIntensity * 0.25).round(),
      'health': (selectedIntensity * 0.25).round(),
    };

    MoodEntry newEntry = MoodEntry(
      mood: selectedMood,
      intensity: selectedIntensity,
      tags: List.from(selectedTags),
      note: currentNote,
      factors: factors,
    );

    setState(() {
      moodHistory.add(newEntry);
      totalEntries = totalEntries + 1;
      moodFrequency[selectedMood] = (moodFrequency[selectedMood] ?? 0) + 1;
      _calculateAverageMood();

      if (totalEntries % 3 == 0) {
        _detectPatterns();
      }

      if (moodHistory.length >= 2) {
        MoodEntry lastEntry = moodHistory[moodHistory.length - 2];
        if (selectedIntensity > lastEntry.intensity + 2) {
          _addInsight("Mood intensity increased significantly");
        } else if (selectedIntensity < lastEntry.intensity - 2) {
          _addInsight("Mood intensity decreased significantly");
        }
      }

      _resetInputs();
    });
  }

  void _calculateAverageMood() {
    if (moodHistory.isEmpty) {
      averageMood = 0.0;
      return;
    }

    int totalIntensity = 0;
    for (int i = 0; i < moodHistory.length; i++) {
      totalIntensity = totalIntensity + moodHistory[i].intensity;
    }

    averageMood = totalIntensity / moodHistory.length;

    if (averageMood > 7.5) {
      _addInsight("Consistently positive mood pattern detected");
    } else if (averageMood < 4.0) {
      _addInsight("Consider exploring mood improvement strategies");
    }
  }

  void _detectPatterns() {
    patternInsights.clear();

    if (moodHistory.length < 3) {
      currentPattern = "Need more data for pattern detection";
      return;
    }

    int positiveCount = 0;
    int negativeCount = 0;
    int neutralCount = 0;

    for (var entry in moodHistory) {
      switch (entry.mood) {
        case 'Happy':
        case 'Excited':
        case 'Peaceful':
          positiveCount = positiveCount + 1;
          break;
        case 'Sad':
        case 'Anxious':
        case 'Angry':
          negativeCount = negativeCount + 1;
          break;
        default:
          neutralCount = neutralCount + 1;
      }
    }

    double total = moodHistory.length.toDouble();
    patternInsights['positive_pct'] = (positiveCount / total) * 100;
    patternInsights['negative_pct'] = (negativeCount / total) * 100;
    patternInsights['neutral_pct'] = (neutralCount / total) * 100;

    if (positiveCount > negativeCount && positiveCount > neutralCount) {
      currentPattern = "Positivity Trend";
      if (positiveCount > (total * 0.7)) {
        _addInsight("Strong positive bias in mood history");
      }
    } else if (negativeCount > positiveCount && negativeCount > neutralCount) {
      currentPattern = "Negativity Trend";
    } else {
      currentPattern = "Balanced Mood Pattern";
    }

    _analyzeTimePatterns();
    _analyzeTagCorrelations();
  }

  void _analyzeTimePatterns() {
    Map<String, int> hourDistribution = {};

    int index = 0;
    while (index < moodHistory.length) {
      MoodEntry entry = moodHistory[index];
      int hour = entry.timestamp.hour;

      String timeSlot;
      if (hour >= 5 && hour < 12) {
        timeSlot = "Morning";
      } else if (hour >= 12 && hour < 17) {
        timeSlot = "Afternoon";
      } else if (hour >= 17 && hour < 22) {
        timeSlot = "Evening";
      } else {
        timeSlot = "Night";
      }

      hourDistribution[timeSlot] = (hourDistribution[timeSlot] ?? 0) + 1;
      index = index + 1;
    }

    String mostCommonSlot = "Morning";
    int highestCount = 0;

    hourDistribution.forEach((slot, count) {
      if (count > highestCount) {
        highestCount = count;
        mostCommonSlot = slot;
      }
    });

    patternInsights['peak_time'] = mostCommonSlot;

    if (hourDistribution.containsKey("Morning") && hourDistribution["Morning"]! > (totalEntries * 0.4)) {
      _addInsight("Most entries recorded in mornings");
    }
  }

  void _analyzeTagCorrelations() {
    Map<String, Map<String, int>> moodTagCorrelation = {};

    for (var entry in moodHistory) {
      String mood = entry.mood;

      if (!moodTagCorrelation.containsKey(mood)) {
        moodTagCorrelation[mood] = {};
      }

      for (var tag in entry.tags) {
        moodTagCorrelation[mood]![tag] = (moodTagCorrelation[mood]![tag] ?? 0) + 1;
      }
    }

    moodTagCorrelation.forEach((mood, tags) {
      if (tags.isNotEmpty) {
        String mostCommonTag = "";
        int maxCount = 0;

        tags.forEach((tag, count) {
          if (count > maxCount) {
            maxCount = count;
            mostCommonTag = tag;
          }
        });

        if (maxCount >= 2) {
          patternInsights['${mood}_correlation'] = mostCommonTag;
        }
      }
    });
  }

  void _addInsight(String insight) {
    insightsList.add(insight);

    if (insightsList.length > 5) {
      insightsList.removeAt(0);
    }
  }

  void _toggleAnalysisMode() {
    setState(() {
      analysisMode = !analysisMode;

      if (analysisMode && moodHistory.isNotEmpty) {
        _detectPatterns();
      }
    });
  }

  void _resetInputs() {
    selectedMood = "Neutral";
    selectedIntensity = 5;
    selectedTags.clear();
    currentNote = "";
  }

  void _clearAllData() {
    setState(() {
      moodHistory.clear();
      moodFrequency.clear();
      patternInsights.clear();
      insightsList.clear();
      currentPattern = "";
      totalEntries = 0;
      averageMood = 0.0;
      _resetInputs();
    });
  }

  void _loadSampleData() {
    setState(() {
      _clearAllData();

      List<MoodEntry> samples = [
        MoodEntry(mood: "Happy", intensity: 8, tags: ["work", "achievement"], note: "Completed project"),
        MoodEntry(mood: "Anxious", intensity: 6, tags: ["meeting", "pressure"], note: "Important presentation"),
        MoodEntry(mood: "Peaceful", intensity: 7, tags: ["weekend", "nature"], note: "Morning walk"),
        MoodEntry(mood: "Sad", intensity: 4, tags: ["alone", "tired"], note: "Missed family"),
        MoodEntry(mood: "Excited", intensity: 9, tags: ["plans", "friends"], note: "Weekend trip planned"),
        MoodEntry(mood: "Neutral", intensity: 5, tags: ["routine", "work"], note: "Regular day"),
        MoodEntry(mood: "Happy", intensity: 8, tags: ["celebration", "friends"], note: "Birthday party"),
        MoodEntry(mood: "Tired", intensity: 3, tags: ["long-day", "work"], note: "Overtime at work"),
      ];

      for (var entry in samples) {
        moodHistory.add(entry);
        totalEntries = totalEntries + 1;
        moodFrequency[entry.mood] = (moodFrequency[entry.mood] ?? 0) + 1;
      }

      _calculateAverageMood();
      _detectPatterns();
    });
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Happy':
        return '😊';
      case 'Excited':
        return '🎉';
      case 'Peaceful':
        return '😌';
      case 'Neutral':
        return '😐';
      case 'Sad':
        return '😢';
      case 'Anxious':
        return '😰';
      case 'Angry':
        return '😠';
      case 'Tired':
        return '😴';
      default:
        return '❓';
    }
  }

  Color _getMoodColor(String mood) {
    if (mood == 'Happy' || mood == 'Excited' || mood == 'Peaceful') {
      return Colors.green;
    } else if (mood == 'Sad' || mood == 'Anxious' || mood == 'Angry') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  List<String> _getTopMoods() {
    if (moodFrequency.isEmpty) return [];

    List<MapEntry<String, int>> entries = moodFrequency.entries.toList();

    for (int i = 0; i < entries.length - 1; i++) {
      for (int j = i + 1; j < entries.length; j++) {
        if (entries[j].value > entries[i].value) {
          var temp = entries[i];
          entries[i] = entries[j];
          entries[j] = temp;
        }
      }
    }

    return entries.take(3).map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<String> topMoods = _getTopMoods();
    List<MapEntry<String, dynamic>> correlationEntries =
    patternInsights.entries.where((entry) => entry.key.endsWith('_correlation')).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(analysisMode ? Icons.analytics : Icons.analytics_outlined),
            onPressed: _toggleAnalysisMode,
            tooltip: 'Toggle Analysis Mode',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // INPUT SECTION - Fixed height
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'How are you feeling right now?',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          // Mood Selection
                          const Text('Select Mood:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              'Happy', 'Excited', 'Peaceful', 'Neutral',
                              'Sad', 'Anxious', 'Angry', 'Tired'
                            ].map((mood) {
                              Color baseColor = _getMoodColor(mood);
                              return ChoiceChip(
                                label: Text('${_getMoodEmoji(mood)} $mood'),
                                selected: selectedMood == mood,
                                onSelected: (_) {
                                  setState(() {
                                    selectedMood = mood;
                                  });
                                },
                                backgroundColor: baseColor.withOpacity(0.1),
                                selectedColor: baseColor,
                                labelStyle: TextStyle(
                                  color: selectedMood == mood ? Colors.white : Colors.black,
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // Intensity Slider
                          Text('Intensity: $selectedIntensity/10', style: TextStyle(fontWeight: FontWeight.bold)),
                          Slider(
                            value: selectedIntensity.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            onChanged: (value) {
                              setState(() {
                                selectedIntensity = value.round();
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // Quick Tags
                          const Text('Quick Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              'work', 'home', 'social', 'alone',
                              'achievement', 'stress', 'relaxed', 'tired'
                            ].map((tag) {
                              return FilterChip(
                                label: Text(tag),
                                selected: selectedTags.contains(tag),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedTags.add(tag);
                                    } else {
                                      selectedTags.remove(tag);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _addMoodEntry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Record Mood Entry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // STATS SECTION
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Total Entries', '$totalEntries'),
                      _buildStatCard('Avg Intensity', averageMood.toStringAsFixed(1)),
                      _buildStatCard('Pattern', currentPattern, isPattern: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ANALYSIS SECTION
              if (analysisMode && patternInsights.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '📊 Pattern Insights',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        if (patternInsights.containsKey('positive_pct'))
                          _buildPercentageRow('Positive', patternInsights['positive_pct'] as double),
                        if (patternInsights.containsKey('negative_pct'))
                          _buildPercentageRow('Negative', patternInsights['negative_pct'] as double),
                        if (patternInsights.containsKey('neutral_pct'))
                          _buildPercentageRow('Neutral', patternInsights['neutral_pct'] as double),

                        ...correlationEntries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('🔗 ${entry.key.replaceAll('_correlation', '')} → "${entry.value}"',
                                style: const TextStyle(fontSize: 12)),
                          );
                        }),

                        if (patternInsights.containsKey('peak_time'))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('⏰ Peak time: ${patternInsights['peak_time']}',
                                style: const TextStyle(fontSize: 12)),
                          ),

                        if (insightsList.isNotEmpty)
                          ...insightsList.map((insight) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('💡 $insight', style: const TextStyle(fontSize: 12)),
                          )).toList(),

                        if (topMoods.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Most frequent: ${topMoods.map((m) => '${_getMoodEmoji(m)} $m').join(', ')}',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // HISTORY SECTION - Takes remaining space
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '📝 Recent Entries',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        Expanded(
                          child: moodHistory.isEmpty
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.psychology, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                const Text('No mood entries yet'),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _loadSampleData,
                                  child: const Text('Tap to load sample data'),
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            itemCount: moodHistory.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              MoodEntry entry = moodHistory[moodHistory.length - 1 - index];
                              String time = '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}';
                              Color baseColor = _getMoodColor(entry.mood);

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: baseColor.withOpacity(0.05),
                                child: ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    backgroundColor: baseColor,
                                    radius: 16,
                                    child: Text(
                                      _getMoodEmoji(entry.mood),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  title: Text('${entry.mood} (${entry.intensity}/10)',
                                      style: const TextStyle(fontSize: 14)),
                                  subtitle: entry.tags.isNotEmpty
                                      ? Text('Tags: ${entry.tags.join(', ')}',
                                      style: const TextStyle(fontSize: 11))
                                      : null,
                                  trailing: Text(time, style: const TextStyle(fontSize: 12)),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              onPressed: _clearAllData,
              tooltip: 'Clear All Data',
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete, size: 20),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: _loadSampleData,
              tooltip: 'Load Sample Data',
              backgroundColor: Colors.blue,
              child: const Icon(Icons.data_exploration, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, {bool isPattern = false}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPattern ? Colors.purple : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageRow(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text('$label:', style: const TextStyle(fontSize: 12))),
          Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}