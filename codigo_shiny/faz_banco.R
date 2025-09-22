if(!require(pacman)){install.packages("pacman")}

pacman::p_load(lubridate, dplyr, stringr,geosphere,phylin)

mean_rm = function(vet){
  
  return(mean(vet, na.rm = T))
  
}

carrega_csv = function(pasta, banco_nome){
  # A ideia dessa função é pegar o nome do csv e a partir disso deixar preparado
  # todas as variáveis do banco
  
  banco = read.csv2(file.path(pasta, banco_nome))
  
  banco = banco |> dplyr::rename(data_dia = Data,
                                 hora_num = Hora..UTC.,
                                 temp_med = Temp..Ins...C.,
                                 temp_max = Temp..Max...C.,
                                 temp_min = Temp..Min...C.,
                                 umi_med = Umi..Ins.....,
                                 umi_max = Umi..Max.....,
                                 umi_min = Umi..Min.....,
                                 pto_orvalho_med = Pto.Orvalho.Ins...C.,
                                 pto_orvalho_max = Pto.Orvalho.Max...C.,
                                 pto_orvalho_min = Pto.Orvalho.Min...C.,
                                 press_med = Pressao.Ins...hPa.,
                                 press_max = Pressao.Max...hPa.,
                                 press_min = Pressao.Min...hPa.,
                                 vento_vel = Vel..Vento..m.s.,
                                 vento_dir = Dir..Vento..m.s.,
                                 vento_rajada = Raj..Vento..m.s.,
                                 radiacao = Radiacao..KJ.m..,
                                 chuva = Chuva..mm.)
  
  # Podemos no futuro querer agregar por dia, mes, semana ou ano,
  # pra isso podemos ter varias variaveis de tempo baseado em
  # que tipo de agregacao queremos fazer
  banco$data_dia =  banco$data_dia |> as.Date(format = "%d/%m/%Y")
  banco$data_semana = paste0(banco$data_dia |> year(), "-", banco$data_dia |> week())
  banco$data_mes = paste0(banco$data_dia |> year(), "-", banco$data_dia |> month())
  banco$data_ano = banco$data_dia |> year()
  
  # Agora colocar as coordenadas no banco baseado em qual estacao eh
  banco$lat = switch(banco_nome,
                     "ALEGRETE_A826.csv" = -29.71,
                     "BAGE_A827.csv" = -31.35,
                     "BENTO_GONCALVES_A840.csv" = -29.16,
                     "CACAPAVA_DO_SUL_A812.csv" = -30.55,
                     "CAMAQUA_A838.csv" = -30.81,
                     "CAMBARA_DO_SUL_A897.csv" = -29.05,
                     "CAMPO_BOM_A884.csv" = -29.67,
                     "CANELA_A879.csv" = -29.37,
                     "CANGUCU_A811.csv" = -31.40,
                     "CAPAO_DO_LEAO_(PELOTAS)_A887.csv" = -31.45,
                     "CRUZ_ALTA_A853.csv" = -28.60,
                     "DOM_PEDRITO_A881.csv" = -31.00,
                     "ENCRUZILHADA_DO_SUL_A893.csv" = -30.54,
                     "ERECHIM_A828.csv" = -27.66,
                     "FREDERICO_WESTPHALEN_A854.csv" = -27.40,
                     "JAGUARAO_A836.csv" = -32.53,
                     "LAGOA_VERMELHA_A844.csv" = -28.22,
                     "PALMEIRA_DAS_MISSOES_A856.csv" = -27.92,
                     "PASSO_FUNDO_A839.csv" = -28.23,
                     "PORTO_ALEGRE_BELEM_NOVO_B807.csv" = -30.19,
                     "PORTO_ALEGRE_JARDIM_BOTANICO_A801.csv" = -30.05,
                     "RIO_GRANDE_A802.csv" = -32.08,
                     "RIO_PARDO_A813.csv" = -29.87,
                     "QUARAI_A831.csv" = -30.37,
                     "SANTA_MARIA_A803.csv" = -29.72,
                     "SANTANA_DO_LIVRAMENTO_A804.csv" = -30.75,
                     "SANTIAGO_A833.csv" = -29.19,
                     "SANTO_AUGUSTO_A805.csv" = -27.85,
                     "SAO_BORJA_A830.csv" = -28.65,
                     "SAO_GABRIEL_A832.csv" = -30.34,
                     "SAO_JOSE_DOS_AUSENTES_A829.csv" = -28.74,
                     "SAO_LUIZ_GONZAGA_A852.csv" = -28.42,
                     "SAO_VICENTE_DO_SUL_A889.csv" = -29.70,
                     "SERAFINA_CORREA_A894.csv" = -28.70,
                     "SOLEDADE_A837.csv" = -28.86,
                     "TEUTONIA_A882.csv" = -29.45,
                     "TRAMANDAI_A834.csv" = -30.01,
                     "TUPANCIRETA_A886.csv" = -29.09,
                     "URUGUAIANA_A809.csv" = -29.75,
                     "VACARIA_A880.csv" = -28.51)
  
  banco$lon = switch(banco_nome,
                     "ALEGRETE_A826.csv" = -55.53,
                     "BAGE_A827.csv" = -54.01,
                     "BENTO_GONCALVES_A840.csv" = -51.53,
                     "CACAPAVA_DO_SUL_A812.csv" = -53.47,
                     "CAMAQUA_A838.csv" = -51.83,
                     "CAMBARA_DO_SUL_A897.csv" = -50.15,
                     "CAMPO_BOM_A884.csv" = -51.06,
                     "CANELA_A879.csv" = -50.83,
                     "CANGUCU_A811.csv" = -52.70,
                     "CAPAO_DO_LEAO_(PELOTAS)_A887.csv" = -52.29,
                     "CRUZ_ALTA_A853.csv" = -53.67,
                     "DOM_PEDRITO_A881.csv" = -54.62,
                     "ENCRUZILHADA_DO_SUL_A893.csv" = -52.52,
                     "ERECHIM_A828.csv" = -52.31,
                     "FREDERICO_WESTPHALEN_A854.csv" = -53.43,
                     "JAGUARAO_A836.csv" = -53.38,
                     "LAGOA_VERMELHA_A844.csv" = -51.51,
                     "PALMEIRA_DAS_MISSOES_A856.csv" = -53.32,
                     "PASSO_FUNDO_A839.csv" = -52.40,
                     "PORTO_ALEGRE_BELEM_NOVO_B807.csv" = -51.18,
                     "PORTO_ALEGRE_JARDIM_BOTANICO_A801.csv" = -51.17,
                     "RIO_GRANDE_A802.csv" = -52.17,
                     "RIO_PARDO_A813.csv" = -52.38,
                     "QUARAI_A831.csv" = -56.44,
                     "SANTA_MARIA_A803.csv" = -53.72,
                     "SANTANA_DO_LIVRAMENTO_A804.csv" = -55.40,
                     "SANTIAGO_A833.csv" = -54.89,
                     "SANTO_AUGUSTO_A805.csv" = -53.79,
                     "SAO_BORJA_A830.csv" = -56.02,
                     "SAO_GABRIEL_A832.csv" = -54.31,
                     "SAO_JOSE_DOS_AUSENTES_A829.csv" = -50.06,
                     "SAO_LUIZ_GONZAGA_A852.csv" = -54.96,
                     "SAO_VICENTE_DO_SUL_A889.csv" = -54.69,
                     "SERAFINA_CORREA_A894.csv" = -51.87,
                     "SOLEDADE_A837.csv" = -52.54,
                     "TEUTONIA_A882.csv" = -51.82,
                     "TRAMANDAI_A834.csv" = -50.14,
                     "TUPANCIRETA_A886.csv" = -53.83,
                     "URUGUAIANA_A809.csv" = -57.08,
                     "VACARIA_A880.csv" = -50.88)
  
  # Colocando o codigo da estacao caso seja necessario dps
  banco$codigo_estacao = banco_nome |> str_sub(start = -8) |> str_sub(end = 4)
  
  banco$nome_estacao = banco_nome |> str_sub(end = -10)
  
  banco$nome_estacao = banco$nome_estacao |> as.factor()
  banco$codigo_estacao = banco$codigo_estacao |> as.factor()
  
  return(banco)
  
}

 # teste1 = carrega_csv("dados_estacoes", "ALEGRETE_A826.csv")
 # teste2 = carrega_csv("dados_estacoes", "CANGUCU_A811.csv")
 # teste3 = carrega_csv("dados_estacoes", "JARDIM_BOTANICO_A801.csv")
 # teste4 = carrega_csv("dados_estacoes", "PALMEIRA_DAS_MISSOES_A856.csv")
 # teste5 = carrega_csv("dados_estacoes", "SANTA_MARIA_A803.csv")

