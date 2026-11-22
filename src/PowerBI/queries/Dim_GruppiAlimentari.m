let
    // Percorso del CSV locale sul PC (da aggiornare se il file viene spostato)
    Origine = Csv.Document(File.Contents("C:\Users\Gabs\Documents\Università\Project Management e BI\DashMe\data\raw\Contamination_european_food.csv"), [Delimiter=",", Columns=18, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    IntestazioniPromosse = Table.PromoteHeaders(Origine, [PromoteAllScalars=true]),
    SoloGruppi = Table.SelectColumns(IntestazioniPromosse, {"FoodGroupID", "FoodGroupName"}),
    TipiCorretti = Table.TransformColumnTypes(SoloGruppi, {{"FoodGroupID", Int64.Type}, {"FoodGroupName", type text}}),
    // Una riga per ID: garantisce chiave univoca per la relazione molti-a-uno
    UnaRigaPerID = Table.Distinct(TipiCorretti, {"FoodGroupID"}),
    Ordinati = Table.Sort(UnaRigaPerID, {{"FoodGroupID", Order.Ascending}})
in
    Ordinati