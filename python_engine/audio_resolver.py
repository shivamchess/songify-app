"""
audio_resolver.py
-----------------
Core audio URL extraction engine using yt-dlp.
This module is called by main.py which is the serious_python entry point.

Flow:
  Flutter sends: {"query": "Blinding Lights The Weeknd audio"}
  We search YouTube for the best audio-only stream.
  We return: {"url": "...", "title": "...", "duration": 213}
"""
import yt_dlp


def resolve_audio_url(query: str) -> dict:
    """
    Resolve a direct audio stream URL for a given search query.

    Args:
        query: The search string, e.g. "Blinding Lights The Weeknd audio"

    Returns:
        A dict with keys: url (str), title (str), duration (int seconds)

    Raises:
        RuntimeError: If no results found or extraction fails.
    """
    ydl_opts = {
        'format': 'bestaudio[ext=m4a]/bestaudio/best',
        'quiet': True,
        'no_warnings': True,
        'extract_flat': False,
        'noplaylist': True,
        # Prevent actual download — we only want the URL
        'skip_download': True,
    }

    search_query = f"ytsearch1:{query}"

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        try:
            info = ydl.extract_info(search_query, download=False)
        except yt_dlp.utils.DownloadError as e:
            raise RuntimeError(f"yt-dlp extraction failed: {e}") from e

        if not info or 'entries' not in info or not info['entries']:
            raise RuntimeError(f"No YouTube results for query: {query!r}")

        entry = info['entries'][0]

        # Prefer the direct URL; fall back to formats list
        stream_url = entry.get('url')
        if not stream_url and entry.get('formats'):
            # Pick the best audio format
            audio_formats = [
                f for f in entry['formats']
                if f.get('acodec') != 'none' and f.get('vcodec') == 'none'
            ]
            if audio_formats:
                stream_url = audio_formats[-1]['url']
            else:
                stream_url = entry['formats'][-1]['url']

        if not stream_url:
            raise RuntimeError("Could not extract stream URL from entry.")

        return {
            'url': stream_url,
            'title': entry.get('title', query),
            'duration': int(entry.get('duration') or 0),
        }