agrupa_csv = function(pasta, vet_nomes){
  
  # Faz o primeiro manualmente pra poder dar bind nos outros
  banco = carrega_csv(pasta, vet_nomes[1])
  
  # Bind de todos os outros pulando o primeiro
  for (i in 2:length(vet_nomes)){
    
    print(vet_nomes[i])
    
    if (vet_nomes[i] %in% c("IBIRUBA_A883.csv",
                            "MOSTARDAS_A878.csv",
                            "SANTA_ROSA_A810.csv",
                            "Santa_Vitoria_do_Palmar_Barra_do_Chui_A899.csv")) {print("!!!!!! skippado"); next}
    
    aux = carrega_csv(pasta, vet_nomes[i])
    
    banco = rbind(banco, aux)
    
  }
  
  return(banco)
  
}

# teste_grupo = agrupa_csv("dados_estacoes",
#                          list.files("dados_estacoes"))

grp_csv_por_pasta = function(nome_pasta){
  
  # Pega tds arquivos na pasta
  nomes_arquivos = list.files(nome_pasta)
  
  # Manda os nomes deles + o nome da pasta
  dados = agrupa_csv(nome_pasta,
                     nomes_arquivos)
  
  return(dados)
  
}

condensa_horas = function(dados){
  
  niveis = unique(dados$data_dia)
  
  dados_agrupdos = data.frame()
  
  for (i in niveis){
    
    aux = dados |> subset(data_dia == i)
    
    aux = aux |> group_by(nome_estacao) |> summarise(data_dia = unique(data_dia),
                                                     data_semana = unique(data_semana),
                                                     data_mes = unique(data_mes),
                                                     data_ano = unique(data_ano),
                                                     lon = unique(lon),
                                                     lat = unique(lat),
                                                     chuva = sum(chuva, na.rm = T),
                                                     vento = mean(vento_vel, na.rm = T),
                                                     press = mean(press_med, na.rm = T),
                                                     temp = mean(temp_med, na.rm = T),
                                                     umidade = mean(umi_med, na.rm = T),
                                                     rajada = max(vento_rajada, na.rm = T),
                                                     amp = round(max(temp_max, na.rm = T) - min(temp_min, na.rm = T), 2))
    
    
    dados_agrupdos = rbind(dados_agrupdos, aux)
    
  }
  
  return(dados_agrupdos)
  
}


