.ZENODO_URL <- "https://zenodo.org/records/19987906/files/EnsDb.Osativa.v62.sqlite?download=1"

.datacache <- new.env(hash = TRUE, parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  ## --- Use BiocFileCache to manage the SQLite database ---
  cache_dir <- tools::R_user_dir("EnsDb.Osativa.IRGSP.62", "cache")
  bfc <- BiocFileCache::BiocFileCache(cache_dir, ask = FALSE)

  ## Look for the database file in the cache
  rid <- BiocFileCache::bfcquery(bfc, "EnsDb.Osativa.v62.sqlite", "rname")$rid
  if (!length(rid)) {
    ## Not cached yet – download from Zenodo
    rid <- names(BiocFileCache::bfcadd(bfc, "EnsDb.Osativa.v62.sqlite", .ZENODO_URL))
  }
  dbfile <- BiocFileCache::bfcrpath(bfc, rids = rid)

  ## Create the EnsDb object and attach it to the package namespace
  db <- ensembldb::EnsDb(dbfile)
  assign("EnsDb.Osativa.IRGSP.62", db, envir = asNamespace(pkgname))
  namespaceExport(asNamespace(pkgname), "EnsDb.Osativa.IRGSP.62")

  ## Remember the object so we can disconnect the database on unload
  assign("db", db, envir = .datacache)
}

.onUnload <- function(libpath) {
  if (exists("db", envir = .datacache)) {
    ## Disconnect the database connection
    DBI::dbDisconnect(ensembldb::dbconn(.datacache$db))
  }
}
