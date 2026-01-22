"""
uv pip install yt-dlp
uv run main.py
"""

import os

import yt_dlp


def download_youtube_audio(url):
    # Configuration for audio download
    ydl_opts = {
        "format": "bestaudio",  # Downloads best available audio without conversion
        "outtmpl": os.path.join("music", "%(title)s.mp3"),  # Force .mp3 extension
        "noplaylist": True,
        "verbose": True,
    }

    try:
        # Create music folder if it doesn't exist
        os.makedirs("music", exist_ok=True)

        # Download process
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            print(f"Downloading: {url}")
            ydl.download([url])
            print("Audio saved in 'music' folder!")

    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    url = input("YouTube URL: ").strip()
    if url:
        download_youtube_audio(url)
    else:
        print("Invalid URL! Example: https://www.youtube.com/watch?v=dQw4w9WgXcQ")
