# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#' @title Insere Valores em uma Série Especificada
#' @name insert_series
#' 
#' @description Função para inserir dados estimados ou realizados em uma determinada série
#'
#' @param filepath String com caminho para o arquivo \code{.ini} de autenticação ou **NULL** para utilizar variáveis de ambiente. Para gerar um arquivo utilize a função \code{generate_ini} ou \code{generate_r_environ}
#' @param serie String com o código de 16 digitos da série
#' @param overwrite Logical para definir se as observações poderão ser sobrescritas ou não
#' @param access_group String com o nome do grupo de acesso para inserir a série
#' @param contents DataFrame contendo as observações com obrigatóriamente duas colunas: \code{date} e \code{val}, as datas devem estar no formato ISO \code{yyyy-mm-dd}
#' @param estimate Logical \code{TRUE} se são dados projetados, para dados realizados \code{FALSE}
#' @param label_estimate String com nome da projeção, obrigatório somente para dados projetados
#'
#' @author João Gustavo Oliveira
#' 
#' @details Utiliza das variáveis de ambiente \code{.Renviron} para a validação dos dados.
#' Para criar um arquivo de autenticação utilize a função \code{generate_r_environ}
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
#' Para criar um arquivo de autenticação utilize a função \code{generate_ini}
#' 
#' @return O retorno consiste em uma lista contendo dois campos, code e message, code contém o código da resposta do servidor e
#' message um texto explicitando o código recebido. Os possíveis códigos de retorno são:
#'
#' \item{0}{Dados inseridos com sucesso;}
#' \item{1}{Erro no formato da requisição;}
#' \item{2}{Parâmetro usr não está no formato correto;}
#' \item{3}{Parâmetro pwd não está no formato correto;}
#' \item{4}{Código da série não está no formato correto;}
#' \item{5}{Grupo de acesso não está no formato correto;}
#' \item{6}{Parâmetro estimate não está no formato correto;}
#' \item{7}{Parâmetro label_estimate não está no formato correto;}
#' \item{8}{Data frame com os dados não está no formato correto;}
#' \item{9}{Erro de autenticação com os dados do usuário;}
#' \item{10}{Grupo de acesso não está disponível para o usuário;}
#' \item{11}{Série não existe para o grupo de acesso;}
#' \item{12}{Valores do data frame não estão no formato correto;}
#' \item{13}{Dados duplicados, neste caso um terceiro valor será retornado, repeated_date, indicando os dados duplicados.}
#' 
#' 
#' @examples 
#' \dontrun{
#' df <- data.frame("date" = c("2020-05-13"), "val" = c("21.5"))
#' insert_series("/home/joao/auth.ini", "BRLDG0002000SOML", TRUE, "Geral", df, FALSE)
#' insert_series("/home/joao/auth.ini", "BRLDG0002000SOML", FALSE, "Geral", df, TRUE, 
#'     "Estimado em 2020-05-13")
#' }
#' 
#' @export 
insert_series <- function(filepath = NULL, serie, overwrite, access_group, contents, estimate, label_estimate = NULL) {
	
	if( ! is.null(filepath) )
	{
		# Read .ini file
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
	
	url <- base::paste0(url_base, "/services/GoetheDB/procedureExecutor/procedure/execute/createPutSeries")
	
	if(is.null(label_estimate)) {
		label_estimate = ""
	}
	
	request_data = list(
		"uid" = auth_data$usr,
		"pwd" = auth_data$pwd,
		"sid" = serie,
		"ag"  = access_group,
		"est" = estimate,
		"lbl" = label_estimate,
		"ovr" = overwrite,
		"contents" = contents
	)
	
	request_json_data <- base::as.character(jsonlite::toJSON(request_data, auto_unbox = TRUE))

	res <- httr::POST(url = url, body = list(request = request_json_data), encode = "json")
	
	res <- httr::content(res, "text")
	res_json <- jsonlite::fromJSON(res)
	res_json <- jsonlite::fromJSON(res_json$response)
	
	if(res_json$reqresp$code == 13) {
		ret <- list("code" = res_json$reqresp$code,
					"message" = res_json$reqresp$text,
					"repeated_date" = res_json$reqresp$refdates
				)	
	} else {
		ret <- list("code" = res_json$reqresp$code,
					"message" = res_json$reqresp$text
				)
	}
	
	return(ret)
}
