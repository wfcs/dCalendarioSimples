let
    ListaFeriados = 
         let
            // Definindo o ano inicial para a geração das datas
            AnoInicial = 2024,

            // Usando List.Generate para criar uma lista de anos de 2024 até 2050
            ListaDeDatas = List.Generate(
                () => AnoInicial,          // Valor inicial: ano 2024
                each _ <= 2050,            // Condição de parada: enquanto o ano for menor ou igual a 2050
                each _ + 1                 // Incremento: soma 1 ao ano para gerar o próximo ano
            ),

            // Convertendo a lista de anos em uma tabela de texto
            Source = Table.FromList(List.Transform(ListaDeDatas, Text.From), Splitter.SplitByNothing(), {"Ano"}),

            // Adicionando uma coluna "Custom" para acessar o conteúdo da página web de feriados
            // A URL será construída a partir do ano, substituindo [Column1] pelo valor de cada linha
            AddedCustomColumn = Table.AddColumn(Source, "Custom", 
                each Web.BrowserContents("https://www.anbima.com.br/feriados/fer_nacionais/" & [Ano] & ".asp")
            ),

            // Transformando a coluna "Custom" que contém conteúdo HTML em tabelas,
            // promovendo cabeçalhos e extraindo as colunas necessárias: "Data", "Dia da Semana", e "Feriado"
            Custom1 = Table.TransformColumns(AddedCustomColumn, {
                "Custom", 
                each Table.PromoteHeaders(
                    Html.Table(_, {
                        {"Data", "TABLE.interna > * > TR > :nth-child(1)"},      // Seleciona a primeira coluna (Data)
                        {"DiaDaSemana", "TABLE.interna > * > TR > :nth-child(2)"}, // Seleciona a segunda coluna (Dia da Semana)
                        {"Feriado", "TABLE.interna > * > TR > :nth-child(3)"}      // Seleciona a terceira coluna (Feriado)
                    }, 
                    [RowSelector="TABLE.interna > * > TR"]
                ) ) } ),

            // Expandindo a coluna "Custom" para incluir as colunas extraídas: "Data", "Dia da Semana" e "Feriado"
            ExpandedCustomColumn = Table.ExpandTableColumn(Custom1, "Custom", {"Data", "Dia da Semana", "Feriado"}),

            // Adicionando uma nova coluna "Tipo Dia", definindo o valor "dia não útil" para todos os registros
            AddedTipoDiaColumn = Table.AddColumn(ExpandedCustomColumn, "Tipo Dia", each "Dia Não Útil"),

            // Alterando os tipos de dados das colunas para os tipos apropriados
            ChangedColumnTypes = Table.TransformColumnTypes(AddedTipoDiaColumn, {
                {"Data", type date},           // Convertendo "Data" para o tipo date
                {"Dia da Semana", type text},  // Convertendo "Dia da Semana" para o tipo text
                {"Ano", Int64.Type},       // Convertendo "Column1" para o tipo Int64 (se necessário)
                {"Feriado", type text},        // Convertendo "Feriado" para o tipo text
                {"Tipo Dia", type text}        // Convertendo "Tipo Dia" para o tipo text
            })[Data]

        in
     List.Buffer( ChangedColumnTypes ),
    MenorData = #date(2024,1,1),
    MaiorData =  Date.AddDays( DateTime.Date(DateTime.LocalNow()), -1 ),
    ListarDatas = 
        List.Generate(
		() => MenorData , // Valor inicial
        each _ <= MaiorData, // Condição: enquanto a data for menor ou igual a 10 de janeiro de 2023
		each Date.AddDays(_, 1)  // Próximo valor: adiciona 1 dia à data máxima 
        ),
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
            SemanaAno = Int64.Type,
            SemanaMes = Int64.Type,
            DiaSemanaNum = Int64.Type,
            DiaSemana = text,
            DiaUtil = text
        ],
        List.Transform(
            List.Positions(ListarDatas), 
            each { 
                // Índice: cada linha da tabela vai receber um número único, começando de 1
                _ + 1, 
                ListarDatas{_}, 
                // Dia: extrai o número do dia da data (1 a 31)
                Date.Day ( ListarDatas{_} ),
                // Ano: extrai o ano da data
                Date.Year(ListarDatas{_}),
                // Nome do mês: converte o nome do mês para formato capitalizado (ex.: Janeiro, Fevereiro, etc.)
                Text.Proper(Date.MonthName(ListarDatas{_})),
                // Abreviação do mês: utiliza as três primeiras letras do nome do mês
                Text.Proper(Text.Start(Date.MonthName(ListarDatas{_}), 3)),
                // Inicial do mês: o mês é representado por um texto contendo a inicial do nome do mês em português
                Text.Repeat ( Character.FromNumber ( 8203 ), 12 - Date.Month(ListarDatas{_}) ) & Text.Start ( Text.Proper ( Date.MonthName ( ListarDatas{_}, "pt-BR" ) ), 1 ),
                // Formato Mês-Ano: cria um texto no formato "MMM-YY" (ex.: Jan-24)
                Text.Proper(Text.Start(Date.MonthName(ListarDatas{_}), 3)) & "-" & Text.End(Text.From(Date.Year(ListarDatas{_})), 2),
                // Número do mês: número do mês (1 a 12)
                Date.Month(ListarDatas{_}),
                 // Ano-Mês: um código numérico representando o ano e o mês (ex.: 202401)
                Date.Year(ListarDatas{_}) * 100 + Date.Month(ListarDatas{_}),
                // Início do mês: calcula a data do primeiro dia do mês
                Date.StartOfMonth(ListarDatas{_}),
                // Trimestre: identifica em que trimestre do ano a data se encontra (1 a 4)
                Date.QuarterOfYear(ListarDatas{_}),
                // Trimestre abreviado: exibe o trimestre de forma abreviada (ex.: "1º Trim")
                Text.From(Date.QuarterOfYear(ListarDatas{_})) & "º Trim",
                // Bimestre: identifica em qual bimestre o mês pertence (1 a 6)
                Text.From(Number.RoundUp(Date.Month(ListarDatas{_}) / 2, 0)) & "º Bim",
                // Semestre: identifica o semestre do ano (1º ou 2º)
                Text.From(Number.RoundUp(Date.Month(ListarDatas{_}) / 6, 0)) & "º Sem",
                // Semana do ano: número da semana no ano (1 a 53)
                Date.WeekOfYear(ListarDatas{_}),
                // Semana do mês: número da semana dentro do mês
                Date.WeekOfMonth(ListarDatas{_}),
                // Dia da semana numérico: representa o dia da semana (0 a 6, sendo 0 = Domingo)
                Date.DayOfWeek(ListarDatas{_}),
                // Nome do dia da semana: exibe o nome do dia da semana (ex.: "Seg")
                Text.Start( Date.DayOfWeekName(ListarDatas{_}), 3 ),
                // Tipo de dia: determina se o dia é útil ou não, considerando os feriados e finais de semana
                if List.Contains(ListaFeriados,ListarDatas{_}) or Date.DayOfWeek(ListarDatas{_}) = 0  then "Dia não útil" else "Dia útil"
            }
        )
    )
in
    Tabela
