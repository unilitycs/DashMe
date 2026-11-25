let
    Origine = Csv.Document(File.Contents("C:\Users\Gabs\Documents\Università\Project Management e BI\DashMe\data\raw\Contamination_european_food.csv"),[Delimiter=",", Columns=18, Encoding=1252, QuoteStyle=QuoteStyle.None]),
        IntestazioniPromosse = Table.PromoteHeaders(Origine, [PromoteAllScalars=true]),
    
        // 2. ETL: Rimozione colonne 100% ridondanti (GEMSFoodName, RegionCode, UnitName) e testi spostati nelle Dimensioni
        RimosseColonneRidondanti = Table.RemoveColumns(IntestazioniPromosse, {
            "GEMSFoodName", "RegionCode", "UnitName", 
            "CountryName", "FoodGroupName", "ContaminantName"
        }),
    
        // 3. ETL: Conversione Tipi Numerici (Importante: "en-US" su ResultValue perché i decimali usano il punto ".")
        TipiInteri = Table.TransformColumnTypes(RimosseColonneRidondanti, {
            {"ContaminationIndividualID", Int64.Type},
            {"FoodID", Int64.Type},
            {"FoodGroupID", Int64.Type},
            {"CountryID", Int64.Type},
            {"ContaminantID", Int64.Type},
            {"UnitID", Int64.Type},
            {"Year", Int64.Type}
        }),
        TipoResultValue = Table.TransformColumnTypes(TipiInteri, {{"ResultValue", type number}}, "en-US"),
    
        // 4. ETL: Pulizia spazi bianchi iniziali su SerialNumber (es. "             2467839") e stringhe vuote -> null
        SerialNumberPulito = Table.TransformColumns(TipoResultValue, {
            {"SerialNumber", each if _ = null then null else let t = Text.Trim(_) in if t = "" then null else t, type text}
        }),
    
        // 5. ETL: Creazione Esito Analisi (separa i 959.424 Positivi > LOD dagli 1.461.721 Zeri < LOD e 3.330 Null)
        AggiuntoEsitoAnalisi = Table.AddColumn(SerialNumberPulito, "Esito Analisi", each 
            if [ResultValue] = null then "Dato Mancante (Null)"
            else if [ResultValue] = 0 then "Non Rilevato (< LOD)"
            else "Positivo Rilevato (> LOD)", type text),
    
        // 6. ETL: Flag Binario 1/0 per i conteggi rapidi
        AggiuntoFlagPositivo = Table.AddColumn(AggiuntoEsitoAnalisi, "Is_Positive", each 
            if [ResultValue] <> null and [ResultValue] > 0 then 1 else 0, Int64.Type),
    
        // 7. ETL: Discretizzazione in 6 Fasce di Concentrazione Logaritmica (µg/kg)
        AggiuntaFasciaConcentrazione = Table.AddColumn(AggiuntoFlagPositivo, "Fascia Concentrazione", each 
            if [ResultValue] = null then "0. Dato Mancante"
            else if [ResultValue] = 0 then "1. Assente / < LOD (0 µg/kg)"
            else if [ResultValue] <= 1 then "2. Ultra-Tracce (0–1)"
            else if [ResultValue] <= 10 then "3. Tracce Basse (1–10)"
            else if [ResultValue] <= 100 then "4. Moderata (10–100)"
            else if [ResultValue] <= 1000 then "5. Elevata (100–1.000)"
            else "6. Critica (>1.000)", type text)
    in
        AggiuntaFasciaConcentrazione
