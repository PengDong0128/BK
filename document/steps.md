# Get accounting data from compustat, output: table comp, 1980-2015

## Problem, remove all the rows where indfmt = FS, very rare, 3% of total data, some companies have two tag, INDL or FS in one year   
## Create table comp_extract1 to get BE0
- calcualte she
	1. if SEQ not missing, then she = SEQ, else
	2. if CEQ not missing and PSTK not missing, then she = CEQ+PSTK, else
	3. if AT not missing and LT not missing and MIB not missing, then she = at-(LT+MIB),else
	4. she = missing
- calculate BE0
	1. if PSTKRV not missing, then BE0 = she - PSTKRV, else
	2. if PSTKL not missing, then BE0 = she-PSTKL, else
	3. if PSTK not missing, then BE0 = she - PSTK, else
	4. BE0 = missing
- convert fiscal year into calendar year data
	1. fyr: 2-character numeric month code, if a company ends its fiscal year on day 1-14, fyr = month-1, else, fyr = month
	2. fyear: if the current fiscal year-end month falls in 1-5, fyear = calendar year -1 , else fyear = calendar year
	3. create date_fyend, the actual fiscal year end date for a company
	4. create calyear, calyear = year(date_fyend), the actual calendar year
	5. accounting data since calendar year t-1
## Create table comp_extract to add pension annual item info to BE0 to get BE
- if TXDITC and PRBA not missing, BE = BE0+TXDITC-PRBA, else
- BE = BE0
## Create table comp1 to get comp data
## Merge table comp_extract(BE info) and comp1(all other accounting info) to get table comp1
## Add dldte and dlrsn into comp1, get table compyr

# Get market data from crsp, output: table crsp from 1980-2015

## Download raw data
- download 'return_new.csv‘ with python, containing features:CUSIP PERMNO DATE PRC RET SHROUT
- download 'delist_new.csv' with python, containing features:PERMNO CUSIP DLSTDT DLSTCD DLPRC DLRET
- download 'sp_500.csv' on web interface,containing features:DATE vwretd vwretx ewretd ewretx sprtrn totval totcnt
## Link tables:
- first link return_new with delist_new on PERMNO, the output table is Return_with_delist.csv
- then link Return_with_delist with sp_500 on PERMNO and mdate, mdate is a new feature calculated from DATE
## Process data
- calculate mdate for Return_with_delist and sp_500, mdate contains year and month in the 'DATE', that is yyyymm
- PRC = abs(PRC),the new PRC is the absolute value of the original PRC if both RET and PRC are not null
- fill 0 to RET with null value
- calculate sigma: for a company in a specific mdate, sigma is the zero-centered variance for the last 3 months
- reconstruct PRC :
- if PRC>15 prc2 =15, else prc2=PRC
- PRC = ln(prc2)
- calculate mket: mket = PRC*shrout/1000
- calculate exrcamp: exrcamp = ln(1+RET)-ln(1+vwretd)
## Transfer the monthly data into yearly data:
- for ret and vwretd, we calculate the factorial of the year to get the final yearly ret and vwretd, for those month whose ret or vwretd is missing , we set the factor of that month as 1
- for the rest of the data, we take average of them
- we define bankruptcy as the delist code in [400,401,403,450,460,470,480,490,572,574]
- output is anulized_marketing_data_new.csv
## Detect which year bankrupts
- In anualized_marketing_data_new.csv, for a bankruptcy company , the delist label of every year is 1, so here we set only the last year as 1 , others as 0.
- output is crsp.csv

# Model and results
- We use the data one year ahead to predict if a company will bankrupt in the next year
- Train test split： we regard the data before 2008 as training set, 2008-2015 as testing set.
- Classifier: We use LogisticRegressionCV with l1 regulazation as the classifier, we've tried different lambda:[5, 2.5, 1.66, 1.25, 1]
- Benchmark: Random Forest Classifier
- Evaluation method: we use Tian's accuracy ratio , which is (auc-0.5)/2, we also provide the original auc score as well as the decile performance table.

# SAS command
- missing(), works for either character or numeric variables and it also checks for the special numeric missing values(.A, .B, .C), 0 is present and 1 is data point missing
- INTNX(interval,start-from,increment),
- mdy(), create a SAS date value from numeric values that represent the month,day,and year, mdy(3,2,2010),gets, 02MAR2010


# Reference
- [Link compustat with crsp](https://wrds-web.wharton.upenn.edu/wrds/support/Additional%20Support/WRDS%20Knowledge%20Base%20with%20FAQs.cfm?article_id=1432&folder_id=671)     
- [CUSIP: Backfilled and Historical](https://wrds-web.wharton.upenn.edu/wrds/support/Additional%20Support/WRDS%20Knowledge%20Base%20with%20FAQs.cfm?article_id=664&folder_id=657)
