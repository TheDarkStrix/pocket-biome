"""Run real Godot suites, preserve failures, and write a fresh evidence summary."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
SUITES = ['run', 'campaign', 'save_validation', 'save_io_failures', 'fusion_edges',
          'input_gestures', 'layout', 'presentation', 'services', 'screens', 'scene_smoke', 'touch_ui', 'mobile_layout']

def source_digest():
    digest = hashlib.sha256()
    paths = [ROOT / 'project.godot', ROOT / 'export_presets.cfg']
    for directory in ['scripts', 'scenes', 'data', 'native', 'tests', 'assets', 'tools']:
        paths.extend(p for p in (ROOT / directory).rglob('*') if p.is_file())
    for path in sorted(paths):
        if path == ROOT / 'data/build_info.json':
            continue
        if path.suffix in ['.pyc'] or '.gradle' in path.parts or 'build' in path.parts:
            continue
        digest.update(str(path.relative_to(ROOT)).encode() + b'\0' + path.read_bytes())
    return digest.hexdigest()

def main():
    results = []
    evidence = ROOT / 'artifacts/test-logs'
    evidence.mkdir(parents=True, exist_ok=True)
    initial_digest = source_digest()
    targets = [(s, ['--script', f'tests/{s}.gd'], 30) for s in SUITES]
    targets += [('progression_simulation', ['--script', 'tests/progression_simulation.gd'], 120),
                ('startup', ['--quit-after', '120'], 30)]
    for name, args, deadline in targets:
        try:
            run = subprocess.run([str(ROOT / 'tools/godot.sh'), '--headless', *args],
                                 cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 text=True, timeout=deadline)
            output, code = run.stdout, run.returncode
        except subprocess.TimeoutExpired as failure:
            raw = failure.stdout or b''
            output = raw.decode(errors='replace') if isinstance(raw, bytes) else raw
            output += '\nTEST TIMEOUT\n'
            code = 124
        print(output, end='', flush=True)
        (evidence / f'{name}.log').write_text(output)
        match = re.search(r'RESULT: (\d+) checks, (\d+) failures', output)
        errors = bool(re.search(r'SCRIPT ERROR:|^ERROR:|^FAIL:', output, re.MULTILINE))
        ok = code == 0 and not errors
        if name in SUITES:
            ok = ok and match is not None and int(match[1]) > 0 and int(match[2]) == 0
        elif name == 'progression_simulation':
            ok = ok and 'PROGRESSION RESULT: all 20 discoveries, all 5 chapters' in output
        results.append({'suite': name, 'passed': ok, 'exit_code': code,
                        'assertions': int(match[1]) if match else None})
        if not ok:
            break
    final_digest = source_digest()
    passed = len(results) == len(targets) and all(r['passed'] for r in results) and initial_digest == final_digest
    report = {'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'source_sha256': initial_digest, 'source_unchanged_during_run': initial_digest == final_digest,
              'passed': passed, 'assertions': sum(r['assertions'] or 0 for r in results), 'results': results}
    (ROOT / 'artifacts/test-results.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f"CHECK SUMMARY: {report['assertions']} assertions; {'PASS' if passed else 'FAIL'}")
    return 0 if passed else 1

if __name__ == '__main__':
    sys.exit(main())
