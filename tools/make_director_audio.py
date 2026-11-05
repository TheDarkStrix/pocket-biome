"""Generate original, restrained restoration/visitor feedback (no external assets)."""
from pathlib import Path
import math
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
RATE = 22050
for name, duration, notes in [('restoration', 1.2, [523.25, 659.25, 783.99, 1046.5]),
                              ('visitor', .45, [880.0, 1174.66])]:
    samples = []
    for i in range(round(RATE * duration)):
        t = i / RATE
        value = 0.0
        for n, frequency in enumerate(notes):
            start = n * duration / (len(notes) + 1)
            local = t - start
            if local < 0:
                continue
            envelope = min(1.0, local / .015) * math.exp(-local * 6)
            value += .15 * envelope * (math.sin(2 * math.pi * frequency * local) + .2 * math.sin(4 * math.pi * frequency * local))
        samples.append(round(max(-.65, min(.65, value)) * 32767))
    with wave.open(str(ROOT / 'assets/audio' / f'{name}.wav'), 'wb') as out:
        out.setparams((1, 2, RATE, len(samples), 'NONE', 'not compressed'))
        out.writeframes(struct.pack('<' + 'h' * len(samples), *samples))
