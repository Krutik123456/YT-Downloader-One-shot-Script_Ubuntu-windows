#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  YT-Downloader — YouTube Video & Playlist
#  One-shot: paste link → choose quality → go
# ─────────────────────────────────────────────
set -euo pipefail

BASE_DIR="$HOME/Documents/yt-downloader"
mkdir -p "$BASE_DIR"

# ── Colours ──────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

banner() {
  clear 2>/dev/null || true
  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════╗"
  echo "  ║       YT-Downloader  (yt-dlp)        ║"
  echo "  ║  Video / Playlist / MP3 / MP4        ║"
  echo "  ╚══════════════════════════════════════╝"
  echo -e "${NC}"
}

check_deps() {
  if ! command -v yt-dlp &>/dev/null; then
    echo -e "${RED}[!] yt-dlp not found. Installing...${NC}"
    pip install yt-dlp
  fi
  if ! command -v ffmpeg &>/dev/null; then
    echo -e "${RED}[!] ffmpeg not found. Install it first.${NC}"
    exit 1
  fi
}

ask_url() {
  echo
  echo -e "${YELLOW}📎 Paste YouTube URL (video or playlist):${NC}"
  read -r VIDEO_URL
  if [[ -z "$VIDEO_URL" ]]; then
    echo -e "${RED}[!] No URL entered. Exiting.${NC}"
    exit 1
  fi
}

ask_format() {
  echo
  echo -e "${YELLOW}📦 Select download format:${NC}"
  echo "  1) MP3  — audio only (extract/convert)"
  echo "  2) MP4  — video + audio"
  echo
  echo -n -e "${CYAN}Choice [1/2]: ${NC}"
  read -r FMT_CHOICE
  case "$FMT_CHOICE" in
    1) FORMAT="mp3" ;;
    2) FORMAT="mp4" ;;
    *) echo -e "${RED}[!] Invalid. Defaulting to MP4.${NC}" ; FORMAT="mp4" ;;
  esac
}

ask_quality() {
  echo
  if [[ "$FORMAT" == "mp3" ]]; then
    echo -e "${YELLOW}🎵 Select audio quality:${NC}"
    echo "  1) Best  (320k — largest file)"
    echo "  2) Good  (192k — balanced)"
    echo "  3) Fair  (128k — smaller)"
    echo
    echo -n -e "${CYAN}Choice [1/2/3]: ${NC}"
    read -r Q_CHOICE
    case "$Q_CHOICE" in
      1) QUALITY="320" ;;
      2) QUALITY="192" ;;
      3) QUALITY="128" ;;
      *) echo -e "${YELLOW}[⇒] Defaulting to 192k${NC}" ; QUALITY="192" ;;
    esac
  else
    echo -e "${YELLOW}🎬 Select video quality:${NC}"
    echo "  1) Best     (highest available)"
    echo "  2) 1080p    (Full HD)"
    echo "  3) 720p     (HD)"
    echo "  4) 480p     (SD)"
    echo "  5) 360p     (low)"
    echo
    echo -n -e "${CYAN}Choice [1/2/3/4/5]: ${NC}"
    read -r Q_CHOICE
    case "$Q_CHOICE" in
      1) QUALITY="bestvideo+bestaudio/best" ;;
      2) QUALITY="bestvideo[height<=1080]+bestaudio/best[height<=1080]" ;;
      3) QUALITY="bestvideo[height<=720]+bestaudio/best[height<=720]" ;;
      4) QUALITY="bestvideo[height<=480]+bestaudio/best[height<=480]" ;;
      5) QUALITY="bestvideo[height<=360]+bestaudio/best[height<=360]" ;;
      *) echo -e "${YELLOW}[⇒] Defaulting to 720p${NC}" ; QUALITY="bestvideo[height<=720]+bestaudio/best[height<=720]" ;;
    esac
  fi
}

confirm_download() {
  local display_quality
  [[ "$FORMAT" == "mp3" ]] && display_quality="${QUALITY}k" || display_quality="$QUALITY"

  echo
  echo -e "${GREEN}══════════════════════════════════════${NC}"
  echo -e "  URL:      ${CYAN}$VIDEO_URL${NC}"
  echo -e "  Format:   ${CYAN}$FORMAT${NC}"
  echo -e "  Quality:  ${CYAN}$display_quality${NC}"
  echo -e "  Save to:  ${CYAN}$BASE_DIR/${NC}"
  echo -e "${GREEN}══════════════════════════════════════${NC}"
  echo
  echo -n -e "${YELLOW}⏎ Press Enter to start download (or Ctrl+C to cancel): ${NC}"
  read -r
}

do_download() {
  local args=()

  if [[ "$FORMAT" == "mp3" ]]; then
    args+=(
      -x                          # extract audio
      --audio-format mp3
      --audio-quality "${QUALITY}k"
      --embed-thumbnail
      --add-metadata
    )
  else
    args+=(
      -f "$QUALITY"
      --merge-output-format mp4
      --embed-thumbnail
      --add-metadata
    )
  fi

  # Common settings
  args+=(
    --no-playlist-reverse
    --ignore-errors
    --no-overwrites
    --console-title
    --progress
    -o "$BASE_DIR/%(playlist_title|UNKNOWN)s/%(playlist_index)s - %(title)s.%(ext)s"
  )

  echo
  echo -e "${GREEN}[↓] Downloading...${NC}"
  echo

  yt-dlp "${args[@]}" "$VIDEO_URL"

  local exit_code=$?
  echo
  if [[ $exit_code -eq 0 ]]; then
    echo -e "${GREEN}[✓] Download complete!${NC}"
    echo -e "    Files saved in: ${CYAN}$BASE_DIR/${NC}"
  else
    echo -e "${RED}[✗] Download finished with warnings/errors (exit $exit_code).${NC}"
  fi
}

# ── Main ─────────────────────────────────────
banner
check_deps
ask_url
ask_format
ask_quality
confirm_download
do_download

echo
echo -e "${CYAN}────────────────────────────────────────────${NC}"
echo -e "  Run again:  ${GREEN}bash ~/Documents/yt-downloader/yt.sh${NC}"
echo -e "${CYAN}────────────────────────────────────────────${NC}"
echo
