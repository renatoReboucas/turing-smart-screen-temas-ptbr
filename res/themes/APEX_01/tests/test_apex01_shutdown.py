import tempfile
import threading
import unittest
from pathlib import Path

from apex01.app import watch_stop_request


class APEX01ShutdownTests(unittest.TestCase):
    def test_stop_request_sets_event_and_is_removed(self):
        with tempfile.TemporaryDirectory() as directory:
            stop_file = Path(directory) / "stop.request"
            stop_event = threading.Event()
            stop_file.write_text("stop", encoding="utf-8")
            watcher = threading.Thread(
                target=watch_stop_request,
                args=(stop_event, stop_file),
                daemon=True,
            )

            watcher.start()
            self.assertTrue(stop_event.wait(timeout=2))
            watcher.join(timeout=1)

            self.assertFalse(stop_file.exists())


if __name__ == "__main__":
    unittest.main()
