# DNA-In-Pits-Analysis-Codes-CatL
Codes to analyze DNA interactions in nanopits, using FRET signals, FRET efficiency, diffusion coefficients,...-Cat

*Still in progress* 

--------------------------------------------------------------------------------------------------------------------------------

Grid Registration: 

    use GridRegistration.m to register a new grid. Take 2 sample videos by calling TifSample.m, one should include empty pits and the other non-empty pits. Will save the grid paramters (horizontal & vertical spacing, pit radius and sample pits images in both channels) in .mat file. The .mat file must be in the folder containing the samples (saved as .tif) to be analyzed. 

--------------------------------------------------------------------------------------------------------------------------------
    
Pit Finder :

    the main function calls ConstructPitsGrid.m to localize the pits using cross correlation with the samples in the .mat file. Radon transform is used to find the grid tilt (to a precision of 0.5°), and the approximate positions of the rows and columns of the grid. The default grid is then fitted to the peaks (but the grid parameters remain unchanged - the grid registration must have been done properly). Detect the pits by collapsing the video into a single image, and uniformizing the background and enhancing the contrast of the image.
 
 --------------------------------------------------------------------------------------------------------------------------------
    
Main functions :

DNA_In_Pits_Analysis.m calls TifSample.m, the pit finder, creates PitSample objects with properties including the conditions of the experiment and the date and time, as well as PitChannel objects for each channel in the green laser, and the red channel in the red laser. Associates a red laser experiment to a green laser experiment as long as the variation in temperature is within some delta. Uses the red laser experiment to calculate the FRET efficiency (1 out of 2 methods). The PitSample object calculates the background, the spatial average in the pits of the relative signals and feeds the properties of the PitChannel objects. The masks of the pits are generated by my_mask.m Sends videos of pits to the PitChannel objects to calculate the diffusion coefficients using 2 methods (autoccorelation of the relative signals and partial tracking). PitSample also generates a FRETefficiency object containing the results of the FRET efficiency using the proximity ratio with corrections for cross talks (cross emission and cross excitation), as well as the acceptor emission method, and a FRETanalysis object containing the FRET signals. PitsChannel also uses binning/clustering to estimate the number of molecules per pit in time (using averaged relative signals), and calculates 'an indicator' of molecular activity in the pit, as well as the molecular brightness. It takes the difference between the intensity of 1 molecules using clustering and compares it to the molecular brightness to try to estimate the offset to remove it from the relative signals. CrossEmission.m returns the cross-emission coefficient as well as the coefficient against temperature. Move all .*tif files to be analyzed in a folder, containing the GridRegistration.mat file. Will do the analysis and save the PitSample objects in a single .mat file with the date and time of the analysis.

--------------------------------------------------------------------------------------------------------------------------------  
User Interface:

    Allows the user to interactively do the analysis with visual support, as well as running batch runs.

--------------------------------------------------------------------------------------------------------------------------------
  
Things to fix : 

     o Molecular brightness VS intensity of 1 molecule + cross exciation.
     o Diffusion coefficient using partial tracking and autoccorelation of relative signals
     o Molecule counting using binning/clustering of relative signals could be compared to the same process but spatially and for each pit individually.
     o FRET signals + analysis (Frequency, Duration, Amplitude)
     o User interface
    
