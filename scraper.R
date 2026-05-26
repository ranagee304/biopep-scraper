# ==========================================
# BIOPEP FULL PEPTIDE SCRAPER
# Extract ALL peptide sequences into Excel
# ==========================================

# ------------------------------------------
# Install packages automatically
# ------------------------------------------

packages <- c(
  "rvest",
  "httr",
  "stringr",
  "dplyr",
  "purrr",
  "openxlsx"
)

installed <- packages %in% rownames(installed.packages())

if(any(!installed)){
  install.packages(
    packages[!installed],
    repos = "https://cloud.r-project.org"
  )
}

# ------------------------------------------
# Load libraries
# ------------------------------------------

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

max_id <- 12000

cat("Running scraper up to ID:", max_id, "\n")

# ------------------------------------------
# Function to scrape peptide page
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

    sequence <- str_match(
      text,
      "Sequence\\s+([A-Z]+)"
    )[,2]

    if(is.na(sequence)){
      return(NULL)
    }

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
# Run scraper
# ------------------------------------------

results <- map_dfr(
  1:max_id,
  scrape_peptide
)

# ------------------------------------------
# Clean results
# ------------------------------------------

results <- results %>%
  filter(!is.na(Sequence)) %>%
  distinct()

# ------------------------------------------
# Save Excel
# ------------------------------------------

output_file <- "BIOPEP_ALL_sequences.xlsx"

write.xlsx(results, output_file)

cat("\n=================================\n")
cat("DONE!\n")
cat("Sequences collected:", nrow(results), "\n")
cat("Saved as:", output_file, "\n")
cat("=================================\n")
