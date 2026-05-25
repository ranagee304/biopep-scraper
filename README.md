# 🧬 BIOPEP Parallel Scraper

This project is an automated bioinformatics pipeline to extract peptide sequences from the BIOPEP database.

🔗 Source: https://biochemia.uwm.edu.pl/biopep/

---

## 🚀 Features

- Parallel web scraping using R (`furrr`, `future`)
- Automatic package installation
- Extracts peptide sequences, names, and IDs
- Saves results into Excel format
- GitHub Actions automation support

---

## 📦 Output

The script generates:

- `BIOPEP_sequences.xlsx`

Columns:
- ID
- Sequence
- Name
- URL

---

## ⚙️ How to Run Locally

```bash
Rscript biopep_parallel.R
