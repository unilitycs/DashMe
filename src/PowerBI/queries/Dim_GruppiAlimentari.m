let
    // Percorso del CSV locale sul PC (da aggiornare se il file viene spostato)
    Origine = Csv.Document(File.Contents("C:\Users\Gabs\Documents\Università\Project Management e BI\DashMe\data\raw\Contamination_european_food.csv"), [Delimiter=",", Columns=18, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    IntestazioniPromosse = Table.PromoteHeaders(Origine, [PromoteAllScalars=true]),
    SoloGruppi = Table.SelectColumns(IntestazioniPromosse, {"FoodGroupID", "FoodGroupName"}),
    TipiCorretti = Table.TransformColumnTypes(SoloGruppi, {{"FoodGroupID", Int64.Type}, {"FoodGroupName", type text}}),
    // Una riga per ID: garantisce chiave univoca per la relazione molti-a-uno
    UnaRigaPerID = Table.Distinct(TipiCorretti, {"FoodGroupID"}),
    Ordinati = Table.Sort(UnaRigaPerID, {{"FoodGroupID", Order.Ascending}}),

    // Traduzione italiana dei gruppi alimentari (chiave = FoodGroupID)
    Traduzioni = [
        #"1"  = "Cereali e prodotti a base di cereali",
        #"2"  = "Ortaggi e prodotti vegetali (funghi inclusi)",
        #"3"  = "Radici amidacee e tuberi",
        #"4"  = "Legumi",
        #"5"  = "Frutta a guscio e semi oleosi",
        #"6"  = "Frutta e prodotti a base di frutta",
        #"7"  = "Carne e prodotti a base di carne (frattaglie commestibili incluse)",
        #"8"  = "Pesce e altri prodotti ittici (inclusi anfibi, rettili, lumache e insetti)",
        #"9"  = "Latte e prodotti lattiero-caseari",
        #"10" = "Uova e ovoprodotti",
        #"11" = "Zucchero e prodotti dolciari (prodotti a base di cacao inclusi)",
        #"12" = "Grassi e oli animali e vegetali (burro escluso)",
        #"13" = "Succhi di frutta e di ortaggi",
        #"14" = "Bevande analcoliche (esclusi latte, succhi di frutta e ortaggi, acqua e stimolanti)",
        #"15" = "Bevande alcoliche",
        #"16" = "Acqua potabile (senza additivi tranne anidride carbonica; incluso il ghiaccio per consumo)",
        #"18" = "Alimenti per lattanti e bambini piccoli",
        #"19" = "Prodotti per uso nutrizionale speciale",
        #"20" = "Alimenti composti (inclusi i surgelati)",
        #"21" = "Snack e dessert",
        #"22" = "Altri alimenti",
        #"23" = "Bevande stimolanti, secche e diluite (esclusi i prodotti a base di cacao)"
    ],
    ConTraduzione = Table.AddColumn(Ordinati, "Gruppo Alimentare (IT)", each Record.FieldOrDefault(Traduzioni, Text.From([FoodGroupID]), [FoodGroupName]), type text)
in
    ConTraduzione
