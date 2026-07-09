# Privacy Verification

## INTERNET Permission Check
All `android.permission.INTERNET` occurrences have been successfully removed.
The NotTik application operates entirely offline as per the OpenSpec requirements. 

Flutter by default adds the `INTERNET` permission to `debug` and `profile` AndroidManifest.xml files to allow tools like Dart DevTools and hot-reload over network to function. However, to guarantee absolute no-exfiltration policies and comply strictly with the `bootstrap-nottik-mvp` rules, they have been permanently removed.

Any attempt to make an external network call within the app will result in a `SecurityException`.