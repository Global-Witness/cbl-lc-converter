library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(stringr)
library(pdftools)

data <- pdf_data(Sys.getenv("PDF_PATH"))

LEFT_MARGINS <- as.numeric(c(
  Sys.getenv("MARGIN_1"),
  Sys.getenv("MARGIN_2"),
  Sys.getenv("MARGIN_3"),
  Sys.getenv("MARGIN_4"),
  Sys.getenv("MARGIN_5"),
  Sys.getenv("MARGIN_6")))

COLUMN_NAMES <- c(
  Sys.getenv("COLUMN_NAME_1"),
  Sys.getenv("COLUMN_NAME_2"),
  Sys.getenv("COLUMN_NAME_3"),
  Sys.getenv("COLUMN_NAME_4"),
  Sys.getenv("COLUMN_NAME_5"),
  Sys.getenv("COLUMN_NAME_6"))

extract_table <- function(page) {
  page %>%
    arrange(y, x) %>%
    mutate(
      new_row_flag = case_when(
        y - lag(y) > 10 ~ 1,
        TRUE ~ 0),
      row_id = cumsum(new_row_flag) + 1,
      cell_id = case_when(
        between(x, LEFT_MARGINS[1], LEFT_MARGINS[2] - 1) ~ COLUMN_NAMES[1],
        between(x, LEFT_MARGINS[2], LEFT_MARGINS[3] - 1) ~ COLUMN_NAMES[2],
        between(x, LEFT_MARGINS[3], LEFT_MARGINS[4] - 1) ~ COLUMN_NAMES[3],
        between(x, LEFT_MARGINS[4], LEFT_MARGINS[5] - 1) ~ COLUMN_NAMES[4],
        between(x, LEFT_MARGINS[5], LEFT_MARGINS[6] - 1) ~ COLUMN_NAMES[5],
        x >= LEFT_MARGINS[6] ~ COLUMN_NAMES[6])) %>%
    select(row_id, cell_id, text) %>%
    rowwise() %>%
    mutate(text = case_when(
      !str_detect(str_to_upper(text), "[A-Z0-9]") ~ str_c(rev(str_split(text, "")[[1]]), collapse = ""),
      TRUE ~ text)) %>%
    arrange(row_id, cell_id) %>%
    group_by(row_id, cell_id) %>%
    summarise(text = case_when(
      !str_detect(str_to_upper(str_c(text, collapse = " ")), "[A-Z0-9]") ~ str_c(rev(text), collapse = " "),
      TRUE ~ str_c(text, collapse = " ")),
      .groups = "drop") %>%
    pivot_wider(id_cols = row_id, names_from = cell_id, values_from = text) %>%
    filter(!is.na(COLUMN_NAMES[1])) %>%
    select(row_id, COLUMN_NAMES)
}

data %>%
  map_dfr(extract_table) %>%
  write_csv(Sys.getenv("CSV_PATH"))