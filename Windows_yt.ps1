<#
  ─────────────────────────────────────────────
  YT-Downloader.ps1 — YouTube Video & Playlist
  One-shot: paste link → choose quality → go
  ─────────────────────────────────────────────
#>

$BaseDir = "$env:USERPROFILE\Documents\yt-downloader"
New-Item -ItemType Directory -Force -Path $BaseDir | Out-Null

function Show-Banner {
    Clear-Host
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║       YT-Downloader  (yt-dlp)        ║" -ForegroundColor Cyan
    Write-Host "║  Video / Playlist / MP3 / MP4        ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host
}

function Check-Deps {
    $ytdlp = Get-Command yt-dlp -ErrorAction SilentlyContinue
    if (-not $ytdlp) {
        Write-Host "[!] yt-dlp not found. Installing..." -ForegroundColor Red
        pip install yt-dlp
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[!] Failed to install yt-dlp. Try: pip install yt-dlp" -ForegroundColor Red
            exit 1
        }
    }

    $ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if (-not $ffmpeg) {
        Write-Host "[!] ffmpeg not found." -ForegroundColor Red
        Write-Host "    Download from: https://ffmpeg.org/download.html" -ForegroundColor Yellow
        Write-Host "    Or install via: winget install ffmpeg" -ForegroundColor Yellow
        Write-Host "    Or: choco install ffmpeg" -ForegroundColor Yellow
        Write-Host "    Or: scoop install ffmpeg" -ForegroundColor Yellow
        exit 1
    }
}

function Ask-Url {
    Write-Host
    Write-Host "📎 Paste YouTube URL (video or playlist):" -ForegroundColor Yellow
    $script:VideoUrl = Read-Host
    if ([string]::IsNullOrWhiteSpace($script:VideoUrl)) {
        Write-Host "[!] No URL entered. Exiting." -ForegroundColor Red
        exit 1
    }
}

function Ask-Format {
    Write-Host
    Write-Host "📦 Select download format:" -ForegroundColor Yellow
    Write-Host "  1) MP3  — audio only (extract/convert)"
    Write-Host "  2) MP4  — video + audio"
    Write-Host
    $choice = Read-Host "Choice [1/2]"
    switch ($choice) {
        "1" { $script:Format = "mp3" }
        "2" { $script:Format = "mp4" }
        default {
            Write-Host "[⇒] Invalid. Defaulting to MP4." -ForegroundColor Yellow
            $script:Format = "mp4"
        }
    }
}

function Ask-Quality {
    Write-Host
    if ($script:Format -eq "mp3") {
        Write-Host "🎵 Select audio quality:" -ForegroundColor Yellow
        Write-Host "  1) Best  (320k — largest file)"
        Write-Host "  2) Good  (192k — balanced)"
        Write-Host "  3) Fair  (128k — smaller)"
        Write-Host
        $choice = Read-Host "Choice [1/2/3]"
        switch ($choice) {
            "1" { $script:Quality = "320" }
            "2" { $script:Quality = "192" }
            "3" { $script:Quality = "128" }
            default {
                Write-Host "[⇒] Defaulting to 192k" -ForegroundColor Yellow
                $script:Quality = "192"
            }
        }
    } else {
        Write-Host "🎬 Select video quality:" -ForegroundColor Yellow
        Write-Host "  1) Best     (highest available)"
        Write-Host "  2) 1080p    (Full HD)"
        Write-Host "  3) 720p     (HD)"
        Write-Host "  4) 480p     (SD)"
        Write-Host "  5) 360p     (low)"
        Write-Host
        $choice = Read-Host "Choice [1/2/3/4/5]"
        switch ($choice) {
            "1" { $script:Quality = "bestvideo+bestaudio/best" }
            "2" { $script:Quality = "bestvideo[height<=1080]+bestaudio/best[height<=1080]" }
            "3" { $script:Quality = "bestvideo[height<=720]+bestaudio/best[height<=720]" }
            "4" { $script:Quality = "bestvideo[height<=480]+bestaudio/best[height<=480]" }
            "5" { $script:Quality = "bestvideo[height<=360]+bestaudio/best[height<=360]" }
            default {
                Write-Host "[⇒] Defaulting to 720p" -ForegroundColor Yellow
                $script:Quality = "bestvideo[height<=720]+bestaudio/best[height<=720]"
            }
        }
    }
}

function Confirm-Download {
    $displayQuality = if ($script:Format -eq "mp3") { "${script:Quality}k" } else { $script:Quality }

    Write-Host
    Write-Host "══════════════════════════════════════" -ForegroundColor Green
    Write-Host "  URL:      " -NoNewline; Write-Host "$script:VideoUrl" -ForegroundColor Cyan
    Write-Host "  Format:   " -NoNewline; Write-Host "$script:Format" -ForegroundColor Cyan
    Write-Host "  Quality:  " -NoNewline; Write-Host "$displayQuality" -ForegroundColor Cyan
    Write-Host "  Save to:  " -NoNewline; Write-Host "$BaseDir\" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════" -ForegroundColor Green
    Write-Host
    Write-Host "⏎ Press Enter to start download (or Ctrl+C to cancel):" -ForegroundColor Yellow
    $null = Read-Host
}

function Do-Download {
    $argsList = [System.Collections.ArrayList]::new()

    if ($script:Format -eq "mp3") {
        $argsList.AddRange(@(
            "-x"
            "--audio-format", "mp3"
            "--audio-quality", "${script:Quality}k"
            "--embed-thumbnail"
            "--add-metadata"
        ))
    } else {
        $argsList.AddRange(@(
            "-f", "$script:Quality"
            "--merge-output-format", "mp4"
            "--embed-thumbnail"
            "--add-metadata"
        ))
    }

    # Common settings
    $argsList.AddRange(@(
        "--no-playlist-reverse"
        "--ignore-errors"
        "--no-overwrites"
        "--console-title"
        "--progress"
        "-o", "$BaseDir\%%(playlist_title|UNKNOWN)s\%%(playlist_index)s - %%(title)s.%%(ext)s"
    ))

    Write-Host
    Write-Host "[↓] Downloading..." -ForegroundColor Green
    Write-Host

    # yt-dlp outputs Unicode — force UTF-8 for proper display
    $oldEncoding = [Console]::OutputEncoding
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true)

    # Run yt-dlp and capture exit code
    yt-dlp @argsList $script:VideoUrl
    $exitCode = $LASTEXITCODE

    [Console]::OutputEncoding = $oldEncoding

    Write-Host
    if ($exitCode -eq 0) {
        Write-Host "[✓] Download complete!" -ForegroundColor Green
        Write-Host "    Files saved in: $BaseDir\" -ForegroundColor Cyan
    } else {
        Write-Host "[✗] Download finished with warnings/errors (exit $exitCode)." -ForegroundColor Red
    }
}

# ── Main ─────────────────────────────────────
Show-Banner
Check-Deps
Ask-Url
Ask-Format
Ask-Quality
Confirm-Download
Do-Download

Write-Host
Write-Host "────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host "  Run again:  .\Documents\yt-downloader\yt.ps1" -ForegroundColor Green
Write-Host "────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host
