#' Get the available templates
#'
#' @return template names
#' @export
#'
#' @examples
#' get_deepdown()
get_deepdown <- function(){
  gsub(".md.html", "", list.files(system.file('demo', package = 'deepdown'), pattern = "md.html"))
}

#' Convert a markdown or R markdown file into a markdeep file
#'
#' @param input Character. The path of the (R) markdown file.
#' @param remove_yaml Logical. Whether remove the yaml header of the input file
#' @param view Logical. Whether view the output in the web browser.
#'
#' @return a html file
#' @export
#'
#' @examples
#' library(deepdown)
#' deepdown("mdr.Rmd")
#' input <- "d:/Seafile/pz/doing/rpkg/deepdown/inst/rmarkdown/templates/deepdown-book/skeleton/skeleton.Rmd"
deepdown <- function(input, view = TRUE, remove_yaml = TRUE){
  # read data
  inputtext <- readLines(input, encoding = "UTF-8")
  yaml <- rmarkdown::yaml_front_matter(input)

  # css text
  if (is.null(yaml$output$`deepdown::deepdown`$css)){
    text_css <- NULL
  } else {
    text_css <- paste0('<link rel="stylesheet" href="', yaml$output$`deepdown::deepdown`$css, '">')
  }

  # book title text
  text_booktitlepage <- NULL
  if (yaml$output$`deepdown::deepdown`$class == "book"){
    booktitlepage_index <- !sapply(yaml$output$`deepdown::deepdown`$booktitlepage, is.null)
    booktitlepage_name <- names(yaml$output$`deepdown::deepdown`$booktitlepage)[booktitlepage_index]
    booktitlepage_value <- unlist(yaml$output$`deepdown::deepdown`$booktitlepage[booktitlepage_index])
    text_booktitlepage <- c(
      paste0('<script>var titlePage={',
             paste0(booktitlepage_name, ':"', booktitlepage_value, '"',
                    collapse = ', '),
             '};</script>')
    )
  }

  # get text at the top
  text_before <- paste0('<meta charset="utf-8">', text_css, text_booktitlepage)

  # get text at the bottom
  ## default text
  after_body <- system.file("template", paste0("after_body_", yaml$output$`deepdown::deepdown`$class, ".md"), package = "deepdown")
  text_after <- readLines(after_body, encoding = "UTF-8")
  ## user's text
  if (!is.null(yaml$output$`deepdown::deepdown`$after_body)) {
    text_after <- c(text_after, readLines(yaml$output$`deepdown::deepdown`$after_body, encoding = "UTF-8"))
  }
  ## js text
  if (is.null(yaml$output$`deepdown::deepdown`$js)){
    text_js <- NULL
  } else{
    if (yaml$output$`deepdown::deepdown`$js == "local"){
      yaml$output$`deepdown::deepdown`$js <- system.file("js", paste0("deepdown-", yaml$output$`deepdown::deepdown`$class,".js"), package = "deepdown")
    }
    text_js <- c(
      '<!-- Markdeep js: -->',
      paste0('<script src="', yaml$output$`deepdown::deepdown`$js, '" charset="utf-8"></script>'))
  }

  ## paragraph number
  text_paragraph_number <- NULL
  if (is.logical(yaml$output$`deepdown::deepdown`$paragraph_number)) {
    if (yaml$output$`deepdown::deepdown`$paragraph_number){
      text_paragraph_number <- readLines(system.file("template", "paragraph_number.md", package = "deepdown"))
      text_paragraph_number <- gsub("LEADING", '', text_paragraph_number)
    }
  } else {
    text_paragraph_number <- readLines(system.file("template", "paragraph_number.md", package = "deepdown"))
    text_paragraph_number <- gsub("LEADING", yaml$output$`deepdown::deepdown`$paragraph_number, text_paragraph_number)
  }

  ## option text
  text_initSlides <- if (yaml$output$`deepdown::deepdown`$class == "slides") ",onLoad:function() {initSlides();}" else NULL
  text_option <- get_options(opt_list = yaml$output$`deepdown::deepdown`$options,
                             before = "markdeepOptions",
                             after = text_initSlides
  )

  ## slides option text
  text_slidesoption <- NULL
  if (yaml$output$`deepdown::deepdown`$class == "slides"){
    text_slidesoption <- get_options(yaml$output$`deepdown::deepdown`$slidesoptions,
                                     "markdeepSlidesOptions")
  }

  ## book option text
  text_bookoption <- NULL
  if (yaml$output$`deepdown::deepdown`$class == "book"){
    text_bookoption <- get_options(yaml$output$`deepdown::deepdown`$bookoptions,
                                   "markdeepThesisOptions",
                                   ", titlePage: titlePage, runningHeader: function (page) {if (page.isLeft) {if (page.heading.h1 != null) {return `${page.number} - ${page.heading.h1}`} return `${page.number}`} else {return `${page.number}`; }}"
                                   )
  }

  ## merge all bottom text
  text_after <- c(text_paragraph_number, text_js, text_option, text_slidesoption, text_bookoption, text_after)

  # knit .Rmd file
  remove_md <- FALSE
  if (grepl(".Rmd$", input)) {
    remove_md <- TRUE
    knitr::knit(input, output = gsub(".Rmd$", ".md", input), encoding = "UTF-8")
    input <- gsub(".Rmd$", ".md", input)
    inputtext <- readLines(input, encoding = "UTF-8")
  }
  if (remove_md) file.remove(input)

  # remove yaml
  if (remove_yaml){
    loc <- grep("^---$", inputtext)
    if (length(loc) > 1) inputtext <- inputtext[-(loc[1]:loc[2])]
  }

  # code block line and line number
  i1 <- grep("^```.+$", inputtext)
  if (yaml$output$`deepdown::deepdown`$code_linenumber) {
    inputtext[i1] <- gsub("^```(.+)$", "~~~~~~~~~~~~~~~~~~~~~~~~~~~\\1 linenumbers", inputtext[i1])
  } else {
    inputtext[i1] <- gsub("^```(.+)$", "~~~~~~~~~~~~~~~~~~~~~~~~~~~\\1", inputtext[i1])
  }
  i2 <- grep("^```$", inputtext)
  inputtext[i2] <- "~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  # output
  outputtext <- c(text_before,
                  "",
                  paste0("**", yaml$title, "**"),
                  if (!is.null(yaml$subtitle)) paste0(" ", yaml$subtitle),
                  if (!is.null(yaml$author)) paste0(" ", yaml$author),
                  if (!is.null(yaml$date)) paste0(" ", yaml$date),
                  "",
                  inputtext,
                  text_after)
  htmlfile <- gsub(".md$", ".deepdown.html", input)
  writeLines(outputtext, htmlfile, useBytes = TRUE)
  if (view) rstudioapi::viewer(htmlfile)
}

