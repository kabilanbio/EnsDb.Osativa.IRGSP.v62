#' @name EnsDb.Osativa.IRGSP.v62
#' 
#' @title EnsDb object for Oryza sativa IRGSP-1.0 Release 62
#'
#' @description
#' This object provides gene, transcript and exon annotations for the
#' rice genome IRGSP‑1.0 based on Ensembl release 62.  Gene IDs follow
#' the RAP‑DB nomenclature (`OsXXgXXXXXXX`).  MSU v7.0 functional
#' descriptions are stored in the `gene_name` column.
#'
#' The object is automatically loaded when the package is attached.
#' Use \code{EnsDb.Osativa.IRGSP.v62} directly after
#' \code{library(EnsDb.Osativa.IRGSP.v62)}.
#'
#' @return An \code{EnsDb} object providing access to the rice annotation
#'     database.
#'
#' @examples
#' library(EnsDb.Osativa.IRGSP.v62)
#' edb <- EnsDb.Osativa.IRGSP.v62
#' # Retrieve the first 3 genes
#' head(genes(edb), 3)
#'
#' @import ensembldb
#' @importFrom DBI dbDisconnect
#' @keywords data
NULL

# zzz.R

.ZENODO_URL <- paste0(
  "https://zenodo.org/records/19987906/files/",
  "EnsDb.Osativa.v62.sqlite?download=1"
)

.onLoad <- function(libname, pkgname) {
  
  ## Create cache directory
  cache_dir <- tools::R_user_dir(pkgname, which = "cache")
  
  ## Initialize BiocFileCache
  bfc <- BiocFileCache::BiocFileCache(
    cache = cache_dir,
    ask = FALSE
  )
  
  ## Check whether SQLite file already exists in cache
  qres <- BiocFileCache::bfcquery(
    bfc,
    "EnsDb.Osativa.v62.sqlite",
    field = "rname"
  )
  
  rid <- qres$rid
  
  ## Download if not available
  if (length(rid) == 0) {
    
    packageStartupMessage(
      "Downloading EnsDb SQLite database from Zenodo..."
    )
    
    rid <- names(
      BiocFileCache::bfcadd(
        x = bfc,
        rname = "EnsDb.Osativa.v62.sqlite",
        fpath = .ZENODO_URL
      )
    )
  }
  
  ## Get local cached file path
  dbfile <- BiocFileCache::bfcrpath(
    bfc,
    rids = rid
  )
  
  ## Validate database file
  if (!file.exists(dbfile)) {
    stop("Failed to obtain SQLite database file.")
  }
  
  if (file.info(dbfile)$size == 0) {
    stop("Downloaded SQLite database file is empty.")
  }
  
  ## Create EnsDb object
  edb <- ensembldb::EnsDb(dbfile)
  
  ## Make object available in package namespace
  assign(
    "EnsDb.Osativa.IRGSP.v62",
    edb,
    envir = asNamespace(pkgname)
  )
}