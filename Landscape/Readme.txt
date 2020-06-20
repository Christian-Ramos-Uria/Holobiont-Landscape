Landscape analysis from Chang et al. (2019) applied to four different datasets:

- Human [dataset from Bokulich et al. (2016)] 

- Human2 [dataset from Vanaten et al. (2016)]

- Plant [dataset from Vannier et al. (2018)]

- Mosquito [dataset from Arkoli et al. (2019)]

For an explanation of the analysis, please go to: 'https://github.com/kellylab/microbial-landscapes'

The 'LandscapeMain.R' script calls all the scrips in order, running the model for all datasets.
The scripts are intended to work when the datasets are downloaded in the 'Raw/' folder, and the GO annotation of the Human2 dataset 'ERP108956_GO_abundances_v4.1.tsv' is downloaded in the 'data/human2/' folder. As the OTU tables are provided here, it is possible to run the scripts starting from the Tax4Fun2 part without downloading the datasets if the Tax4Fun2 refernce database path is specified in the scripts. 

References:

Bokulich, N. A., Chung, J., Battaglia, T., Henderson, N., Jay, M., Li, H., ... & Schweizer, W. (2016). Antibiotics, birth mode, and diet shape microbiome maturation during early life. Science translational medicine, 8(343), 343ra82-343ra82.

Chang, W. K., VanInsberghe, D., & Kelly, L. (2019). Towards a potential landscape framework of microbiome dynamics. bioRxiv, 584201.

Vatanen, T., Kostic, A. D., d’Hennezel, E., Siljander, H., Franzosa, E. A., Yassour, M., ... & Peet, A. (2016). Variation in microbiome LPS immunogenicity contributes to autoimmunity in humans. Cell, 165(4), 842-853.

Bokulich, N. A., Chung, J., Battaglia, T., Henderson, N., Jay, M., Li, H., ... & Schweizer, W. (2016). Antibiotics, birth mode, and diet shape microbiome maturation during early life. Science translational medicine, 8(343), 343ra82-343ra82.