class Stats {
  int? _acceptedAnnotations = 0;
  int? _contributors = 0;
  int? _iqEarners = 0;
  int? _transcribers = 0;
  int? _unreviewedAnnotations = 0;
  int? _verifiedAnnotations = 0;
  bool? _hot = false;
  int? _pageviews = 0;
  Map<String, dynamic> _stats = {};

  Stats({required Map<String, dynamic> stats}) {
    _stats = stats;
    _acceptedAnnotations = stats["accepted_annotations"];
    _contributors = stats["contributors"];
    _iqEarners = stats["iq_earners"];
    _transcribers = stats["transcribers"];
    _unreviewedAnnotations = stats["unreviewed_annotations"];
    _verifiedAnnotations = stats["verified_annotations"];
    _hot = stats["hot"];
    _pageviews = stats["pageviews"];
  }

  /// Returns the stats data
  Map<String, dynamic> get stats => _stats;

  int? get acceptedAnnotations => _acceptedAnnotations;

  int? get contributors => _contributors;

  int? get iqEarners => _iqEarners;

  int? get transcribers => _transcribers;

  int? get unreviewedAnnotations => _unreviewedAnnotations;

  int? get verifiedAnnotations => _verifiedAnnotations;

  bool? get hot => _hot;

  int? get pageviews => _pageviews;
}
