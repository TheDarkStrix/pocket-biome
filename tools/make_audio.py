"""Original synthesized UI cues; deterministic PCM masters, no external samples."""
from pathlib import Path
import math, struct, wave
RATE = 22050
CUES = {
    'wood': [(0, 196, .12), (.045, 293.66, .14)],
    'stone': [(0, 146.83, .1), (.025, 932.32, .08)],
    'water': [(0, 523.25, .22), (.07, 698.46, .27), (.13, 1046.5, .2)],
    'card': [(0, 329.63, .09), (.045, 493.88, .12)],
    'legendary': [(0, 261.63, 1.6), (.15, 392, 1.5), (.3, 523.25, 1.4), (.45, 659.25, 1.3), (.6, 783.99, 1.2)],
    'reaction': [(0, 392, .24), (.09, 523.25, .3)],
    'harvest': [(0, 659.25, .18), (.06, 880, .24)],
    'place': [(0, 392, .24), (.08, 587.33, .3)],
    'evolve': [(0, 523.25, .55), (.13, 659.25, .55), (.26, 783.99, .7), (.4, 1046.5, .8)],
    'fusion': [(0, 261.63, .8), (.12, 392, .8), (.3, 523.25, .8), (.5, 783.99, .9)],
    'pulse': [(0, 440, .5), (.15, 659.25, .6), (.3, 880, .65)]
}
for name, notes in CUES.items():
    samples=[]
    duration=max(t+d for t,f,d in notes)+.05
    for i in range(int(duration*RATE)):
        t=i/RATE
        value=0
        for start, freq, length in notes:
            age=t-start
            if 0 <= age < length:
                envelope=min(1,age/.012)*(1-age/length)**2
                tone=math.sin(math.tau*freq*age)+.15*math.sin(math.tau*freq*2*age)
                if name in ['wood','stone']:
                    noise=2*((i*1103515245+12345)%65536)/65535-1
                    tone=.65*tone+.35*noise*math.exp(-age*45)
                elif name=='water':
                    tone=math.sin(math.tau*(freq*age+freq*age*age*.25))*.8
                value += (.08 if name=='legendary' else .15)*envelope*tone
        samples.append(int(max(-1,min(1,value))*32767))
    out=Path(__file__).resolve().parents[1]/'assets/audio'/f'{name}.wav'
    with wave.open(str(out),'wb') as file:
        file.setnchannels(1);file.setsampwidth(2);file.setframerate(RATE)
        file.writeframes(struct.pack('<'+'h'*len(samples),*samples))

# Original seamless 32-second pentatonic ambient loop; no third-party samples.
RATE = 16000
DURATION = 32
chords = [(130.8128,164.8138,195.9977),(110.0,146.8324,195.9977),(146.8324,195.9977,246.9417),(130.8128,164.8138,220.0)]
samples=[]
for i in range(RATE*DURATION):
    t=i/RATE
    value=0.0
    for segment in range(4):
        age=(t-segment*8)%32
        if age<10:
            envelope=math.sin(math.pi*age/10)**2
            for freq in chords[segment]:value += .035*envelope*(math.sin(math.tau*freq*t)+.16*math.sin(math.tau*freq*2*t))
    # Fade the exact loop boundary smoothly to silence to avoid a click.
    edge=min(1,t/.3,(DURATION-t)/.3)
    samples.append(int(max(-1,min(1,value*max(0,edge)))*32767))
with wave.open(str(Path(__file__).resolve().parents[1]/'assets/audio/ambience.wav'),'wb') as file:
    file.setnchannels(1);file.setsampwidth(2);file.setframerate(RATE)
    file.writeframes(struct.pack('<'+'h'*len(samples),*samples))
