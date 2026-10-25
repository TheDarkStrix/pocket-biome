"""Embed source provenance before checks/export; excluded from its own digest."""
from pathlib import Path
import datetime
import json
from run_checks import ROOT,source_digest

stamp={'source_sha256':source_digest(),'utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
(ROOT/'data/build_info.json').write_text(json.dumps(stamp,indent=2)+'\n')
print('Prepared source provenance for Android export.')
