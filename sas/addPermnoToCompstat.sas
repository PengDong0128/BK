libname bk 'C:\Users\Administrator\Desktop\bk\data';

proc import datafile = 'C:\Users\Administrator\Desktop\bk\data\firmdel.csv' out = firmdel dbms = csv replace;
	delimiter = ',';
	getnames = yes;
run;

data delist;
set firmdel;
drop var1;
run;

proc sort data = delist;
by permno;
run;

data delist;
set delist;
keep PERMNO CUSIP DLSTDT DLSTCD DLPRC DLRET;
run;


proc import datafile = 'C:\Users\Administrator\Desktop\bk\data\return.csv' out = TempRet dbms = csv replace;
	delimiter = ',';
	getnames = yes;
run;

proc SQL;
create table ret as 
	SELECT CUSIP 
		,(CUSIP) FORMAT = Z8. as NewCusip
		,PERMNO, DATE, RET, SHROUT, mdate, PRC
	FROM work.TempRet;
QUIT;

data one;
set ret;
drop CUSIP;
run;

proc sort data = one;
by permno;
run;


data one;
set one;
rename newcusip = cusip;
run;

data delist;
set delist(rename=(permno=temppermno));
permno = put(temppermno, 5.);
drop temppermno;
run;

data one;
set one(rename=(permno=temppermno));
permno = put(temppermno, 5.);
drop temppermno;
run;


data one;
set one(rename=(cusip=tempcusip));
cusip = put(tempcusip, 8.);
drop tempcusip;
run;

data one;
merge one(IN=IN1) delist(IN=IN2);
by permno;
IF IN1=1 AND IN2=1;
run;

%let wrds = wrds.wharton.upenn.edu 4016;
options comamid=TCP remote=wrds;
signon username=_prompt_;

 
rsubmit;

* Create 8-digit CUSIP using "NAMES" file;
data compcusip (keep = gvkey cusip cusip8 tic);
set comp.names;
cusip8 = substr (cusip,1,8);
run;
 
proc print data=compcusip noobs label;
var gvkey tic cusip cusip8;
run;
 
*Extract CRSP Cusip from "STOCKNAMES" file;
proc sort data=crsp.stocknames (keep=cusip permco permno)out=crspcusip nodupkey;
by cusip;run;
 
 
* Merge Compusat cusip with CRSP cusip and create table "total";
proc sql;
create table total as select
compcusip.*,  crspcusip.*
from compcusip, crspcusip
where compcusip.cusip8 = crspcusip.cusip;
quit;
run; 
 
proc print noobs data = total;
var gvkey tic cusip8 permno;
run;



proc download data=total out=bk.total;
run;

rsubmit;
endrsubmit;
*Merge Compusat set with Linking table;
proc sql;
create table mydata
as select *
from work.compyr as a, bk.total as b
where a.gvkey = b.gvkey;
quit;

rsubmit;
proc download data=mydata out=bk.compwithpermno;
run;
 

libname bk 'C:\Users\Administrator\Desktop\bk\data';



data temp;
set return_with_delist;
retyear = year(date);
retmonth = month(date);
run;


data comp_with_permno;
set comp_with_permno(rename=(permno=temppermno));
permno = put(temppermno, 5.);
drop temppermno;
run;

proc sql;
create table merge
as select *
from comp_with_permno as a, temp as b
where a.permno = b.permno and
        a.fyear = b.retyear;
quit;

