#' rosr pdf template
#'
#' @param template_name the template name.
#' @inheritParams rmarkdown::pdf_document
#' @param
#'   ..., keep_tex, citation_package, md_extensions
#'   Arguments passed to \code{rmarkdown::pdf_document()}.
#'
#' @return An R Markdown output format.
#' @details statement_svm, article_svm, cv_svm, syllabus_svm, manuscript_svm are adapted from \url{https://github.com/svmiller/svm-r-markdown-templates}.
deepdown_doc <- function(...,
                         template_name,
                         keep_tex = TRUE,
                         citation_package = "natbib",
                         md_extensions = c(
                           "-autolink_bare_uris", # disables automatic links, needed for plain email in \correspondence
                           "-auto_identifiers"    # disables \hypertarget commands
                         )) {
  if (!rmarkdown::pandoc_available()) {
    return("Pandoc is required.")
  } else {
    deepdown("mdr.Rmd")
  }
}
