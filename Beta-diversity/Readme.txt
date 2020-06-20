## Simulations of pairs of communities ##

1) We used seqtime to simulate comunities with different initial conditions and with different fractions of interacting species.
2) Then, we measured the Morisita index for independent pairs of communities.
3) We runned a glm to see if the parameters of the simulations (the difference in the initial conditions and the fraction of interacting species) explain the Morisita index.

For each step, the scripts are:

1) Idea1.1.R
2) Idea1.1A.R
3) Idea1.1AT.R

There are two other scripts in the folder:

- mHubbell.R
- mSOI.R

Those correspond to modified functions from the seqtime package, and are called by 'Idea1.1.R'.

The folder 'CSVfiles/' contains all generated csv files.

- 'Idea1.4.csv' contains the simulated communities and the parameters of the simulations
- 'Analysis1-lm.csv' contains the Morisita Index for the pairs of simulations