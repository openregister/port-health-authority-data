# Scrape http://www.porthealthassociation.co.uk/port-directory

library(tidyverse)
library(rvest)
library(here)

url_home <- "http://www.porthealthassociation.co.uk/port-directory"
pages <- 1:9

pha_html <-
  tibble(page_number = 1:9,
         page_url = paste0(url_home,
                           "/?pagenum=",
                           page_number,
                           "&gv_search&mode=any"),
         page_html = map(page_url, read_html))

pha <-
  map(pha_html$page_html,
      ~ .x %>%
        html_nodes(".gv-field-2-3") %>%
        html_text() %>%
        str_replace("^Authority:", "")) %>%
  reduce(c) %>%
  unique()

# The `local-authority` and `legislation` fields are blank and will have to be
# completed manually
pha_register <- tibble(`port-health-authority` = seq_along(pha),
                       `name` = pha,
                       `legislation` = NA_character_,
                       `local-authority` = NA_character_,
                       `start-date` = NA,
                       `end-date` = NA)

write_tsv(pha_register,
          here("lists",
               "association-of-port-health-authorities",
               "port-health-authority.tsv"))
