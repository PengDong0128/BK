libname bk 'C:\Users\Administrator\Desktop\bk';


%let wrds = wrds.wharton.upenn.edu 4016;
options comamid = TCP remote = WRDS;
signon username = _prompt_;
rsubmit;

libname mywrds '/home/';

libname compx '/wrds/comp/sasdata/naa';
libname compy '/wrds/comp/sasdata/naa/pension';


libname compn '/wrds/comp/sasdata/naa/company';

/****************************************************
*****************************************************
Highlight:
SEQ: Stockholders Equity - Parent
CEQ: Common/Ordinary Equity - Total
PSTK: Preferred/Preference Stock (Capital) - Total
if (1<=fyr<=5) then date_fyend=intnx('month',mdy(fyr,1,fyear+1),0,'end'); 
*****************************************************
*****************************************************/


data comp_extract1; 
   set compx.funda ; 
   if missing(SEQ)=0 then she=SEQ;else /*SEQ: Stockholders\'\' Equity - Total*/
   if missing(CEQ)=0 and missing(PSTK)=0 then she=CEQ+PSTK;else /* CEQ:Common/Ordinary Equity - Total;PSTK: Preferred/Preference Stock (Capital) - Total*/
   if missing(AT)=0 and missing(LT)=0 and missing(MIB)=0 then she=AT-(LT+MIB);else she=.;  /*MIB: Minority Interest (Balance Sheet)*/
   if missing(PSTKRV)=0 then BE0=she-PSTKRV;else if missing(PSTKL)=0 then BE0=she-PSTKL; 
   else if missing(PSTK)=0 then BE0=she-PSTK; else BE0=.; 
   * Converts fiscal year into calendar year data; 
    if (1<=fyr<=5) then date_fyend=intnx('month',mdy(fyr,1,fyear+1),0,'end'); 
    else if (6<=fyr<=12) then date_fyend=intnx('month',mdy(fyr,1,fyear),0,'end'); 
    calyear=year(date_fyend); 
    format date_fyend date9.; 
    * Accounting data since calendar year 't-1'; 
   if (year(date_fyend) >= 1979) and (year(date_fyend) <=2015); 
	if final = 'Y';	
	if indfmt = 'INDL';
   keep gvkey fyear date_fyend fyr calyear BE0 consol datafmt popsrc datadate TXDITC final; 
run; 

proc download data=comp_extract1 out=bk.comp_extract1;
run;



data pension; 
set compy.aco_pnfnda;
if indfmt = 'INDL';
keep gvkey consol datafmt popsrc datadate prba;
run;
proc download data=pension out=bk.pension;
run;

proc sql; 
create table comp_extract 
as select a.gvkey, a.final, a.calyear, a.fyr, a.date_fyend, a.fyear,
          case when missing(TXDITC)=0 and missing(PRBA)=0 then BE0+TXDITC-PRBA else BE0 
          end as BE 
    from work.comp_extract1 as a left join  
         work.pension (keep=gvkey consol datafmt popsrc datadate prba) as b 
on a.gvkey=b.gvkey and a.consol=b.consol and a.datafmt=b.datafmt  
   and a.popsrc=b.popsrc and a.datadate=b.datadate; 
quit; 

proc download data=comp_extract out=bk.comp_extract;
run;


Data comp1; set compx.funda
(where = (1979<= fyear and fyear<=2015));
if final = 'Y';
if indfmt = 'INDL';
keep cusip datadate fyear gvkey WCAP AT RE EBIT SALE LT ACT LCT SEQ NI DLC DLTT DP MIB
AP CH INVCH INVT INTAN OIADP CHE FFO prcc_f csho;
run;

proc download data = comp1 out = bk.comp1;
run;

PROC SORT DATA = COMP1;
BY GVKEY FYEAR;
RUN;

PROC SORT DATA = comp_extract;
BY GVKEY FYEAR;
RUN;


DATA COMP1;
merge comp1(in=in1) comp_extract(in=in2);
by gvkey fyear;
if in1=1 and in2=1;
run;



data comp1; set comp1;
MVE = abs(prcc_f)*csho;
NEGINVT = (-1)*INVT;
QA = SUM(ACT,NEGINVT);
drop prcc_f csho  NEGINVT;
run; 

proc sort data=comp1;
by gvkey decending fyear;run;

proc contents data = comp1;
run;


/****************************************************
*****************************************************
38 dldte Num  8 Research Company Deletion Date 
14 dlrsn Char  8 Research Co Reason for Deletion 
*****************************************************
*****************************************************/
data bkone; set compn.company;
keep gvkey sic dldte dlrsn;
run;

proc sort data=bkone;
by gvkey;run;

proc download data=bkone out=work.bkone;
run;


proc sort data=work.bkone;
by gvkey;run;

data work.comp1; 
merge work.comp1(in=in1) work.bkone(in=in2);
by gvkey;
if in1=1 and in2=1;
run;



proc download data=comp1 out=bk.compyr;
run;

proc export data = bk.Compyr
	outfile = 'C:\Users\Administrator\Desktop\bk\compyr.csv'
	dbms = csv;
run;