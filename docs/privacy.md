# NotTik Privacy and Safety

- **Notification Access:** NotTik requires Android Notification Access to function.
- **Local Storage:** All extracted notification content (text, icons, images) is saved strictly to local device storage (SQLite/Room and internal files). 
- **No Backend & No Analytics:** There is no server to sync to, and no analytics SDKs are included. 
- **No INTERNET Permission:** The app does not declare `android.permission.INTERNET`, physically preventing network exfiltration.
- **Limitations:** NotTik cannot recover notifications sent before installation or before the permission was granted. It does not bypass OS-level redactions (like hidden OTPs).
- **Physical Access:** The MVP does not currently implement app-level biometric locking, meaning anyone with physical access to your unlocked phone could open the app and read the history.
