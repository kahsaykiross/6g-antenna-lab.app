// lib/models/proposal.dart
// Simple data model for the proposal content displayed in the app.
// For demo purposes we include a sample factory. Replace / extend with actual parsed PDF content if needed.

class Proposal {
  final String title;
  final String author;
  final String abstractText;
  final List<String> keywords;
  final List<Section> sections;

  Proposal({
    required this.title,
    required this.author,
    required this.abstractText,
    required this.keywords,
    required this.sections,
  });

  // Simple sample that mirrors the earlier uploaded proposal.
  factory Proposal.sample() {
    return Proposal(
      title: 'Innovative Antenna Architectures for 5G and 6G Telecommunication Systems',
      author: 'Kahsay Kiross Meresa',
      abstractText: 'This research focuses on innovative antenna solutions combining electromagnetic design and signal processing for mmWave and sub-THz systems, hybrid beamforming, and RIS control.',
      keywords: ['5G', '6G', 'hybrid beamforming', 'RIS', 'antenna design'],
      sections: [
        Section(title: 'Introduction', content: 'Rationale, objectives and background.'),
        Section(title: 'Methodology', content: 'Hybrid beamforming, RIS optimization, measurement campaigns.'),
        Section(title: 'Experimental Plan', content: 'EM simulation, prototype hardware, SDR validation.'),
        Section(title: 'Expected Outcomes', content: 'Improved energy efficiency and adaptive beam control for 6G systems.'),
      ],
    );
  }
}

class Section {
  final String title;
  final String content;
  Section({required this.title, required this.content});
}
