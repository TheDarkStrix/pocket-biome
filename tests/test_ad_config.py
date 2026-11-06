import copy
import json
from pathlib import Path
import sys
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from ad_config import resolve,native_resources

class AdConfigurationTests(unittest.TestCase):
 def config(self):return json.loads((Path(__file__).resolve().parents[1]/'data/services.json').read_text())
 def live(self):
  c=self.config();c['mode']='production';c['admob']={'app_id':'ca-app-pub-1111111111111111~1111111111','interstitial_unit_id':'ca-app-pub-1111111111111111/2222222222','rewarded_unit_id':'ca-app-pub-1111111111111111/3333333333','audience':'teens_adults_13_plus'};return c
 def test_default_uses_test_ads_and_reports_missing_live_setup(self):
  r=resolve(self.config());self.assertEqual(r['mode'],'sandbox');self.assertFalse(r['live_ad_configuration_ready']);self.assertTrue(r['debug_build_uses_test_units'])
 def test_live_configuration_is_bound_into_native_resources(self):
  c=self.live();r=resolve(c);self.assertTrue(r['live_ad_configuration_ready']);self.assertIn(c['admob']['interstitial_unit_id'],native_resources(c))
 def test_live_missing_identifiers_fail_closed(self):
  c=self.config();c['mode']='production'
  with self.assertRaises(ValueError):resolve(c)
 def test_unset_audience_cannot_enable_live_ads(self):
  c=self.live();c['admob']['audience']='unconfigured'
  with self.assertRaises(ValueError):resolve(c)
 def test_mixed_publishers_are_rejected(self):
  c=self.live();c['admob']['rewarded_unit_id']='ca-app-pub-2222222222222222/3333333333'
  with self.assertRaises(ValueError):resolve(c)
 def test_wrong_app_unit_formats_are_rejected(self):
  c=self.live();c['admob']['app_id']=c['admob']['interstitial_unit_id']
  with self.assertRaises(ValueError):resolve(c)
 def test_overaggressive_or_non_integer_policy_is_rejected(self):
  for field,value in [('first_interstitial_seconds',0),('min_fullscreen_gap_seconds',10),('max_interstitials_per_window',99),('failure_backoff_seconds',True)]:
   c=self.config();c['ad_policy'][field]=value
   with self.assertRaises(ValueError):resolve(c)
 def test_ads_only_native_binding_disables_billing(self):
  c=self.live();c["billing_enabled"]=False;self.assertIn('name="pocket_ads_billing_enabled" translatable="false">false',native_resources(c))
 def test_child_directed_audience_is_an_explicit_binding(self):
  c=self.live();c['admob']['audience']='children_families';self.assertIn('children_families',native_resources(c))
