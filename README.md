# Codigos PowerQuery 
> Usados no Power BI e Excel

## Querys

### dCalendario Simples
```pq 

let
    MenorData = #date(2024,1,1),
    MaiorData = #date(2024,9,29),
    DataInicio = Date.StartOfYear(MenorData),
    DataFim = Date.EndOfYear(MaiorData),
    Dias = Duration.Days(DataFim - DataInicio) + 1,
    ListarDatas = List.Dates(DataInicio, Dias, #duration(1, 0, 0, 0)),

    // Criação do índice junto com a tabela
    Tabela = #table(
        type table[
            Índice = Int64.Type,
            Data = date,
            Dia = Int64.Type,
            Ano = Int64.Type,
            NomeMes = text,
            MesAbre = text,
            InicialMes = text,
            MesAno = text,
            MesNum = number,
            AnoMesINT = number,
            InicioMes = date,
            Trimestre = Int64.Type,
            TrimestreAbreviado = text,
            Bimestre = text,
            Semestre = text,
            SemanaMes = Int64.Type,
            DiaSemanaNum = Int64.Type,
            DiaSemana = text
        ],
        List.Transform(
            List.Positions(ListarDatas), 
            each { 
                _ + 1, // Índice começando em 1
                ListarDatas{_}, 
                Date.Day ( ListarDatas{_} ),
                Date.Year(ListarDatas{_}),
                Text.Proper(Date.MonthName(ListarDatas{_})),
                Text.Proper(Text.Start(Date.MonthName(ListarDatas{_}), 3)),
                Text.Repeat ( Character.FromNumber ( 8203 ), 12 - Date.Month(ListarDatas{_}) ) & Text.Start ( Text.Proper ( Date.MonthName ( ListarDatas{_}, "pt-BR" ) ), 1 ),
                Text.Proper(Text.Start(Date.MonthName(ListarDatas{_}), 3)) & "-" & Text.End(Text.From(Date.Year(ListarDatas{_})), 2),
                Date.Month(ListarDatas{_}),
                Date.Year(ListarDatas{_}) * 100 + Date.Month(ListarDatas{_}),
                Date.StartOfMonth(ListarDatas{_}),
                Date.QuarterOfYear(ListarDatas{_}),
                Text.From(Date.QuarterOfYear(ListarDatas{_})) & "º Trim",
                Text.From(Number.RoundUp(Date.Month(ListarDatas{_}) / 2, 0)) & "º Bim",
                Text.From(Number.RoundUp(Date.Month(ListarDatas{_}) / 6, 0)) & "º Sem",
                Date.WeekOfMonth(ListarDatas{_}),
                Date.DayOfWeek(ListarDatas{_}),
                Date.DayOfWeekName(ListarDatas{_})
            }
        )
    )
in
    Tabela![image](https://github.com/user-attachments/assets/981ff8d8-042d-4a18-8bdf-a55147dad2cf)
```

### Juntar/Criar várias colunas de uma só vez

```pq
JuntarColunas = Table.AddColumn(
    LinhasFiltradas, 
    "Tempos", each  
        [
          EntradaFabrica = [Dt Entrada] & [Hr Entrada], 
          #"InicioCarreg." = [DT INI CARGA] & [HR INI CARGA], 
          #"FimCarreg."     = [DT FIM CARGA]& [HR FIM CARGA], 
          CriacaoNota  = [Dt Emissão]& [Hr Criação] 
        ], 
        type [
                EntradaFabrica   = datetime,
                #"InicioCarreg." = datetime, 
                #"FimCarreg."    = datetime, 
                CriacaoNota      = datetime
            ]
  )
```
### Dimensão Hora/Tempo

```pq
let
    Lista = {0..86399},
    ConverteParaTabela = Table.FromList(Lista, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    AlteraTipo = Table.TransformColumnTypes(ConverteParaTabela,{{"Column1", Int64.Type}}),
    AlteraNomeCol = Table.RenameColumns(AlteraTipo,{{"Column1", "Segundo"}}),
    ColDuracao = Table.AddColumn(AlteraNomeCol,"Duração", each #duration(0,0,0,[Segundo]), type duration),
    ColHora = Table.AddColumn(ColDuracao, "Hora", each #time(Duration.Hours([Duração]),Duration.Minutes([Duração]),Duration.Seconds([Duração])), type time),
    RemoveCols = Table.RemoveColumns(ColHora,{"Duração", "Segundo"}),
    ColHoraNum = Table.AddColumn(RemoveCols, "Hora Num", each Time.Hour([Hora]), Int64.Type),
    ColMinutoNum = Table.AddColumn(ColHoraNum, "Minuto Num", each Time.Minute([Hora]), Int64.Type),
    ColSegundoNum = Table.AddColumn(ColMinutoNum, "Segundo Num", each Time.Second([Hora]), Int64.Type),
    ColAMPM = Table.AddColumn(ColSegundoNum,"AMPM", each if [Hora Num] < 12 then "AM" else "PM", type text),
    ColHoraAMPM = Table.AddColumn(ColAMPM, "Hora AMPM", each 
        if [Hora Num] = 0 then "12 AM"
        else if [Hora Num] >= 1 and [Hora Num] <= 11 then Number.ToText([Hora Num]) & " AM" 
        else if [Hora Num] = 12 then "12 PM"
        else if [Hora Num] >= 13 then Number.ToText([Hora Num] - 12) & " PM"  
        else "Unknown", type text),
    ColPeriodo = 
        Table.AddColumn(ColHoraAMPM, "Período", each 
            if        [Hora Num] >= 0 and [Hora Num] <= 5 then "12AM to 6AM"
            else if   [Hora Num] >= 6 and [Hora Num] <= 11 then "6AM to 12PM"
            else if   [Hora Num] >= 12 and [Hora Num] <= 17  then "12PM to 6PM"
            else if   [Hora Num] >= 18 and [Hora Num] <= 23 then "6PM to 12AM"
            else "Unknown", type text
            ),
    ColPeriodoOrdem = 
        Table.AddColumn(ColPeriodo, "Período Ordem", each 
            if        [Hora Num] >= 0 and [Hora Num] <= 5 then 1
            else if   [Hora Num] >= 6 and [Hora Num] <= 11 then 2
            else if   [Hora Num] >= 12 and [Hora Num] <= 17  then 3
            else if   [Hora Num] >= 18 and [Hora Num] <= 23 then 4
            else 5, Int64.Type
        )
in
    ColPeriodoOrdem
```
