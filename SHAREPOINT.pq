let
  Fonte = Table.SelectRows(
    SharePoint.Contents("https://unidasti.sharepoint.com/sites/UnidasImpeatriz/", [ApiVersion = 15])
    {[Name = "Documentos Compartilhados"]}[Content]{[Name = "Arquivos Transporte Suzano Imperatriz"]}[Content][[Content], [Extension],[Date created]], 
    each [Extension] = ".xlsx" or [Extension] = ".XLSX"
  )[[Content],[Date created]],
    #"Tipo Alterado" = Table.TransformColumnTypes(Fonte,{{"Date created", type datetime}}),
    #"Linhas Filtradas" = Table.SelectRows(#"Tipo Alterado", each [Date created] >= RangeStart and [Date created] < RangeEnd),
    Excel.Workbook = Table.RemoveRowsWithErrors(
    Table.TransformColumns(#"Linhas Filtradas", {"Content", each Excel.Workbook(_, true)[Data]{0}}), 
    {"Content"}
  ), 
  ColunaAjustes = Table.TransformColumns(
    Table.TransformColumns(
      Excel.Workbook, 
      {
        "Content", 
        each Table.SelectColumns(
          _, 
          {
            "Região", "Volume", "TpDepOGM", "UP", "Nº ORM", "Dt Entrada", "Hr Entrada", "Permanência", "Placa CM", 
            "Nome Transportador", "Espécie", "Tmp Carga Campo", "Peso Inicial", "Peso Liquido", "KM", "KM Asfalto", 
            "KM Terra", "DT INI CARGA", "HR INI CARGA", "DT FIM CARGA", "HR FIM CARGA", "Dt Emissão", "Hr Criação"
          }
        )
      }
    ), 
    {"Content", Table.Distinct}
  ),
    BaseCombinada = Table.Combine ( ColunaAjustes[Content] ), 
  LinhasFiltradas = Table.SelectRows(
    BaseCombinada, 
    each (
      Text.Contains( [Nome Transportador],  "OURO VERDE") or 
      Text.Contains( [Nome Transportador], "UNIDAS" )
    )
  ), 
  Bufferizado = Table.Buffer(LinhasFiltradas), 
  TipoAlterado = Table.TransformColumnTypes(
    Table.SelectRows(Bufferizado, each ([Dt Entrada] <> null)), 
    {
      {"Região", type text}, {"Volume", type number}, {"TpDepOGM", type text}, {"UP", type text}, 
      {"Nº ORM", Int64.Type}, {"Dt Entrada", type date}, {"Hr Entrada", type time}, {"Placa CM", type text}, 
      {"Espécie", type text}, {"Peso Inicial", Int64.Type}, {"Peso Liquido", Int64.Type}, {"KM", type number}, 
      {"Dt Emissão", type date}, {"Hr Criação", type time}, {"Permanência", type time}, {"Tmp Carga Campo", type time}, 
      {"DT INI CARGA", type date}, {"HR INI CARGA", type time}, {"DT FIM CARGA", type date}, {"HR FIM CARGA", type time}
    }
  ), 
  ConsultasMescladas = Table.NestedJoin(
    TipoAlterado, 
    {"Nº ORM"}, 
    fApisul, 
    {"Doc. Controle"}, 
    "fApisul", 
    JoinKind.LeftOuter
  ), 
  fApisulExp = Table.ExpandTableColumn(
    ConsultasMescladas, 
    "fApisul", 
    {"Entrada Destino", "Saída Destino", "Início Previsto", "TempoFazenda"}, 
    {"Entrada Destino", "Saída Destino", "Início Previsto", "TempoFazenda"}
  ), 
  Ciclos = Table.AddColumn(
    fApisulExp, 
    "Personalizar", 
    each Table.FromRecords(
      {
        [
          CicloNota      = Ciclo([Dt Entrada], [Hr Entrada], [Dt Emissão], [Hr Criação]), 
          CicloCarregado = Duration.TotalSeconds(([Dt Entrada] & [Hr Entrada]) - [Saída Destino]), 
          CicloVazio     = Duration.TotalSeconds([Entrada Destino] - ([Dt Emissão] & [Hr Criação])), 
          TempoDescarga  = HorasEmDecimal([Permanência]), 
          TempoCarga     = HorasEmDecimal([Tmp Carga Campo])
        ]
      }
    ), 
    type number
  ), 
  CiclosExpandido = Table.ExpandTableColumn(
    Ciclos, 
    "Personalizar", 
    {"CicloCarregado", "CicloNota", "CicloVazio", "TempoCarga", "TempoDescarga"}, 
    {"CicloCarregado", "CicloNota", "CicloVazio", "TempoCarga", "TempoDescarga"}
  ), 
  DuplicatasRemovidas = Table.Distinct(CiclosExpandido, {"Nº ORM"})[
    [Região], 
    [Volume], 
    [TpDepOGM], 
    [UP], 
    [Nº ORM], 
    [Dt Entrada], 
    [Placa CM], 
    [Espécie], 
    [Peso Inicial], 
    [Peso Liquido], 
    [KM], 
    [KM Asfalto], 
    [KM Terra], 
    [TempoFazenda], 
    [CicloCarregado], 
    [CicloNota], 
    [CicloVazio], 
    [TempoCarga], 
    [TempoDescarga]
  ], 
  ColunasMescladas = Table.CombineColumns(
    DuplicatasRemovidas, 
    {"TpDepOGM", "UP"}, 
    Combiner.CombineTextByDelimiter("", QuoteStyle.None), 
    "UP"
  ), 
  Expandido = Table.ExpandTableColumn(
    Table.NestedJoin(
      ColunasMescladas, 
      {"Espécie"}, 
      CadFazendas, 
      {"FAZENDA1"}, 
      "CadFazendas", 
      JoinKind.LeftOuter
    ), 
    "CadFazendas", 
    {"ID_FAZENDA"}, 
    {"ID_FAZENDA"}
  ), 
  TipoAlterado1 = Table.TransformColumnTypes(
    Expandido, 
    {
      {"KM Asfalto", type number}, 
      {"KM Terra", type number}, 
      {"TempoFazenda", Int64.Type}, 
      {"CicloCarregado", Int64.Type}, 
      {"CicloNota", Int64.Type}, 
      {"CicloVazio", Int64.Type}, 
      {"TempoCarga", Int64.Type}, 
      {"TempoDescarga", Int64.Type}
    }
  )
in
    TipoAlterado1
