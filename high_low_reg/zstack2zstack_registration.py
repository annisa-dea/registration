#!/usr/bin/env python

from __future__ import print_function

import SimpleITK as sitk
import sys
import os
import numpy as np
from skimage.io import imread
import experimentInfo as ei
import subVolume as sv
import registrationStack as rs
from skimage.measure import regionprops
from skimage.morphology import ball, dilation, binary_dilation
from scipy.ndimage.morphology import grey_dilation
from sklearn.cluster import KMeans, AffinityPropagation
from skimage.measure import label, regionprops
from skimage.color import label2rgb
from mpl_toolkits.mplot3d import Axes3D

import matplotlib.pyplot as plt

#get command line args
cmd_args=sys.argv
print("COMMANDS PASSED TO REG CODE")
print(cmd_args)


#%env SITK_SHOW_COMMAND /home/remy/Fiji.app/ImageJ-linux64

def command_iteration(method):
    print("{0:3} = {1:10.5f}".format(method.GetOptimizerIteration(), method.GetMetricValue()))
    print("\t#: ", len(method.GetOptimizerPosition()))


def command_multi_iteration(method):
    print("--------- Resolution Changing ---------")




#%%

ei_25 = ei.ExperimentInfo(pixelX=1024, pixelY=1024, pixelSizeUM=0.6060606, Zsteps=cmd_args[1], stepSizeUM=1, res=[0.6060606,0.6060606,1], ts=1, frameRate=1)
ei_40 = ei.ExperimentInfo(pixelX=1024, pixelY=1024, pixelSizeUM=0.3787879, Zsteps=cmd_args[2], stepSizeUM=1, res=[0.3787879,0.3787879,1], ts=1, frameRate=1)

fixed_filepath = cmd_args[3];
moving_filepath = cmd_args[4];

zstack_c = rs.RegistrationStack(nImage=imread(moving_filepath),
                                expInfo=ei_40)
zstack_d = rs.RegistrationStack(nImage=imread(fixed_filepath),
                                expInfo=ei_25)


#%% initial global transform

#folder = '/mnt/storage/Remy/2018 analysis/2018-07-01_analysis'
#tform_folder = os.path.join(folder, 'transforms', 'zstack_d2b_registration')
#outfolder = tform_folder
folder = cmd_args[5];
tform_folder = os.path.join(folder, 'transforms', cmd_args[6])
outfolder = tform_folder

if not os.path.exists(outfolder):
    os.makedirs(outfolder)

fixed = sitk.Cast(zstack_d.sImage, sitk.sitkFloat32)
moving = sitk.Cast(zstack_c.sImage, sitk.sitkFloat32)

#%%

#sitk.Show(out, 'Resampled moving (global)')
#sitk.Show(fixed, 'fixed')

#%%

initialTx = sitk.CenteredTransformInitializer(fixed, moving, sitk.Euler3DTransform(),
                                              sitk.CenteredTransformInitializerFilter.GEOMETRY)

R = sitk.ImageRegistrationMethod()
R.SetMetricFixedMask(zstack_d.get_nonzero_mask())
R.SetMetricMovingMask(zstack_c.get_nonzero_mask())
R.SetMetricAsMattesMutualInformation(numberOfHistogramBins=100)
R.SetMetricSamplingPercentage(0.8)

R.SetOptimizerAsGradientDescent(learningRate=1.0,
                                numberOfIterations=300,
                                convergenceMinimumValue=1e-4,
                                convergenceWindowSize=10,
                                estimateLearningRate=R.EachIteration)
R.SetShrinkFactorsPerLevel(shrinkFactors=[4, 2, 1])
R.SetSmoothingSigmasPerLevel(smoothingSigmas=[2, 1, 0])

R.SetOptimizerScalesFromPhysicalShift()
R.SetInterpolator(sitk.sitkLinear)

globalTx = sitk.Euler3DTransform(initialTx)
R.SetInitialTransform(globalTx)

R.AddCommand(sitk.sitkIterationEvent, lambda: command_iteration(R))
R.AddCommand(sitk.sitkMultiResolutionIterationEvent, lambda: command_multi_iteration(R))
R.Execute(fixed, moving)

print("-------")
print(globalTx)
print("Optimizer stop condition: {0}".format(R.GetOptimizerStopConditionDescription()))
print(" Iteration: {0}".format(R.GetOptimizerIteration()))
print(" Metric value: {0}".format(R.GetMetricValue()))

resampler = sitk.ResampleImageFilter()
resampler.SetReferenceImage(fixed)
resampler.SetInterpolator(sitk.sitkLinear)
resampler.SetTransform(globalTx)
#change moving
out = resampler.Execute(moving)

sitk.WriteTransform(globalTx, os.path.join(outfolder, 'tform_subvol_000.tfm'))
sitk.WriteImage(out, os.path.join(outfolder, 'global_resampled.tif'))
sitk.WriteImage(fixed, os.path.join(outfolder, 'fixed.tif'))

#%%

channels=[cmd_args[7]]
channels = channels[0].split()
i=0
while (i<len(channels)): 
    print("LKJSEWRKLJESRLJKHERSJKL")
    print(channels[i])
    zstack_c = rs.RegistrationStack(nImage=imread(channels[i]),
                                expInfo=ei_40)
    moving = sitk.Cast(zstack_c.sImage, sitk.sitkFloat32)
    out = resampler.Execute(moving)
    transforms_folder=os.path.join(folder, 'transforms')
    sitk.WriteImage(out, os.path.join(transforms_folder, 'global_resampled' + str(i) + '.tif'))
    i=i+1


