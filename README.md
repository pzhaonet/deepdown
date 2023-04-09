# Introduction

The R package **deepdown** allows you another way of using R **markdown** with some interesting features inherited from [Markdeep](http://casual-effects.com/markdeep/). With **deepdown**, you can create documents, books, and slides with integrating R codes and their outputs, ASCII diagrams, calendars, equations, and other features in plain text documents. Besides the R language, you have to install nothing more than the **deepdown** and **knitr** packages. The output file can be viewed by any web browser.

# Quick start

## Installation

```
remotes::install_github("pzhaonet/deepdown")
```

## Create a demo file

`R Studio` ==> `New File` ==> `R Markdown` ==> `From Template` ==> `deepdown`.

## Knit the demo file into a webpage

You can click the `knit` button in RStudio for a deepdown output. Alternatively, you can save the Rmd file as, for example, `dd.Rmd`, and run:

```
deepdown::deepdown("dd.Rmd")
```

You will see the output in your web browser.

# Major Features

It supports basic syntax of R markdown. The major differences and extended features are as follows:

- Videos and audios easily embedded.
- ASCII diagrams.
- Built-in mini calendars.
- Task lists.
- Built-in notices.
- Easy cross references of tables, images, listings, and equations.
- Citations and references.
- Paragraph numbers and code line numbers.
- Multi columns for the texts.

More features can be found in the [Markdeep](http://casual-effects.com/markdeep/) documents.
