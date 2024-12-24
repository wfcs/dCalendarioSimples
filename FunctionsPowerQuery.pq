(DataNascimento as date) =>
let
    DataAtual =     
    let
        Data = DateTime.Date(DateTime.LocalNow()),
        Dia = Date.Day(Data),
        Mes = Date.Month(Data)-3,
        Ano = Date.Year(Data)
    in
        Text.From(Ano)&"-"&Text.From(Mes)&"-"&Text.From(1),
    DataConvert = 
        Date.FromText(DataAtual),
    idade = 
        Duration.TotalDays(
            (DataConvert - DataNascimento)
        ) / 365
in
    Number.Round(idade,0)

//----------------------------------------------------------------------------------------------------------------------------//-----------------------------------------------------------------------------------------------------------//

= 
(ColunaHora) =>
let
    
  Hora = Int64.From(Text.BeforeDelimiter(ColunaHora,":")) * 3600,
  Minuto = Int64.From(Text.BetweenDelimiters(ColunaHora,":",":")) * 60,
  Segundo = Int64.From(Text.AfterDelimiter(ColunaHora, ":",1)),
  Tempo = try Hora + Minuto + Segundo otherwise null
    
in
   Tempo

//----------------------------------------------------------------------------------------------------------------------------//-----------------------------------------------------------------------------------------------------------//

IntervaloDatas : 

(DataInicio as date, DataFim as date) =>
let
    
    Intervalo = try if DataFim = null  then {0..Duration.Days( DateTime.Date( DateTime.LocalNow() ) - DataInicio)} else {0..Duration.Days(DataFim  - DataInicio)}  otherwise null
in
    Intervalo

//----------------------------------------------------------------------------------------------------------------------------//-----------------------------------------------------------------------------------------------------------//

FxHoras 

(InicioParada as datetime, FimParada as datetime, DataExpandida as date, Lista as number) =>
  let
    Hora = Text.From(Time.Hour(DateTime.LocalNow())), 
    Minuto = Text.From(Time.Minute(DateTime.LocalNow())), 
    Segundo = Text.From(Int32.From(Time.Second(DateTime.LocalNow()))), 
    Horas = Text.Combine({Hora, Minuto, Segundo}, ":"), 
    DataNova = DataExpandida, 
    DataHoje = DateTime.Date(DateTime.LocalNow()), 
    DataHoraInicio = DataNova & Time.From("00:00:00"), 
    DataHoraFim = DataNova & Time.From("23:59:59"), 
    DataConclusao = if FimParada = null then DataHoje & Horas else FimParada, 
    DataParada = if InicioParada = null then DataHoje & Time.From("00:00:00") else InicioParada, 
    Maior = List.Max({0 .. Duration.Days(DataConclusao - DataConclusao)}), 
    Total = Duration.TotalHours(
      if Lista = 0 and DateTime.Date(InicioParada) = DateTime.Date(FimParada) then
        FimParada - InicioParada
      else if Lista = 0 and DateTime.Date(InicioParada) <> DateTime.Date(FimParada) then
        DataHoraFim - InicioParada
      else if DateTime.Date(FimParada) = DateTime.Date(DataNova) then
        FimParada - DataHoraInicio
      else
        DataHoraFim - DataHoraInicio
    )
  in
    Number.Round( Total, 4 )


//----------------------------------------------------------------------------------------------------------------------------//-----------------------------------------------------------------------------------------------------------//


fxListasDias

(DatadaParada as datetime, DataConclusao as datetime) as list => 
 
let
 
Dias = if DataConclusao = null 
        then {0..Duration.Days( DateTime.LocalNow()  - DatadaParada)} 
        else {0..Duration.Days(DataConclusao  - DatadaParada)}
 
in
 
Dias


//----------------------------------------------------------------------------------------------------------------------------//-----------------------------------------------------------------------------------------------------------//



fxJornada

= (Entrada , Saida)  => 
let
    VarHoras = DateTime.Time(#datetime(2022, 12, 31, 23, 59, 59)),
    Conta = 
         if Saida < Entrada then 
            (VarHoras - Entrada) + Saida else 
        Saida - Entrada 
in
    Conta

//----------------------------------------------------------------------------------------------------------------------------//-----------------------------------------------------------------------------------------------------------//
