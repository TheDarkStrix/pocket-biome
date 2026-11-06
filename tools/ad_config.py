"""Validate monetization configuration and produce the native resource binding."""
from pathlib import Path
import argparse
import json
import re
from xml.sax.saxutils import escape

ROOT=Path(__file__).resolve().parents[1]
TEST={'app_id':'ca-app-pub-3940256099942544~3347511713','rewarded_unit_id':'ca-app-pub-3940256099942544/5224354917','interstitial_unit_id':'ca-app-pub-3940256099942544/1033173712'}
AUDIENCES=['unconfigured','teens_adults_13_plus','children_families']

def validate_policy(policy):
    if not isinstance(policy,dict) or policy.get('id')!='balanced_breaks_v1':raise ValueError('Unknown ad policy version')
    ranges={'first_interstitial_seconds':(180,600),'returning_interstitial_seconds':(60,180),'min_fullscreen_gap_seconds':(120,600),'rolling_window_seconds':(900,3600),'max_interstitials_per_window':(1,10),'opportunity_lifetime_seconds':(30,180),'failure_backoff_seconds':(15,120)}
    for key,(low,high) in ranges.items():
        if type(policy.get(key)) is not int or not low<=policy[key]<=high:raise ValueError('Invalid ad policy: '+key)
    if policy['max_interstitials_per_window']*policy['min_fullscreen_gap_seconds']>policy['rolling_window_seconds']:raise ValueError('Rolling cap exceeds possible spaced placements')

def resolve(config):
    validate_policy(config.get('ad_policy'))
    if config.get('mode') not in ['sandbox','production']:raise ValueError('Ad mode must be sandbox or production')
    if type(config.get('interstitials_enabled')) is not bool:raise ValueError('Interstitial switch must be a boolean')
    if type(config.get('billing_enabled',True)) is not bool:raise ValueError('Billing switch must be boolean')
    provider=config.get('admob',{})
    if not isinstance(provider,dict) or provider.get('audience') not in AUDIENCES:raise ValueError('Choose an explicit supported audience')
    missing=[]
    for key in TEST:
        value=provider.get(key,'');separator='~' if key=='app_id' else '/'
        if not isinstance(value,str) or not re.fullmatch(r'ca-app-pub-\d{16}'+re.escape(separator)+r'\d{10}',value) or value.startswith('ca-app-pub-3940256099942544'):missing.append(key)
    if provider.get('audience')=='unconfigured':missing.append('audience')
    if not missing:
        publishers={provider[k].split('~')[0].split('/')[0] for k in TEST}
        if len(publishers)!=1:raise ValueError('Ad app and units must use the same publisher')
        if provider['rewarded_unit_id']==provider['interstitial_unit_id']:raise ValueError('Use separate rewarded and interstitial units')
    if config['mode']=='production' and missing:raise ValueError('Production ads need: '+', '.join(missing))
    return {'mode':config['mode'],'audience':provider['audience'],'effective_ids':TEST if config['mode']=='sandbox' else {k:provider[k] for k in TEST},'live_ad_configuration_ready':not missing,'missing_for_live_ads':missing,'debug_build_uses_test_units':True}

def native_resources(config):
    result=resolve(config);values={**result['effective_ids'],'mode':result['mode'],'audience':result['audience'],'billing_enabled':str(config.get('billing_enabled',True)).lower()}
    return '<resources>\n'+''.join('    <string name="pocket_ads_'+k+'" translatable="false">'+escape(v)+'</string>\n' for k,v in values.items())+'</resources>\n'

def main():
    config=json.loads((ROOT/'data/services.json').read_text())
    try:result=resolve(config)
    except ValueError as error:result={'valid':False,'error':str(error)}
    else:result['valid']=True;result['scope']='Configuration syntax and native binding only. AdMob approval, live delivery, consent and revenue are not verified.'
    print(json.dumps(result,indent=2));return 0 if result['valid'] else 1
if __name__=='__main__':raise SystemExit(main())
