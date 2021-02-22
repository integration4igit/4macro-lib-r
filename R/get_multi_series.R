# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#' @title Busca de informações de uma ou mais séries
#' @name get_multi_series
#' 
#' @description Função que busca dados de uma ou mais séries
#'
#' @param filepath String com caminho para o arquivo \code{.ini} de autenticação ou **NULL** para utilizar variáveis de ambiente. Para gerar um arquivo utilize a função \code{generate_ini} ou \code{generate_r_environ}
#' @param base_parameters Data Frame, obrigatóriamente, com todos os parâmetros necessários para a API funcionar. Os parâmetros são datalhados no teim details desta documentação
#' @param lang String com a língua definida para as respostas das séries
#'
#' @author Gustavo Marins Bitencourt
#' 
#' @details Utiliza das variáveis de ambiente \code{.Renviron} para a validação dos dados.
#' 
#' O Data Frame de consulta deve ter obrigatóriamente os seguintes campos:
#' 
#' \itemize{
#' \item{sid: }{Obrigatório. Códigos de 16 dígitos das séries que deseja consultar;}
#' \item{label: }{Opcional. String com nome da projeção, obrigatório somente para dados projetados;}
#' \item{estimate: }{Opcional. Logical TRUE se são dados projetados, para dados realizados FALSE;}
#' \item{force: }{Opcional. Se TRUE força a geração do conteúdo da resposta com a propriedade label mesmo
#'  que exista nenhuma ou apenas um segmento estimado. Vale FALSE se não for especificado;}
#' \item{reff: }{Opcional. Retornar datas de referência para as observações caso TRUE, ou a data original informada pela fonte primária ou gerada pelo algoritmo de estimativa FALSE;}
#' \item{start: }{Opcional. String com data para inicio dos dados da série a serem requisitados;}
#' \item{end: }{Opcional. String com data limite das informações da série;}
#' }
#' 
#' **DEPRECATED**
#' O arquivo de autenticação \code{.ini} deve conter uma única seção com o nome \code{login}, incluindo o
#' seguintes campos:
#' 
#' \itemize{
#' \item{url: }{Url base de acesso ao servidor;}
#' \item{usr: }{Id do usuário;}
#' \item{pwd: }{Senha do usuário.}
#' }
#' 
#' @return O retorno consiste em uma lista contendo seis campos: series, names, short_names, content, last_actual e status, respectivamente.
#' Dentro de cada campo haverá uma outra lista, em que cada posição representa uma informação das séries
#' consultadas, respeitando a ordem de entrada. O campo names contém o nome longo de cada série, content
#' contém um data frame com as observações, last_actual a última data da observação realizada e status indica
#' se a série foi consultada com sucesso. Os
#' possíveis valores para status são:
#' 
#' \item{0}{Dados consultados com sucesso;}
#' \item{1}{Erro no formato da requisição;}
#' \item{2}{Parâmetro usr não está no formato correto;}
#' \item{3}{Parâmetro pwd não está no formato correto;}
#' \item{4}{Código da série não está no formato correto;}
#' \item{12}{Erro de autenticação com os parâmetros do usuário;}
#' \item{13}{Série não está disponível para o usuário;}
#' \item{14}{O parâmetro series deve ser uma lista.}
#'
#'
#' @examples 
#' 
#' \dontrun{
#' query_data <- data.frame(
#'    sid = c('BRGDP0002000ROQL', 'BRGDP0021000ROQL'),
#'    label = c(NA, "Estimativa 2020-01-02"),
#'    estimate = c(TRUE, TRUE),
#'    force = c(FALSE, FALSE),
#'    reff = c(TRUE, FALSE)
#'  )
#' 
#' get_multi_series("/home/joao/auth.ini", query_data, "pt-br")
#' 
#' query_data <- data.frame(
#'    sid = c('BRGDP0002000ROQL'),
#'    label = c(NA),
#'    estimate = c(TRUE),
#'    force = c(FALSE),
#'    reff = c(TRUE)
#'  )
#' 
#' get_multi_series(query_data, "pt-br")
#' 
#' }
#' 
#' @export
get_multi_series <- function(filepath = NULL, base_parameters, lang) {
	
	if( ! is.null(filepath) )
	{
		# Read .ini file
		ds_data <- ini::read.ini(filepath)[[1]] 
	}
	else
	{
		# Read environment variables
		ds_data <- list('url' = Sys.getenv("URL_4MACRO"),
						'usr' = Sys.getenv("USR_4MACRO"),
						'pwd' = Sys.getenv("PWD_4MACRO"))
	}
	
	url_base <- ds_data$url
	
	
	if(stringr::str_detect(url_base, "https://", TRUE)) {
		url_base <- base::paste0("https://", url_base)  
	}
	
	url <- base::paste0(url_base, "/services/GoetheDB/procedureExecutor/procedure/execute/createGetMultiSeries")
	
	sids <- NULL
	parameters_sid = colnames(base_parameters)
	
	sids$sid <- base_parameters$sid
	if("label" %in% parameters_sid) sids$lbl <- base_parameters$label
	if("estimate" %in% parameters_sid) sids$est <- base_parameters$estimate
	if("force" %in% parameters_sid) sids$forcelbl <- base_parameters$force
	if("reff" %in% parameters_sid) sids$reff <- base_parameters$reff
	if("start" %in% parameters_sid) sids$start <- base_parameters$start
	if("end" %in% parameters_sid) sids$end <- base_parameters$end
	
	sids <- data.frame(sids)
	
	user_info <- list(
		"uid" = ds_data$usr,
		"pwd" = ds_data$pwd,
		"lang" = lang,
		"sidset" = sids
	)
	
	params <- base::as.character(jsonlite::toJSON(user_info, auto_unbox = TRUE))
	r <- httr::POST(url, body = list("request" = params), encode = "json")
	
	r_content <- httr::content(r, "text")
	r_json <- jsonlite::fromJSON(r_content)
	resp <- jsonlite::fromJSON(r_json$response)
	
	r_sid_code <- as.list(resp$sidset$sid)
	r_sid_name <- as.list(resp$sidset$snl)
	r_sid_short_name <- as.list(resp$sidset$sns)
	r_content <- as.list(resp$sidset$cont)
	r_status <- as.list(resp$sidset$reqresp$code)
	r_last <- as.list(resp$sidset$lastactual)
	
	tidy_data <- list("sid" = r_sid_code,
					  "names" = r_sid_name,
					  "short_names" = r_sid_short_name,
					  "contents" = r_content,
					  "status" = r_status,
					  "last_actual" = r_last)
	
	return(tidy_data)
}
 