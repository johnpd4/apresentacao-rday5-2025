if(!require(pacman)){install.packages("pacman")}

pacman::p_load(shiny, leaflet, dplyr, htmltools, leaflet, sp, sf, gstat, ggplot2,
               terra, leaflet.minicharts, shinyWidgets, plotly, rlang, leafsync)

server = function(input, output){
  
  # dados = reactive({
  #   
  #   dados = read.csv2("banco_shiny.csv")
  #   
  #   return(dados)
  #   
  # })
  
  dados = read.csv2("banco_shiny.csv")
  
  # dados$chuva[is.na(dados$chuva)] = 0
  
  rs = geobr::read_state("RS")
  
  # dados_esp = dados
  # coordinates(dados_esp) = ~lon + lat
  # 
  # dados_esp = dados_esp[-zerodist(dados_esp)[,1],] 
  
  # proj4string(dados_esp) = CRS("+init=epsg:4326")
  
  output$seletor_tempo = renderUI({
    
    dados_aux = get("dados")
    
    tempo = dados_aux |> getElement(input$unidade_tempo) |> unique()
    
    selectInput("tempo_selecionado", "Selecione o Momento no Tempo",
                choices = rev(tempo))
    
  })
  
  output$seletor_tempo_inicio = renderUI({
    
    dados_aux = get("dados")
    
    tempo = dados_aux |> getElement(input$unidade_tempo) |> unique()
    
    tempo = tempo[-length(tempo)]
    
    data_final = input$tempo_selecionado
    
    vet_data = dados_aux |> getElement(input$unidade_tempo)

    datas_antes = vet_data[vet_data < data_final] |> unique() |> rev()
    
    aux_inicial = ifelse(length(datas_antes) > 6, 7, 1)
    
    selectInput("tempo_inicio", "Selecione o Início da Série Temporal",
                choices = datas_antes, selected = datas_antes[aux_inicial])
    
  })
  
  # output$seletor_tempo_final = renderUI({
  #   
  #   dados_aux = get("dados")
  #   
  #   tempo = dados_aux |> getElement(input$unidade_tempo) |> unique()
  #   
  #   data_inicio = input$tempo_inicio
  #   
  #   vet_data = dados_aux |> getElement(input$unidade_tempo)
  #   
  #   datas_dps = vet_data[vet_data > data_inicio] |> unique()
  #   
  #   selectInput("tempo_final", "Selecione o Final da Série Temporal",
  #               choices = rev(datas_dps))
  #   
  # })
  
  output$seletor_estacoes = renderUI({
    
    dados_aux = get("dados")
    
    estacoes = dados_aux |> select(nome_estacao) |> unique()
    
    pickerInput("estacoes_serie", "Selecione as Estações que serão usadas",
                  choices = estacoes, multiple = TRUE,
                  selected = c("ALEGRETE", "BAGE", "BENTO_GONCALVES", "CACAPAVA_DO_SUL", "CAMAQUA", "CAMBARA_DO_SUL", 
                             "CAMPO_BOM", "CANELA", "CANGUCU", "CAPAO_DO_LEAO_(PELOTAS)", "CRUZ_ALTA", "DOM_PEDRITO", 
                             "ENCRUZILHADA_DO_SUL", "ERECHIM", "FREDERICO_WESTPHALEN", "JAGUARAO", "LAGOA_VERMELHA",
                             "PALMEIRA_DAS_MISSOES", "PASSO_FUNDO", "PORTO_ALEGRE_BELEM_NOVO", "PORTO_ALEGRE_JARDIM_BOTANICO",
                             "QUARAI", "RIO_GRANDE", "RIO_PARDO", "SANTA_MARIA", "SANTANA_DO_LIVRAMENTO", "SANTIAGO", 
                             "SANTO_AUGUSTO", "SAO_BORJA", "SAO_GABRIEL", "SAO_JOSE_DOS_AUSENTES", "SAO_LUIZ_GONZAGA",
                             "SAO_VICENTE_DO_SUL", "SERAFINA_CORREA", "SOLEDADE", "TEUTONIA", "TRAMANDAI", "TUPANCIRETA",
                             "URUGUAIANA", "VACARIA"),
                  options = list(`actions-box` = TRUE,
                    `deselect-all-text` = "Desselecionar",
                    `select-all-text` = "Selecionar Todos",
                    `none-selected-text` = "Nenhuma"))
    
  })
  
  agrupar_dados = function(dados){
    
    dados_grp = get("dados")
    
    # Para testes
    # input = data.frame(unidade_tempo = c("data_dia"), tempo_selecionado = c("2024-03-16"))
    
    parse(text = paste0("dados_grp = dados_grp |> subset(", input$unidade_tempo, " == input$tempo_selecionado)")) |> eval()
    
    # medias = dados_grp |> group_by(nome_estacao) |>
    #                                 summarise(lat = unique(lat),
    #                                           lon = unique(lon),
    #                                           chuva = mean(chuva, na.rm = T),
    #                                           vento = mean(vento, na.rm = T),
    #                                           press = mean(press, na.rm = T),
    #                                           temp = mean(temp, na.rm = T),
    #                                           umidade = mean(umidade, na.rm = T))
    
    # medias = dados_grp |>
    #               summarise(lat = unique(lat),
    #                         lon = unique(lon),
    #                         chuva = mean(chuva, na.rm = T),
    #                         vento = mean(vento, na.rm = T),
    #                         press = mean(press, na.rm = T),
    #                         temp = mean(temp, na.rm = T),
    #                         umidade = mean(umidade, na.rm = T), .by = nome_estacao)
    
    medias = dados_grp |>
                reframe(lat = unique(lat),
                        lon = unique(lon),
                        chuva = mean(chuva, na.rm = T),
                        vento = mean(vento, na.rm = T),
                        press = mean(press, na.rm = T),
                        temp = mean(temp, na.rm = T),
                        umidade = mean(umidade, na.rm = T),
                        rajada = max(rajada, na.rm = T),
                        amp = max(amp, na.rm = T), .by = nome_estacao)
    
    return(medias)
    
  }
  
  agrupar_dados_serie = function(dados, unidade_tempo){
    
    dados = dados |> reframe(nome_estacao = unique(nome_estacao),
                             lat = unique(lat),
                             lon = unique(lon),
                             chuva = mean(chuva, na.rm = T),
                             vento = mean(vento, na.rm = T),
                             press = mean(press, na.rm = T),
                             temp = mean(temp, na.rm = T),
                             umidade = mean(umidade, na.rm = T),
                             rajada = max(rajada, na.rm = T),
                             amp = max(amp, na.rm = T), .by = c(!!unidade_tempo))
    
    return(dados)
    
  }
  
  agrupar_dados = function(dados){
    
    dados_grp = dados
    
    # Para testes
    # input = data.frame(unidade_tempo = c("data_dia"), tempo_selecionado = c("2024-03-16"))
    
    parse(text = paste0("dados_grp = dados_grp |> subset(", input$unidade_tempo, " == input$tempo_selecionado)")) |> eval()
    
    medias = dados_grp |>
      reframe(lat = unique(lat),
              lon = unique(lon),
              chuva = mean(chuva, na.rm = T),
              vento = mean(vento, na.rm = T),
              press = mean(press, na.rm = T),
              temp = mean(temp, na.rm = T),
              umidade = mean(umidade, na.rm = T),
              amp = max(amp, na.rm = T),
              rajada = max(rajada, na.rm = T),
              .by = nome_estacao)
    
    return(medias)
    
  }
  
  dados_grp = reactive({
    
    dados_grp = get("dados")
    
    dados_grp = agrupar_dados(dados_grp)
    
    vet_estacao = dados_grp |> getElement("nome_estacao")
    
    dados_grp = dados_grp[vet_estacao %in% input$estacoes_serie,]
    
    dados_grp = dados_grp |> data.frame()
    
    return(dados_grp)
    
  })
  
  poligono = sp::Polygon(sf::st_coordinates(rs$geom)[, 1:2])
  poligonos = sp::Polygons(list(poligono), ID = "1")
  
  spatial_poligono = SpatialPolygons(list(poligonos))
  
  #spatial_df = SpatialPolygonsDataFrame(Sr = spatial_poligono, data = dados |> select(-lat, -lon))
  
  proj4string(spatial_poligono) = CRS("+init=epsg:4674")
  
  grade = reactive({
    
    # Para testes
    # input = data.frame(grade_tamanho = c(10000))
    
    grade <- makegrid(spatial_poligono, n = input$grade_tamanho)
    colnames(grade) <- c("x", "y")
    
    grade_pts <- SpatialPoints(
      coords      = grade, 
      proj4string = CRS(proj4string(spatial_poligono))
    )
    
    grade_pts_in <- grade_pts[spatial_poligono, ]
    
    #plot(grade_pts_in)
    
    return(grade_pts_in)

  })
  
  dados_grp_esp = reactive({
    
    dados_grp = dados_grp()
    coordinates(dados_grp) = ~lon + lat
    
    proj4string(dados_grp) = CRS("+init=epsg:4674")
    
    # print("dados crs")
    # print(st_crs(dados_grp))
    
    # dados_grp_esp = dados_grp[-zerodist(dados_grp)[,1],]
    
    return(dados_grp)
    
  })
  
  variogramas_angulos = reactive({

    formula = as.formula(paste0("chuva ~ 1"))

    dados_grp_esp = dados_grp_esp()
    
    # Para testes
    # dados_grp_esp = dados_grp
    # vari_aniso = variogram(formula, data = dados_grp, alpha = c(0, 45, 90, 135))
    
    vari_aniso = variogram(formula, data = dados_grp_esp, alpha = c(0, 45, 90, 135))

    return(vari_aniso)

  })
  
  variogramas_angulos_mutavel = reactive({
    
    formula = as.formula(paste0(input$var_selecionada, " ~ 1"))
    
    dados_grp_esp = dados_grp_esp()
    
    # Para testes
    # dados_grp_esp = dados_grp
    # vari_aniso = variogram(formula, data = dados_grp, alpha = c(0, 45, 90, 135))
    
    vari_aniso = variogram(formula, data = dados_grp_esp, alpha = c(0, 45, 90, 135))
    
    return(vari_aniso)
    
  })

  variograma_angulo = reactive({

    vari_aniso = variogramas_angulos()

    # Para testes
    # vgm_ang = subset(vari_aniso, vari_aniso$dir.hor == 90)
    
    vgm_ang = subset(vari_aniso, vari_aniso$dir.hor == input$angulo)

    return(vgm_ang)

  })
  
  variograma_angulo_mutavel = reactive({
    
    vari_aniso = variogramas_angulos_mutavel()
    
    # Para testes
    # vgm_ang = subset(vari_aniso, vari_aniso$dir.hor == 90)
    
    vgm_ang = subset(vari_aniso, vari_aniso$dir.hor == input$angulo)
    
    return(vgm_ang)
    
  })

  variograma = reactive({

    modelo_variograma = input$modelo_variograma

    if(is.null(modelo_variograma)){

      modelo_variograma = "Mat"

    }

    # Para testes
    # fit = fit.variogram(vgm_ang, vgm(model = modelo_variograma))

    fit = fit.variogram(variograma_angulo(), vgm(psill = input$psill,
                                                 model = modelo_variograma,
                                                 range = input$range,
                                                 nugget = input$nugget))

    return(fit)

  })
  
  
  variograma_mutavel = reactive({
    
    modelo_variograma = input$modelo_variograma
    
    if(is.null(modelo_variograma)){
      
      modelo_variograma = "Mat"
      
    }
    
    # Para testes
    # fit = fit.variogram(vgm_ang, vgm(model = modelo_variograma))
    
    fit = fit.variogram(variograma_angulo_mutavel(), vgm(psill = input$psill,
                                                 model = modelo_variograma,
                                                 range = input$range,
                                                 nugget = input$nugget))
    
    return(fit)
    
  })

  krigagem = reactive({

    formula = as.formula(paste0("chuva ~ 1"))

    # Para testes
    # krig = krige(formula = formula, location = dados_grp_esp,
    #              newdata = grade_pts_in, model = fit)
    
    krig = krige(formula = formula, location = dados_grp_esp(),
                 newdata = grade(), model = variograma())

    # print(krig)
    
    return(krig)

  })
  
  krigagem_mutavel = reactive({
    
    formula = as.formula(paste0(input$var_selecionada, " ~ 1"))
    
    # Para testes
    # krig = krige(formula = formula, location = dados_grp_esp,
    #              newdata = grade_pts_in, model = fit)
    
    krig = krige(formula = formula, location = dados_grp_esp(),
                 newdata = grade(), model = variograma_mutavel())
    
    # print(krig)
    
    return(krig)
    
  })
  
  
  
  faz_labels = function(medias){
    
    label = paste0("Estação: ", medias$nome_estacao, "<br>",
                   "Chuva: ", medias$chuva |> round(3), "<br>",
                   "Temperatura: ", medias$temp |> round(3), "<br>",
                   "Pressão: ", medias$press |> round(3), "<br>",
                   "Vento: ", medias$vento |> round(3), "<br>",
                   "Umidade: ", medias$umidade |> round(3), "<br>")
    
    label = data.frame(label)
    
    label = label |> getElement("label")
    
    return(label)
    
  }
    
  output$plot_grade = renderPlot({

    dados_grp_esp = dados_grp_esp()

    # Para testes
    # ggplot()+
    #   geom_sf(data = grade_pts_in |> st_as_sf())+
    #   geom_point(aes(x = dados_grp_esp@coords[,1], y = dados_grp_esp@coords[,2]), col = "red")
    
    ggplot()+
      geom_sf(data = grade() |> st_as_sf())+
      geom_point(aes(x = dados_grp_esp@coords[,1], y = dados_grp_esp@coords[,2]), col = "red")+
      ggtitle("Grade Guia para Interpolação da Krigagem")

  })

  output$plot_krig_pred = renderPlot({

    krigagem = krigagem()

    #spplot(krigagem["var1.pred"], main = "Valores preditos")
    
    ggplot()+
      geom_sf(data = krigagem |> st_as_sf(), aes(col = var1.pred)) +
      scale_color_continuous(type = "viridis") +
      ggtitle("Valores Preditos pela Krigagem")

  })
  
  output$plot_krig_var = renderPlot({
    
    krigagem = krigagem()
    
    #spplot(krigagem["var1.pred"], main = "Valores preditos")
    
    ggplot()+
      geom_sf(data = krigagem |> st_as_sf(), aes(col = var1.var)) +
      scale_color_gradient(low="lightblue", high="red")+
      ggtitle("Variância da Krigagem")
    
  })
  
  
  output$hist = renderPlotly({

    dados_aux = dados_grp()
    
    plogt = ggplot(dados_aux, aes_string(input$Var_hist)) + 
               geom_histogram() +
               ggtitle("Histograma :)")
    
    ggplotly(plogt)
                  

  })
  
  output$media_temp = renderText({

    dados_aux = dados_grp()

    paste0(round(mean(dados_aux$temp, na.rm = TRUE), 1), " (C°)")

  })
  
  output$media_umidade = renderText({
    
    dados_aux = dados_grp()
    
    paste0(round(mean(dados_aux$umidade, na.rm = TRUE), 2), "%")
    
  })
  
  output$media_vento = renderText({
    
    dados_aux = dados_grp()
    
    paste0(round(mean(dados_aux$vento, na.rm = TRUE), 2), " (m/s)")
    
  })
  
  output$media_chuva = renderText({
    
    dados_aux = dados_grp()
    
    paste0(round(mean(dados_aux$chuva), 4), " (mm)")
    
  })
  
  output$maior_amp = renderText({
    
    dados_aux = dados_grp()
    
    paste0(max(dados_aux$rajada), " (C°)")
    
  })
  
  output$maior_raj = renderText({
    
    dados_aux = dados_grp()
    
    paste0(max(dados_aux$amp), " (m/s)")
    
  })
  
  output$nome_plot = renderText({
    
    nome_mutavel = switch(input$var_selecionada,
                          "vento" = "Vento", 
                          "temp" = "Temperatura",
                          "umidade" = "Umidade")
    
    paste0("Gráfico de Chuva e ", nome_mutavel, " - ", input$tempo_selecionado)
    
  })
  
  output$nome_serie = renderText({
    
    nome_mutavel = switch(input$var_selecionada,
                          "vento" = "Vento", 
                          "temp" = "Temperatura",
                          "umidade" = "Umidade")
    
    paste0("Série Temporal de Chuva e ", nome_mutavel)
    
  })
  
  output$plot_tempo = renderPlotly({
    
    dados_aux = get("dados")
    
    # Para testes
    # input = list(unidade_tempo = "data_dia",
    #              tempo_inicio = "2025-03-11",
    #              tempo_selecionado = "2025-03-16",
    #              estacoes_serie = c("ALEGRETE", "BAGE", "VACARIA"),
    #              var_selecionada = c("vento"))
    
    vet_tempo = dados_aux |> getElement(input$unidade_tempo)
    
    vet_tempo_aux = vet_tempo[vet_tempo >= input$tempo_inicio]
    
    vet_tempo_aux = vet_tempo_aux[vet_tempo_aux <= input$tempo_selecionado]
    
    dados_aux = dados[vet_tempo %in% vet_tempo_aux,]
    
    vet_estacao = dados_aux |> getElement("nome_estacao")
    
    dados_aux = dados_aux[vet_estacao %in% input$estacoes_serie,]
    
    dados_aux = dados_aux |> agrupar_dados_serie(unidade_tempo = input$unidade_tempo)
    
    dados_aux = dados_aux |> dplyr::select(input$unidade_tempo, chuva, input$var_selecionada)
    
    nome_tempo = switch(input$unidade_tempo,
                        "data_dia" = "Dia",
                        "data_semana" = "Semana",
                        "data_mes" = "Mês",
                        "data_ano" = "Ano")
    
    names(dados_aux) = c("data_dia", "chuva", "var_selecionada")
    
    cor_mutavel = switch(input$var_selecionada,
                         "vento" = "green", 
                         "temp" = "red",
                         "umidade" = "lightblue")
    
    nome_mutavel = switch(input$var_selecionada,
                          "vento" = "Vento (m/s)", 
                          "temp" = "Temperatura (ºC)",
                          "umidade" = "Umidade (%)")
    
    m_ini = dados_aux[which(dados_aux$data_dia == input$tempo_inicio), ]
    m_ini = m_ini[1,]
    rownames(m_ini) = paste0("Início ", m_ini$data_dia)
    anotacao_ini = list(x = m_ini$data_dia, y = m_ini$chuva, text = rownames(m_ini), xref = "x", yref = "y",
                        showarrow = TRUE, arrowhead = 7, ax = 20, ay = -40)
    
    
    m_fim = dados_aux[which(dados_aux$data_dia == input$tempo_selecionado), ]
    m_fim = m_fim[1,]
    rownames(m_fim) = paste0("Final ", m_fim$data_dia)
    anotacao_fim = list(x = m_fim$data_dia, y = m_fim$chuva, text = rownames(m_fim), xref = "x", yref = "y",
                        showarrow = TRUE, arrowhead = 7, ax = 20, ay = -40)
    
    plot = plot_ly(data = dados_aux, type = "scatter", mode = 'lines+markers') |>
             add_trace(x = ~data_dia, y = ~chuva, name = "Chuva",
                       marker = list(color = c("blue")), line = list(color = c("blue"))) |>
             layout(yaxis = list(title = "Chuva (mm)"),
                    xaxis = list(title = paste0("Agrupado por ", nome_tempo)),
                    annotations = list(anotacao_ini, anotacao_fim))
    
    anotacao_ini$y = m_ini$var_selecionada
    
    anotacao_fim$y = m_fim$var_selecionada
    
    plot2 = plot_ly(data = dados_aux, type = "scatter", mode = 'lines+markers') |>
              add_trace(x = ~data_dia, y = ~var_selecionada, name = nome_mutavel,
                        marker = list(color = c(cor_mutavel)), line = list(color = c(cor_mutavel))) |>
              layout(yaxis = list(title = nome_mutavel),
                     xaxis = list(title = paste0("Agrupado por ", nome_tempo)),
                     annotations = list(anotacao_ini, anotacao_fim))
    
    subplot(plot, plot2, nrows = 2, shareX = TRUE) %>% layout(legend = list(orientation = 'h'))

    
  })
  
  output$plot_chuva = renderUI({
    
    dados_aux = dados_grp_esp()
    
    # Para testes
    # dados_aux = cbind(dados_grp_esp@data, dados_grp_esp@coords)
    
    dados_aux = cbind(dados_aux@data, dados_aux@coords)
    
    # print(dados_aux)
    
    #dados_aux = cbind(dados_aux, labels)
    #dados_aux$labels = labels
    
    krig_aux = krigagem()
    
    krig_aux_2 = krigagem_mutavel()
    
    # Para testes
    # krig_aux = krig
    
    raster = data.frame(x = c(krig_aux@coords[,1]), y = c(krig_aux@coords[,2]), z = c(krig_aux$var1.pred))
    raster = raster |> rast()
    crs(raster) = crs("EPSG:4674")
    
    raster_2 = data.frame(x = c(krig_aux_2@coords[,1]), y = c(krig_aux_2@coords[,2]), z = c(krig_aux_2$var1.pred))
    raster_2 = raster_2 |> rast()
    crs(raster_2) = crs("EPSG:4674")
    
    #dominio = c(0, 2)
    
    pallette = colorNumeric("Blues", domain = krig_aux$var1.pred, na.color = "transparent")
    
    mapa = leaflet() |>
             addTiles() |> 
             addRasterImage(raster, colors = pallette, opacity = 0.8) |>
             addLegend(pal = pallette, position = "topright", values = range(krig_aux$var1.pred), title = "Chuva") |>
             setMaxBounds(-58.95, -34.83, -48.41, -26.50)
    
    nome_mutavel = switch(input$var_selecionada,
                          "vento" = "Vento", 
                          "temp" = "Temperatura",
                          "umidade" = "Umidade")
    
    paleta_mutavel = switch(input$var_selecionada,
                            "vento" = "Greens", 
                            "temp" = "OrRd",
                            "umidade" = "PuBuGn")
    
    pallette_2 = colorNumeric(paleta_mutavel, domain = krig_aux_2$var1.pred, na.color = "transparent")
    
    mapa_2 = leaflet() |>
               addTiles() |> 
               addRasterImage(raster_2, colors = pallette_2, opacity = 0.8)|>
               addLegend(pal = pallette_2, position = "topright", values = range(krig_aux_2$var1.pred), title = nome_mutavel) |>
               setMaxBounds(-58.95, -34.83, -48.41, -26.50)
    
    icone = makeIcon("Weather_Icons8.png",iconAnchorX = 4,
                     iconAnchorY = 10)

    if(input$marker_mapa == "padrao"){
    
      labels = faz_labels(dados_aux)
      mapa = mapa |> addMarkers(data = dados_aux, lat = ~lat, lng = ~lon, label = ~lapply(labels, htmltools::HTML), icon = icone)
      mapa_2 = mapa_2 |> addMarkers(data = dados_aux, lat = ~lat, lng = ~lon, label = ~lapply(labels, htmltools::HTML), icon = icone)
      
      sync(mapa, mapa_2)
      
    } else if(input$marker_mapa == "grafico"){
      
      grafico = dados_aux |> select(chuva, vento)
      colors = c("#3093e5", "#fcba50")
      
      mapa = mapa %>%
               addMinicharts(
                 dados_aux$lon, dados_aux$lat,
                 chartdata = grafico,
                 colorPalette = colors,
                 width = 45, height = 45
               )
      
      mapa_2 = mapa_2 %>%
        addMinicharts(
          dados_aux$lon, dados_aux$lat,
          chartdata = grafico,
          colorPalette = colors,
          width = 45, height = 45
        )
      
      sync(mapa, mapa_2)
      
    } else {sync(mapa, mapa_2)}
      
    
  })
  
}