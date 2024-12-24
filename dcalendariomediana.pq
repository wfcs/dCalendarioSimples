let
  MenorData = #date(2015,03,02), 
  MaiorData = Date.EndOfMonth(DateTime.Date(DateTime.LocalNow())), 
  Dias = Duration.Days(MaiorData - MenorData) + 1, 
  ListarDatas = List.Dates(MenorData, Dias, #duration(1, 0, 0, 0)), 
  ConverterAlterarTipo = Table.TransformColumnTypes(
    Table.FromList(ListarDatas, Splitter.SplitByNothing(), null, null, ExtraValues.Error), 
    {{"Column1", type date}}
  ), 
  tbCalendario = Table.AddColumn(
    ConverterAlterarTipo, 
    "Calendar", 
    each Table.FromRecords(
      {
        [
          Dia               = Date.Day([Column1]), 
          Ano               = Date.Year([Column1]), 
          Num Mês           = Date.Month([Column1]), 
          Mês               = Date.MonthName([Column1]), 
          Mes Abreviado     = Text.Start(Mês, 3), 
          Dia da Semana     = Date.DayOfWeekName([Column1]), 
          Num Dia da Semana = Date.DayOfWeek([Column1])
        ]
      }
    )
  ), 
  CalendarExpandido = Table.ExpandTableColumn(
    tbCalendario, 
    "Calendar", 
    {"Dia", "Ano", "Num Mês", "Mes Abreviado", "Dia da Semana", "Num Dia da Semana"}, 
    {"Dia", "Ano", "Num Mês", "Mes Abrevido", "Dia da Semana", "Num Dia da Semana"}
  ), 
  Ajustes = Table.RenameColumns(
    Table.TransformColumnTypes(
      CalendarExpandido, 
      {
        {"Column1", type date}, 
        {"Dia", Int64.Type}, 
        {"Ano", Int64.Type}, 
        {"Num Mês", Int64.Type}, 
        {"Mes Abrevido", type text}, 
        {"Dia da Semana", type text}, 
        {"Num Dia da Semana", Int64.Type}
      }
    ), 
    {{"Column1", "Data"}}
  ), 
  ColunasRenomeadas = Table.RenameColumns(Ajustes, {{"Mes Abrevido", "Mes"}}), 
  NumMesManu = Table.AddColumn(
    ColunasRenomeadas, 
    "MesFolhaManu", 
    each 
      let
        MêsNovo  = if [Dia] >= 1 and [Dia] < 21 then [Num Mês] else [Num Mês] + 1, 
        MêsNovo2 = if MêsNovo > 12 then 1 else MêsNovo
      in
        MêsNovo2
  ), 
  MesManu = Table.AddColumn(
    Table.AddColumn(
      NumMesManu, 
      "DataMêsfolha", 
      each Text.Combine({Text.From([Dia], "pt-BR"), Text.From([MesFolhaManu], "pt-BR")}, "/"), 
      type date
    ), 
    "MêsFolhaNome", 
    each "Mês: " & Date.MonthName([DataMêsfolha]), 
    type text
  ), 
  #"Preenchido Abaixo" = Table.FillUp(
    Table.ReplaceErrorValues(MesManu, {{"MêsFolhaNome", null}}), 
    {"MêsFolhaNome"}
  ), 
  AnoManu = Table.AddColumn(
    #"Preenchido Abaixo", 
    "AnoManu", 
    each 
      let
        MêsNovo = if [Dia] >= 1 and [Dia] < 21 then [Num Mês] else [Num Mês] + 1, 
        AnoNovo = if MêsNovo > 12 then [Ano] + 1 else [Ano]
      in
        AnoNovo
  ), 
  #"Colunas Removidas" = Table.RemoveColumns(AnoManu, {"DataMêsfolha"}), 
  DiaMesManu = Table.AddColumn(
    #"Colunas Removidas", 
    "Dia-mês-Manu", 
    each Number.ToText([Dia]) & "/" & Number.ToText([Num Mês]), 
    type text
  ), 
  #"Valor Substituído" = Table.ReplaceValue(
    DiaMesManu, 
    13, 
    12, 
    Replacer.ReplaceValue, 
    {"MesFolhaManu"}
  ), 
  #"Colunas Renomeadas" = Table.RenameColumns(#"Valor Substituído", {{"MêsFolhaNome", "Mês Folha"}}), 
  #"Tipo Alterado" = Table.TransformColumnTypes(
    #"Colunas Renomeadas", 
    {{"MesFolhaManu", Int64.Type}}
  ), 
  MesManuAbrev = Table.AddColumn(
    #"Tipo Alterado", 
    "NomeMesManu", 
    each Text.Middle([Mês Folha], 5, 3), 
    type text
  ), 
  NumMesRH = Table.AddColumn(
    MesManuAbrev, 
    "MêsFolhaRH", 
        each 
      let
        MêsNovo  = if [Dia] >= 1 and [Dia] < 10 then [Num Mês] else [Num Mês] + 1, 
        MêsNovo2 = if MêsNovo > 12 then 1 else MêsNovo
      in
        MêsNovo2, 
    Int64.Type
  ), 
  DiaMesRH = Table.AddColumn(
    NumMesRH, 
    "Mês Folha RH", 
    each Text.Combine({Text.From([Dia], "pt-BR"), Text.From([MêsFolhaRH], "pt-BR")}, "/")
  ), 
  MesRH = Table.AddColumn(DiaMesRH, "NomeMêsRH", each Text.Start( Date.MonthName([Mês Folha RH]), 3 )), 
  #"Erros Substituídos" = Table.ReplaceErrorValues(MesRH, {{"NomeMêsRH", null}}), 
  #"Preenchido Acima" = Table.FillUp(#"Erros Substituídos", {"NomeMêsRH"}), 
  DiaMes = Table.AddColumn(
    #"Preenchido Acima", 
    "Dia-Mês-RH", 
    each Text.BeforeDelimiter(Text.From([Data], "pt-BR"), "/", 1), 
    type text
  ),
  AnoRH = Table.AddColumn(
    DiaMes,
    "AnoRH",
    each
        let
        MêsNovo = if [Dia] >= 1 and [Dia] < 10 then [Num Mês] else [Num Mês] + 1, 
        AnoNovo = if MêsNovo > 12 then [Ano] + 1 else [Ano]
      in
        AnoNovo
  ),
    #"Colunas Removidas1" = Table.RemoveColumns(AnoRH,{"Dia da Semana", "Num Dia da Semana"})
in
    #"Colunas Removidas1"
