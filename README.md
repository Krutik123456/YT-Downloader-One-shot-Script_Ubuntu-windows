# YT-Downloader

**One-shot YouTube video & playlist downloader** — paste a link, pick quality & format, go.

Supports **single videos** and **full playlists** with automatic file numbering, metadata embedding, and thumbnail art.

---

## Features

| Feature | Details |
|---|---|
| 🎬 **Single video** | One URL = one file |
| 📋 **Playlists** | Auto-numbers files by index, creates per-playlist folder |
| 🎵 **MP3 audio** | Extracts audio, embeds thumbnail + metadata |
| 🎞️ **MP4 video** | Merges best audio + video, adds cover art |
| ⚡ **Quality picker** | MP3: 128k / 192k / 320k — MP4: 360p → 1080p → Best |
| 🖼️ **Thumbnails** | Embedded into every downloaded file |
| 🧾 **Metadata** | Title, artist, album tags from YouTube |
| 📝 **Subtitles** | Optional — download manual + auto-generated captions, embed or keep separate |
| 🚫 **No overwrites** | Already-downloaded files are skipped automatically |
| 📂 **Organised output** | `~/Documents/yt-downloader/<title>/<N> - <name>.mp4` |

---

## Scripts

- **`Ubuntu_yt.sh`** — Bash (Linux, macOS, WSL, Git Bash)
- **`Windows_yt.ps1`** — PowerShell (Windows)

---

## Prerequisites

### Required (both platforms)

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — `pip install yt-dlp`
- [ffmpeg](https://ffmpeg.org/) — audio/video processing

### Platform-specific

#### Linux / macOS
```bash
pip install yt-dlp
# ffmpeg via your package manager, e.g.
sudo apt install ffmpeg       # Debian/Ubuntu
brew install ffmpeg           # macOS
```

#### Windows
```powershell
pip install yt-dlp
winget install ffmpeg          # or scoop/choco
# Or download manually from https://ffmpeg.org/download.html
```

---

## Usage

### Linux / macOS / WSL

```bash
# Direct
bash ~/Documents/yt-downloader/Ubuntu_yt.sh

# Or with alias (add to ~/.bash_aliases or ~/.zshrc)
alias yt='bash ~/Documents/yt-downloader/Ubuntu_yt.sh'
yt
```

### Windows

```powershell
# Run from PowerShell
.\Documents\yt-downloader\Windows_yt.ps1

# Or one-shot from cmd
powershell -ExecutionPolicy Bypass -File "%USERPROFILE%\Documents\yt-downloader\Windows_yt.ps1"
```

### What you'll see

```
╔══════════════════════════════════════╗
║       YT-Downloader  (yt-dlp)        ║
║  Video / Playlist / MP3 / MP4        ║
╚══════════════════════════════════════╝

📎 Paste YouTube URL (video or playlist):
> https://youtube.com/watch?v=...

📦 Select download format:
  1) MP3  — audio only
  2) MP4  — video + audio
```

Answer format, quality, then optionally configure subtitles. Press Enter and it downloads — that's it.

---

## Output structure

```
~/Documents/yt-downloader/
├── Ubuntu_yt.sh
├── Windows_yt.ps1
├── README.md
├── My Video Title/
│   ├── My Video Title.mp4
│   └── My Video Title.en.vtt          # (if subtitles enabled)
└── My Playlist/
    ├── 1 - First Song.mp3
    ├── 2 - Second Song.mp3
    └── ...
```

---

## How it works

The script wraps [yt-dlp](https://github.com/yt-dlp/yt-dlp) — the most powerful YouTube downloader available. Key arguments used:

| Argument | What it does |
|---|---|
| `-x --audio-format mp3` | Extract audio to MP3 |
| `--audio-quality 192k` | Set audio bitrate |
| `-f bestvideo[height<=1080]+bestaudio` | Select video quality |
| `--embed-thumbnail` | Embed video thumbnail |
| `--add-metadata` | Add title/artist tags |
| `--no-overwrites` | Skip existing files |
| `--ignore-errors` | Continue on errors (playlists) |
| `--write-subs` | Download subtitle files (.vtt / .srt) |
| `--write-auto-subs` | Include YouTube auto-generated captions |
| `--sub-langs en` | Language filter for subtitles |
| `--embed-subs` | Merge subtitles into the video file (mp4/mkv) |

---

## License

MIT — use freely, modify, share.