idw = function(banco,par_idw,neighbours,variaveis) {

for (var in variaveis) {
  
for (k in 1:nrow(banco)) {

  if (is.na(banco[k,var]) == T) {
    
    df = banco
    df[(nrow(df)+1),] = banco[k,]
    
    df$distancia=0
    
    
    df = filter(df,df$data_dia == df$data_dia[k])
    

    
      for (j in 1:nrow(df)) {



        df$distancia[j] = distm(c(df$lon[(nrow(df))], df$lat[(nrow(df))]), c(df$lon[j], df$lat[j]), fun = distHaversine)


      }
    
    df[nrow(df), var ] = 0 
    df = df[!is.na(df[,var]), ]
    
    df = df |> arrange(distancia) |>
      slice(2:(neighbours+1))
    
    
    
    banco[k,var] =  round( sum(df[var] * df$distancia^(-par_idw))/sum(df$distancia^(-par_idw)), 3 )
    
        }
      }
    }
  return(banco)
}

grp_csv_por_anos = function(path){
  
  anos = list.files(path)
  
  #banco = grp_csv_por_pasta(paste0(path, "/", anos[1]))
  
  banco = data.frame()
  
  for (i in 1:length(anos)){
    
    #print(i)
    
    print(anos[i])
    
    aux = grp_csv_por_pasta(paste0(path, "/", anos[i]))
    
    banco = rbind(banco, aux)
    
  }
  
  return(banco)
  
}

teste_pasta = grp_csv_por_anos("dados_estacoes")

#teste_pasta = grp_csv_por_pasta("dados_estacoes/2022")

dados_grp = condensa_horas(teste_pasta)

dados_grp$rajada[(dados_grp$rajada) < 0] = 0
dados_grp$amp[(dados_grp$amp) < 0] = 0

par_idw = 2
neighbours = 5
vari = c("chuva", "vento", "press", "temp", "umidade")

dados_grp = idw(dados_grp,par_idw, neighbours,vari)

write.csv2(dados_grp, "banco_shiny.csv", row.names = F)


