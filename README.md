Features of Nonstationary Directional Coupling
==============================================

Matlab code to generate the feature set used in the publication:

`JM O'Toole, EM Dempsey, D Van Laere, Nonstationary coupling between heart rate and
perfusion index in extremely preterm infants in the first day of life, Physiological
Measurement, 2021.`
[DOI:10.1088/1361-6579/abe3de](https://doi.org/10.1088/1361-6579/abe3de)

---

[Requirements](#requires) | [Examples](#examples) | [References](#references) | [Contact](#contact)

# Requires
  As Matlab code requires [Matlab](https://uk.mathworks.com/products/matlab.html). Not
  tested with [GNU Octave](https://www.gnu.org/software/octave/) but may work.

  Specific packages required:

  1. The `asymp_package_v3` toolbox which is available
     (http://www.lcs.poli.usp.br/~baccala/pdc/)
  2. `ARfit` toolbox, available (https://github.com/tapios/arfit)
  
  Download both packages and add to Matlab paths. See [how to add
  path](https://uk.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html)
  for more details. 
  
  Next, add the path for this project in Matlab; can do so by
  ```matlab
  >> add_path_here();
  ```



# Main Functions

  * Short-time information partial directed coherence (ST-iPDC): `shorttime_iPDC.m`
  * Estimate features of the individual ST-iPDC: `feats_IF_STiPDC.m`
    - including Hjorth parameters: `hjorth_feats.m`
  * Features for time-varying direction of the coupling:
    `feats_direction_coupling_STiPDC.m`
	- includes the 2D fractal measure: `fd_curves.m`

For more information on function type `help <filename.m>`.


# Examples

### Synthetic signals
To generate the 4 time-varying bi-variate autoregressive examples and plot (Figure 3):

```
>> gen_STiPDC_all_signals;
```
Example of the short-time information partial directed coherence (ST-iPDC) function
(middle), with the time-vary coupling coefficients (top) and the spectral representations
of the signals _x_ and _y_:
![Plots of the ST-iPDC function (middle)](pics/tvmvar_example2.svg 'ST-iPDC functions')


### 2D fractal dimension 
Plot examples for 2D fractal dimension measure an extension of the Higuchi approach (Figure 2):
```
>> plot_FD_examples;
```

Which plots the following fractal dimension estimates _D_ for 3 different planar signals:

![Examples of fractal dimension estimates](pics/fractal_dim_examples.svg 'Fractal dimension
(D) estimates for 3 different planar signals')


### Estimating instantaneous frequency in the STiPDC
Estimate and plot the instantaneous frequency (IF) estimates from one of the synthetic
signals (Figure 4A):
```
>> estimate_IF_STiPDC_example;
```

which will produce estimates for the 1,000 iterations:

![IF esimates](pics/if_estimate_example.svg 'IF estimates from the ST-iPDC')

To estimate features from the IF see `help feats_IF_STiPDC.m`.

### Time-varying directional coupling
Plot the time-varying directional coupling between the bi-variate signals (2 examples in Figure 4B and
4C):
```
>> time_traj_coupling_examples;
```

which will produce the trajectory plots for 2 different signal types:

![Time-varying coupling](pics/coupling_traj_examples2.svg 'Coupling
trajectories')![Time-varying coupling](pics/coupling_traj_examples3.svg 'Coupling trajectories')

To estimate features from the IF see `help feats_direction_coupling_STiPDC.m`.

# References

1. Baccala LA, Takahashi DY, & Sameshima K. (2016). Directed Transfer Function: Unified
Asymptotic Theory and Some of its Implications. IEEE Transactions on Biomedical
Engineering, 63(12), 2450–2460. [doi:10.1109/TBME.2016.2550199](https://doi.org/10.1109/TBME.2016.2550199)

2. Baccala LA, de Brito CSN, Takahashi DY, & Sameshima K. (2013). Unified asymptotic
theory for all partial directed coherence forms. Philosophical Transactions of the Royal
Society A: Mathematical, Physical and Engineering Sciences,
371(1997), 20120158. [doi:10.1098/rsta.2012.0158](https://doi.org/10.1098/rsta.2012.0158)

# 

# Contact
John M. O' Toole

INFANT Research Centre, Ireland.
Department of Paediatrics and Child Health,  
Room 2.19, UCC Paediatric Academic Unit, Cork University Hospital,  
University College Cork, Ireland.

Email: jotoole AT ucc. ie

