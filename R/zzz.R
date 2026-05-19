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

.datacache <- new.env(hash = TRUE, parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  ## --- Use BiocFileCache to manage the database file ---
  cache_dir <- tools::R_user_dir("EnsDb.Osativa.IRGSP.v62", "cache")
  bfc <- BiocFileCache::BiocFileCache(cache_dir, ask = FALSE)
  
  ## Query if the file is already in the cache
  rid <- BiocFileCache::bfcquery(bfc, "EnsDb.Osativa.v62.sqlite", "rname")$rid
  if (!length(rid)) {
    ## Not cached – download from Zenodo
    packageStartupMessage("Downloading EnsDb database from Zenodo...")
    rid <- names(BiocFileCache::bfcadd(bfc, "EnsDb.Osativa.v62.sqlite", .ZENODO_URL))
  }
  
  ## Get the local path to the cached file
  dbfile <- BiocFileCache::bfcrpath(bfc, rids = rid)
  
  ## Validate that the file exists and is non‑empty
  if (!file.exists(dbfile) || file.info(dbfile)$size == 0) {
    stop("Failed to obtain a valid EnsDb database file from Zenodo.")
  }
  
  ## Connect to the database and create the EnsDb object
  db <- ensembldb::EnsDb(dbfile)
  
  ## Assign the object to the package namespace so users can access it
  assign("EnsDb.Osativa.IRGSP.v62", db, envir = asNamespace(pkgname))
  namespaceExport(asNamespace(pkgname), "EnsDb.Osativa.IRGSP.v62")
  
  ## Store the connection in datacache so we can disconnect on unload
  assign("db", db, envir = .datacache)
}

.onUnload <- function(libpath) {
  if (exists("db", envir = .datacache)) {
    tryCatch({
      DBI::dbDisconnect(ensembldb::dbconn(.datacache$db))
    }, error = function(e) NULL)
  }
}