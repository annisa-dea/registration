
import SimpleITK as sitk
import numpy as np
import experimentInfo as ei


class RegistrationStack:
    def __init__(self, **kwargs):
        # define default attributes

        allowed_keys = ['expInfo', 'nImage', 'sImage']

        if kwargs.has_key('sImage'):
            self.sImage = kwargs['sImage']
            self.nImage = sitk.GetArrayFromImage(self.sImage)

            pixelX = self.sImage.GetWidth()
            pixelY = self.sImage.GetHeight()
            Zsteps = self.sImage.GetDepth()
            res = self.sImage.GetSpacing()
            self._expInfo = ei.ExperimentInfo(pixelX=pixelX, pixelY=pixelY, Zsteps=Zsteps,
                                          pixelSizeUM=res[0], stepSizeUM=res[2], res=res)
        else:
            if kwargs.has_key('nImage'):
                self.nImage = kwargs['nImage']
                self.sImage = sitk.GetImageFromArray(self.nImage)
                if kwargs.has_key('expInfo') and isinstance(kwargs['expInfo'], ei.ExperimentInfo):
                    self._expInfo = kwargs['expInfo']
                    self.sImage.SetSpacing(self._expInfo.res)
                else:
                    pixelX = self.sImage.GetWidth()
                    pixelY = self.sImage.GetHeight()
                    Zsteps = self.sImage.GetDepth()
                    res = self.sImage.GetSpacing()
                    self._expInfo = ei.ExperimentInfo(pixelX=pixelX, pixelY=pixelY, Zsteps=Zsteps,
                                                      pixelSizeUM=res[0], stepSizeUM=res[2], res=res)

    def set_exp_info(self, exp_info):
        if isinstance(exp_info, ei.ExperimentInfo):
            self._expInfo = exp_info
            self.sImage.SetSpacing(self._expInfo)
        else:
            print('error: expInfo was not an instance of ExperimentInfo.')

    def get_exp_info(self):
        return self._expInfo

    def get_nonzero_mask(self):
        nmask = np.zeros(self.nImage.shape, dtype=np.uint8)
        nmask[self.nImage > 0] = 1
        smask = sitk.GetImageFromArray(nmask)
        smask.CopyInformation(self.sImage)
        return smask

    def get_subvolume_mask(self, corner_UL, corner_LR):

        siz = self.sImage.GetSize()
        nmask = np.zeros(siz[::-1], dtype=np.uint8)

        nmask[corner_UL[2]:corner_LR[2] + 1,
        corner_UL[1]:corner_LR[1] + 1,
        corner_UL[0]:corner_LR[0] + 1] = 1

        smask = sitk.GetImageFromArray(nmask)
        smask.CopyInformation(self.sImage)
        return smask

    def __repr__(self):
        toshow = ''
        for k, v in self.__dict__.items():
            toshow = toshow + '\n\t{}: {}'.format(k, v)
        return toshow
