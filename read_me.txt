The folders within contain files, both original and modified, necessary for the construction of the tax progressivity measure. In the following, I describe the folder structure. The first word is the name of the folder.

--------------------------------------------------------------------------------------------------------

AMTR:

Contains 2 files necessary to construct AMTR defined by Ferriere, Axelle, and Gaston Navarro. "The Heterogeneous Effects of Government Spending: It's All About Taxes." FRB International Finance Discussion Paper 1237 (2018).

Quote from appendix A.1:
"For the Average Marginal Tax Rate [AMTR], we use the time series of Barro and Redlick
(2011) (data: federal, until 1945) and Mertens and Olea (2018) (data: federal, years 1946-2012)"

The 2 files described in the quote are precisely these files. 

--------------------------------------------------------------------------------------------------------

AMTR_construction:

Constructs AMTR using Mertens and Olea (2018). Code is modified for the additional years and new tax reporting measures.
 
1) For the folder "barro_redlick", it contains a file on how they constructed their AMTR.
2) For the folder "mertens_olea": 
	- 1st folder, auxiliary files: contains code to run Construct_Marginal_Individual_Income_Tax_Rates.m and 
	- 2nd folder, data: contains final data to be used in Construct_Marginal_Individual_Income_Tax_Rates.m
	- The next 3 folders contain 2 folders: (1) cleaned_tables (2) original_tables. The name of the folder tells you which data file it supports (see "data" to see).
	- (1) cleaned_tables: tables made containing data from original tables. The data chosen depends on the data needed to run the code. The data needed to run the code is in the folder above: "data". 
	- (2) original_tables: contains data from the original sources (Main Source: IRS, Statistics of Income Division)													- The folder "for_TIME_SERIES" supports the TIME_SERIES_DATA.xlsx. There are some notes in the folder concerning the files contained. Please read. 
	- The folder "original_files" contains original files from Mertens and Olea (2018)
	- The folder "output" contains the excel files produced by the code except for the last file. These are:
	- AMPTRs: Average marginal payroll tax rate
	- AMIITRs: Average marginal individal income tax rate
	- their sum is equal to the AMTR defined by Mertens and Olea (2018) 
	- The "progressivity_measure.xls", the last file, contains the ATR, AMPTR, AMIITR, and "P"rogressivity series 

3) The last 2 files are the matlab files to generate files in output. 
--------------------------------------------------------------------------------------------------------

ATR:

1) Contains 2 folders: (1) cleaned_tables (2) original_tables
	- in "cleaned_tables", there's only 1 file. It contains the Average tax rate and the data to calculate it. There is a "sources" tab within the excel file. Please read for more details.
	-  in "original_tables", you will find all the original sources needed to construct the cleaned table
--------------------------------------------------------------------------------------------------------