import unittest

from apex01.metrics import MetricsSnapshot
from apex01.renderer import format_vram_usage


class APEX01VRAMTests(unittest.TestCase):
    def test_metrics_snapshot_exposes_gpu_vram(self):
        snapshot = MetricsSnapshot(
            gpu_percent=56.0,
            gpu_temp_c=72.0,
            gpu_vram_used_gb=3.5,
            gpu_vram_total_gb=8.0,
        )

        self.assertEqual(snapshot.gpu_vram_used_gb, 3.5)
        self.assertEqual(snapshot.gpu_vram_total_gb, 8.0)

    def test_formats_vram_capacity_in_gigabytes(self):
        self.assertEqual(format_vram_usage(3.5, 8.0), "3.5/8GB")

    def test_formats_unavailable_vram(self):
        self.assertEqual(format_vram_usage(None, None), "N/A")


if __name__ == "__main__":
    unittest.main()
