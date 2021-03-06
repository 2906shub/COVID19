OpenIND <- function(cache, level){
  # Author: Rijin Baby
  
  if(level==1){

    # reading source data
    # https://www.covid19india.org/
    url <- "https://api.covid19india.org/csv/latest/case_time_series.csv"
    x   <- read.csv(url, cache = cache)
    
    # date
    Sys.setlocale("LC_TIME", "C")
    x$date <- as.Date(x$Date, format = "%d %B")
    
    # formatting
    x <- x[,c("date","Total.Deceased","Total.Confirmed","Total.Recovered")] 
    colnames(x) <- c("date","deaths","confirmed","recovered")
        
  }
  if(level==2){

    # reading source data
    # https://www.covid19india.org/
    url <- "https://api.covid19india.org/csv/latest/state_wise_daily.csv"
    x   <- read.csv(url, cache = cache)
    
    # drop total
    x <- x[,-3]
    
    # date
    x$Date <- as.Date(x$Date, format = "%d-%b-%y")
    colnames(x)[1] <- "date"
    
    # cumulative 
    x <- x %>% 
      dplyr::group_by(Status) %>%
      dplyr::group_map(keep = TRUE, function(x,g) c(x[,1:2], cumsum(x[,-(1:2)]))) %>%
      dplyr::bind_rows()
    
    # formatting
    x <- x %>% 
      tidyr::pivot_longer(-(1:2), names_to = "state", values_to = "value") %>%
      tidyr::pivot_wider(names_from = "Status")
    
    colnames(x) <- mapvalues(colnames(x), c(
      'Confirmed' = 'confirmed',
      'Deceased'  = 'deaths',
      'Recovered' = 'recovered'
    ))
    
  }
  
  # return
  return(x)
  
}
