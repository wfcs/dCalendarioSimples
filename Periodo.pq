let
    //Criando função encapsuladora
    fnGerarPeriodos = (Periodo as text, DataInicial as date, DataFinal as date, Ordem as number) =>
    let
        QtdDias = Duration.Days(DataFinal-DataInicial)+1,
        Datas = List.Dates(DataInicial, QtdDias, #duration(1,0,0,0)),
        Cabecalho = type table[Data=date, Periodo= text, Ordem=number],
        Lista = List.Transform(
            Datas,
            each
            {
                _,
                Periodo,
                Ordem
            }
        ),
        Tabela = #table(Cabecalho,Lista)
    in
    Tabela,
    //Data do dia de Hoje
    DataHoje = DateTime.Date(DateTime.LocalNow()),
    //Data do dia de Ontem
    DataOntem = Date.AddDays(DataHoje, -1),
    //Semana Atual
    InicioSemana = Date.StartOfWeek(DataHoje),
    FimSemana = Date.EndOfWeek(DataHoje),
    //Semana Passada
    InicioSemanaPassada = Date.AddDays(InicioSemana, -7),
    FimSemanaPassada = Date.AddDays(FimSemana, 7),
    // Quinzena
    Inicio2Semanas = Date.AddDays(InicioSemanaPassada, -7),
    Fim2Semnas = Date.AddDays(FimSemanaPassada, 7),
    //Mês Atual
    InicioMes = Date.StartOfMonth(DataHoje),
    FimMes = Date.EndOfMonth(DataHoje),
    //Este ano
    InicioAno = Date.StartOfYear(DataHoje),
    FimAno = Date.EndOfYear(DataHoje),

    Intervalos = 
    {
        {"Hoje", DataHoje, DataHoje, 1},
        {"Ontem", DataOntem, DataOntem, 2},
        {"Esta Semana", InicioSemana, FimSemana, 3},
        {"Ultimos 7 Dias", Date.AddDays(DataHoje, -6), DataHoje, 4},
        {"Semana Passada", InicioSemanaPassada, FimSemanaPassada, 5},
        {"15 Dias Atras", Date.AddDays(DataHoje, -14), DataHoje, 6},
        {"Este Mês", InicioMes, FimMes, 7},
        {"Mês Passado", Date.StartOfMonth(Date.AddMonths(DataHoje, -1)), Date.EndOfMonth(Date.AddMonths(DataHoje, -1)), 8},
        {"Ultimos 3 Meses", Date.StartOfMonth(Date.AddMonths(DataHoje, -3)), Date.EndOfMonth(Date.AddMonths(DataHoje, -1)), 9},
        {"Ultimos 6 Meses", Date.StartOfMonth(Date.AddMonths(DataHoje, -6)), Date.EndOfMonth(Date.AddMonths(DataHoje, -1)), 10},
        {"Este Ano", InicioAno, FimAno, 11}
    },
    // Aplicando a função
    Periodos = List.Transform(
        Intervalos,
        each
        fnGerarPeriodos(_{0},_{1},_{2},_{3})
    )
    ,Tabela = Table.Combine(Periodos)
    in
    Tabela