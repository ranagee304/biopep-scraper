# ==========================================
# BIOPEP FULL PEPTIDE SCRAPER
# Extract ALL peptide sequences into Excel
# ==========================================

# Install packages if needed
packages <- c(
  "rvest",
  "httr",
  "stringr",
  "dplyr",
  "purrr",
  "openxlsx"
)

installed <- packages %in% installed.packages()

if(any(!installed)){
  install.packages(packages[!installed])
}

library(rvest)
library(httr)
library(stringr)
library(dplyr)
library(purrr)
library(openxlsx)

# ------------------------------------------
# SETTINGS
# ------------------------------------------

base_url <- "https://biochemia.uwm.edu.pl/biopep/"

# Adjust max_id if needed
# BIOPEP IDs are several thousands
max_id <- 12000

# ------------------------------------------
# Function to scrape one peptide page
# ------------------------------------------

scrape_peptide <- function(id){
  
  url <- paste0(
    base_url,
    "peptide_data_page4.php?zm_ID=",
    id
  )
  
  cat("Checking ID:", id, "\n")
  
  tryCatch({
    
    page <- read_html(url)
    
    text <- page %>%
      html_text2()
    
    # Extract sequence
    sequence <- str_match(
      text,
      "Sequence\\s+([A-Z]+)"
    )[,2]
    
    # Skip empty pages
    if(is.na(sequence)){
      return(NULL)
    }
    
    # Extract peptide name if available
    peptide_name <- str_match(
      text,
      "Name\\s+([A-Za-z0-9\\-\\s]+)"
    )[,2]
    
    data.frame(
      ID = id,
      Sequence = sequence,
      Name = peptide_name,
      URL = url,
      stringsAsFactors = FALSE
    )
    
  }, error = function(e){
    
    return(NULL)
  })
}

# ------------------------------------------
# Scrape ALL IDs
# ------------------------------------------

results <- map_dfr(1:max_id, scrape_peptide)

# ------------------------------------------
# Clean results
# ------------------------------------------

results <- results %>%
  filter(!is.na(Sequence)) %>%
  distinct()

# ------------------------------------------
# Save Excel file
# ------------------------------------------

output_file <- "BIOPEP_ALL_sequences.xlsx"

write.xlsx(results, output_file)

cat("\n=================================\n")
cat("DONE!\n")
cat("Sequences collected:", nrow(results), "\n")
cat("Saved as:", output_file, "\n")
cat("=================================\n")
