# Prepare Play Release Design

## Release signing
Use Android Gradle signing configs backed by `android/key.properties`. The file points to a local JKS keystore and stores aliases/passwords outside version control.

Release builds must not silently use the debug signing config. If signing data is missing, the Gradle build should fail with a clear message.

## About page
Add a normal Flutter screen reachable from Settings. Keep it local-only; opening links uses Android intents through `url_launcher` and does not add the `INTERNET` permission.

Content:
- App purpose and honest privacy limits.
- Website: `https://nottik.app`.
- GitHub: `https://github.com/isina-nej/NotTik`.

## Documentation
README should explain:
- What NotTik does.
- Privacy model and limitations.
- Architecture.
- Development setup.
- Testing commands.
- Release signing and Play output.

`docs/release.md` should contain the exact release checklist and keystore handling rules.

## Cleanup
Do not use broad `git clean -X` because this project currently ignores Gradle wrapper files. Remove only disposable caches/build artifacts with explicit paths.
