let
    // Listas com IDs para cada dimensão
 EscopoProjeto = {
            {0, "Sem escopo definido"}, 
            {1, "Apenas com diretrizes gerais"}, 
            {2, "Informações suficientes"}, 
            {3, "Escopo detalhado e documentado"}
        },
        MaturidadeCliente = {
            {0, "Baixa"}, 
            {1, "Média"}, 
            {2, "Alta"}
        },
        Tecnologia = {
            {0, "Low Code"}, 
            {1, "Hard Code"}, 
            {2, "Misto"}
        },
        PrazoEntrega = {
            {0, "< 45"}, 
            {1, "45 - 60"}, 
            {2, "61 - 90"}, 
            {3, "> 90"}
        },
        Pagamento = {
            {0, "Antecipado (100%)"}, 
            {1, "Parcial (50/50)"}, 
            {2, "Parcelado (em três ou mais vezes)"}, 
            {3, "1º Pagamento após 45 dias ou mais"}
        },
        Ferramentas = {
            {1, "1"}, 
            {2, "2"}, 
            {3, "3"}, 
            {4, "4"}, 
            {5, "> 5"}
        },
        ClienteNovo = {
            {0, "Não"}, 
            {1, "Sim"}
        },
        Complexidade = {
            {0, "Baixa"}, 
            {1, "Média"}, 
            {2, "Alta"}
        },
        Ambiente = {
            {0, "Casa"}, 
            {1, "Cliente"}
        },
        Engajamento = {
            {0, "Baixo"}, 
            {1, "Médio"}, 
            {2, "Alto"}
        },
        Suporte = {
            {0, "Sem suporte extra"}, 
            {1, "Suporte pontual"}, 
            {2, "Suporte contínuo"}
        },
        Infraestrutura = {
            {0, "Infraestrutura fornecida pelo cliente"}, 
            {1, "Infraestrutura fornecida pela WGG"}
        },
        Treinamento = {
            {0, "Não necessário"}, 
            {1, "Treinamento básico"}, 
            {2, "Treinamento avançado"}
        },
        Riscos = {
            {0, "Baixo"}, 
            {1, "Moderado"}, 
            {2, "Alto"}
        },
        Idioma = {
            {0, "Internacional"}, 
            {1, "Local"}
        },
        Iteracao = {
            {0, "Entrega única"}, 
            {1, "Entregas parciais"}, 
            {2, "Entregas contínuas"}
        },
        Desconto = {
            {0, "5%"}, 
            {1, "10%"}, 
            {2, "12%"}, 
            {3, "15%"}
        },
    EstimativaHoras = List.Transform(List.Numbers(1, 3, 1), each { _ }), // Estimativa ajustável de 1 até 1000 horas

    // Função auxiliar para combinar listas (produzindo listas aninhadas)
    CombinarListas = (lista1 as list, lista2 as list) =>
        List.Combine(
            List.Transform(
                lista1,
                each List.Transform(lista2, (item2) => List.Combine({_, item2}))
            )
        ),

    // Criar combinações passo a passo
    Comb0 = CombinarListas(EscopoProjeto,EstimativaHoras ),
    Comb1 = CombinarListas(MaturidadeCliente,EstimativaHoras ),
    Comb2 = CombinarListas(Tecnologia,EstimativaHoras),
    Comb3 = CombinarListas(PrazoEntrega,EstimativaHoras),
    Comb4 = CombinarListas(Pagamento,EstimativaHoras),
    Comb5 = CombinarListas(Ferramentas,EstimativaHoras),
    Comb6 = CombinarListas(ClienteNovo,EstimativaHoras),
    Comb7 = CombinarListas(Complexidade,EstimativaHoras),
    Comb8 = CombinarListas(Ambiente,EstimativaHoras),
    Comb9 = CombinarListas(Engajamento,EstimativaHoras),
    Comb10 = CombinarListas( Suporte,EstimativaHoras),
    Comb11 = CombinarListas(Infraestrutura,EstimativaHoras),
    Comb12 = CombinarListas(Treinamento,EstimativaHoras),
    Comb13 = CombinarListas(Riscos,EstimativaHoras),
    Comb14 = CombinarListas(Idioma,EstimativaHoras),
    Comb15 = CombinarListas(Iteracao,EstimativaHoras),
    Comb16 = CombinarListas(Desconto,EstimativaHoras),
    CombFinal = List.Combine({Comb0,Comb1,Comb2,Comb3,Comb4,Comb5,Comb6,Comb7,Comb8,Comb9,Comb10,Comb11,Comb12,Comb13,Comb14,Comb15,Comb16 }),

    // Transformar combinações em tabela
    TabelaFinal = Table.FromList(
        CombFinal,
        Splitter.SplitByNothing(),
        {"Combinações"}
    ),
    #"Extracted Values" = Table.TransformColumns(TabelaFinal, {"Combinações", each Text.Combine(List.Transform(_, Text.From), ","), type text}),
    #"Added Custom Column" = Table.AddColumn(#"Extracted Values", "Custom", each let splitCombinações = Splitter.SplitTextByDelimiter(" definido,", QuoteStyle.None)([Combinações]), splitsplitCombinações0 = Splitter.SplitTextByDelimiter(",", QuoteStyle.None)(splitCombinações{0}?) in Text.Combine({Text.Combine(List.Transform(splitCombinações, each Text.Start(_, 2))), splitsplitCombinações0{2}?}), type text),
    #"Added Index" = Table.AddIndexColumn(#"Added Custom Column", "Index", 1, 1, Int64.Type),
    #"Added Custom" = Table.AddColumn(#"Added Index", "Custom2", each 
        List.Sum(
             List.Transform(
                        List.FirstN(#"Added Index"[Custom], [Index]), 
                            each if _ = "0,1" then 1 else 0)
    )
        ),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom",{"Index"}),
    
    // Fonte dos dados (substitua por sua tabela real)
    Fonte = #"Removed Columns",

// Lista de mapeamento entre valores e nomes
    Mapeamento = [
        1 = "EscopoProjeto",
        2 = "MaturidadeCliente",
        3 = "Tecnologia",
        4 = "PrazoEntrega",
        5 = "Pagamento",
        6 = "Ferramentas",
        7 = "ClienteNovo",
        8 = "Complexidade",
        9 = "Ambiente",
        10 = "Engajamento",
        11 = "Suporte",
        12 = "Infraestrutura",
        13 = "Treinamento",
        14 = "Riscos",
        15 = "Idioma",
        16 = "Iteracao",
        17 = "Desconto"
    ],

    // Converte a coluna Custom para texto
    ConverterParaTexto = Table.TransformColumnTypes(Fonte, {{"Custom2", type text}}),

    // Adiciona uma nova coluna mapeando os valores da coluna Custom
    AdicionarColuna = Table.AddColumn(
        ConverterParaTexto,
        "Dimensão",
        each Record.FieldOrDefault(Mapeamento, [Custom2], "Não Mapeado")
    ),
    #"Split Column by Delimiter" = Table.SplitColumn(AdicionarColuna, "Combinações", Splitter.SplitTextByDelimiter(",", QuoteStyle.Csv), {"Combinações.1", "Combinações.2","Combinações.3"})
in
    #"Split Column by Delimiter"
