import sys
import json
for fname in sys.argv[1:]:
    # print fname
    f = open(fname)
    s = f.read()
    l = json.loads(s)
    print fname, len(l)
