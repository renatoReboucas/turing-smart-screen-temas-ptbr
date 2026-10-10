import unittest

from apex01.metrics import MetricsSnapshot


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


if __name__ == "__main__":
    unittest.main()
