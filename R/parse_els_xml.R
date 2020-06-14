#' Get OA info from Elsevier full-text
#'
#' @param tdm_url link to Elsevier XML full-text
#'
#' @return
#' @importFrom crminer crm_xml
#' @importFrom xml2 xml_find_first xml_text
#' @importFrom tibble tibble
#' @export
#'
#' @examples
elsevier_parse <- function(tdm_url) {
  req <- crminer::crm_xml(tdm_url)
  oa_sponsor_name <-  xml2::xml_text(
    xml2::xml_find_first(req, "//d1:coredata//d1:openaccessSponsorName")
    )
  oa_sponsor_type <- xml2::xml_text(
    xml2::xml_find_first(req, "//d1:coredata//d1:openaccessSponsorType")
    )
  oa_article <-  xml2::xml_text(
    xml2::xml_find_first(req, "//d1:coredata//d1:openaccessArticle")
  )
  oa_type <- xml2::xml_text(
    xml2::xml_find_first(req, "//d1:coredata//d1:openaccessType")
  )
  oa_archive <-  xml2::xml_text(
    xml2::xml_find_first(req, "//d1:coredata//d1:openArchiveArticle")
    )
  tibble(oa_sponsor_name, oa_sponsor_type, oa_article, oa_type, oa_archive, tdm_url)
}