-- KyoryokunaEnhancements
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Portuguese (Portugal)

local _, ns = ...

ns.LOCALES.ptPT = {
	-- Pages
	["General"] = "Geral",
	["About"] = "Sobre",
	["Dark Mode"] = "Modo escuro",

	-- General
	["Language"] = "Língua",
	["The language of the addon's texts."] = "A língua dos textos do addon.",
	["Minimap"] = "Minimapa",
	["Show the minimap button"] = "Mostrar o botão do minimapa",
	["A click on it opens the options. Drag it to move it around the minimap."] =
		"Um clique abre as opções. Arrasta-o para o mudar de sítio à volta do minimapa.",
	["Drag to move this button."] = "Arrasta para mudar este botão de sítio.",
	["Dark mode"] = "Modo escuro",
	["Darkens the art of the game's interface: frames, borders and bar decorations. Turned off, everything gets its own colors back."] =
		"Escurece a arte da interface do jogo: molduras, bordas e decorações das barras. Desligado, tudo volta às suas cores.",
	["Darkness"] = "Escuridão",
	["How dark the art gets, from barely darker (5%) to black (100%). Changes show at once, while you drag. The end caps of the action bar, the buttons and the level circles stay a little lighter, so their shapes still show."] =
		"O quão escura fica a arte, de quase nada (5%) até preto (100%). As mudanças aparecem logo, enquanto arrastas. As pontas da barra de ação, os botões e os círculos do nível ficam um pouco mais claros, para se continuar a ver a forma deles.",
	["Unit frames"] = "Molduras das unidades",
	["Player, target, focus, pet, party and boss frames."] = "Molduras do jogador, alvo, foco, pet, grupo e bosses.",
	["Action bars"] = "Barras de ação",
	["The buttons' borders, the bar's decoration, the bags, the menu and the experience bar."] =
		"As bordas dos botões, a decoração da barra, as bolsas, o menu e a barra de experiência.",
	["Cast bars"] = "Barras de cast",
	["The borders of the player's, target's and focus's cast bars."] = "As bordas das barras de cast do jogador, do alvo e do foco.",
	["Its ring, its buttons and the rings of the addon buttons around it."] =
		"O aro, os botões e os aros dos botões de addons à volta dele.",
	["Tooltips"] = "Tooltips",
	["Their border, and a darker background."] = "A borda e um fundo mais escuro.",
	["Objectives"] = "Objetivos",
	["The headers of the quest and objective list."] = "Os cabeçalhos da lista de quests e objetivos.",
	["Personal resource display"] = "Recursos pessoais",
	["The bars and class points under your character: the borders of the bars and the backgrounds of the points (combo points, runes, chi, essence...)."] =
		"As barras e os pontos de classe por baixo da tua personagem: as bordas das barras e os fundos dos pontos (combo points, runas, chi, essência...).",
	["Bags"] = "Bolsas",
	["The bag windows and the borders of their slots (the items stay as they are)."] =
		"As janelas das bolsas e as bordas dos espaços (os itens ficam como estão).",
	["Game menu"] = "Menu do jogo",
	["The menu that opens with Escape."] = "O menu que abre com a tecla Escape.",
	["Dark mode: pieces found by part"] = "Modo escuro: peças encontradas por parte",
	["what the dark mode finds of each part"] = "o que o modo escuro encontra de cada parte",
	["Party and raid frames"] = "Molduras de grupo e raid",
	["The borders of the party and raid frames."] = "As bordas das molduras de grupo e raid.",

	-- About
	["Version"] = "Versão",
	["Author"] = "Autor",
	["What it is"] = "O que é",
	["Kyoryokuna Enhancements brings small improvements to the game. It's just starting: its first features are on the way."] =
		"O Kyoryokuna Enhancements traz pequenas melhorias ao jogo. Está a começar: as primeiras funcionalidades estão a caminho.",
	["Copyright"] = "Copyright",
	["This addon may be used freely for personal use. Copying, modifying or redistributing its code, in whole or in part, is not allowed without written permission from the author. See the LICENSE file for the full terms."] =
		"Este addon pode ser usado livremente para uso pessoal. Não é permitido copiar, modificar ou redistribuir o seu código, no todo ou em parte, sem autorização escrita do autor. Vê o ficheiro LICENSE para os termos completos.",
	["World of Warcraft is a trademark of Blizzard Entertainment, Inc. This addon is not affiliated with or endorsed by Blizzard Entertainment."] =
		"World of Warcraft é uma marca registada da Blizzard Entertainment, Inc. Este addon não está associado nem é aprovado pela Blizzard Entertainment.",

	-- Window, chat and the game's settings
	["Click to open the options."] = "Clica para abrir as opções.",
	["All options are in the addon's own window. You can also type /ke."] =
		"Todas as opções estão na janela do próprio addon. Também podes escrever /ke.",
	["Open options"] = "Abrir as opções",
	["Commands:"] = "Comandos:",
	["open the options"] = "abrir as opções",
	["show recorded errors"] = "mostrar os erros registados",

	-- Errors
	["An error happened. Type /ke errors to see it."] = "Aconteceu um erro. Escreve /ke errors para o veres.",
	["No errors recorded."] = "Nenhum erro registado.",
	["%d error(s) recorded, newest last:"] = "%d erro(s) registado(s), o mais recente no fim:",

	-- Pages
	["Action Bars"] = "Barras de ação",
	["Experience Bar"] = "Barra de experiência",
	["Queue"] = "Fila",
	["Parts"] = "Partes",

	-- Action bars
	["Texts on the buttons"] = "Textos nos botões",
	["Hide the keys"] = "Esconder as teclas",
	["The key each button is bound to, on every action bar."] = "A tecla de cada botão, em todas as barras de ação.",
	["Hide the names of macros"] = "Esconder os nomes das macros",
	["The name of a macro, written on its button."] = "O nome de uma macro, escrito no botão.",
	["Cooldown numbers"] = "Números de cooldown",
	["The seconds left on a button whose spell is on cooldown. They show when the game's option \"Show cooldown numbers\" is on (Options > Action Bars)."] =
		"Os segundos que faltam num botão cujo feitiço está em cooldown. Aparecem quando a opção do jogo \"Mostrar números de cooldown\" está ligada (Opções > Barras de ação).",
	["Size"] = "Tamanho",
	["100% is the game's own size."] = "100% é o tamanho do próprio jogo.",
	["Key press"] = "Tecla premida",
	["Show when a button's key is pressed"] = "Mostrar quando se carrega na tecla de um botão",
	["A short effect over the button whenever you press its key, so you see which button you used."] =
		"Um efeito curto por cima do botão sempre que carregas na tecla dele, para veres que botão usaste.",
	["Effect"] = "Efeito",
	["Flash"] = "Clarão",
	["Glowing border"] = "Borda brilhante",
	["Flash: the button lights up for a moment. Glowing border: a golden border around it, growing as it fades."] =
		"Clarão: o botão acende-se por um instante. Borda brilhante: uma borda dourada à volta, que cresce enquanto desaparece.",
	["Micro menu"] = "Micro menu",
	["Hide the micro menu's frame"] = "Esconder a moldura do micro menu",
	["The frame and background around the small buttons of the game's menus (character, spellbook, talents...). The buttons stay."] =
		"A moldura e o fundo à volta dos botões pequenos dos menus do jogo (personagem, livro de feitiços, talentos...). Os botões ficam.",

	-- Experience bar
	["Texture"] = "Textura",
	["A cleaner look for the experience bar and the other bars the game shows there (reputation, honor). Each keeps its own color."] =
		"Um aspeto mais limpo para a barra de experiência e as outras barras que o jogo mostra aí (reputação, honra). Cada uma mantém a sua cor.",
	["Use the addon's texture"] = "Usar a textura do addon",
	["Smooth"] = "Suave",
	["Flat"] = "Lisa",
	["Classic"] = "Clássica",
	["Raid"] = "Raid",
	["Smooth: a soft shine. Flat: one plain color. Classic: the glossy bars of old. Raid: like the raid frames."] =
		"Suave: um brilho leve. Lisa: uma cor simples. Clássica: as barras brilhantes de antigamente. Raid: como as molduras de raid.",

	-- Queue
	["Time left to accept"] = "Tempo para aceitar",
	["When a dungeon (dungeon finder) or a battleground is ready, the game's window to enter it shows how long is left to accept: green, then yellow from 20 seconds, red from 10."] =
		"Quando uma dungeon (dungeon finder) ou uma battleground fica pronta, a janela do jogo para entrar mostra quanto tempo falta para aceitar: verde, depois amarelo a partir dos 20 segundos e vermelho a partir dos 10.",
	["Show the time left"] = "Mostrar o tempo que falta",
	["With a bar that empties"] = "Com uma barra que vai esvaziando",
	["Under the game's window."] = "Por baixo da janela do jogo.",
	["Expires in"] = "Expira em",

	-- Import / Export
	["Import / Export"] = "Importar / Exportar",
	["Export"] = "Exportar",
	["A code with all your settings, to share with someone. Click the box (or the button) and press Ctrl+C to copy it. Your language, the minimap button and each character's missing buffs aren't in it."] =
		"Um código com todas as tuas definições, para partilhar com alguém. Clica na caixa (ou no botão) e carrega em Ctrl+C para o copiar. A língua, o botão do minimapa e os buffs em falta de cada personagem não vão no código.",
	["Your code"] = "O teu código",
	["Select the code"] = "Selecionar o código",
	["Press Ctrl+C to copy the code."] = "Carrega em Ctrl+C para copiar o código.",
	["Import"] = "Importar",
	["Paste a code (Ctrl+V) in the box and click Import. Your current settings are kept as a backup first, so you can go back."] =
		"Cola um código (Ctrl+V) na caixa e clica em Importar. Antes disso, as tuas definições atuais ficam guardadas numa cópia de segurança, para poderes voltar atrás.",
	["Code to import"] = "Código a importar",
	["Paste a code in the box first."] = "Cola primeiro um código na caixa.",
	["Replace your settings with the %d from this code? Your current settings are kept as a backup."] =
		"Substituir as tuas definições pelas %d deste código? As tuas definições atuais ficam guardadas numa cópia de segurança.",
	["That isn't a Kyoryokuna Enhancements code."] = "Isso não é um código do Kyoryokuna Enhancements.",
	["That code has no settings this version knows."] = "Esse código não tem definições que esta versão conheça.",
	["%d settings imported. Your previous settings were kept as a backup."] =
		"%d definições importadas. As tuas definições anteriores ficaram guardadas numa cópia de segurança.",
	["Backups"] = "Cópias de segurança",
	["Copies of all your settings, to put back if you change something and don't like it. The last 10 are kept; one is also made by itself before an import or a restore."] =
		"Cópias de todas as tuas definições, para repor se mudares alguma coisa e não gostares. Ficam guardadas as últimas 10; também é feita uma automaticamente antes de importar ou repor.",
	["Create a backup"] = "Criar uma cópia de segurança",
	["Name of the backup (optional)"] = "Nome da cópia (opcional)",
	["Edit"] = "Editar",
	["Gives this backup a name of your own. Enter keeps it; an empty name gives it back its first one."] =
		"Dá um nome teu a esta cópia. Enter guarda-o; um nome vazio devolve-lhe o nome que tinha.",
	["Backup created."] = "Cópia de segurança criada.",
	["No backups yet."] = "Ainda não há cópias de segurança.",
	["Backup"] = "Cópia",
	["Before import"] = "Antes de importar",
	["Before restore"] = "Antes de repor",
	["Restore"] = "Repor",
	["Puts these settings back. Your current ones are kept as a backup first."] =
		"Repõe estas definições. Antes disso, as atuais ficam guardadas numa cópia de segurança.",
	["Put back the settings of %s? Your current settings are kept as a backup."] =
		"Repor as definições de %s? As tuas definições atuais ficam guardadas numa cópia de segurança.",
	["Backup of %s restored."] = "Cópia de %s reposta.",
	["Delete"] = "Apagar",
	["Deletes this backup. Asks first."] = "Apaga esta cópia de segurança. Pergunta primeiro.",
	["Delete the backup of %s? This can't be undone."] = "Apagar a cópia de %s? Não dá para desfazer.",

	-- Controls of the options
	["Right-click to type a value."] = "Clique direito para escrever um valor.",
	["Default"] = "Padrão",
	["Puts this color back to its default."] = "Repõe esta cor no valor por defeito.",
	["Yes"] = "Sim",
	["No"] = "Não",

	-- Updated, with the game still to be restarted (Core\Init.lua)
	["%s was updated to version %s. Close the game and open it again to use it: a /reload isn't enough, because the game only reads the addon's new files when it starts. Until then the addon is turned off."] =
		"%s foi atualizado para a versão %s. Fecha o jogo e abre-o de novo para o usar: um /reload não chega, porque o jogo só lê os ficheiros novos do addon quando arranca. Até lá, o addon fica desligado.",

	-- Missing buffs (page and Modules\MissingBuffs.lua)
	["Missing Buffs"] = "Buffs em falta",
	["Missing buffs"] = "Buffs em falta",
	["When something you chose is missing, its icon shows on the screen, grey and faded, in and out of combat (not while you're dead). Each thing goes to one of two groups, Essential or Utility, each with its own place and look."] =
		"Quando falta alguma coisa que escolheste, o ícone dela aparece no ecrã, cinzento e desvanecido, dentro e fora de combate (não enquanto estás morto). Cada coisa vai para um de dois grupos, Essenciais ou Utilidade, cada um com o seu sítio e aspeto.",
	["Show what's missing"] = "Mostrar o que está em falta",
	["Buffs of %s (%s)"] = "Buffs de %s (%s)",
	["Tick the buffs to watch, and pick their group. Buffs that can't be on together, like the armors of a mage, are one line: any of them is enough, and you can pick the icon. The same buff from someone else counts too."] =
		"Marca os buffs a vigiar e escolhe o grupo de cada um. Buffs que não podem estar ativos ao mesmo tempo, como as armaduras do mage, são uma só linha: basta um deles, e podes escolher o ícone. O mesmo buff dado por outra pessoa também conta.",
	["No usual buffs of your class in your spellbook. Any other spell can be chosen at the bottom of the page."] =
		"Não há buffs habituais da tua classe no teu spellbook. Podes escolher qualquer outro feitiço no fim da página.",
	["Conjured items"] = "Itens conjurados",
	["Shown when your bags hold fewer than the minimum (any rank counts)."] =
		"Aparecem quando tens nas bags menos do que o mínimo (qualquer rank conta).",
	["All this is kept for this character only, and read from your spellbook: a spell you learn later shows up then."] =
		"Tudo isto fica guardado só para este personagem e é lido do teu spellbook: um feitiço que aprendas mais tarde aparece nessa altura.",
	["Group"] = "Grupo",
	["Where its icon shows: with the essential buffs, or with the utility ones."] =
		"Onde aparece o ícone: com os buffs essenciais ou com os de utilidade.",
	["Essential"] = "Essenciais",
	["Utility"] = "Utilidade",
	["Icon"] = "Ícone",
	["The icon shown when the family is missing: one of its spells, or the one you used last."] =
		"O ícone mostrado quando a família está em falta: um dos seus feitiços, ou o último que usaste.",
	["Last used"] = "Último usado",
	["Minimum"] = "Mínimo",
	["Shown when your bags hold fewer than this. The icon shows how many you have."] =
		"Aparece quando tens nas bags menos do que isto. O ícone mostra quantos tens.",
	["Min. %d"] = "Mín. %d",
	["Copy the choice of another character of your class (it replaces this character's):"] =
		"Copiar a escolha de outro personagem da tua classe (substitui a deste personagem):",
	["Copy"] = "Copiar",
	["Copy from %s (%d)"] = "Copiar de %s (%d)",
	["Puts that character's choice on this one."] = "Põe neste personagem a escolha desse personagem.",
	["Copy the missing buffs of %s to this character? Its own choice is replaced."] =
		"Copiar os buffs em falta de %s para este personagem? A escolha dele é substituída.",
	["Missing buffs copied from %s."] = "Buffs em falta copiados de %s.",
	["Your %s %s has missing buffs chosen. To copy them to this character: /ke, Missing Buffs page."] =
		"O teu %s %s tem buffs em falta escolhidos. Para os copiar para este personagem: /ke, página Buffs em falta.",
	["Essential group"] = "Grupo Essenciais",
	["Utility group"] = "Grupo Utilidade",
	["Icon size"] = "Tamanho dos ícones",
	["Opacity"] = "Opacidade",
	["How see-through the icons are: lower is more faded."] = "O quão transparentes ficam os ícones: quanto mais baixo, mais desvanecidos.",
	["Space between icons"] = "Espaço entre os ícones",
	["Direction"] = "Direção",
	["Where the icons go when more than one is missing. The side they grow from stays in place."] =
		"Para onde vão os ícones quando falta mais do que um. O lado de onde crescem fica no mesmo sítio.",
	["Centered"] = "Ao centro",
	["To the right"] = "Para a direita",
	["To the left"] = "Para a esquerda",
	["Up"] = "Para cima",
	["Down"] = "Para baixo",
	["Place on the screen"] = "Sítio no ecrã",
	["Move"] = "Mover",
	["Done"] = "Concluído",
	["Shows both groups with a green frame: drag each where you want, then click again (closing the options also ends it)."] =
		"Mostra os dois grupos com uma moldura verde: arrasta cada um para onde quiseres e clica outra vez (fechar as opções também termina).",
	["Reset position"] = "Repor a posição",
	["Puts both groups back in their first place, above the middle of the screen."] =
		"Põe os dois grupos de volta no sítio inicial, acima do meio do ecrã.",
	["Essential: drag to move"] = "Essenciais: arrasta para mover",
	["Utility: drag to move"] = "Utilidade: arrasta para mover",
	["Other spells"] = "Outros feitiços",
	["Every other spell of your spellbook, for a buff that isn't in the lists above."] =
		"Todos os outros feitiços do teu spellbook, para um buff que não esteja nas listas de cima.",
	["Show the other spells"] = "Mostrar os outros feitiços",
	["Hide the other spells"] = "Esconder os outros feitiços",
	["Buffs read: %d. In combat: %s. Readable: %s."] = "Buffs lidos: %d. Em combate: %s. Legíveis: %s.",
	["the buffs the addon can read on you now"] = "os buffs que o addon consegue ler em ti agora",
}
