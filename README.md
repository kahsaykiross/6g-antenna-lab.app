# 6g-antenna-lab.app
This Flutter app is a research lab tool for 5G/6G antenna systems. 
It includes a proposal viewer, hybrid beamforming controls, 
RIS tuning UI, and calibration diagnostics. 
Each simulation run is saved with parameters and results, 
and can be exported as CSV or PNG. Lightweight, modular, 
and ready for backend integration or advanced DSP extensions.
# 6G Antenna Lab App

## Features

- **Proposal Viewer:** View and manage research proposals and experimental setups.  
- **Hybrid Beamforming Controls:** Adjust and simulate beamforming configurations for MIMO and phased array antennas.  
- **RIS Tuning UI:** Reconfigurable Intelligent Surface (RIS) tuning interface for optimizing antenna reflections.  
- **Calibration Diagnostics:** Built-in tools to run calibration checks and verify system performance.  
- **Simulation Data Export:** Each simulation run is automatically saved with parameters and results. Data can be exported as CSV or PNG for further analysis.  

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0
- Dart ≥ 3.0
- Compatible IDE (VS Code, Android Studio, or IntelliJ IDEA)
- Device/emulator with Android or iOS support  

### Installation
1. Clone the repository:  
   ```bash
   git clone https://github.com/kahsaykiross/6g-antenna-lab.app.git
navigate the project directory 
cd 6g-antenna-lab.app
install dependency
flutter pub get
run the app
flutter run
Project Structure

lib/ – Main Dart source code

screens/ – UI pages for beamforming, RIS tuning, proposal viewer, and diagnostics

models/ – Data models for simulation parameters and results

services/ – Backend integration, CSV/PNG export, and simulation logic

widgets/ – Reusable UI components

assets/ – Images, icons, and proposal documents

test/ – Unit and widget tests

Contributing

Contributions are welcome! Please fork the repository, create a feature branch, and submit a pull request. Ensure proper documentation and testing for new features.

License

 License. See the LICENSE
 file for details.

Contact

For questions, feedback, or collaboration, please contact Kahsay Kiross at kahsaykirossmtc@gmail.com
flutter-6g-lab/
├─ pubspec.yaml
├─ README.md
├─ lib/
│  ├─ main.dart
│  ├─ models/
│  │  └─ proposal.dart
│  ├─ services/
│  │  └─ backend_service.dart
│  ├─ pages/
│  │  ├─ home_page.dart
│  │  └─ proposal_page.dart
│  ├─ widgets/
│  │  └─ array_pattern_widget.dart
│  └─ utils/
│     └─ dsp_math.dart
└─ assets/
   └─ proposal.json   (optional cached proposal content)

