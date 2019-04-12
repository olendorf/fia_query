# FIA Web Query for R

This is currently a first pass at querying the Forest Inventory Analysis [FIA DataMart](https://apps.fs.usda.gov/fia/datamart/datamart.html). Currently  it is not packagized, althought that may happen in the future.

## Usage

The easiest way to set up the script is to use the [EVALIDator Tool](https://apps.fs.usda.gov/Evalidator/evalidator.jsp). It walks you throug a wizard and delivers an HTML formated version of the data and the URL with the query terms. Use the query terms in the provided URL to edit the *__query_parameters__* list in the script. You must provide empty quotes for unused parameters and the period must be included on the schemaName.

```r
query_parameters <- list(
  reptype="State",
  lat=0,
  lon=0,
  radius=0,
  snum="Net merchantable bole volume of live trees (at least 5 inches d.b.h./d.r.c.), in cubic feet, on forest land",
  sdenom="No denominator - just produce estimates",
  wc=372017,
  pselected="Basal area all live",
  rselected="Species",
  cselected="All live stocking",
  ptime="Current",
  rtime="Current",
  ctime="Current",
  wf="",
  wnum="",
  wnumdenom="",
  FIAorRPA="FIADEF",
  outputFormat="JSON",
  estOnly="N",
  schemaName="FS_FIADB."
)
```

The FIA data uses a dash (**-**) to denote missing values or zeros. Edit the blanks veriable to suit your needs.

```r

## How to handle cells with a dash

blanks <- NA  #Should be either NA or 0 depending on your needs
```
The documentation at https://apps.fs.usda.gov/fia/datamart/images/FIADB_API.pdf sshows that you can either send a GET request or a POST request. The post request can return larger quantities of data. The script has code to do either, the code for the GET request is commented out. 

Finally, there is an example of transforming the JSON returned by FIA into a dataframe. The code here will be specific to
your particular query and needs. This code is included to get you started. EVerything below this section marker should be 
edited.

```r
####################################################################################################
## This section maps the JSON to a tabular format (dataframe). You will need to change           ##
## This logic depending on your exact query                                                      ##
###################################################################################################
```

## Reuse
This script is given freely with no real restrictions on use or reuse.
