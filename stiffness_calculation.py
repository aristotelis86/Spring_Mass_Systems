# -*- coding: utf-8 -*-

import numpy
import scipy

file = open('distances.txt','w') 
LL = 10
MM = 11
NN = 110
ratio = 1.1
restLength = (LL/(NN-1))

def stretch_calculator(L, M, N, ratio, stiff):
    
    g = 10
    m = (M/N)*numpy.ones(N)
    
    stretch = numpy.zeros(N-1)
    
    for ij in range(N-1):
        stretch[ij] = (g/stiff)*sum(m[ij+1:])
        
    return stretch
    
def stiff_calculator(stiff):
    
    stretch = stretch_calculator(LL, MM, NN, ratio, stiff)
    OUT = (ratio-1)*restLength - stretch
    
    return sum(OUT)
    
    
    
STIFFNESS = scipy.optimize.fsolve(stiff_calculator,1000)

DISTS = stretch_calculator(LL, MM, NN, ratio, STIFFNESS)

POS = numpy.zeros(NN-1)


for ij in range(NN-1):
    POS[ij] = DISTS[ij] + restLength
    file.write('%f \n' % POS[ij])
    

file.close() 
#print(STIFFNESS)
#print(len(DISTS))
#print(POS)