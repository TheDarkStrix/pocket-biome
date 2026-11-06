from pathlib import Path
import json
import sys
import tempfile
import unittest
import zipfile
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from device_smoke import authorized_devices,embedded_source

class DeviceSmokeTests(unittest.TestCase):
    def test_only_authorized_devices_can_be_selected(self):
        self.assertEqual(authorized_devices('List of devices attached\na\tdevice\nb\tunauthorized\nc\toffline\n'),['a'])
    def test_missing_inventory_never_passes(self):
        self.assertEqual(authorized_devices('List of devices attached\n'),[])
    def test_binding_is_read_from_the_actual_package(self):
        with tempfile.TemporaryDirectory() as d:
            apk=Path(d)/'fixture.apk'
            with zipfile.ZipFile(apk,'w') as z:z.writestr('assets/data/build_info.json',json.dumps({'source_sha256':'actual-embedded-source'}))
            self.assertEqual(embedded_source(apk),'actual-embedded-source')
    def test_absent_binding_is_not_invented(self):
        with tempfile.TemporaryDirectory() as d:
            apk=Path(d)/'fixture.apk'
            with zipfile.ZipFile(apk,'w') as z:z.writestr('unrelated','{}')
            with self.assertRaises(KeyError):embedded_source(apk)
