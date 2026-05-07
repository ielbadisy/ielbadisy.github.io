# Placeholder automation script for course confirmation emails.
# Requires a CSV export from Google Sheets and a configured gmailr account.

required_packages <- c("readr", "dplyr", "glue", "gmailr")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing_packages) > 0) {
  stop(
    "Install required packages before running this script: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

participants_path <- Sys.getenv("PARTICIPANTS_CSV", "participants.csv")
template_path <- Sys.getenv("CONFIRMATION_TEMPLATE", "templates/confirmation_email.html")
log_path <- Sys.getenv("CONFIRMATION_LOG", "confirmation_email_log.csv")

if (!file.exists(participants_path)) {
  stop("Participant CSV not found: ", participants_path, call. = FALSE)
}

if (!file.exists(template_path)) {
  stop("Email template not found: ", template_path, call. = FALSE)
}

`%||%` <- function(x, y) {
  if (length(x) == 0 || is.null(x) || is.na(x) || identical(x, "")) y else x
}

participants <- readr::read_csv(participants_path, show_col_types = FALSE)
template <- paste(readLines(template_path, warn = FALSE), collapse = "\n")

to_send <- participants |>
  dplyr::filter(
    tolower(.data$payment_status) == "paid",
    is.na(.data$confirmation_email_sent) |
      tolower(.data$confirmation_email_sent) != "yes"
  )

if (nrow(to_send) == 0) {
  message("No confirmation emails to send.")
  quit(save = "no", status = 0)
}

# Configure gmailr outside this script. Do not store credentials in the project.
# Example once per machine/session:
# gmailr::gm_auth_configure(path = "path/to/oauth-client.json")
# gmailr::gm_auth(email = "your-email@example.com")

sent_log <- lapply(seq_len(nrow(to_send)), function(i) {
  participant <- to_send[i, ]
  course_name <- participant$course_selected %||% "Methods in Health Data Science with R"
  body <- glue::glue(template, .open = "{{", .close = "}}")

  email <- gmailr::gm_mime() |>
    gmailr::gm_to(participant$email) |>
    gmailr::gm_from(Sys.getenv("GMAIL_FROM", "REPLACE_WITH_SENDER_EMAIL")) |>
    gmailr::gm_subject(paste("Confirmation d'inscription -", course_name)) |>
    gmailr::gm_html_body(as.character(body))

  gmailr::gm_send_message(email)

  data.frame(
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S %z"),
    email = participant$email,
    full_name = participant$full_name,
    course_selected = course_name,
    status = "sent",
    stringsAsFactors = FALSE
  )
})

sent_log <- dplyr::bind_rows(sent_log)

if (file.exists(log_path)) {
  existing_log <- readr::read_csv(log_path, show_col_types = FALSE)
  sent_log <- dplyr::bind_rows(existing_log, sent_log)
}

readr::write_csv(sent_log, log_path)
message("Confirmation email log written to: ", log_path)
