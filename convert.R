library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(stringr)
library(pdftools)

LEFT_MARGINS <- as.numeric(str_split(Sys.getenv("LEFT_MARGINS"), ",")[[1]])
COLUMN_NAMES <- str_split(Sys.getenv("COLUMN_NAMES"), ",")[[1]]

data <- pdf_data(Sys.getenv("PDF_PATH"))
data[[1]] <- filter(data[[1]], y > as.numeric(Sys.getenv("TOP_MARGIN")))

extract_table <- function(page) {
  page %>%
    arrange(y, x) %>%
    # Remove page number in footer
    filter(y != max(y)) %>%
    mutate(
      new_row_flag = case_when(
        y - lag(y) > 10 ~ 1,
        TRUE ~ 0),
      row = cumsum(new_row_flag) + 1,
      cell = case_when(
        between(x, LEFT_MARGINS[1], LEFT_MARGINS[2] - 1) ~ COLUMN_NAMES[1],
        between(x, LEFT_MARGINS[2], LEFT_MARGINS[3] - 1) ~ COLUMN_NAMES[2],
        between(x, LEFT_MARGINS[3], LEFT_MARGINS[4] - 1) ~ COLUMN_NAMES[3],
        between(x, LEFT_MARGINS[4], LEFT_MARGINS[5] - 1) ~ COLUMN_NAMES[4],
        between(x, LEFT_MARGINS[5], LEFT_MARGINS[6] - 1) ~ COLUMN_NAMES[5],
        x >= LEFT_MARGINS[6] ~ COLUMN_NAMES[6])) %>%
    select(row, cell, text) %>%
    rowwise() %>%
    mutate(text = case_when(
      !str_detect(str_to_upper(text), "[A-Z0-9]") ~ str_c(rev(str_split(text, "")[[1]]), collapse = ""),
      TRUE ~ text)) %>%
    arrange(row, cell) %>%
    group_by(row, cell) %>%
    summarise(text = case_when(
      !str_detect(str_to_upper(str_c(text, collapse = " ")), "[A-Z0-9]") ~ str_c(rev(text), collapse = " "),
      TRUE ~ str_c(text, collapse = " ")),
      .groups = "drop") %>%
    pivot_wider(id_cols = row, names_from = cell, values_from = text) %>%
    select(row, all_of(COLUMN_NAMES))
}

data %>%
  map_dfr(extract_table, .id = "page") %>%
  write_csv(Sys.getenv("CSV_PATH"))