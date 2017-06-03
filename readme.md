## Bankruptcy prediction using accounting and market data

SAS code:
==========
- compstat.sas : use SAS to retrieve accounting data
- addPermnoToCompstat.sas : use SAS to add Permno to compstat data, later will use permno to link with market data


Data:
=========
=======
- market_raw.csv : raw market data     
- Return_with_delist.csv : add delist info to market data      
- anualized_marketing_data.csv :
- sp_500.csv : sp 500 data     
- comp.csv : compustat data with permno, final   
- crsp.csv : market data to calculate features, final  
- final_variables.csv : all features, bankruptcy indicator Y, and fyear, cusip, permno, permco

Document:
=========
- working_log.md
- steps.md
- merge_missing.md
- result

ipython notebook:
- process_market_data.ipynb : calculate market data     
- working_nb_py3.ipynb : get features and models, in python 3        
