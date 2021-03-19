library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(stringr)
library(pdftools)

LEFT_MARGINS <- as.numeric(str_split(Sys.getenv("LEFT_MARGINS"), ",")[[1]])

data <- pdf_data(Sys.getenv("SOURCE_URL"))
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
        between(x, LEFT_MARGINS[1], LEFT_MARGINS[2] - 1) ~ "bank",
        between(x, LEFT_MARGINS[2], LEFT_MARGINS[3] - 1) ~ "representative",
        between(x, LEFT_MARGINS[3], LEFT_MARGINS[4] - 1) ~ "item",
        between(x, LEFT_MARGINS[4], LEFT_MARGINS[5] - 1) ~ "currency",
        between(x, LEFT_MARGINS[5], LEFT_MARGINS[6] - 1) ~ "amount",
        x >= LEFT_MARGINS[6] ~ "company")) %>%
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
    # Fix broken multi-line rows
    mutate(bad_row_flag = (is.na(currency) & !is.na(lead(currency)))) %>%
    mutate_at(vars(bank, representative, item, currency, amount, company), ~case_when(
      lag(bad_row_flag) ~ str_c(replace_na(lag(.x), ""), .x),
      TRUE ~ .x
    )) %>%
    filter(!bad_row_flag) %>%
    select(-bad_row_flag) %>%
    mutate_at(vars(amount), parse_number)
}

data %>%
  map_dfr(extract_table, .id = "page") %>%
  group_by(page) %>%
  mutate(
    # Fix cases where a row has been removed
    row = row_number(),
    source_url = Sys.getenv("SOURCE_URL"),
    release_date = parse_date(Sys.getenv("RELEASE_DATE"))) %>%
  ungroup() %>%
  select(source_url, release_date, page, row, everything()) %>%
  write_csv(Sys.getenv("CSV_PATH"))
