/*
Use tian's lasso feature selection code to select feature based on her and ours datasets
*/


proc import datafile="C:\Users\lma10\Desktop\one_year_tian.csv" out=one_year dbms=csv replace;
    getnames=yes;
run;

proc contents data=one_year;
run;

data one_year(drop = _);
set one_year;
run;

data train test;
set one_year;
if mdate < 200612 then output train;
else output test;
run;

ods html;
ods graphics on;

proc glmselect data = train plot=(CriterionPanel Coefficients) testData = test;
model Default = x1-x13 x15-x27 NIMTA LTMTA CASHMTA rsize PRc2 MBE sigma exrcamp/ selection = LASSO;
footnote 'Tian dataset lasso var selection on 12 month prior prediction';
run;

ods graphics off;
ods html close;


proc import datafile="C:\Users\lma10\Desktop\one_year.csv" out=one_year_self dbms=csv replace;
    getnames=yes;
run;


proc contents data=one_year;
run;


data one_year_self(drop = _ gvkey datadate cusip PERMNO PERMCO);
set one_year_self;
run;


data train test;
set one_year_self;
if fyear < 2008 then output train;
else output test;
run;

data train(drop = fyear);
set train;
run;

data test(drop = fyear);
set test;
run;


ods html;
ods graphics on;

proc glmselect data = train plot=(CriterionPanel Coefficients) testData = test;
model Y = NIAT NISALE OIADPAT OIADPSALE EBITAT EBITDPAT EBITSALE SEQAT REAT LCTAT LCTCHAT LTAT LOGSALE CHAT CHLCT QALCT ACTLCT WCAPAT LCTLT INVTSALE SALEAT APSALE LOGAT INVCHINVT CASHAT LCTSALE RELCT FAT SIGMA NIMTA LTMTA CASHMTA PRICE RSIZE EXCESS_RETURN MBE/
       selection = LASSO;
footnote 'our datasetlasso var selection on 12 month prior prediction';
run;

ods graphics off;
ods html close;
