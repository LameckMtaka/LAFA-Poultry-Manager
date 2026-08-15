# LAFA Poultry Manager v2.0 — GitHub Ready

App ya Android ya incubation, candling, hatch, makuzi na vaccination reminders.

## Features
- Camera Candling Assistant: Fertile / Infertile / Dead Embryo / Suspect (experimental image analysis)
- Day 8 candling alarm
- Day 18 transfer / lockdown alarm
- Day 21 hatch alarm
- Day 22 chick-removal alarm
- Day 7 Newcastle I
- Day 14 Gumboro I
- Day 21 Newcastle II
- Day 28 Gumboro II
- Day 35 Ndui / Fowl Pox
- Adult booster reminder kila baada ya miezi 3
- Multiple incubators
- Temperature & humidity records
- Egg, fertile, infertile, suspect, dead embryo and hatch records
- Hatch rate %
- Chick batches and mortality %
- Batch history
- Local Android notifications
- Kiswahili UI
- JSON backup, share and restore

## Build APK on GitHub (phone only)
Project already contains `.github/workflows/build-apk.yml`.

1. Create a new GitHub repository, for example `LAFA-Poultry-Manager`.
2. Extract this ZIP on your Android phone.
3. Upload the project files/folders to the repository and commit them to the default branch (`main`).
4. Confirm `.github/workflows/build-apk.yml` exists in the repository.
5. Open **Actions** → **Build Android APK** → **Run workflow**.
6. Open the completed green workflow run.
7. Under **Artifacts**, download **LAFA-Poultry-Manager-v2-APK**.
8. Extract the downloaded artifact ZIP and install `LAFA-Poultry-Manager-v2.apk` on your Android phone.

If Android blocks installation, allow **Install unknown apps** for the browser/file manager you used to open the APK.

## Important about Camera Candling
The v2.0 camera feature is an experimental offline image-analysis assistant. It analyzes image brightness, red/vascular signal and dark regions. It is not a validated veterinary AI model and must not be treated as 100% accurate. Shell color, candling lamp, exposure and camera angle can change the result. Recheck Suspect eggs after 1–2 days and do not discard eggs based only on the app prediction.
