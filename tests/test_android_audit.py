"""Reject unsafe native artifacts and incomplete production declarations."""
import copy
from pathlib import Path
import struct
import sys
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from audit_android import elf_load_alignments,production_blockers

class AndroidAuditTests(unittest.TestCase):
    def elf(self,alignment=16384):
        data=bytearray(120);data[:6]=b'\x7fELF\x02\x01'
        struct.pack_into('<Q',data,32,64);struct.pack_into('<HH',data,54,56,1)
        struct.pack_into('<I',data,64,1);struct.pack_into('<Q',data,112,alignment)
        return data
    def facts(self):
        return dict(source_sha256='verified',debuggable=False,debug_certificate=False,preview_version=False,
            sandbox_services=False,test_provider_ids=False,
            release={'privacy_policy_url':'https://example.com/privacy','support_url':'https://example.com/support'},
            evidence={name:{'passed':True,'source_sha256':'verified'} for name in
                ('physical_device_report','play_sandbox_report','creative_review_report')})
    def test_reads_actual_load_alignment(self):self.assertEqual(elf_load_alignments(self.elf()),[16384])
    def test_detects_legacy_4k_alignment(self):self.assertTrue(any(a<16384 for a in elf_load_alignments(self.elf(4096))))
    def test_rejects_truncation(self):
        with self.assertRaises(ValueError):elf_load_alignments(self.elf()[:100])
    def test_rejects_non_elf(self):
        with self.assertRaises(ValueError):elf_load_alignments(b'not an ELF'*20)
    def test_debug_and_test_configuration_blocks_production(self):
        facts=self.facts();facts.update(debuggable=True,debug_certificate=True,sandbox_services=True,test_provider_ids=True)
        self.assertEqual(len(production_blockers(facts)),4)
    def test_stale_physical_evidence_rejected(self):
        facts=self.facts();facts['evidence']['physical_device_report']['source_sha256']='old'
        self.assertIn('physical_device_report',production_blockers(facts)[0])
    def test_missing_privacy_and_sandbox_results_rejected(self):
        facts=self.facts();facts['release']['privacy_policy_url']='';facts['evidence'].pop('play_sandbox_report')
        self.assertEqual(len(production_blockers(facts)),2)
    def test_complete_fixture_only_clears_configuration_gate(self):self.assertEqual(production_blockers(self.facts()),[])

if __name__=='__main__':unittest.main()
