#/usr/bin/env python3
import sys
from pathlib import Path
import re
import shutil

def natural_sort(l):
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [convert(c) for c in re.split('([0-9]+)', str(key))]
    return sorted(l, key=alphanum_key)

source = Path(sys.argv[1])
target = Path(sys.argv[2])


names = sys.stdin.readlines()
images = natural_sort(map(str, source.glob("*.svg")))

for name, image in zip(names, images):
    # copy image to named_images
    shutil.copy(image, target / f"{name.strip()}.svg")

