#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr  2 15:59:41 2018

@author: remy
"""


class SubVolume:
    def __init__(self, **kwargs):
        # define default attributes

        allowed_keys = ['siz', 'win', 'padding']

        self.siz = kwargs['siz']
        self.win = kwargs['win']
        self.padding = kwargs['padding']

        corner_list_ul, corner_list_rl = get_subvolume_ind(self.siz, self.win)
        self.cornerListUL = corner_list_ul
        self.cornerListRL = corner_list_rl

        padded_corner_list_ul, padded_corner_list_rl = get_padded_subvolumes(self.siz, self.win, self.padding)
        self.paddedCornerListUL = padded_corner_list_ul
        self.paddedCornerListRL = padded_corner_list_rl

        self.numSubVol = len(self.cornerListUL)


def get_subvolume_ind(siz, win):
    x = range(0, siz[0], win[0])
    y = range(0, siz[1], win[1])
    z = range(0, siz[2], win[2])

    corner_list_UL = []
    corner_list_LR = []

    for iz in z:
        for ix in x:
            for iy in y:
                corner_list_UL.append((ix, iy, iz))
                corner_list_LR.append((min(ix + win[0], siz[0]),
                                       min(iy + win[1], siz[1]),
                                       min(iz + win[2], siz[2])))

    return corner_list_UL, corner_list_LR


def get_padded_subvolumes(siz, win, padding):
    # sitk order
    x = range(0, siz[0], win[0])
    y = range(0, siz[1], win[1])
    z = range(0, siz[2], win[2])

    corner_list_UL = []
    corner_list_LR = []

    for iz in z:
        for ix in x:
            for iy in y:
                corner_list_UL.append((max(ix - padding[0], 0),
                                       max(iy - padding[1], 0),
                                       max(iz - padding[2], 0)))

                corner_list_LR.append((min(ix + win[0] + padding[0], siz[0]),
                                       min(iy + win[1] + padding[1], siz[1]),
                                       min(iz + win[2] + padding[2], siz[2])))
    return corner_list_UL, corner_list_LR
