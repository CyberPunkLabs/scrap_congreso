library(tidyverse)
library(RSelenium)
library(rvest)

closeAllConnections()

url <- "https://www.camara.cl/legislacion/ProyectosDeLey/proyectos_ley.aspx"

sesion <- html_session(url)


#Numero de ley
sesion %>% 
  html_nodes("div.grid-9.lista-proyectos.aleft.border-left") %>%
  html_nodes("span.numero") %>%
  html_text() %>%
  str_remove_all("[\n\r]") %>%
  str_trim()


#Obteniendo fecha
sesion %>% 
  html_nodes("div.grid-9.lista-proyectos.aleft.border-left") %>%
  html_nodes("span.fecha") %>%
  html_text() %>%
  str_remove_all("[\n\r]") %>%
  str_trim()

#Obteniendo tipo
sesion %>% 
  html_nodes("div.grid-9.lista-proyectos.aleft.border-left") %>%
  html_nodes("li.select") %>%
  html_text() %>%
  str_remove_all("[\n\r]") %>%
  str_trim()

#Obteniendo cuerpo de la ley
sesion %>% 
  html_nodes("div.grid-9.lista-proyectos.aleft.border-left") %>%
  html_nodes("h3") %>%
  html_text() %>%
  str_remove_all("[\n\r]") %>%
  str_trim()

#Estado
sesion %>% 
  html_nodes("div.grid-9.lista-proyectos.aleft.border-left") %>%
  html_nodes("div.aleft > ul.etapas-legislativas > li.select") %>%
  html_text() %>%
  str_remove_all("[\n\r]") %>%
  str_trim()

#Links
sesion %>% 
  html_nodes("div.grid-9.lista-proyectos.aleft.border-left") %>%
  html_nodes("div.aleft > h3 > a") %>%
  html_attr("href") %>%
  str_c("https://www.camara.cl/legislacion/ProyectosDeLey/", .)






closeAllConnections()

# intentando login con rselenium

driver <- rsDriver(browser = c("firefox"))

remote_driver <- driver[["client"]]
# si al correr el "driver" ya está en uso, solo abrir 
# la sesión

# =============== CÓDIGO PARA RECORRER LAS PÁGINAS DE LEYES =====
remote_driver$open()

remote_driver$navigate(url)

busqueda <- remote_driver$findElement("name", 
  "ctl00$ctl00$ContentPlaceHolder1$ContentPlaceHolder1$txtBuscarPLey")

busqueda$sendKeysToElement(list("-"))
remote_driver$findElements("id", 
      "ContentPlaceHolder1_ContentPlaceHolder1_lnkBuscar")[[1]]$clickElement()

listado <- remote_driver$findElement("class", "grid-9")

#Obteniendo número
nro <- listado$getElementAttribute("outerHTML")[[1]] %>%
  read_html() %>%
  html_nodes("span.numero") %>%
  html_text() %>%
  str_remove_all("[\n\r]") %>%
  str_trim()

#Obteniendo la fecha
fecha <-  listado$getElementAttribute("outerHTML")[[1]] %>%
          read_html() %>%
          html_nodes("span.fecha") %>%
          html_text() %>%
          str_remove_all("[\n\r]") %>%
          str_trim()

#Obteniendo tipo
tipo <-  listado$getElementAttribute("outerHTML")[[1]] %>%
  read_html() %>%
  html_nodes("li.select") %>%
  html_text() %>%
  str_remove_all("[\n\r]") %>%
  str_trim()


#Obteniendo cuerpo de la ley
cuerpo <-  listado$getElementAttribute("outerHTML")[[1]] %>%
            read_html() %>%
            html_nodes("h3") %>%
            html_text() %>%
            str_remove_all("[\n\r]") %>%
            str_trim()

#Obteniendo estado
estado <- listado$getElementAttribute("outerHTML")[[1]] %>%
  read_html() %>% 
  html_nodes("div.aleft > ul.etapas-legislativas > li.select") %>%
  html_text() %>%
  str_remove_all("[\n\r]") %>%
  str_trim()

#Obteniendo links
link <- listado$getElementAttribute("outerHTML")[[1]] %>%
  read_html() %>% 
  html_nodes("div.aleft > h3 > a") %>%
  html_attr("href") %>%
  str_c("https://www.camara.cl/legislacion/ProyectosDeLey/", .)

p <- paste0("ContentPlaceHolder1_ContentPlaceHolder1_pager_rptPager_page_", 0)

remote_driver$findElements("id", 
      p)[[1]]$clickElement()




# ======  CÓDIGO PA METERSE A CADA LEY ============

sesion <- html_session(link[1])

# Obteniendo autores
autores <- sesion %>%
            html_nodes("#info-ficha > div.auxi > div:nth-child(8) > div.info") %>%
            html_text() %>%
            str_remove_all("[\n\r]") %>%
            str_squish() %>%
            str_split("[|]") %>% 
            unlist() %>%
            str_trim("both")

temp.ses <- sesion %>% follow_link(autores[1])

region <- temp.ses %>%
  html_nodes(xpath = '//*[@id="info-ficha"]/div[1]/div[2]/p/text()[3]') %>%
  html_text() %>%
  str_remove_all("[\n\r]") %>%
  sub('.*: ', '', .)  %>%  
  str_trim()

partido <- temp.ses %>%
          html_nodes(xpath = '//*[@id="info-ficha"]/div[1]/div[2]/p/text()[5]') %>%
          html_text() %>%
          str_remove_all("[\n\r]") %>%
          sub('.*: ', '', .) %>%  
  str_trim() 














