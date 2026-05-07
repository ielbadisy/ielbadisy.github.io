# Placeholder script to generate a clean participant list from Google Sheets CSV export.

participants_path <- Sys.getenv("PARTICIPANTS_CSV", "participants.csv")
output_path <- Sys.getenv("PARTICIPANT_LIST_CSV", "participant_list.csv")

required_packages <- c("readr", "dplyr")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  stop(
    "Install required packages before running this script: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

if (!file.exists(participants_path)) {
  stop("Participant CSV not found: ", participants_path, call. = FALSE)
}

participants <- readr::read_csv(participants_path, show_col_types = FALSE)

participant_list <- participants |>
  dplyr::filter(tolower(.data$payment_status) == "paid") |>
  dplyr::select(
    full_name,
    email,
    phone,
    country,
    course_selected,
    preferred_channel,
    payment_date
  ) |>
  dplyr::arrange(.data$course_selected, .data$full_name)

readr::write_csv(participant_list, output_path)
message("Participant list written to: ", output_path)
