# UmuCare - Doctor Appointment Booking App

UmuCare is a modern, responsive mobile application built with Flutter, designed to streamline the process of finding and booking appointments with healthcare professionals.

---

## 🌟 Features

- **Doctor Browsing:** View a list of doctors with their specialties, ratings, and consultation fees.  
- **Search & Filtering:** Easily search for doctors by name or specialty.  
- **Detailed Doctor Profiles:** Access comprehensive information about each doctor, including available days and pricing.  
- **Safe Appointment Booking:** Select a date and time slot using a robust date picker that only allows selection of dates the doctor is available.   
- **Real-time State Management:** Uses the `provider` package for simple, reactive state management across the application.  

---

## ⚙️ Architecture and Technologies

**Technology Stack:**

- **Framework:** Flutter  
- **Language:** Dart  
- **State Management:** provider  

**Core Libraries:**

- `intl` – For date and currency formatting  
- `http` – (Assumed for API integration)  

**Project Structure (Minimal View):**

lib/
├── models/
│ ├── doctor_model.dart # Data structure for doctor profiles
│ └── appointment_model.dart # Data structure for booked appointments
├── providers/
│ ├── doctor_provider.dart # Manages doctor data fetching and state
│ └── appointment_provider.dart # Manages booking and appointment history
├── screens/
│ ├── home_screen.dart # Main doctor listing screen
│ ├── doctor_detail_screen.dart # Profile and information screen
│ └── booking_details_screen.dart # Contains safe date picker logic
└── main.dart # App entry point and theme definitions

---

---

## 🛠️ Getting Started

**Prerequisites:**

- Flutter SDK installed and configured  
- A compatible IDE (VS Code or Android Studio) with Flutter and Dart extensions  

**Installation:**

```bash
git clone [YOUR_REPO_URL]
cd umucare-app
flutter pub get
flutter run
🔑 Key Implementation Detail: Safe Date Picker

To prevent the common Flutter runtime error:
'selectableDayPredicate == null || initialDate == null || selectableDayPredicate(initialDate)': 
Provided initialDate [DATE] must satisfy selectableDayPredicate.
The lib/screens/booking_details_screen.dart implements the following pattern:

Predicate Definition: A function (_isDaySelectable) defines which days are allowed based on the doctor's availability (doctor.availableDays).

Initial Date Validation: Before calling showDatePicker, the desired initialDateCandidate is checked against the predicate.

Fallback Mechanism: If the candidate date is not selectable, a utility function (_findFirstSelectableDate) iteratively finds the next selectable date.

Guaranteed Success: The validated, selectable date is then passed as initialDate to showDatePicker, ensuring the widget always initializes correctly.

This pattern ensures a smooth user experience where users returning to the booking screen weeks later will not encounter unavailable dates.

---

✅ This version:

- Uses proper headings (`#`, `##`)  
- Uses **lists** for features and steps  
- Formats **code snippets** properly with backticks  
- Uses bold or inline code where appropriate  

You can **copy-paste this directly into your `README.md`** in GitHub.  

If you want, I can also **add a section for your app logo and badges** to make it look even more professional. Do you want me to do that?
![image alt](image url)
![image alt]( https://github.com/OrlandoKhaledia/UmuCare/blob/7fd9f5ab000e7717c16d4e7ed5682105a4e3dd63/login_1%5B1%5D.png)
![image alt](https://github.com/OrlandoKhaledia/UmuCare/blob/547c3e0d048f730d3277a780dd7eff623759960f/register2%5B1%5D.png)
![image alt](https://github.com/OrlandoKhaledia/UmuCare/blob/547c3e0d048f730d3277a780dd7eff623759960f/home3%5B1%5D.png)
![image alt](https://github.com/OrlandoKhaledia/UmuCare/blob/547c3e0d048f730d3277a780dd7eff623759960f/doctors4%5B1%5D.png)
![image alt](https://github.com/OrlandoKhaledia/UmuCare/blob/547c3e0d048f730d3277a780dd7eff623759960f/booking5%5B2%5D.png)
![image alt](https://github.com/OrlandoKhaledia/UmuCare/blob/547c3e0d048f730d3277a780dd7eff623759960f/book2%5B1%5D.png)
![image alt](https://github.com/OrlandoKhaledia/UmuCare/blob/547c3e0d048f730d3277a780dd7eff623759960f/account_sett8%5B1%5D.png)
