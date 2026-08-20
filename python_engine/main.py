"""
main.py
-------
Entry point for the serious_python embedded engine.

serious_python calls this module when Flutter invokes the MethodChannel.
All communication is via JSON strings over the platform channel.

Protocol:
  Incoming payload JSON: {"query": "<search string>"}
  Outgoing result JSON:  {"url": "...", "title": "...", "duration": 213}
  Error JSON:            {"error": "<message>"}
"""
import json
import sys
from audio_resolver import resolve_audio_url


def handle_request(payload_json: str) -> str:
    """
    Main dispatcher called by serious_python MethodChannel handler.

    Args:
        payload_json: JSON string from Flutter, e.g. '{"query": "Song Title Artist"}'

    Returns:
        JSON string with result or error.
    """
    try:
        payload = json.loads(payload_json)
        query = payload.get('query', '').strip()

        if not query:
            return json.dumps({'error': 'Empty query provided.'})

        result = resolve_audio_url(query)
        return json.dumps(result)

    except RuntimeError as e:
        return json.dumps({'error': str(e)})
    except json.JSONDecodeError as e:
        return json.dumps({'error': f'Invalid JSON payload: {e}'})
    except Exception as e:  # noqa: BLE001
        return json.dumps({'error': f'Unexpected error: {e}'})


if __name__ == '__main__':
    # Allow manual CLI testing: python main.py '{"query": "test song"}'
    if len(sys.argv) < 2:
        print(json.dumps({'error': 'No payload argument provided.'}))
        sys.exit(1)
    print(handle_request(sys.argv[1]))
