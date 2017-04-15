import os
import random

if __name__ == '__main__':

    filepath = './Images_ori'

    filelist = os.listdir(filepath)

    rand_idxs = random.sample(range(len(filelist)), int(len(filelist)/2))  # int(len(filelist)/2)

    for idx in rand_idxs:
        file = filelist[idx]
        filedir = os.path.join(filepath, file)
        print(filedir)
        if os.path.exists(filedir):
            os.remove(filedir)
        else:
            print('no such dir\n')
