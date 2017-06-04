# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import numpy
import scipy


def stretch_calculator(L, M, N, ratio, stiff):
    
    g = 10
    m = (M/N)*numpy.ones(N)
    #Lnew = ratio*L
    
    restLength = (L/(N-1))*numpy.ones(N-1)
    stretch = numpy.zeros(N-1)
    
    for ij in range(N-1):
        stretch[ij] = (g/stiff)*sum(m[ij+1:])
        
    return (ratio-1)*restLength - stretch
    


def stiff_calculator(stiff):
    
    LL = 10
    MM = 11
    NN = 11
    ratio = 1.1
    
    stretch = stretch_calculator(LL, MM, NN, ratio, stiff)
    
    return sum(stretch);
    
    
    
for ij in numpy.linspace(0,1000,10):
    print(scipy.optimize.fsolve(stiff_calculator,ij))