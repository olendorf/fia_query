###################
## Automate package install and load

is_installed <- function(package_name) is.element(package_name, installed.packages()[,1])

# If a package is not installed, install it. Then load the package.
install_and_load <- function(package_name) {
  if(!is_installed(package_name)) {
    install.packages(package_name)
  }
  library(package_name, character.only = TRUE)
}

install_packages <- function(packages) {
  for(package in packages) {
    install_and_load(package)
  }
}

install_packages(c("httr", "rjson"))

# Enter the desired parameters below. See FIA documentation for details
# https://apps.fs.usda.gov/fia/datamart/images/FIADB_API.pdf
# 
# The EVALIDator tool will build a full url, but you willl need to chop up the 
# query string to enter below.  https://apps.fs.usda.gov/Evalidator/evalidator.jsp
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


## How to handle cells with a dash

blanks <- NA

###########
## Build the query for GET request

# The base url for the request
# get_url <- "https://apps.fs.usda.gov/Evalidator/rest/Evalidator/fullreport"
#   
# # Take all the key value pairs and build a properly escaped query string                        
# string <- ""
# 
# # Loop through the keys
# params <- names(query_parameters)
# query_segements <- c()
# for(param in params) {
#   segment <- paste( c(param, query_parameters[[param]]), collapse="=" ) # find the value and add an equals
#   query_segements <- c(query_segements, URLencode(segment))  # create the key-value segment
# }
# 
# 
# query_string <- paste(query_segements, collapse="&")  # Paste the segments together
# 
# 
# response <- GET(url = paste(c(get_url, "?"), collapse=""))

###########
## Build the query for GET request

# The base url for the request
post_url <- "https://apps.fs.usda.gov/Evalidator/rest/Evalidator/fullreportPost"


###################
## Build query for POST request - according to the docs this is better able to handle very large responseses with a lot of data.


response <- POST(url = post_url, body=query_parameters, encode="form" )

json_response <- content(response)   # Returns the response as nested lists

## This section maps the JSON to a tabular format (dataframe). You will need to change 
## This logic depending on your exact query

#initialize some vector, to build the dateframe out of later
estimates_list <- list(
                    species=c(),
                    total=c(),
                    overstocked=c(),
                    fully_stocked=c(),
                    medium_stocked=c(),
                    poorly_stocked=c(),
                    nonstocked=c()
                  )

sampling_error_list <- list(
                    species=c(),
                    total=c(),
                    overstocked=c(),
                    fully_stocked=c(),
                    medium_stocked=c(),
                    poorly_stocked=c(),
                    nonstocked=c()
                  )

non_zero_plots_list <- list(
                        species=c(),
                        total=c(),
                        overstocked=c(),
                        fully_stocked=c(),
                        medium_stocked=c(),
                        poorly_stocked=c(),
                        nonstocked=c()
                      )

# the other pages just subsample the first page so just need that
# loop through the rows and build the vectors for the tables
for(row in json_response$EVALIDatorOutput$page[[1]]$row) {
  
  # 
  estimates_list$species <- c(estimates_list$species, row$content)
  sampling_error_list$species <- c(sampling_error_list$species, row$content)
  non_zero_plots_list$species <- c(non_zero_plots_list$species, row$content)
  
  for(column in row$column) {
    column_name <- gsub(" ", "_", tolower(column$content))  #STandardize the column name, R tends to handle it its own ugly way
    estimates_list[[column_name]] <- c(estimates_list[[column_name]], column$cellValueNumerator)
    sampling_error_list[[column_name]] <- c(sampling_error_list[[column_name]], column$cellSE)
    non_zero_plots_list[[column_name]] <- c(non_zero_plots_list[[column_name]], column$cellPlotNumerator)
  }
  
  
}

estimates <- data.frame(estimates_list)
sampling_error <- data.frame(sampling_error_list)
non_zero_plots <- data.frame(non_zero_plots_list)

estimates[estimates == "-"] <- blanks
sampling_error[sampling_error == "-"] <- blanks
non_zero_plots[non_zero_plots <- "-"] <- blanks
