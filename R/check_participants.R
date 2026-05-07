# Placeholder quality checks for the participant database.

participants_path <- Sys.getenv("PARTICIPANTS_CSV", "participants.csv")

if (!requireNamespace("readr", quietly = TRUE)) {
  stop("Install the readr package before running this script.", call. = FALSE)
}

if (!file.exists(participants_path)) {
  stop("Participant CSV not found: ", participants_path, call. = FALSE)
}

participants <- readr::read_csv(participants_path, show_col_types = FALSE)

required_columns <- c(
  "timestamp",
  "full_name",
  "email",
  "phone",
  "country",
  "course_selected",
  "preferred_channel",
  "payment_status",
  "payment_id",
  "amount_paid",
  "payment_date",
  "confirmation_email_sent",
  "community_invite_sent",
  "notes"
)

missing_columns <- setdiff(required_columns, names(participants))

if (length(missing_columns) > 0) {
  warning("Missing columns: ", paste(missing_columns, collapse = ", "))
}

cat("Participants:", nrow(participants), "\n")
cat("Paid:", sum(tolower(participants$payment_status) == "paid", na.rm = TRUE), "\n")
cat("Confirmation emails pending:", sum(
  tolower(participants$payment_status) == "paid" &
    (is.na(participants$confirmation_email_sent) |
       tolower(participants$confirmation_email_sent) != "yes"),
  na.rm = TRUE
), "\n")
