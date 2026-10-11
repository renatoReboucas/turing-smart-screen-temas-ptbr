import unittest
from unittest.mock import patch

from apex01.platform_sensors import WindowsSensorSampler, _select_cpu_temperature


class APEX01CPUTemperatureTests(unittest.TestCase):
    def test_windows_sampler_waits_for_collector_start(self):
        with patch.object(WindowsSensorSampler, "start") as start:
            WindowsSensorSampler()

        start.assert_not_called()

    def test_prefers_cpu_package_temperature(self):
        self.assertEqual(
            _select_cpu_temperature(
                [
                    ("temperature core 1", 44.0),
                    ("temperature core (tctl/tdie)", 51.5),
                ]
            ),
            51.5,
        )

    def test_ignores_zero_temperature_readings(self):
        self.assertIsNone(_select_cpu_temperature([]))
        self.assertIsNone(_select_cpu_temperature([("temperature core (tctl/tdie)", 0.0)]))


if __name__ == "__main__":
    unittest.main()
