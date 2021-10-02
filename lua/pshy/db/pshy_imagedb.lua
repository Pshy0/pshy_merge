--- pshy_imagedb.lua
--
-- Images available for TFM scripts.
-- Note: I did not made the images, 
-- I only gathered and classified them in this script.
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua



--- Module Help Page:
pshy.help_pages["pshy_imagedb"] = {back = "pshy", title = "Image Search", text = "List of common module images.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_imagedb"] = pshy.help_pages["pshy_imagedb"]



--- Module Settings:
pshy.imagedb_max_search_results = 20		-- maximum search displayed results



--- Images.
-- Map of images.
-- The key is the image code.
-- The value is a table with the folowing fields:
--	- w: The pixel width of the picture.
--	- h: The pixel height of the picture (default to `w`).
pshy.imagedb_images = {}
-- model
pshy.imagedb_images["00000000000.png"] = {w = nil, h = nil, desc = ""}
-- pixels (source: Peanut_butter https://atelier801.com/topic?f=6&t=827044&p=1#m12)
pshy.imagedb_images["165965055b2.png"] = {author = "Dea_bu#0000", w = 25, h = 34, desc = "pixel 1"}
pshy.imagedb_images["1659658dc8f.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 2"}
pshy.imagedb_images["165966b6346.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 3"}
pshy.imagedb_images["165966cc2db.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 4"}
pshy.imagedb_images["165966d9a68.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 5"}
pshy.imagedb_images["165966f86f6.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 6"}
pshy.imagedb_images["16596700568.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 7"}
pshy.imagedb_images["165967088be.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 8"}
pshy.imagedb_images["1659671b6fb.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 9"}
pshy.imagedb_images["16596720dd2.png"] = {author = "Dea_bu#0000", w = 25, h = 34, desc = "pixel 10"}
pshy.imagedb_images["1659672d821.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 11"}
pshy.imagedb_images["16596736237.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 12"}
pshy.imagedb_images["1659673b8d5.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 13"}
pshy.imagedb_images["16596740a8f.png"] = {author = "Dea_bu#0000", w = 25, h = 34, desc = "pixel 14"}
pshy.imagedb_images["16596746e71.png"] = {author = "Dea_bu#0000", w = 25, h = 34, desc = "pixel 15"}
-- flags (source: Bolodefchoco https://atelier801.com/topic?f=6&t=877911#m1)
pshy.imagedb_images["1651b327097.png"] = {w = 16, h = 11, desc = "xx flag"}
pshy.imagedb_images["1651b32290a.png"] = {w = 16, h = 11, desc = "ar flag"}
pshy.imagedb_images["1651b300203.png"] = {w = 16, h = 11, desc = "bg flag"}
pshy.imagedb_images["1651b3019c0.png"] = {w = 16, h = 11, desc = "br flag"}
pshy.imagedb_images["1651b3031bf.png"] = {w = 16, h = 11, desc = "cn flag"}
pshy.imagedb_images["1651b304972.png"] = {w = 16, h = 11, desc = "cz flag"}
pshy.imagedb_images["1651b306152.png"] = {w = 16, h = 11, desc = "de flag"}
pshy.imagedb_images["1651b307973.png"] = {w = 16, h = 11, desc = "ee flag"}
pshy.imagedb_images["1651b309222.png"] = {w = 16, h = 11, desc = "es flag"}
pshy.imagedb_images["1651b30aa94.png"] = {w = 16, h = 11, desc = "fi flag"}
pshy.imagedb_images["1651b30c284.png"] = {w = 16, h = 11, desc = "fr flag"}
pshy.imagedb_images["1651b30da90.png"] = {w = 16, h = 11, desc = "gb flag"}
pshy.imagedb_images["1651b30f25d.png"] = {w = 16, h = 11, desc = "hr flag"}
pshy.imagedb_images["1651b310a3b.png"] = {w = 16, h = 11, desc = "hu flag"}
pshy.imagedb_images["1651b3121ec.png"] = {w = 16, h = 11, desc = "id flag"}
pshy.imagedb_images["1651b3139ed.png"] = {w = 16, h = 11, desc = "il flag"}
pshy.imagedb_images["1651b3151ac.png"] = {w = 16, h = 11, desc = "it flag"}
pshy.imagedb_images["1651b31696a.png"] = {w = 16, h = 11, desc = "jp flag"}
pshy.imagedb_images["1651b31811c.png"] = {w = 16, h = 11, desc = "lt flag"}
pshy.imagedb_images["1651b319906.png"] = {w = 16, h = 11, desc = "lv flag"}
pshy.imagedb_images["1651b31b0dc.png"] = {w = 16, h = 11, desc = "nl flag"}
pshy.imagedb_images["1651b31c891.png"] = {w = 16, h = 11, desc = "ph flag"}
pshy.imagedb_images["1651b31e0cf.png"] = {w = 16, h = 11, desc = "pl flag"}
pshy.imagedb_images["1651b31f950.png"] = {w = 16, h = 11, desc = "ro flag"}
pshy.imagedb_images["1651b321113.png"] = {w = 16, h = 11, desc = "ru flag"}
pshy.imagedb_images["1651b3240e8.png"] = {w = 16, h = 11, desc = "tr flag"}
pshy.imagedb_images["1651b3258b3.png"] = {w = 16, h = 11, desc = "vk flag"}
-- Memes (source: Zubki https://atelier801.com/topic?f=6&t=827044&p=1#m1)
--@TODO  (40;50)
-- Misc (source: Shamousey https://atelier801.com/topic?f=6&t=827044&p=1#m5)
--@TODO
-- Jerry (source: Noooooooorr https://atelier801.com/topic?f=6&t=827044&p=1#m13)
pshy.imagedb_images["174d14019e2.png"] = {w = 86, h = 90, desc = "jerry 1"}
pshy.imagedb_images["174d12f1634.png"] = {w = 61, h = 80, desc = "jerry 2"}
pshy.imagedb_images["1717581457e.png"] = {w = 70, h = 100, desc = "jerry 3"}
pshy.imagedb_images["171524ab085.png"] = {w = 67, h = 60, desc = "jerry 4"}
pshy.imagedb_images["1740c7d4de6.png"] = {w = 80, h = 72, desc = "jerry 5"}
pshy.imagedb_images["1718e698ac9.png"] = {w = 85, h = 110, desc = "jerry 6"}
pshy.imagedb_images["17526faf702.png"] = {w = 80, h = 50, desc = "jerry 7"}
pshy.imagedb_images["17526fc5a1c.png"] = {w = 70, h = 73, desc = "jerry 8"}
pshy.imagedb_images["1792c9c8635.png"] = {w = 259, h = 290, desc = "hungry nibbbles"}
-- Among us (source: Noooooooorr https://atelier801.com/topic?f=6&t=827044&p=1#m13)
pshy.imagedb_images["174d9e0072e.png"] = {w = 37, h = 50, desc = "among us red"}
pshy.imagedb_images["174d9e01e9e.png"] = {w = 37, h = 50, desc = "among us cyan"}
pshy.imagedb_images["174d9e03612.png"] = {w = 37, h = 50, desc = "among us blue"}
pshy.imagedb_images["174d9e0c2be.png"] = {w = 37, h = 50, desc = "among us purple"}
pshy.imagedb_images["174d9e04d84.png"] = {w = 37, h = 50, desc = "among us green"}
pshy.imagedb_images["174d9e064f6.png"] = {w = 37, h = 50, desc = "among us pink"}
pshy.imagedb_images["174d9e07c67.png"] = {w = 37, h = 50, desc = "among us yellow"}
pshy.imagedb_images["174d9e093d9.png"] = {w = 37, h = 50, desc = "among us black"}
pshy.imagedb_images["174d9e0ab49.png"] = {w = 37, h = 50, desc = "among us white"}
pshy.imagedb_images["174da01d1ae.png"] = {w = 24, h = 30, desc = "among us mini white"}
-- misc (source: Noooooooorr https://atelier801.com/topic?f=6&t=827044&p=1#m14)
pshy.imagedb_images["1789e6b9058.png"] = {w = 245, h = 264, desc = "skeleton", TFM = true}
pshy.imagedb_images["178cbf1ff84.png"] = {w = 280, h = 290, desc = "meli mouse", TFM = true}
pshy.imagedb_images["1792c9cd64e.png"] = {w = 290, h = 390, desc = "skeleton cat", TFM = true}
pshy.imagedb_images["1789d45e0a4.png"] = {w = 234, h = 280, desc = "explorer dora", TFM = true}
-- misc (source: Wercade https://atelier801.com/topic?f=6&t=827044&p=1#m10)
pshy.imagedb_images["1557c364a52.png"] = {w = 150, h = 100, desc = "mouse"} -- @TODO: resize
pshy.imagedb_images["155c49d0331.png"] = {w = 60, h = 33, desc = "horse"}
pshy.imagedb_images["155c4a31e48.png"] = {w = 50, h = 49,  desc = "poop", oriented = false}
pshy.imagedb_images["155ca47179a.png"] = {w = 74, h = 50, desc = "computer mouse"}
pshy.imagedb_images["155c9e6aad4.png"] = {w = 60, h = 50, desc = "toilet paper"}
pshy.imagedb_images["155c5133917.png"] = {w = 70, h = 45, desc = "waddles pig"}
pshy.imagedb_images["155c4cdd0e3.png"] = {w = 50, h = 51, desc = "cock"}
pshy.imagedb_images["155c4976244.png"] = {w = 60, h = 50, desc = "sponge bob"}
pshy.imagedb_images["155c9fab3f1.png"] = {w = 72, h = 60, desc = "mouse on broom", TFM = true}
-- gravity falls (source: Breathin https://atelier801.com/topic?f=6&t=827044&p=1#m15)
pshy.imagedb_images["17a52468a34.png"] = {w = 30, h = 50, desc = "waddles pig sitting"}
-- pacman (Made by Nnaaaz#0000)
pshy.imagedb_images["17ad578a939.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "open pacman"}
pshy.imagedb_images["17ad578c0aa.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "closed pacman"}
pshy.imagedb_images["17afe1cf978.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "open yellow pac-cheese"}
pshy.imagedb_images["17afe1ce20a.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "closed yellow pac-cheese"}
pshy.imagedb_images["17afe2a6882.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "open orange pac-cheese"}
pshy.imagedb_images["17afe1d18bc.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "closed orange pac-cheese"}
-- pacman fruits (Uploaded by Nnaaaz#0000)
pshy.imagedb_images["17ae46fd894.png"] = {pacman = true, w = 25, desc = "strawberry"}
pshy.imagedb_images["17ae46ff007.png"] = {pacman = true, w = 25, desc = "chicken leg"}
pshy.imagedb_images["17ae4700777.png"] = {pacman = true, w = 25, desc = "burger"}
pshy.imagedb_images["17ae4701ee9.png"] = {pacman = true, w = 25, desc = "rice bowl"}
pshy.imagedb_images["17ae4703658.png"] = {pacman = true, w = 25, desc = "french potatoes"}
pshy.imagedb_images["17ae4704dcc.png"] = {pacman = true, w = 25, desc = "aubergine"}
pshy.imagedb_images["17ae4706540.png"] = {pacman = true, w = 25, desc = "bear candy"}
pshy.imagedb_images["17ae4707cb0.png"] = {pacman = true, w = 25, desc = "butter"}
pshy.imagedb_images["17ae4709422.png"] = {pacman = true, w = 25, desc = "candy"}
pshy.imagedb_images["17ae470ab94.png"] = {pacman = true, w = 25, desc = "bread"}
pshy.imagedb_images["17ae470c307.png"] = {pacman = true, w = 25, desc = "muffin"}
pshy.imagedb_images["17ae470da77.png"] = {pacman = true, w = 25, desc = "raspberry"}
pshy.imagedb_images["17ae470f1e8.png"] = {pacman = true, w = 25, desc = "green lemon"}
pshy.imagedb_images["17ae4710959.png"] = {pacman = true, w = 25, desc = "croissant"}
pshy.imagedb_images["17ae47120dd.png"] = {pacman = true, w = 25, desc = "watermelon"}
pshy.imagedb_images["17ae471383b.png"] = {pacman = true, w = 25, desc = "cookie"}
pshy.imagedb_images["17ae4714fad.png"] = {pacman = true, w = 25, desc = "wrap"}
pshy.imagedb_images["17ae4716720.png"] = {pacman = true, w = 25, desc = "cherry"}
pshy.imagedb_images["17ae4717e93.png"] = {pacman = true, w = 25, desc = "biscuit"}
pshy.imagedb_images["17ae4719605.png"] = {pacman = true, w = 25, desc = "carrot"}
-- emoticons
pshy.imagedb_images["16f56cbc4d7.png"] = {emoticon = true, w = 29, h = 26, desc = "nausea"}
pshy.imagedb_images["17088661168.png"] = {emoticon = true, w = 29, h = 26, desc = "cry"}
pshy.imagedb_images["16f5d8c7401.png"] = {emoticon = true, w = 29, h = 26, desc = "rogue"}
pshy.imagedb_images["16f56ce925e.png"] = {emoticon = true, desc = "happy cry"}
pshy.imagedb_images["16f56cdf28f.png"] = {emoticon = true, desc = "wonder"}
pshy.imagedb_images["16f56d09dc2.png"] = {emoticon = true, desc = "happy cry 2"}
pshy.imagedb_images["178ea94a353.png"] = {emoticon = true, w = 35, h = 30, desc = "vanlike novoice"}
pshy.imagedb_images["178ea9d3ff4.png"] = {emoticon = true, desc = "vanlike vomit"}
pshy.imagedb_images["178ea9d5bc3.png"] = {emoticon = true, desc = "vanlike big eyes"}
pshy.imagedb_images["178ea9d7876.png"] = {emoticon = true, desc = "vanlike pinklove"}
pshy.imagedb_images["178ea9d947c.png"] = {emoticon = true, desc = "vanlike eyelove"}
pshy.imagedb_images["178eac181f1.png"] = {emoticon = true, author = "rchl#0000", w = 35, h = 28, desc = "drawing zzz"}
pshy.imagedb_images["178ebdf194a.png"] = {emoticon = true, author = "rchl#0000", desc = "glasses1"}
pshy.imagedb_images["178ebdf317a.png"] = {emoticon = true, author = "rchl#0000", desc = "glasses2"}
pshy.imagedb_images["178ebdf0153.png"] = {emoticon = true, author = "rchl#0000", w = 35, h = 31, desc = "clown"}
pshy.imagedb_images["178ebdee617.png"] = {emoticon = true, author = "rchl#0000", w = 35, h = 31, desc = "vomit"}
pshy.imagedb_images["178ebdf495d.png"] = {emoticon = true, author = "rchl#0000", w = 35, h = 31, desc = "sad"}
pshy.imagedb_images["17aa125e853.png"] = {emoticon = true, author = "rchl#0000", w = 48, h = 48, desc = "sad2"}
pshy.imagedb_images["17aa1265ea4.png"] = {emoticon = true, author = "feverchild#0000", desc = "ZZZ"} -- source: https://discord.com/channels/246815328103825409/522398576706322454/834007372640419851
pshy.imagedb_images["17aa1264731.png"] = {emoticon = true, author = "feverchild#0000", desc = "no voice"}
pshy.imagedb_images["17aa1bcf1d4.png"] = {emoticon = true, author = "Nnaaaz#0000", w = 60, h = 60, desc = "pro"}
pshy.imagedb_images["17aa1bd3a05.png"] = {emoticon = true, author = "Nnaaaz#0000", w = 60, h = 49, desc = "noob"}
pshy.imagedb_images["17aa1bd0944.png"] = {emoticon = true, author = "Nnaaaz#0000", desc = "pro2"}
pshy.imagedb_images["17aa1bd20b5.png"] = {emoticon = true, author = "Nnaaaz#0000", desc = "noob2"}
-- memes (source: https://atelier801.com/topic?f=6&t=827044&p=1#m14)
pshy.imagedb_images["15565dbc655.png"] = {meme = true, desc = "WTF cat"} -- 
pshy.imagedb_images["15568238225.png"] = {meme = true, w = 40, h = 40, desc = "FUUU"}
pshy.imagedb_images["155682434d5.png"] = {meme = true, desc = "me gusta"}
pshy.imagedb_images["1556824ac1a.png"] = {meme = true, w = 40, h = 40, desc = "trollface"}
-- Rats (Processed and uploaded by Nnaaaz#0000)
pshy.imagedb_images["17b23214ca6.png"] = {rats = true, w = 137, h = 80, desc = "true mouse/rat 1"}
pshy.imagedb_images["17b23216417.png"] = {rats = true, w = 216, h = 80, desc = "true mouse/rat 2"}
pshy.imagedb_images["17b23217b8a.png"] = {rats = true, w = 161, h = 80, desc = "true mouse/rat 3"}
pshy.imagedb_images["17b232192fc.png"] = {rats = true, w = 142, h = 80, desc = "true mouse/rat 4"}
pshy.imagedb_images["17b2321aa6f.png"] = {rats = true, w = 217, h = 80, desc = "true mouse/rat 5"}
-- TFM
pshy.imagedb_images["155593003fc.png"] = {TFM = true, w = 48, h = 29, desc = "cheese left"}
pshy.imagedb_images["155592fd7d0.png"] = {TFM = true, w = 48, h = 29, desc = "cheese right"}
pshy.imagedb_images["153d331c6b9.png"] = {TFM = true, desc = "normal mouse"}
-- TFM (source: Laagaadoo https://atelier801.com/topic?f=6&t=877911#m3)
pshy.imagedb_images["1569ed22fca.png"] = {TFM = true, furniture = true, desc = ""} -- Estante de livros
pshy.imagedb_images["1569edb5d05.png"] = {TFM = true, furniture = true, desc = ""} -- Estante de livros (invertida)
pshy.imagedb_images["1569ec80946.png"] = {TFM = true, furniture = true, desc = ""} -- Lareira
pshy.imagedb_images["15699c75f35.png"] = {TFM = true, furniture = true, desc = ""} -- Lareira (invertida)
pshy.imagedb_images["1569e9e54f4.png"] = {TFM = true, furniture = true, desc = ""} -- Caixão
pshy.imagedb_images["15699c67278.png"] = {TFM = true, furniture = true, desc = ""} -- Caixão (invertido)
pshy.imagedb_images["1569e7e4495.png"] = {TFM = true, furniture = true, desc = ""} -- Cemiterio
pshy.imagedb_images["156999e1f40.png"] = {TFM = true, furniture = true, desc = ""} -- Cemiterio (invertido)
pshy.imagedb_images["156999ebf03.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore de natal
pshy.imagedb_images["1569e7d3bac.png"] = {TFM = true, furniture = true, desc = ""} -- Arvore de natal (invertida)
pshy.imagedb_images["1569e7ca20e.png"] = {TFM = true, furniture = true, desc = ""} -- Arvore com neve
pshy.imagedb_images["156999e6b7e.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore com neve (invertida)
pshy.imagedb_images["155a7b9a815.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore
pshy.imagedb_images["1569e788f68.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore (invertida)
pshy.imagedb_images["155a7c4e15a.png"] = {TFM = true, furniture = true, desc = ""} -- Flor vermelha
pshy.imagedb_images["155a7c50a6b.png"] = {TFM = true, furniture = true, desc = ""} -- Flor azul
pshy.imagedb_images["155a7c834a4.png"] = {TFM = true, furniture = true, desc = ""} -- Janela
pshy.imagedb_images["1569e9bfb87.png"] = {TFM = true, furniture = true, desc = ""} -- Janela (invertida)
pshy.imagedb_images["155a7ca38b7.png"] = {TFM = true, furniture = true, desc = ""} -- Sofá
pshy.imagedb_images["156999f093a.png"] = {TFM = true, furniture = true, desc = ""} -- Palmeira
pshy.imagedb_images["1569e7706c4.png"] = {TFM = true, furniture = true, desc = ""} -- Palmeira (invertido)
pshy.imagedb_images["15699b2da1f.png"] = {TFM = true, furniture = true, desc = ""} -- Estante de halloween
pshy.imagedb_images["1569e77e3a5.png"] = {TFM = true, furniture = true, desc = ""} -- Estante de halloween (invertido)
pshy.imagedb_images["1569e79c9e3.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore do outono
pshy.imagedb_images["15699b344da.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore do outono (invertida)
pshy.imagedb_images["1569e773235.png"] = {TFM = true, furniture = true, desc = ""} -- Abobora gigante
pshy.imagedb_images["15699c5e038.png"] = {TFM = true, furniture = true, desc = ""} -- Piano
pshy.imagedb_images["15699c3eedd.png"] = {TFM = true, furniture = true, desc = ""} -- Barril
pshy.imagedb_images["15699b15524.png"] = {TFM = true, furniture = true, desc = ""} -- Guada roupa
pshy.imagedb_images["1569e7ae2e0.png"] = {TFM = true, furniture = true, desc = ""} -- Guarda roupa (invertido)
pshy.imagedb_images["1569edb8321.png"] = {TFM = true, furniture = true, desc = ""} -- Baú
pshy.imagedb_images["1569ed263b4.png"] = {TFM = true, furniture = true, desc = ""} -- Baú (invertido)
pshy.imagedb_images["1569edbaea9.png"] = {TFM = true, furniture = true, desc = ""} -- Postêr
pshy.imagedb_images["1569ed28f41.png"] = {TFM = true, furniture = true, desc = ""} -- Postêr (invertido)
pshy.imagedb_images["1569ed2cb80.png"] = {TFM = true, furniture = true, desc = ""} -- Boneco de neve
pshy.imagedb_images["1569edbe194.png"] = {TFM = true, furniture = true, desc = ""} -- Boneco de neve (invertido)
-- backgrounds (source: Travonrodfer https://atelier801.com/topic?f=6&t=877911#m6)
pshy.imagedb_images["14e555a4c1b.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa Independence Day
pshy.imagedb_images["14e520635b4.png"] = {TFM = true, background = true, desc = ""} -- Estatua da liberdade(Mapa Independence Day)
pshy.imagedb_images["14e78118c13.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa Bastille Day
pshy.imagedb_images["14e7811b53a.png"] = {TFM = true, background = true, desc = ""} -- Folha das arvores(Mapa Bastille Day)
pshy.imagedb_images["149c04b50ac.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa do ceifador
pshy.imagedb_images["149c04bc447.png"] = {TFM = true, background = true, desc = ""} -- Mapa do ceifador(partes em primeiro plano)
pshy.imagedb_images["14abae230c8.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa Rua Nuremberg
pshy.imagedb_images["14aa6e36f3e.png"] = {TFM = true, background = true, desc = ""} -- Mapa Rua Nuremberg(partes em primeiro plano)
pshy.imagedb_images["14a88571f89.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa Fabrica de brinquedos
pshy.imagedb_images["14a8d41a838.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa dia das crianças
pshy.imagedb_images["14a8d430dfa.png"] = {TFM = true, background = true, desc = ""} -- Mapa dia das crianças(partes em primeiro plano)
pshy.imagedb_images["15150c10e92.png"] = {TFM = true, background = true, desc = ""} -- Mapa de ano novo
-- TFM Particles (source: Tempo https://atelier801.com/topic?f=6&t=877911#m7)
pshy.imagedb_images["1674801ea08.png"] = {TFM = true, particle = true, desc = ""} -- Raiva
pshy.imagedb_images["16748020179.png"] = {TFM = true, particle = true, desc = ""} -- Palmas
pshy.imagedb_images["167480218ea.png"] = {TFM = true, particle = true, desc = ""} -- Confete
pshy.imagedb_images["1674802305b.png"] = {TFM = true, particle = true, desc = ""} -- Dança
pshy.imagedb_images["167480247cc.png"] = {TFM = true, particle = true, desc = ""} -- Facepalm
pshy.imagedb_images["16748025f3d.png"] = {TFM = true, particle = true, desc = ""} -- High five
pshy.imagedb_images["167480276af.png"] = {TFM = true, particle = true, desc = ""} -- Abraçar
pshy.imagedb_images["16748028e21.png"] = {TFM = true, particle = true, desc = ""} -- Pedir Beijo
pshy.imagedb_images["1674802a592.png"] = {TFM = true, particle = true, desc = ""} -- Beijar
pshy.imagedb_images["1674802bd07.png"] = {TFM = true, particle = true, desc = ""} -- Risada
pshy.imagedb_images["1674802d478.png"] = {TFM = true, particle = true, desc = ""} -- Pedra papel tesoura
pshy.imagedb_images["1674802ebea.png"] = {TFM = true, particle = true, desc = ""} -- Sentar
pshy.imagedb_images["1674803035b.png"] = {TFM = true, particle = true, desc = ""} -- Dormir
pshy.imagedb_images["16748031acc.png"] = {TFM = true, particle = true, desc = ""} -- Chorar
-- Pokemon (source: Shamousey https://atelier801.com/topic?f=6&t=827044&p=1#m6)
-- Mario
pshy.imagedb_images["156d7dafb2d.png"] = {mario = true, desc = "mario (undersized)"} -- @TODO: replace whith a properly sized image
pshy.imagedb_images["17aa6f22c53.png"] = {mario = true, w = 27, h = 38, desc = "mario coin"}
pshy.imagedb_images["17c41851d61.png"] = {mario = true, w = 30, h = 30, desc = "mario flower"}
pshy.imagedb_images["17c41856d4a.png"] = {mario = true, w = 30, h = 30, desc = "mario star"}
-- Bonuses (Pshy#3752)
pshy.imagedb_images["17bef4f49c5.png"] = {bonus = true, w = 30, h = 30, desc = "empty bonus"}
pshy.imagedb_images["17bf4b75aa7.png"] = {bonus = true, w = 30, h = 30, desc = "question bonus"}
pshy.imagedb_images["17bf4ba4ce5.png"] = {bonus = true, w = 30, h = 30, desc = "teleporter bonus"}
pshy.imagedb_images["17bf4b9e11d.png"] = {bonus = true, w = 30, h = 30, desc = "crate bonus"}
pshy.imagedb_images["17bf4b9af56.png"] = {bonus = true, w = 30, h = 30, desc = "high speed bonus"}
pshy.imagedb_images["17bf4b977f5.png"] = {bonus = true, w = 30, h = 30, desc = "ice cube bonus"}
pshy.imagedb_images["17bf4b94d8a.png"] = {bonus = true, w = 30, h = 30, desc = "snowflake bonus"}
pshy.imagedb_images["17bf4b91c35.png"] = {bonus = true, w = 30, h = 30, desc = "broken heart bonus"}
pshy.imagedb_images["17bf4b8f9e4.png"] = {bonus = true, w = 30, h = 30, desc = "heart bonus"}
pshy.imagedb_images["17bf4b8c42d.png"] = {bonus = true, w = 30, h = 30, desc = "feather bonus"}
pshy.imagedb_images["17bf4b89eba.png"] = {bonus = true, w = 30, h = 30, desc = "cross"}
pshy.imagedb_images["17bf4b868c3.png"] = {bonus = true, w = 30, h = 30, desc = "jumping mouse bonus"}
pshy.imagedb_images["17bf4b80fc3.png"] = {bonus = true, w = 30, h = 30, desc = "balloon bonus"}
pshy.imagedb_images["17bef4f49c5.png"] = {bonus = true, w = 30, h = 30, desc = "empty bonus"}
pshy.imagedb_images["17bf4b7ddd6.png"] = {bonus = true, w = 30, h = 30, desc = "triggered mouse trap"}
pshy.imagedb_images["17bf4b7a091.png"] = {bonus = true, w = 30, h = 30, desc = "mouse trap"}
pshy.imagedb_images["17bf4b7250e.png"] = {bonus = true, w = 30, h = 30, desc = "wings bonus"}
pshy.imagedb_images["17bf4b6f226.png"] = {bonus = true, w = 30, h = 30, desc = "transformations bonus"}
pshy.imagedb_images["17bf4b67579.png"] = {bonus = true, w = 30, h = 30, desc = "grow bonus"}
pshy.imagedb_images["17bf4b63aaa.png"] = {bonus = true, w = 30, h = 30, desc = "shrink bonus"}
pshy.imagedb_images["17bf4c421bb.png"] = {bonus = true, w = 30, h = 30, desc = "flag bonus"}
pshy.imagedb_images["17bf4f3f2fb.png"] = {bonus = true, w = 30, h = 30, desc = "v check"}
--@TODO



--- Tell if an image should be oriented
function pshy.imagedb_IsOriented(image)
	if type(image) == "string" then
		image = pshy.imagedb_images[image]
	end
	assert(type(image) == "table", "wrong type " .. type(image))
	if image.oriented ~= nil then
		return image.oriented
	end
	if image.meme or image.emoticon or image.w <= 30 then
		return false
	end
	return true
end



--- Search for an image.
-- @private
-- This function is currently for testing only.
-- @param desc Text to find in the image's description.
-- @param words words to search for.
-- @return A list of images matching the search.
function pshy.imagedb_Search(words)
	local results = {}
	for image_name, image in pairs(pshy.imagedb_images) do
		local not_matching = false
		for i_word, word in pairs(words) do
			if not string.find(image.desc, word) and not image[word] then
				not_matching = true
				break
			end
		end
		if not not_matching then
			table.insert(results, image_name)
		end
	end
	return results
end



--- !searchimage [words...]
function pshy.changeimage_ChatCommandSearchimage(user, word)
	local words = pshy.StrSplit(word, ' ', 5)
	if #words >= 5 then
		return false, "You can use at most 4 words per search!"
	end
	if #words == 1 and #words[1] <= 1 then
		return false, "Please perform a more accurate search!"
	end
	local image_names = pshy.imagedb_Search(words)
	if #image_names == 0 then
		tfm.exec.chatMessage("No image found.", user)
	else
		for i_image, image_name in pairs(image_names) do
			if i_image > pshy.imagedb_max_search_results then
				tfm.exec.chatMessage("+ " .. tostring(#image_names - pshy.imagedb_max_search_results), user)
				break
			end
			local image = pshy.imagedb_images[image_name]
			tfm.exec.chatMessage(image_name .. "\t - " .. tostring(image.desc) .. " (" .. tostring(image.w) .. "," .. tostring(image.w or image.h) .. ")", user)
		end
	end
end
pshy.chat_commands["searchimage"] = {func = pshy.changeimage_ChatCommandSearchimage, desc = "search for an image", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_imagedb"].commands["searchimage"] = pshy.chat_commands["searchimage"]
pshy.perms.cheats["!searchimage"] = true



--- Draw an image (wrapper to tfm.exec.addImage).
-- @public
-- @param image_name The image code (called imageId in te original function).
-- @param target On what game element to attach the image to.
-- @param center_x Center coordinates for the image.
-- @param center_y Center coordinates for the image.
-- @param player_name The player who will see the image, or nil for everyone.
-- @param width Width of the image.
-- @param height Height of the image.
-- @param angle The image's rotation (in radians).
-- @param height Opacity of the image.
-- @return The image ID.
function pshy.imagedb_AddImage(image_name, target, center_x, center_y, player_name, width, height, angle, alpha)
	if image_name == "none" then
		return nil
	end
	local image = pshy.imagedb_images[image_name] or pshy.imagedb_images["15568238225.png"]
	target = target or "!0"
	width = width or image.w
	height = height or image.h or image.w
	local x = center_x + ((width > 0) and 0 or math.abs(width))-- - width / 2
	local y = center_y + ((height > 0) and 0 or math.abs(height))-- - height / 2
	local sx = width / (image.w)
	local sy = height / (image.h or image.w)
	local anchor_x, anchor_y = 0.5, 0.5
	return tfm.exec.addImage(image_name, target, x, y, player_name, sx, sy, angle, alpha, anchor_x, anchor_y)
end



--- Draw an image (wrapper to tfm.exec.addImage) but keep the image dimentions (making it fit at least the given area).
-- @public
-- @param image_name The image code (called imageId in te original function).
-- @param target On what game element to attach the image to.
-- @param center_x Center coordinates for the image.
-- @param center_y Center coordinates for the image.
-- @param player_name The player who will see the image, or nil for everyone.
-- @param width Width of the image.
-- @param height Height of the image.
-- @param angle The image's rotation (in radians).
-- @param height Opacity of the image.
-- @return The image ID.
function pshy.imagedb_AddImageMin(image_name, target, center_x, center_y, player_name, min_width, min_height, angle, alpha)
	if image_name == "none" then
		return nil
	end
	local image = pshy.imagedb_images[image_name] or pshy.imagedb_images["15568238225.png"]
	target = target or "!0"
	local xsign = min_width / (math.abs(min_width))
	local ysign = min_height / (math.abs(min_height))
	width = min_width or image.w
	height = min_height or image.h or image.w
	local sx = width / (image.w)
	local sy = height / (image.h or image.w)
	local sboth = math.max(math.abs(sx), math.abs(sy))
	width = image.w * sboth * xsign
	height = (image.h or image.w) * sboth * ysign
	local x = center_x + ((width > 0) and 0 or math.abs(width))-- - width / 2
	local y = center_y + ((height > 0) and 0 or math.abs(height))-- - height / 2
	local anchor_x, anchor_y = 0.5, 0.5
	return tfm.exec.addImage(image_name, target, x, y, player_name, sboth * xsign, sboth, angle, alpha, anchor_x, anchor_y)
end
