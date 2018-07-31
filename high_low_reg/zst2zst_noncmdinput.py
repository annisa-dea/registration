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
import time as ts


#%env SITK_SHOW_COMMAND /home/remy/Fiji.app/ImageJ-linux64

def command_iteration(method):
    print("{0:3} = {1:10.5f}".format(method.GetOptimizerIteration(), method.GetMetricValue()))
    print("\t#: ", len(method.GetOptimizerPosition()))


def command_multi_iteration(method):
    print("--------- Resolution Changing ---------")
    




#%%
print(ts.time());
ei_25 = ei.ExperimentInfo(pixelX=1024, pixelY=1024, pixelSizeUM=0.6060606, Zsteps=151, stepSizeUM=0.9999287, res=[0.6060606,0.6060606,0.9999287], ts=1, frameRate=1)
ei_40 = ei.ExperimentInfo(pixelX=1024, pixelY=1024, pixelSizeUM=0.3787879, Zsteps=165, stepSizeUM=0.9999287, res=[0.3787879,0.3787879,0.9999287], ts=1, frameRate=1)

fixed_filepath = "/home/emily/registration/images/1/0_01.tif";
moving_filepath = "/home/emily/registration/images/1/1_01.tif";

zstack_c = rs.RegistrationStack(nImage=imread(moving_filepath),
                                expInfo=ei_40)
zstack_d = rs.RegistrationStack(nImage=imread(fixed_filepath),
                                expInfo=ei_25)


#%% initial global transform

#folder = '/mnt/storage/Remy/2018 analysis/2018-07-01_analysis'
#tform_folder = os.path.join(folder, 'transforms', 'zstack_d2b_registration')
#outfolder = tform_folder
folder = "/home/emily/registration/images/";
tform_folder = os.path.join(folder, 'transforms', "xforms")
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
out = resampler.Execute(moving)

sitk.WriteTransform(globalTx, os.path.join(outfolder, 'tform_subvol_000.tfm'))
sitk.WriteImage(out, os.path.join(outfolder, 'global_resampled.tif'))
sitk.WriteImage(fixed, os.path.join(outfolder, 'fixed.tif'))

#%%


#%%
win = [256, 256, 21]
padding = [0, 0, 0]
subvol = sv.SubVolume(siz=fixed.GetSize(), win=win, padding=padding)

all_transforms = [None] * subvol.numSubVol
piecewise_resampled = np.zeros(zstack_d.nImage.shape)

#%%

for idx in range(subvol.numSubVol):
    subvol_mask = zstack_d.get_subvolume_mask(subvol.cornerListUL[idx], subvol.cornerListRL[idx])
    R.SetMetricFixedMask(subvol_mask * zstack_d.get_nonzero_mask())
    R.SetMetricMovingMask(zstack_c.get_nonzero_mask())

    R = sitk.ImageRegistrationMethod()
    #R.SetMetricAsANTSNeighborhoodCorrelation(4)
    R.SetMetricAsMattesMutualInformation(numberOfHistogramBins=100)
    R.SetMetricSamplingStrategy(R.RANDOM)
    R.SetMetricSamplingPercentage(0.8)
    R.SetOptimizerScalesFromPhysicalShift()
    R.SetInterpolator(sitk.sitkLinear)
    R.SetOptimizerAsGradientDescent(learningRate=1.0,
                                    numberOfIterations=300,
                                    convergenceMinimumValue=1e-4,
                                    convergenceWindowSize=10,
                                    estimateLearningRate=R.EachIteration)

    subvolTx = sitk.Euler3DTransform(globalTx)
    R.SetInitialTransform(subvolTx)

    #R.AddCommand(sitk.sitkIterationEvent, lambda: command_iteration(R))
    #R.AddCommand(sitk.sitkMultiResolutionIterationEvent, lambda: command_multi_iteration(R))

    R.Execute(fixed, moving)

    all_transforms[idx] = subvolTx
    resampler = sitk.ResampleImageFilter()
    resampler.SetReferenceImage(fixed)
    resampler.SetInterpolator(sitk.sitkLinear)
    resampler.SetTransform(subvolTx)
    subvol_img = resampler.Execute(moving)
    subvol_nimg = sitk.GetArrayFromImage(subvol_img)

    # save subvolume transform
    sitk.WriteTransform(subvolTx,
                        os.path.join(outfolder, 'tform_subvol_{0}.tfm'.format(str(idx + 1).zfill(3))))

    # # save resampled image (wrt subvolume)
    # sitk.WriteImage(subvol_img,
    #                 os.path.join(outfolder, 'tform_subvol_{0}.tif'.format(str(idx + 1).zfill(3))))

    (xmin, ymin, zmin) = subvol.cornerListUL[idx]
    (xmax, ymax, zmax) = subvol.cornerListRL[idx]

    piecewise_resampled[zmin:zmax, ymin:ymax, xmin:xmax] = subvol_nimg[zmin:zmax, ymin:ymax, xmin:xmax]

sitk.WriteImage(sitk.Cast(sitk.GetImageFromArray(piecewise_resampled), sitk.sitkFloat32),
                os.path.join(outfolder, 'piecewise_resampled.tif'))

#%%
sitk_piecewise_resampled = rs.RegistrationStack(nImage=np.float32(piecewise_resampled),
                                                expInfo=ei.ExperimentInfo(filepath=fixed_filepath))

simFilter = sitk.SimilarityIndexImageFilter()
simFilter.Execute(fixed, sitk_piecewise_resampled.sImage)
print('similarity: fixed & piecewise_resampled')
print(simFilter.GetSimilarityIndex())
print(ts.time())
simFilter.Execute(fixed, out)
print('similarity: fixed & global_resampled')
print(simFilter.GetSimilarityIndex())


