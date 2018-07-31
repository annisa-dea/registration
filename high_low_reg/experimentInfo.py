#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr  2 15:59:41 2018

@author: remy
"""
import xml.etree.ElementTree as ET


class ExperimentInfo:
    def __init__(self, **kwargs):
        # define default attributes

        allowed_keys = ['filepath', 'pixelX', 'pixelY', 'frameRate', 'pixelSizeUM',
                        'Zsteps', 'stepSizeUM', 'res', 'ts']

        if kwargs.has_key('filepath'):
            # tree=xml.etree.ElementTree.parse(kwargs['filepath'])
            print(kwargs['filepath'])
            tree = ET.parse(kwargs['filepath'])
            root = tree.getroot()
            self.filepath = kwargs['filepath']

            self.pixelX = int(root[12].get('pixelX'))
            self.pixelY = int(root[12].get('pixelY'))
            self.Zsteps = int(root[8].get('steps'))

            self.pixelSizeUM = float(root[12].get('pixelSizeUM'))
            self.stepSizeUM = float(root[8].get('stepSizeUM'))
            self.res = [self.pixelSizeUM, self.pixelSizeUM, self.stepSizeUM]

            self.ts = int(root[9].get('timepoints'))
            self.frameRate = float(root[12].get('frameRate'))
            self.complete = True
        else:
            self.filepath = ''
            self.__dict__.update((k, v) for k, v in kwargs.iteritems() if k in allowed_keys)
            self.complete = True



    def __repr__(self):

        toshow= ('filepath: {},' +
                '\npixelX: {},' +
                '\npixelY: {},' +
                '\nZsteps: {},' +
                '\npixelSizeUM: {}' +
                '\nstepSizeUM: {},'+
                 '\nres: {}' +
                 '\nts: {}'+
                 '\nframeRate: {}' +
                 '\ncomplete: {}').format(self.filepath, self.pixelX, self.pixelY, self.pixelSizeUM,
                                          self.Zsteps, self.stepSizeUM, self.res,
                                          self.ts, self.frameRate, self.complete)
        return toshow

    def downscale(self, scaling):
        self.pixelX=self.pixelX/scaling(1)
        self.pixelY=self.pixelY/scaling(2)
        self.Zsteps=self.Zsteps/scaling(3)

        self.pixelSizeUM = self.pixelSizeUM * 2
        self.stepSizeUM = self.stepSizeUM * 2

        self.res = [self.pixelSizeUM, self.pixelSizeUM, self.stepSizeUM]

    def upscale(self, scaling):
        self.pixelX = self.pixelX * scaling(1)
        self.pixelY = self.pixelY * scaling(2)
        self.Zsteps = self.Zsteps * scaling(3)

        self.pixelSizeUM = self.pixelSizeUM / 2
        self.stepSizeUM = self.stepSizeUM / 2

        self.res = [self.pixelSizeUM, self.pixelSizeUM, self.stepSizeUM]


