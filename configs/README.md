# Config backups

Put application configuration that you actually want restored here.

Suggested layout:

- `git/`
- `powershell/`
- `vscode/`
- `firefox/`

The bootstrap currently does **not** copy these automatically. That is intentional:
configuration restore tends to be much more machine/user-specific than installing
the application itself. Add explicit restore scripts once you know what should be
portable between your personal PC and work laptop.
