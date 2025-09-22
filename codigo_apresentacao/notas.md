# Tópicos

- Porque usar shiny?
    - É bonito & dinâmico
    - Deixa tu mostrar muito mais info quando tu tem mtas vars
    - Da pra por na internet de graça
    - Impressionar pessoas

- Estrutura básica de um shiny
    - ui -> server -> ui
    - input$ e output$
    - Nesting

- Falar sobre banco
    - Site do INMET
    - "faz_banco.R"

- Shiny meteorologia RS
    - Controles básicos & todas as coisas de subsetting
    - Objetos reactive
    - Value boxes (shinyapps)
    - Como é legal usar plotly
    - leaflet & comandos simples pontuais + comandos avançados de raster
    - leafsync & seus usos

# Dicas misc

- Comentar o parênteses que fecha um componente de shiny pra saber em que nível da hierarquia tu ta
- Minimizar computações antes do shiny, ie ter um "faz_banco.R"
- Usar os objetos de "reactive" pra não ter que computar a mesma coisa várias vezes
- Usar outros componentes reativos, plotly, DT::data.table, etc.
- Usar value boxes
