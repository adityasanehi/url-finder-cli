# 🔍 URL Finder - Advanced URL Detection Tool

A beautiful, modern CLI tool for discovering URLs in source code repositories and local directories. Built with love for developers and security researchers.

![URL Finder Demo](demo.png)

## ✨ Features

- **🎨 Beautiful ASCII Art Interface** - Professional terminal UI with stunning visuals
- **📄 Paginated Navigation** - Clean 4-page flow with down-arrow navigation
- **🐙 GitHub Repository Support** - Clone and scan remote repositories automatically
- **📁 Local Directory Scanning** - Analyze your local projects and codebases
- **🎯 Smart File Filtering** - Ignores dependencies, lock files, and build artifacts
- **🔗 Comprehensive URL Detection** - Finds HTTP(S), FTP, and www URLs
- **🌈 Color-Coded Output** - Easy-to-read results with icons and highlighting
- **🖥️ Terminal Title Control** - Dynamic title bar showing current operation
- **🧹 Automatic Cleanup** - Smart temporary file management

## 🚀 Quick Start

### Installation

1. **Download the script:**
   ```bash
   curl -O https://raw.githubusercontent.com/yourusername/url-finder/main/find_urls.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x find_urls.sh
   ```

3. **Run it:**
   ```bash
   ./find_urls.sh
   ```

### Prerequisites

- **Bash 3.0+** (works on macOS and Linux)
- **Git** (optional, required only for GitHub repository scanning)
- **Terminal with Unicode support** (for best visual experience)

## 📖 Usage

### Command Line Options

```bash
./find_urls.sh [options]

Options:
  -h, --help     Show help message and exit
```

### Navigation

- **↓ (Down Arrow)** - Navigate between pages
- **q** - Quit at any time
- **1** - Select local directory scanning
- **2** - Select GitHub repository scanning

### Supported Inputs

#### 📁 Local Directories
```bash
# Absolute paths
/Users/username/Projects/my-app

# Relative paths
./my-project
../other-project

# Home directory
~/Documents/code
```

#### 🐙 GitHub Repositories
```bash
# HTTPS URLs
https://github.com/username/repository
https://github.com/username/repository.git

# SSH URLs
git@github.com:username/repository.git
```

## 🎯 What It Scans

### ✅ Included File Types

**Programming Languages:**
- JavaScript/TypeScript: `.js`, `.jsx`, `.ts`, `.tsx`
- Python: `.py`
- Java: `.java`
- C/C++: `.c`, `.cpp`, `.h`, `.hpp`
- C#: `.cs`
- PHP: `.php`
- Ruby: `.rb`
- Go: `.go`
- Rust: `.rs`
- Swift: `.swift`
- Kotlin: `.kt`
- Scala: `.scala`
- Dart: `.dart`

**Web Technologies:**
- HTML: `.html`, `.htm`
- CSS: `.css`, `.scss`, `.sass`, `.less`
- Vue: `.vue`

**Configuration & Data:**
- YAML: `.yml`, `.yaml`
- JSON: `.json`
- XML: `.xml`
- TOML: `.toml`
- INI: `.ini`, `.cfg`, `.conf`
- Environment: `.env`

**Documentation & Scripts:**
- Markdown: `.md`
- Text: `.txt`, `.rst`, `.tex`
- Shell scripts: `.sh`, `.bash`, `.zsh`, `.fish`
- Batch files: `.bat`, `.cmd`, `.ps1`
- Dockerfiles, Makefiles

### ❌ Excluded Files/Directories

**Dependencies:**
- `node_modules/`, `vendor/`, `target/`
- `__pycache__/`, `.pytest_cache/`

**Build Outputs:**
- `build/`, `dist/`, `.next/`, `.nuxt/`
- `coverage/`, `.nyc_output/`

**Lock Files:**
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `uv.lock`, `Pipfile.lock`, `poetry.lock`
- `Cargo.lock`, `Gemfile.lock`, `composer.lock`
- `go.sum`

**Minified Files:**
- `*.min.js`, `*.min.css`
- `bundle.js`, `*.bundle.*`, `*.chunk.*`

**IDE/Editor:**
- `.vscode/`, `.idea/`, `.git/`
- `.cache/`

## 📊 Output Format

The tool provides detailed output with:

- **File paths** (relative to scan directory)
- **Line numbers** where URLs are found
- **Color-coded URLs** for easy identification
- **Summary statistics** (total files and URLs)

Example output:
```
📄 src/config/api.js
  Line 15: https://api.example.com/v1/users
  Line 23: http://localhost:3000/auth

📄 README.md
  Line 45: https://github.com/user/repo
```

## 🎨 Interface Pages

The tool features a clean 4-page interface:

1. **🏠 Main Page** - Configuration and input selection
2. **🔍 Scanning Page** - File analysis with progress indicators
3. **📋 Results Page** - Detailed URL listings with file locations
4. **📊 Summary Page** - Final statistics and completion

## 🔧 Technical Details

### URL Detection Patterns

The tool uses comprehensive regex patterns to detect:
- **HTTP/HTTPS URLs**: `https?://[domain]/[path]`
- **FTP URLs**: `ftp://[domain]/[path]`
- **WWW URLs**: `www.[domain]/[path]`

### Performance

- **Fast scanning** with optimized `find` commands
- **Memory efficient** with streaming file processing
- **Smart filtering** to avoid scanning unnecessary files
- **Shallow git clones** for faster repository downloads

## 🛡️ Security Features

- **Temporary file cleanup** - Automatic removal of cloned repositories
- **Input validation** - Checks for valid directories and GitHub URLs
- **Safe path handling** - Proper escaping of special characters
- **No data persistence** - Scan results are not stored

## 🐛 Troubleshooting

### Common Issues

**"declare: -g: invalid option"**
- Solution: Script fixed for compatibility with older bash versions

**"Directory does not exist"**
- Check path spelling and permissions
- Use absolute paths for clarity
- Ensure spaces in paths are properly escaped

**"Git not found"**
- Install git: `brew install git` (macOS) or `apt install git` (Linux)
- Only affects GitHub repository scanning

**Unicode characters not displaying**
- Use a modern terminal with Unicode support
- Try iTerm2 (macOS) or modern Linux terminals

### Debug Mode

For troubleshooting, you can add debug output:
```bash
bash -x ./find_urls.sh
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on both macOS and Linux
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with modern bash scripting best practices
- Inspired by security research workflows
- Designed for developer productivity

## 📞 Support

If you encounter issues or have questions:

1. Check the troubleshooting section
2. Search existing issues
3. Create a new issue with details about your environment

---

**⭐ Star this repository if you find it useful!**

Made with ❤️ for the developer community