# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#' @title Gera um arquivo para armazenar as variáveis de autenticação
#' @name generate_r_environ
#' 
#' @description Função para criar ou adicionar linhas (caso já exista) no arquivo **.Renviron** com os dados fornecidos
#'
#' @param url String com a url base de acesso ao servidor
#' @param usr String com a identificação do usuário
#' @param pwd String com a senha de acesso do usuário
#'
#' @author Samuel Souza
#' 
#' @details O arquivo será gerado com uma única seção, login, que é por padrão a que todas funções neste pacote utilizam.
#' O local de criação será o mesmo de sua R Session, e irá conter o nome **.Renviron** .
#' 
#' Para acessar o valor das credenciais, utilize a função `Sys.getenv()` e passe como parâmetro a variável que deseja.
#' 
#' Os valores disponíveis são:
#' `Sys.getenv(URL_4MACRO)`
#' `Sys.getenv(USR_4MACRO)`
#' `Sys.getenv(PWD_4MACRO)`
#' 
#' @return Não existe nenhum retorno para a função.
#' 
#' @examples 
#' generate_r_environ("https://4intelligence.com.br/", "example@@4i.com.br", "example_pwd")
#' 
#' @export  
generate_r_environ <- function(url, usr, pwd){
	
	# Create lines to write in .Renviron file
	lines <- base::paste0("\n# Variables from 4macro\n",
						  "URL_4MACRO=", url, '\n',
						  "USR_4MACRO=", usr, '\n',
						  "PWD_4MACRO=", pwd)
	
	# Write/append .Renviron file
	base::write(x = lines, file = '.Renviron', append = TRUE)
	
	# Restart R session (to validate environment variables)
	.rs.restartR()
	
}
