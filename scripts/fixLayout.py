#!/usr/bin/python2.7

import i3
import pprint

# spaces = i3.get_workspaces()

def outputs():
    puts = i3.get_outputs()
    act = [item for item in puts if item['active']]
    s = sorted(act, key=lambda x: x['rect']['x'])
    return s

outs = outputs()
# pprint.pprint(outs)
c = outs[0]['current_workspace']
pprint.pprint(c)
many = len(outs)
spaces = 10/many
current = 1

for output in outs:
    for i in xrange(spaces):
        print output['name']
        print current
        i3.workspace(str(current))
        i3.command('move', 'workspace to output ' + output['name'])
        current += 1


i3.workspace(c)
