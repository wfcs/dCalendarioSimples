# dCalendario Simples

Um script M para criar uma tabela de calendário detalhada no Power Query, ideal para análises temporais em Power BI. Ele gera uma tabela com diversas informações de data, como nome do mês, trimestres, semanas, e outras colunas úteis para segmentação e agregação de dados.

## 📋 Funcionalidades

- Geração de datas entre um intervalo definido.
- Colunas derivadas, como:
  - Nome e abreviação do mês.
  - Ano e número do mês.
  - Número e nome do dia da semana.
  - Trimestre, bimestre e semestre.
  - Semana no mês.
- Compatibilidade com formatos e nomes em português (pt-BR).

## 🔧 Requisitos

- **Power BI Desktop** ou qualquer ferramenta compatível com **Power Query**.
- Versão mínima do Power BI para suportar scripts M modernos.

## 🚀 Como usar

1. **Copie o script**:
   Copie o código do arquivo `dCalendarioSimples.m` (fornecido neste repositório).

2. **Cole no Editor de Consultas**:
   - Abra o Power BI.
   - No Editor de Consultas, clique em **Nova Fonte** > **Consulta em Branco**.
   - Acesse **Exibir Avançado** e cole o script.

3. **Edite o intervalo de datas (opcional)**:
   - Ajuste as variáveis `MenorData` e `MaiorData` para definir o intervalo de geração.

4. **Carregue os dados**:
   Clique em **Fechar e Aplicar** para carregar a tabela de calendário no modelo.

## 📜 Estrutura da Tabela

| Coluna              | Tipo        | Descrição                                           |
|---------------------|-------------|---------------------------------------------------|
| `Índice`           | Número      | Identificador único para cada data.               |
| `Data`             | Data        | Data específica no intervalo definido.            |
| `Dia`              | Número      | Dia do mês.                                        |
| `Ano`              | Número      | Ano da data.                                       |
| `NomeMes`          | Texto       | Nome completo do mês (ex.: Janeiro).              |
| `MesAbre`          | Texto       | Abreviação do mês (ex.: Jan).                     |
| `InicialMes`       | Texto       | Primeira letra do mês.                            |
| `MesAno`           | Texto       | Abreviação do mês e ano (ex.: Jan-24).            |
| `MesNum`           | Número      | Número do mês (1-12).                             |
| `AnoMesINT`        | Número      | Ano e mês no formato `yyyymm` (ex.: 202401).      |
| `InicioMes`        | Data        | Primeira data do mês.                             |
| `Trimestre`        | Número      | Trimestre do ano (1-4).                           |
| `TrimestreAbreviado` | Texto     | Nome do trimestre (ex.: 1º Trim).                 |
| `Bimestre`         | Texto       | Nome do bimestre (ex.: 1º Bim).                   |
| `Semestre`         | Texto       | Nome do semestre (ex.: 1º Sem).                   |
| `SemanaMes`        | Número      | Semana no mês.                                    |
| `DiaSemanaNum`     | Número      | Número do dia da semana (0=domingo, 6=sábado).    |
| `DiaSemana`        | Texto       | Nome do dia da semana (ex.: Segunda-feira).       |

## 🛠️ Personalização

- **Intervalo de datas**: Modifique `MenorData` e `MaiorData` para atender às suas necessidades.
- **Nomes e formatos**: O script utiliza configurações regionais de `pt-BR`, mas pode ser adaptado para outros idiomas.

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE). Sinta-se à vontade para usá-lo e adaptá-lo conforme necessário.

---

Feito com ❤️ e Power Query!
