# CBL LC converter

This R script is designed to extract data tables from PDF disclosures of Letter of Credit (LC) applications made by the Central Bank of Libya. An example of a disclosure can be found [on the CBL Facebook page](https://www.facebook.com/CentralBankofLibya/posts/5059776977426419).

Run the script from within this directory using the command `Rscript converter.R`, or by opening it in an IDE like RStudio. Before running it, update the file `.Renviron` to set the relevant environment variables, as described below.

## Just give me the data!

CSV output from this script for a number of LC releases can be found in the `output` directory. No guarantees are made about this data—please check it carefully against the original PDF files and read the [Limitations](#limitations) section below before using it.

## Requirements

The script requires a recent version of R and the packages `dplyr`, `readr`, `purrr`, `tidyr`, `stringr` and `pdftools`. All of these except `pdftools` can be installed at the same time using the umbrella package `tidyverse`.

## Environment variables

| Variable name | Description |
| ------------- | ----------- |
| `RELEASE_DATE` | The date of the release. |
| `SOURCE_URL` | The source URL of the PDF to process (can be a local path if necessary). |
| `CSV_PATH` | The desired location of the output file in CSV format. |
| `TOP_MARGIN` | The y coordinate of the top of the table (after the column headers) on the first page of the release (see [this Stack Overflow answer](https://stackoverflow.com/a/2592991) for some sugestions about how to calculate x, y coordinates from PDFs). |
| `LEFT_MARGINS` | The x coordinates of the left-hand margin of each column as a comma-separated list. |

## Limitations

The LC disclosures sometimes mix Arabic and Roman characters within cells. Due to the way R handles right-to-left scripts, any cell containing both a Roman character (A-Z) or a numeral (0-9) and some Arabic text may have the Arabic reversed in the output data. It's hoped that this will affect a relatively small number of cells in the data.

Cells with text spanning multiple lines may also be misinterpreted as multiple rows. The script attempts to detect these cases and fix them, but it hasn't been tested extensively.
