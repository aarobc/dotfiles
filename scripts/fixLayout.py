#!/usr/bin/python2.7

import i3
import pprint

pp = pprint.PrettyPrinter(indent=4)


# print len(outputs)
# order is typically:
# EDP1, HDMI2, HDMI1
spaces = i3.get_workspaces()

def outputs():
    puts = i3.get_outputs()
    ray = []
    for i in puts:
        if i['active']:
            # print i
            ray.append(i)
    return ray

def findSpaces(disp):
    ray = []
    for space in spaces:
        if space['output'] == disp:
            ray.append(space)
    return ray

outs = outputs()


layout = {1: 'eDP1', 2: 'eDP1', 
        3:'HDMI1', 4:'HDMI1', 5:'HDMI1', 6:'HDMI1',
        7:'HDMI2', 8:'HDMI2', 9:'HDMI2', 10:'HDMI2'}

for space in spaces:
    # print space['num']
    i3.workspace(str(space['num']))
    i3.command('move', 'workspace to output ' + layout[space['num']])


