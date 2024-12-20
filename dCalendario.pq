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
    Tabela
