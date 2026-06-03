import json
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict

import requests

from scripts.config import (
    API_FOOTBALL_BASE_URL,
    API_FOOTBALL_HOST,
    API_FOOTBALL_KEY,
)


def utc_now_str() -> str:
    """Return current UTC timestamp formatted for file names."""
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def ensure_dir(path: str) -> None:
    """Create directory if it does not exist."""
    Path(path).mkdir(parents=True, exist_ok=True)


def api_get(endpoint: str, params: Dict[str, Any]) -> Dict[str, Any]:
    """
    Execute GET request against API-Football.

    Args:
        endpoint: API endpoint, for example '/fixtures'.
        params: Query parameters.

    Returns:
        Parsed JSON response.

    Raises:
        RuntimeError: If API key is missing or response is not successful.
    """
    if not API_FOOTBALL_KEY:
        raise RuntimeError(
            "Missing API_FOOTBALL_KEY. Set it in .env before running extraction."
        )

    url = f"{API_FOOTBALL_BASE_URL}{endpoint}"

    headers = {
        "x-rapidapi-host": API_FOOTBALL_HOST,
        "x-rapidapi-key": API_FOOTBALL_KEY,
    }

    response = requests.get(url, headers=headers, params=params, timeout=60)

    if response.status_code != 200:
        raise RuntimeError(
            f"API request failed: status={response.status_code}, body={response.text}"
        )

    payload = response.json()

    if payload.get("errors"):
        raise RuntimeError(f"API returned errors: {payload.get('errors')}")

    return payload


def save_json(payload: Dict[str, Any], output_path: str) -> None:
    """Save dictionary as pretty JSON."""
    ensure_dir(os.path.dirname(output_path))

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)


def save_metadata(entity: str, payload: Dict[str, Any], output_path: str) -> None:
    """Save lightweight metadata for each extraction run."""
    metadata = {
        "entity": entity,
        "extracted_at_utc": datetime.now(timezone.utc).isoformat(),
        "results": payload.get("results"),
        "paging": payload.get("paging"),
        "parameters": payload.get("parameters"),
        "errors": payload.get("errors"),
    }

    save_json(metadata, output_path)

def log_extraction_summary(entity: str, results: int, output_path: str) -> None:
    """
    Print a standardized summary after each extraction.

    Args:
        entity: Name of the extracted entity (fixtures, teams, standings).
        results: Number of records extracted.
        output_path: Path where the file was saved.
    """
    print(f"[{utc_now_str()}] ✓ {entity}: {results} records → {output_path}")


def validate_response(payload: Dict[str, Any], entity: str) -> bool:
    """
    Validate that API response contains results.

    Args:
        payload: Parsed JSON response from API.
        entity: Name of the entity being validated.

    Returns:
        True if valid, False otherwise.
    """
    results = payload.get("results", 0)
    if results == 0:
        print(f"[WARNING] No results returned for entity: {entity}")
        return False
    return True


def build_run_id() -> str:
    """
    Generate a unique run ID based on UTC timestamp.
    Used for partitioning raw files by execution.

    Returns:
        Run ID string in format run_id=YYYYMMDDTHHMMSSZ
    """
    return f"run_id={utc_now_str()}"


def list_json_files(directory: str) -> list:
    """
    List all JSON files in a directory recursively.

    Args:
        directory: Root directory to search.

    Returns:
        List of absolute paths to JSON files.
    """
    return [str(p) for p in Path(directory).rglob("*.json")]