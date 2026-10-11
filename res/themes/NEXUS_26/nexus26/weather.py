from __future__ import annotations

from dataclasses import dataclass, replace
import json
import logging
import ssl
import threading
import urllib.error
import urllib.parse
import urllib.request

import certifi

from .config import WeatherConfig

LOG = logging.getLogger(__name__)


@dataclass(frozen=True)
class WeatherSnapshot:
    temperature: str = "--°C"
    description: str = "SEM DADOS"
    condition: str = "unknown"
    location: str = ""


def compact_condition(description: str) -> tuple[str, str]:
    normalized = description.strip().lower()
    if "thunder" in normalized:
        return "TROVOADA", "thunder"
    if "snow" in normalized or "blizzard" in normalized:
        return "NEVE", "snow"
    if "sleet" in normalized or "ice" in normalized:
        return "GELO", "snow"
    if "rain" in normalized or "shower" in normalized:
        return "CHUVA", "rain"
    if "drizzle" in normalized:
        return "GAROA", "rain"
    if "fog" in normalized or "mist" in normalized:
        return "NEBLINA", "fog"
    if "partly" in normalized:
        return "NUBL. PARC.", "partly_cloudy"
    if "cloud" in normalized or "overcast" in normalized:
        return "NUBLADO", "cloudy"
    if "sun" in normalized or "clear" in normalized:
        return "LIMPO", "clear"
    return "TEMPO", "unknown"


class WeatherCollector:
    def __init__(self, config: WeatherConfig):
        self.config = config
        self._snapshot = WeatherSnapshot()
        self._lock = threading.Lock()
        self._stop = threading.Event()
        self._thread: threading.Thread | None = None

    def start(self) -> None:
        if not self.config.enabled or (self._thread and self._thread.is_alive()):
            return
        self._stop.clear()
        self._thread = threading.Thread(target=self._run, name="nexus26-weather", daemon=True)
        self._thread.start()

    def stop(self) -> None:
        self._stop.set()
        if self._thread:
            self._thread.join(timeout=2)

    def snapshot(self) -> WeatherSnapshot:
        with self._lock:
            return replace(self._snapshot)

    def _fetch(self) -> WeatherSnapshot:
        location = urllib.parse.quote(self.config.location, safe="")
        url = f"https://wttr.in/{location}?format=j1"
        request = urllib.request.Request(url, headers={"User-Agent": "NEXUS26/1.0"})
        context = ssl.create_default_context(cafile=certifi.where())
        with urllib.request.urlopen(
            request, timeout=self.config.timeout_seconds, context=context
        ) as response:
            data = json.loads(response.read().decode("utf-8"))
        current = data["current_condition"][0]
        raw_description = current["weatherDesc"][0]["value"]
        description, condition = compact_condition(raw_description)
        nearest_area = data.get("nearest_area") or []
        location_name = ""
        if nearest_area:
            names = nearest_area[0].get("areaName") or []
            if names:
                location_name = str(names[0].get("value", ""))
        return WeatherSnapshot(
            f"{current['temp_C']}°C",
            description,
            condition,
            location_name,
        )

    def _run(self) -> None:
        while not self._stop.is_set():
            try:
                snapshot = self._fetch()
                with self._lock:
                    self._snapshot = snapshot
            except (KeyError, ValueError, json.JSONDecodeError, urllib.error.URLError, TimeoutError) as exc:
                LOG.warning("Weather update failed: %s", exc)
            self._stop.wait(self.config.refresh_seconds)
