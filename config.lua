Config = {}

Config.Murtoitemi = 'tiirikka' -- tohon itemi minkä tarvii että voit alottaa murron

Config.Tavarat = {
    {Nimi = 'Puhelin', Database = 'phone'}, -- Nimi on mikä näkyy ilmotuksessa että esim. löysit x2 Puhelin ja Database on se mikä on itemin database nimi
} 

Config.Kontit = {
    [1] = {
        Ovi = {Objekti = "ex_prop_door_lowbank_roof", Koordinaatit = vector3(2600.503, 2804.684, 34.27783), Kiinni = true, Suunta = 9.99623}, --tähän ovi ja tällee kaikki käyttää samaa objektii paitsi jos laitat johonki muuhun ku konttii
        Poliisit = 0,
        Kohdat = { -- täs on kohdat mistä saa itemeit ja näin
            {Paikka = vector3(2598.22, 2806.84, 34.1), Suunta = 104.05, Otettu = false}, -- älä koske Otettu kohtaan, Suunta on se mihkä pelaaja kääntyy ku ottaa kohdasta ja näin
            {Paikka = vector3(2605.33, 2807.94, 34.09), Suunta = 282.78, Otettu = false},
            {Paikka = vector3(2600.18, 2807.16, 34.1), Suunta = 1.41, Otettu = false},
            {Paikka = vector3(2603.52, 2807.65, 34.09), Suunta = 10.03, Otettu = false},
            {Paikka = vector3(2601.84, 2807.25, 34.1), Suunta = 14.92, Otettu = false},
        },
    }
}