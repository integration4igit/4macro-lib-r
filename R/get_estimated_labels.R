# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#' @title Consulta Labels de Projeções
#' @name get_estimated_labels
#' 
#' @description Função para consultar todos os labels de projeção de uma determinada série
#'
#' @param serie String com o código de 16 dígitos da série
#' @param ... Parâmetros adicionais: \code{filepath} String com caminho para o arquivo \code{.ini} de autenticação
#' 
#' @author João Gustavo Oliveira, Gabriel Belle
#' 
#' @details Primeiramente é necessário salvar as suas credenciais em um arquivo \code{.ini} ou \code{.Renviron}
#' Para gerar um arquivo de autenticação utilize a função \code{generate_ini} ou \code{generate_r_environ}
#' É altamente recomendável utilizar o \code{.Renviron} como seu arquivo de autenticação.
#' 
#' O parâmetro obrigatório, \code{serie}, deve ser o código de 16 dígitos de uma série com projeção existente
#' 
#' @return O retorno consiste em uma lista contendo todos os labels de projeção para a série requisitada
#' 
#' @examples 
#' \dontrun{
#' # Utilizando um arquivo .ini
#' 
#' get_estimated_labels(serie = 'BRGDP0002000ROQL', filepath = "/home/user/auth.ini")
#' 
#' # Utilizando variáveis de ambiente
#' 
#' get_estimated_labels(serie = 'BRGDP0002000ROQL')
#' 
#' }
#' 
#' @export 
get_estimated_labels <- function(serie, ...) {
	
	parametros <- names(list(...))
	
	if( 'filepath' %in% parametros )
	{
		# Read .ini file
		filepath <- list(...)[['filepath']]
		auth_data <- ini::read.ini(filepath)[[1]] 
	}
	else
	{
		# Read environment variables
		auth_data <- list('url' = Sys.getenv("URL_4MACRO"),
						  'usr' = Sys.getenv("USR_4MACRO"),
						  'pwd' = Sys.getenv("PWD_4MACRO"))
	}
	
	url_base <- auth_data$url
	
	if(stringr::str_detect(url_base, "https://", TRUE)) {
		url_base <- base::paste0("https://", url_base)	
	}
	
	url <- base::paste0(url_base, "/services/GoetheDB/procedureExecutor/procedure/execute/createQuerySeries")
	
	request_data = list(
		"uid" = auth_data$usr,
		"pwd" = auth_data$pwd,
		"sid" = serie
	)
	
	request_json_data <- base::as.character(jsonlite::toJSON(request_data, auto_unbox = TRUE))
	
	res <- httr::POST(url = url, body = list(query_in = request_json_data), encode = "json")
	
	res <- httr::content(res, "text")
	res_json <- jsonlite::fromJSON(res)
	
	res_data <- jsonlite::fromJSON(res_json$outResp)$ans$est[[1]]
	ret <- unique(list(res_data$lb))
	
	return(ret)
}