#' View demo file
#'
#' @param template template name. see get_deepdown().
#'
#' @return a file in the viewer
#' @export
#'
#' @examples
#' view_deepdown()
view_deepdown <- function(template = "latex"){
  demofile <- system.file("demo", paste0(template, ".md.html"), package = "deepdown")
  rstudioapi::viewer(demofile)
}

#' Add a frame for text diagrams
#'
#' @param input "clipboard" or the file path for the text diagram.
#' @param output "clipboard", file name, or cat.
#'
#' @return text diagram with a frame
#' @export
#'
add_frame <- function(input = "clipboard", output = "clipboard"){
  out <- readLines(input, encoding = "UTF-8")
  maxnchar <- max(nchar(out))
  addline <- paste(rep("*", maxnchar + 1), collapse = "")
  out <- c(addline, out, addline)
  out <- paste0("*", out)
  if (output == "cat") {
    return(cat(out, sep = "\n"))
  }
  writeLines(out, output, useBytes = TRUE)
}

get_options <- function(opt_list, before, after = NULL){
  option_index <- !sapply(opt_list, is.null)
  option_name <- names(opt_list)[option_index]
  option_value <- opt_list[option_index]
  i_logical <- unlist(lapply(option_value, is.logical))
  option_value[i_logical] <- lapply(option_value[i_logical], as.integer)
  i_char <- unlist(lapply(option_value, is.character))
  option_value[i_char] <- lapply(option_value[i_char], function(x) paste0('"', x, '"'))
  return(paste0(paste0('<script>', before, '={'),
                paste0(option_name, ':',
                       option_value,
                       collapse = ', '),
                after,
                '};</script>')
  )
}
