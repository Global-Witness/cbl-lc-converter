# CBL LC converter

This R script is designed to extract data tables from PDF disclosures of Letter of Credit (LC) applications made by the Central Bank of Libya. An example of a disclosure can be found [on the CBL Facebook page](https://www.facebook.com/CentralBankofLibya/posts/5059776977426419).

Run the script from within this directory using the command `Rscript converter.R`, or by opening it in an IDE like RStudio. Before running it, update the file `.Renviron` to set the relevant environment variables, as described below.

## Environment variables

| Variable name | Description |
| ------------- | ----------- |
| `PDF_PATH` | The location of the PDF file to extract data from. |
| `CSV_PATH` | The desired location of the output file in CSV format. |
| `MARGIN_[1–6]` | The x coordinate of the left-hand margin of each column (see [this Stack Overflow answer](https://stackoverflow.com/a/2592991) for some sugestions about how to calculate x, y coordinates from PDFs). |
| `COLUMN_NAME_[1–6]` | The desired name of each columns in the output file. |

## Limitations

The LC disclosures sometimes mix Arabic and Roman characters within cells. Due to the way R handles right-to-left scripts, any cell containing both a Roman character (A-Z) or a numeral (0-9) and some Arabic text may have the Arabic reversed in the output data. It's hoped that this will affect a relatively small number of cells in the data. Output data also needs tidying up by hand to remove header and footer rows from each page.