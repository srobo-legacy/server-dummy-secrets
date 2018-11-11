#!/usr/bin/env python

import sys

if len(sys.argv) != 2 or '-h' in sys.argv or '--help' in sys.argv:
    exit("Usage: {} MYSQL_DUMP_FILE".format(sys.argv[0]))

with open(sys.argv[1], mode='r+') as f:
    data = f.read()
    data = data.replace(
        'VALUES (',
        'VALUES\n  (',
    ).replace(
        '),(',
        '),\n  (',
    )
    f.seek(0)
    f.write(data)
