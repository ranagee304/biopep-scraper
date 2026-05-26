# ==========================================
# BIOPEP PARALLEL SCRAPER (CLEAN VERSION)
# ==========================================

# ---------------------------
# INSTALL + LOAD PACKAGES
# ---------------------------

library(rvest)
library(stringr)
library(dplyr)
library(purrr)
library(furrr)
library(future)
library(openxlsx)

# ---------------------------
# PARALLEL SETTINGS
# ---------------------------

plan(multisession, workers = 4)   # safe for GitHub + laptop

base_url <- "https://biochemia.uwm.edu.pl/biopep/"
max_id <- 5000   # safer starting point (you can increase later)

# ---------------------------
# SCRAPER FUNCTION
# ---------------------------

scrape_peptide <- function(id){

  url <- paste0(base_url, "peptide_data_page4.php?zm_ID=", id)

  tryCatch({

    page <- read_html(url)
    text <- page %>% html_text2()

    sequence <- str_match(text, "Sequence\\s+([A-Z]+)")[,2]

    if(is.na(sequence)) return(NULL)

    name <- str_match(text, "Name\\s+([A-Za-z0-9\\-\\s]+)")[,2]

    data.frame(
      ID = id,
      Sequence = sequence,
      Name = name,
      URL = url,
      stringsAsFactors = FALSE
    )

  }, error = function(e) return(NULL))
}

# ---------------------------
# RUN IN PARALLEL
# ---------------------------

ids <- 1:max_id

results <- future_map_dfr(ids, scrape_peptide, .progress = TRUE)

# ---------------------------
# CLEAN DATA
# ---------------------------

results <- results %>%
  distinct() %>%
  filter(!is.na(Sequence))

# ---------------------------
# SAVE OUTPUT
# ---------------------------

write.xlsx(results, "BIOPEP_sequences.xlsx")

cat("\nDONE! Sequences found:", nrow(results), "\n")
