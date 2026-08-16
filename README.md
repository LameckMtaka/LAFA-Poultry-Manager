# LAFA Poultry Solution Pro v4.1.1 FINAL

Offline-first Android poultry management and farming solution.

## Core modules
- Modern dashboard and daily reminders
- Incubation batches: Day 8 candling, Day 18 lockdown, Day 21 hatch, Day 22 chick removal
- Camera Candling Assistant (experimental decision-support)
- Chick growth and vaccination reminders
- Multiple incubators, temperature/humidity records
- Hatch rate and mortality records
- Poultry Solution Center: feeding plans, scalable feed formulas, disease library, housing/biosecurity and farm records
- Kiswahili / English global language selection
- JSON backup / restore
- LAFA branding and launcher icon

## Build APK on GitHub
Upload/replace the project files in your existing repository. The workflow must be at:
`.github/workflows/build-apk.yml`

Then open **Actions → Build Android APK → Run workflow**. When green, open the run **Summary → Artifacts → LAFA-Poultry-Solution-Pro-v4.1-APK**.

## Veterinary safety
The health library is educational decision-support based on the supplied books. It does not replace diagnosis by a veterinarian/livestock officer. Antibiotics, anticoccidials and other medicines must follow registered product labels, professional advice and egg/meat withdrawal periods.


## v4.1 FINAL - Vaccination Schedule Profiles
- Kienyeji / Indigenous
- Broiler
- Layer
- Chotara / Dual-purpose
- Custom / My Schedule
- Every profile is editable on the phone
- Enable/disable individual events
- Add/delete schedule events
- Day-after-hatch scheduling
- Repeat every N months for N repetitions
- Vaccine/deworming/management event categories
- Change a profile per chick batch
- Automatic cancellation + rescheduling of notifications after profile changes
- Reset all built-in profiles to defaults
- Profiles are included in JSON Backup/Restore
- Global Swahili / English setting remains persistent

### Important
Uploaded poultry guides contain different vaccination schedules. v4.1 keeps these as separate editable starter profiles instead of pretending one schedule is universally correct. Confirm the schedule for your area, hatchery, breed, vaccine manufacturer and disease pressure with a veterinary professional.
