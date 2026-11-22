let
        // Tabella Dimensionale Geografica completa (33 entità del CSV)
        TabellaPaesi = #table(
            type table [
                CountryID = Int64.Type,
                CountryName_Originale = text,
                Country_Geo_EN = text,
                #"Paese (IT)" = text,
                #"Tipo Entità Geografica" = text
            ],
            {
                {333, "WHO European Region", null, "Regione Europea OMS (Aggregato)", "Aggregato Sovranazionale OMS"},
                {87,  "Germany", "Germany", "Germania", "Stato Nazionale"},
                {108, "France", "France", "Francia", "Stato Nazionale"},
                {278, "Slovakia", "Slovakia", "Slovacchia", "Stato Nazionale"},
                {86,  "Denmark", "Denmark", "Danimarca", "Stato Nazionale"},
                {307, "United Kingdom of Great Britain and Northern Ireland (the)", "United Kingdom", "Regno Unito", "Stato Nazionale"},
                {216, "Norway", "Norway", "Norvegia", "Stato Nazionale"},
                {106, "Finland", "Finland", "Finlandia", "Stato Nazionale"},
                {84,  "Czech Republic (the)", "Czechia", "Repubblica Ceca", "Stato Nazionale"},
                {28,  "Austria", "Austria", "Austria", "Stato Nazionale"},
                {269, "Spain", "Spain", "Spagna", "Stato Nazionale"},
                {35,  "Belgium", "Belgium", "Belgio", "Stato Nazionale"},
                {151, "Italy", "Italy", "Italia", "Stato Nazionale"},
                {147, "Ireland", "Ireland", "Irlanda", "Stato Nazionale"},
                {280, "Sweden", "Sweden", "Svezia", "Stato Nazionale"},
                {245, "Romania", "Romania", "Romania", "Stato Nazionale"},
                {279, "Slovenia", "Slovenia", "Slovenia", "Stato Nazionale"},
                {207, "Netherlands", "Netherlands", "Paesi Bassi", "Stato Nazionale"},
                {229, "Poland", "Poland", "Polonia", "Stato Nazionale"},
                {138, "Hungary", "Hungary", "Ungheria", "Stato Nazionale"},
                {125, "Greece", "Greece", "Grecia", "Stato Nazionale"},
                {82,  "Cyprus", "Cyprus", "Cipro", "Stato Nazionale"},
                {101, "Estonia", "Estonia", "Estonia", "Stato Nazionale"},
                {230, "Portugal", "Portugal", "Portogallo", "Stato Nazionale"},
                {174, "Luxembourg", "Luxembourg", "Lussemburgo", "Stato Nazionale"},
                {175, "Latvia", "Latvia", "Lettonia", "Stato Nazionale"},
                {50,  "Bulgaria", "Bulgaria", "Bulgaria", "Stato Nazionale"},
                {281, "Switzerland", "Switzerland", "Svizzera", "Stato Nazionale"},
                {172, "Lithuania", "Lithuania", "Lituania", "Stato Nazionale"},
                {139, "Iceland", "Iceland", "Islanda", "Stato Nazionale"},
                {184, "Malta", "Malta", "Malta", "Stato Nazionale"},
                {300, "Turkey", "Turkey", "Turchia", "Stato Nazionale"},
                {305, "Ukraine", "Ukraine", "Ucraina", "Stato Nazionale"}
            }
        )
    in
        TabellaPaesi
