let
    dataini = 
    let
        Data = DateTime.Date(DateTime.LocalNow()),
        Dia = Date.Day(Data),
        Mes = Date.Month(Data)-3,
        Ano = Date.Year(Data)
        in
        Text.From(Ano)&"-"&Text.From(Mes)&"-"&Text.From(1)&" 00:00:00"
    ,
    dataf = 
        let
        Data = Date.From(DateTimeZone.SwitchZone(DateTimeZone.LocalNow(),-3)),
        Dia = Date.Day(Data),
        Mes = Date.Month(Data),
        Ano = Date.Year(Data)
        in
        Text.From(Ano)&"-"&Text.From(Mes)&"-"&Text.From(Dia)&" 23:59:59",
    Fonte = 
    MySQL.Database(
            "172.17.0.4", "mclient", [ReturnSingleDatabase=true, 
            Query= "SELECT DATE(lcpi_data_ini) as DATA_REFERENCIA,
            cmta_login as ID_MOTORISTA,
            lcpo_funcionario as NOME,
            cvei_placa as PLACA,
            time_format(timediff(lcpi_data_fim, lcpi_data_ini),'%H:%i:%s') AS TEMPO_TOTAL,
            time_format(sec_to_time(lcpi_hora_movimento),'%H:%i:%s') AS TEMPO_MOVIMENTACAO,
            time_format(sec_to_time(lcpi_hora_direcao),'%H:%i:%s') AS MAXIMO_DIRECAO_CONTINUA,
            time_format(sec_to_time(lcpi_hora_refeicao),'%H:%i:%s') as REFEICAO_TEMPO,
            if((sec_to_time(lcpi_hora_refeicao)) >= '00:00:01' , 'SIM' , 'NAO') as REFEICAO,
            time_format(sec_to_time(lcpi_hora_carrega),'%H:%i:%s') as TEMPO_CARREGAMENTO,
            time_format(sec_to_time(lcpi_hora_descarrega),'%H:%i:%s') as TEMPO_DESCARREGAMENTO,
            time_format(sec_to_time((time_to_sec(timediff(lcpi_data_fim, lcpi_data_ini)))-(lcpi_hora_movimento)),'%H:%i:%s') AS TEMPO_PARADO
            from log_cartao_ponto_item
            inner join log_cartao_ponto on lcpo_id = lcpi_lcpo_id
            inner join ctl_motorista_ativo on lcpo_cmta_id = cmta_id
            inner join log_cartao_ponto_item_veiculo on lcpv_lcpi_id = lcpi_id
            inner join cad_veiculo on lcpv_cvei_id = cvei_id
            inner join ctl_veiculo_grupo on cvgr_cvei_id = cvei_id
            where lcpi_data_ini >= '"& dataini &"' and lcpi_data_ini <= '"& dataf &"' AND cvgr_cgru_id = 1 
            GROUP BY lcpi_id, cmta_login, cmta_nome, cmta_id, lcpi_data_ini, lcpi_data_fim
            ORDER BY cmta_nome, lcpi_data_ini"]),
    Calculo.Tempos = Table.AddColumn(Fonte, "CalculoTempos", each Table.FromRecords({[
    HorasTrabalhadas = HorasEmDecimal([TEMPO_TOTAL]),
    TempoDirecao = HorasEmDecimal([MAXIMO_DIRECAO_CONTINUA]),
    TempoRefeicao = HorasEmDecimal([REFEICAO_TEMPO]),
    TempoCarregamento = HorasEmDecimal([TEMPO_CARREGAMENTO]),
    TempoDescarga = HorasEmDecimal([TEMPO_DESCARREGAMENTO]),
    TempoMovimentacao = HorasEmDecimal([TEMPO_MOVIMENTACAO]),
    TempoParado = HorasEmDecimal([TEMPO_PARADO])
]})),
    Calculo.Expandido = 
    Table.ExpandTableColumn(Calculo.Tempos, 
    "CalculoTempos", {"HorasTrabalhadas", "TempoDirecao", "TempoRefeicao", "TempoCarregamento", "TempoDescarga", "TempoMovimentacao", "TempoParado"}, 
    {"HorasTrabalhadas", "TempoDirecao", "TempoRefeicao", "TempoCarregamento", "TempoDescarga", "TempoMovimentacao", "TempoParado"}),
    Outras.Colunas.Removidas = 
    Table.SelectColumns(Calculo.Expandido,
    {"DATA_REFERENCIA", "ID_MOTORISTA", "NOME", "PLACA", "HorasTrabalhadas", "TempoDirecao", "TempoRefeicao", "TempoCarregamento", "TempoDescarga", "TempoMovimentacao", "TempoParado"}),
    Tipo.Alterado = 
    Table.TransformColumnTypes(Outras.Colunas.Removidas,
    {{"DATA_REFERENCIA", type date}, {"HorasTrabalhadas", type number}, {"TempoDirecao", type number}, {"TempoRefeicao", type number}, 
    {"TempoCarregamento", type number}, {"TempoDescarga", type number}, {"TempoMovimentacao", type number}, {"TempoParado", type number}})
in
    Tipo.Alterado
