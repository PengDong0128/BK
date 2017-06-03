## Merge comp and crsp
- Basic idea, use the first 8-digit cusip in comp to match the cusip in crsp
- Extract comp 8-digit cusip from comp.names, keep gvkey cusip cusip8
- Extract crsp  cusip from crsp.stocknames, keep cusip permno permco
- Merge comp cusip with crsp cusip and map permno to comp data
- cusip:
	1. 9 digits, the first 6 identify the issuer, 7th8th identify the issue, 9th check number
	2. cusip will change
	3. cusip is backfilled in compustat and crsp, meaning it only shows the latest cusip (so called header cusip), even for historical records
	4. cusip in crsp 8 digits, in compustat 9 digits
	5. crsp has historical cusips linking to every unique permno, compustat not

## Deal with missing values

#### Before calculation variables
- When the denominator is missing, delete the rows, 
    - at, total assets
    - seq, shareholder's equity
    - lt, liabilities
- When the denominator is missing, but too many rows, make it 0
    - invt, inventory, **12.5% missing, when calculate invch/invt, now just make this 0** 
    - lct, current liabilities, **25% missing, when calculate CHLCT,QALCT, ACTLCT, now just make this 0**
    - sale, sale, **11% missing**
- When the nominator is missing, substitue it with 0
    - BE, book equity
    - QA, quick assets
    - act, current assets
    - ap, account payable
    - ch, cash
    - che, cash and short-term investments
    - dlc, debt in current liabilities 
    - dltt, long-term debt
    - dp, depreciation and amortization
    - ebit, earnings before interest and taxes 
    - invch, inventory decrease
    - invt, inventory
    - lct, current liabilities
    - lt, liabilities
    - mib, 
    - ni, net incomings
    - oiadp, operating income after depreciation
    - re, retained earnings
    - sale, sale
    - wcap, working capital
- Delete variable ffo, 99% missing
- Delete the rows where lct is bigger than lt

### After calculation variables
- 2 infinite variables due to logrithm of 0, logsale and logat, make it 0