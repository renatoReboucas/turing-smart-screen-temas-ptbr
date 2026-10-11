import unittest
from unittest.mock import patch

from apex01.metrics import MetricsSnapshot
from apex01.platform_sensors import WindowsSensorSampler
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

    @patch("apex01.platform_sensors.subprocess.check_output", return_value="73, 61, 3001, 8151\n")
    def test_nvidia_smi_reads_current_gpu_and_vram_metrics(self, check_output):
        sampler = WindowsSensorSampler()
        sampler._nvidia_smi_path = "nvidia-smi"
        metrics = sampler._snapshot_nvidia_smi()
        self.assertEqual(metrics, (73.0, 61.0, 3001 / 1024, 8151 / 1024))
        self.assertEqual(format_vram_usage(metrics[2], metrics[3]), "2.9/8GB")
        self.assertIn("memory.used,memory.total", check_output.call_args.args[0][1])
        self.assertEqual(check_output.call_args.kwargs["timeout"], 1)

    @patch.object(
        WindowsSensorSampler,
        "_snapshot_nvidia_smi",
        return_value=(73.0, 61.0, 4.0, 8.0),
    )
    def test_windows_fallback_uses_nvidia_smi_metrics(self, _nvidia_smi):
        self.assertEqual(
            WindowsSensorSampler()._snapshot_python_fallback(),
            (73.0, None, 61.0, None, 4.0, 8.0),
        )


if __name__ == "__main__":
    unittest.main()
