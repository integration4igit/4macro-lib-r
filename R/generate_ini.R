# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#' @title Gera um arquivo de autenticação .ini
#' @name generate_ini
#' 
#' @description Função para criar um arquivo de autenticação com os dados fornecidos
#'
#' @param url String com a url base de acesso ao servidor
#' @param usr String com a identificação do usuário
#' @param pwd String com a senha de acesso do usuário
#'
#' @author João Gustavo Oliveira
#' 
#' @details O arquivo será gerado com uma única seção, login, que é por padrão a que todas funções neste pacote utilizam.
#' O local de criação será o mesmo de sua R Session, e irá conter o nome auth.ini .
#' 
#' @return Não existe nenhum retorno para a função.
#'
#' 
#' @examples 
#' generate_ini("https://4intelligence.com.br/", "example@@4i.com.br", "example_pwd")
#' 
#' 
#' @export  
generate_ini <- function(url, usr, pwd) {
	path <- paste0(getwd(), "/auth.ini")
	
	ans <- list()
	ans[["login"]] <- list(
							"url" = url,
							"usr" = usr,
							"pwd" = pwd
							)
	
	ini::write.ini(x = ans, filepath = path)
}
