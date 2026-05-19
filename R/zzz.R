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
    message("Downloading EnsDb database from Zenodo...")
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