This folder contains the all data to be used in the landscape model. There is one folder per dataset: human, human2, plant, mosquito. In each folder, there are:

- All the corresponding metadata files
- A file containing the functional prediction from Tax4Fun2, transformed to fit the format needed for the landscape scripts, called '*_function.txt'. To be generated when running the scripts.

The metadata per dataset is comprised of:

- Human [dataset from Bokulich et al. (2016)]: 'SraRunTable.txt', obtained from the Sra run selector.

- Human2 [dataset from Vanaten et al. (2016)]: 'SraRunTable.txt', obtained from the Sra run selector, containing the sample IDs; 'filereport_analysis...', which contains the MGrast analysis IDs for each sample; 'DIABIMMUNE...', with host metadata information;  'Human2_metadata' combines the information of all three and 'ERP108956_GO...', containing the GO anottation per each analysis, used to build 'Human2_function.txt'. 'ERP108956_GO...' should be added here before running the scripts.

- Plant [dataset from Vannier et al. (2018)]: 'SraRunTable.txt', obtained from the Sra run selector, containing the sample run IDs and the research IDs; 'plants.csv', cnstructed from the supplementary material of the paper, which relates the research IDs with the sample metadata.

- Mosquito [dataset from Arkoli et al. (2019)]: 'README...' containing the original metadata and 'mosquito.csv' with the same information stored as a dataframe.