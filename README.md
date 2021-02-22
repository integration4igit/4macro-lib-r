# Biblioteca R - 4Macro

![R](https://img.shields.io/badge/R%3E%3D-3.0.0-blue.svg)
![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)

**Biblioteca para acesso e inputação de dados no 4Macro.** 

Este pacote é largamente dependente das APIs do 4Macro.

Repositório sob licença [Mozilla Public Version 2.0](https://www.mozilla.org/en-US/MPL/2.0/).

## Funções
* **generate_ini** cria um arquivo de auntenticação `.ini`;
* **generate_r_environ** cria um arquivo com as variáveis de ambiente `.Renviron`;
* **insert_series** insere dados em uma determinada série;
* **get_multi_series** consulta as observações de uma ou mais séries.

## Instalação

Para a instalação utilize o [devtools](https://cran.r-project.org/package=devtools):

    install.packages("devtools")
    library(devtools)
    install_github("4intelligence/4macro-lib-r")

## Autenticação

Para a utilização das funções presente no pacote é necessário possuir um usuário devidamente autenticado, tais informações de autenticação devem ser fornecidas

* Através de variáveis de ambiente (Recomendado)

* Através de um arquivo `.ini`, este arquivo deve conter obrigatóriamente uma seção `login`.

Independente da forma de autenticação escolhida, deve ser fornecido os seguintes campos:

* **url**: url base de acesso para a API;
* **usr**: identifação do usuário;
* **pwd**: senha do usuário.

Este arquivo pode ser criado utilizando a função `generate_ini` ou `generate_r_environ`, de acordo com o exemplo:

### .Renviron

    library(series.4macro)
    generate_r_environ("https://4intelligence.com.br/example_url", "example@4i.com.br", "example_pwd")

### .ini

    library(series.4macro)
    generate_ini("https://4intelligence.com.br/example_url", "example@4i.com.br", "example_pwd")
    filepath_ini <- paste0(getwd(), "auth.ini")


## Utilização

### insert_series
Função para a inserção de observações realizadas ou projetadas em uma série, argumentos:

* **filepath**: (Parâmetro Opcional) String com caminho para o arquivo `.ini` de autenticação;
* **serie**: String com o código de 16 digitos da série;
* **overwrite**:	Logical para definir se as observações poderão ser sobrescritas ou não;
* **access_group**: String com o nome do grupo de acesso para inserir a série;
* **contents**: DataFrame contendo as observações com obrigatóriamente duas colunas: date e val, as datas devem estar no formato ISO yyyy-mm-dd;
* **estimate**: Logical TRUE se são dados projetados, para dados realizados FALSE;
* **label_estimate**: String com nome da projeção, obrigatório somente para dados projetados;

**Exemplo:**

    library(series.4macro)
    data_to_insert <- data.frame("date" = c("2020-05-13", "2020-05-14"), "val" = c(21.5, 23))
    
    # Com as variáveis de ambiente
    insert_series("BRLDG0002000SOML", TRUE, "Geral", data_to_insert, FALSE)
    
    # Com autenticação .ini
    insert_series(filepath_ini, "BRLDG0002000SOML", TRUE, "Geral", data_to_insert, FALSE)
    
O retorno consiste em uma lista contendo dois campos, ```code``` e ```message```, code contém o código da resposta do servidor e message um texto
explicitando o código recebido. Os possíveis códigos de retorno são:

* **0**:	Dados inseridos com sucesso;
* **1**:	Erro no formato da requisição;
* **2**:	Parâmetro usr não está no formato correto;
* **3**:	Parâmetro pwd não está no formato correto;
* **4**:	Código da série não está no formato correto;
* **5**:	Grupo de acesso não está no formato correto;
* **6**:	Parâmetro estimate não está no formato correto;
* **7**:	Parâmetro label_estimate não está no formato correto;
* **8**:	Data frame com os dados não está no formato correto;
* **9**:	Erro de autenticação com os dados do usuário;
* **10**: Grupo de acesso não está disponível para o usuário;
* **11**: Série não existe para o grupo de acesso;
* **12**: Valores do data frame não estão no formato correto;
* **13**: Dados duplicados, neste caso um terceiro valor será retornado, ```repeated_date```, indicando os dados duplicados.

### get_multi_series
Função que busca dados de uma ou mais séries basendo-se em um DataFrame para consulta, argumentos:

* **filepath**: (Parâmetro Opcional) String com caminho para o arquivo .ini de autenticação, para gerar um arquivo utilize a função generate_auth;
* **base_parameters**: DataFrame, obrigatóriamente, com todos os parâmetros necessários para a API funcionar. Os parâmetros são datalhados abaixo;
* **lang**: String com a língua definida para as respostas das séries.

O DataFrame utilizado em ```base_parameters``` deve conter as seguintes colunas:
* **sid**: Obrigatório. Códigos de 16 dígitos das séries que deseja consultar;
* **label**: Opcional. String com nome da projeção, obrigatório somente para dados projetados;
* **estimate**: Opcional. Logical TRUE se são dados projetados, para dados realizados FALSE;
* **force**: Opcional. Se TRUE força a geração do conteúdo da resposta com a propriedade label mesmo que exista nenhuma ou apenas um segmento estimado. Vale FALSE se não for especificado;
* **reff**: Opcional. Retornar datas de referência para as observações caso TRUE, ou a data original informada pela fonte primária ou gerada pelo algoritmo de estimativa FALSE;
* **start**: Opcional. String com data para inicio dos dados da série a serem requisitados;
* **end**: Opcional. String com data limite das informações da série;

**Exemplo**:

    library(series.4macro)
    df_query_data <- data.frame(
        sid = c('BRGDP0002000ROQL', 'BRGDP0021000ROQL'),
        label = c(NA, "Estimativa 2020-01-02"),
        estimate = c(TRUE, TRUE),
        force = c(FALSE, FALSE),
        reff = c(TRUE, FALSE)
    )
    series_data <- get_multi_series(filepath_ini, query_data, "pt-br")

O retorno consiste em uma lista contendo seis campos: series, names, short_names, content, last_actual e status, respectivamente. Dentro de cada campo haverá
uma outra lista, em que cada posição representa uma informação das séries consultadas, respeitando a ordem de entrada. O campo ```names``` contém o nome longo
de cada série, ```content``` contém um data frame com as observações, ```last_actual``` a última data da observação realizada e ```status``` indica se a série
foi consultada com sucesso. Os possíveis valores para status são:

* **0**: Dados consultados com sucesso;
* **1**: Erro no formato da requisição;
* **2**: Parâmetro usr não está no formato correto;
* **3**: Parâmetro pwd não está no formato correto;
* **4**: Código da série não está no formato correto;
* **12**: Erro de autenticação com os parâmetros do usuário;
* **13**: Série não está disponível para o usuário;
* **14**: O parâmetro series deve ser uma lista.
