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
	["Kyoryokuna Enhancements brings small improvements to the game: the buffs and conjured items you're missing, action bars, the experience bar, the time left to enter a battleground, and a dark mode. Everything starts off, for you to turn on what you want."] =
		"O Kyoryokuna Enhancements traz pequenas melhorias ao jogo: os buffs e itens conjurados que te faltam, as barras de ações, a barra de experiência, o tempo que falta para entrar numa battleground, e um modo escuro. Tudo começa desligado, para ligares o que quiseres.",
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
	["When a battleground is ready, the game's window to enter it shows how long is left to accept: green, then yellow from 20 seconds, red from 10."] =
		"Quando uma battleground fica pronta, a janela do jogo para entrar mostra quanto tempo falta para aceitar: verde, depois amarelo a partir dos 20 segundos e vermelho a partir dos 10.",
	["Show the time left"] = "Mostrar o tempo que falta",
	["With a bar that empties"] = "Com uma barra que vai esvaziando",
	["Under the game's window."] = "Por baixo da janela do jogo.",
	["Expires in"] = "Expira em",

	-- Import / Export
	["Import / Export"] = "Importar / Exportar",
	["Export"] = "Exportar",
	["A code with all your settings, to share with someone. Click the box (or the button) and press Ctrl+C to copy it. Your language, the minimap button and the missing buffs aren't in it: those are each player's own."] =
		"Um código com todas as tuas definições, para partilhar com alguém. Clica na caixa (ou no botão) e carrega em Ctrl+C para o copiar. A língua, o botão do minimapa e os buffs em falta não vão no código: são de cada jogador.",
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
	["Copies of all your settings (but the missing buffs), to put back if you change something and don't like it. The last 10 are kept; one is also made by itself before an import or a restore."] =
		"Cópias de todas as tuas definições (menos os buffs em falta), para repor se mudares alguma coisa e não gostares. Ficam guardadas as últimas 10; também é feita uma automaticamente antes de importar ou repor.",
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
	["Show the number when there are none"] = "Mostrar o número quando não há nenhum",
	["The number on a conjured item's icon is how many your bags hold. Off, an item you have none of shows no number."] =
		"O número no ícone de um item conjurado é quantos tens nas bags. Desligado, um item de que não tens nenhum não mostra número.",
	["Number position"] = "Posição do número",
	["Where the number of a conjured item goes on its icon."] = "Onde fica o número de um item conjurado no seu ícone.",
	["Number size"] = "Tamanho do número",
	["How big the number of a conjured item is on its icon."] = "O tamanho do número de um item conjurado no seu ícone.",
	["Bottom right corner"] = "Canto inferior direito",
	["Bottom left corner"] = "Canto inferior esquerdo",
	["Top right corner"] = "Canto superior direito",
	["Top left corner"] = "Canto superior esquerdo",

	-- Cooldown numbers colored by the time left (Action Bars page)
	["Color the numbers by the time left"] = "Colorir os números pelo tempo que falta",
	["One color while the cooldown is long, another for its last seconds, so you see at a glance what's about to be ready."] =
		"Uma cor enquanto o cooldown é longo e outra para os últimos segundos, para veres logo o que está quase pronto.",
	["Long cooldown"] = "Cooldown longo",
	["The color of the numbers until the last seconds."] = "A cor dos números até aos últimos segundos.",
	["Last seconds"] = "Últimos segundos",
	["The color of the numbers in the last seconds."] = "A cor dos números nos últimos segundos.",
	["Last seconds from"] = "Últimos segundos a partir de",
	["How many seconds before the end the color changes."] = "Quantos segundos antes do fim muda a cor.",

	-- Click to conjure (Missing Buffs page)
	["Click an icon to conjure the item"] = "Clicar num ícone para conjurar o item",
	["A click on the icon of a missing conjured item casts the spell that makes it, with the best rank you know."] =
		"Um clique no ícone de um item conjurado em falta lança o feitiço que o cria, com o melhor rank que sabes.",
	["(Not in combat: Blizzard's API doesn't let addons change clickable buttons during a fight. An icon already on the screen when the fight starts still works; one that shows during it becomes clickable when the fight ends.)"] =
		"(Não em combate: a API da Blizzard não deixa os addons mudar botões clicáveis durante uma luta. Um ícone que já esteja no ecrã quando a luta começa continua a funcionar; um que apareça durante a luta fica clicável quando ela acaba.)",
	["Click an icon to cast the buff"] = "Clicar num ícone para lançar o buff",
	["A click on the icon of a missing buff casts it on you, whoever you have targeted. For a family, the spell of the icon picked, else the one you used last."] =
		"Um clique no ícone de um buff em falta lança-o em ti, seja quem for o teu alvo. Numa família, o feitiço do ícone escolhido ou, sem escolha, o último que usaste.",
	["A click on each icon casts:"] = "Um clique em cada ícone lança:",
	-- The options window, minimized
	["Minimize"] = "Minimizar",
	["Maximize"] = "Maximizar",
	["Only the title bar stays, to see and drag what's on the screen."] = "Fica só a barra do título, para veres e arrastares o que está no ecrã.",
	["The window back to its full size."] = "A janela volta ao tamanho inteiro.",
	-- The welcome window and what's new
	["OK"] = "OK",
	["Version %s"] = "Versão %s",
	["Getting started"] = "Para começar",
	["What's new in %s"] = "Novidades da %s",
	["New"] = "Novo",
	["Fixed"] = "Corrigido",
	["Known issues"] = "Problemas conhecidos",
	["Limits of the game itself, which no addon can get around:"] = "Limites do próprio jogo, que nenhum addon consegue contornar:",
	["See what's new"] = "Ver as novidades",
	["The window of what's new in each version, and the known issues."] =
		"A janela das novidades de cada versão, e os problemas conhecidos.",
	["Thanks for installing! Type /ke to open the options."] = "Obrigado por instalares! Escreve /ke para abrir as opções.",
	["Updated to version %s. Type /ke to see what's new."] = "Atualizado para a versão %s. Escreve /ke para veres as novidades.",
	["Each page on the left is one feature: turn it on at the top of its page, then set it up."] =
		"Cada página à esquerda é uma funcionalidade: liga-a no topo da página e depois configura-a.",
	["Missing Buffs: tick what your character should always have, then Move to put the icons in place (the button beside the X shrinks this window meanwhile)."] =
		"Buffs em falta: marca o que a tua personagem deve ter sempre e depois Mover para pôr os ícones no sítio (entretanto, o botão ao lado do X encolhe esta janela).",
	["Import / Export keeps backups of your settings and shares them with a code."] =
		"O Importar / Exportar guarda cópias das tuas definições e partilha-as com um código.",
	-- Release notes
	["A welcome window: the first time you open the addon, and after each update with what's new and what was fixed."] =
		"Uma janela de boas-vindas: da primeira vez que abres o addon, e depois de cada atualização com as novidades e o que foi corrigido.",
	["A button beside the X of the options window shrinks it to its title bar, to see and drag what's on the screen, and brings it back."] =
		"Um botão ao lado do X da janela das opções encolhe-a até à barra do título, para veres e arrastares o que está no ecrã, e volta a abri-la.",
	["Missing buffs: the size of the number on a conjured item's icon, and Move and Reset position at the top of the page."] =
		"Buffs em falta: o tamanho do número no ícone de um item conjurado, e Mover e Repor a posição no topo da página.",
	["Missing buffs: click an icon to conjure the item or to cast the buff (options; out of combat, a limit of the game)."] =
		"Buffs em falta: clicar num ícone para conjurar o item ou lançar o buff (opções; fora de combate, um limite do jogo).",
	["Action bars: the cooldown numbers can change color by the time left."] =
		"Barras de ações: os números dos cooldowns podem mudar de cor com o tempo que falta.",
	["The number on a conjured item's icon: hidden when there are none, and in any corner or in the middle."] =
		"O número no ícone de um item conjurado: escondido quando não há nenhum, e em qualquer canto ou ao centro.",
	["A click on an icon could cast a lower rank of the spell: it now casts the highest one you know."] =
		"Um clique num ícone podia lançar um rank mais baixo do feitiço: agora lança o mais alto que conheces.",
	["Missing buffs are no longer in the Import / Export code nor in the backups: they're each character's own."] =
		"Os buffs em falta já não vão no código de Importar / Exportar nem nas cópias: são de cada personagem.",
	["Missing buffs: the buffs and conjured items your character should have, read from its spellbook, shown grey and faded on the screen while missing, in two groups (Essential and Utility) with their own place and look."] =
		"Buffs em falta: os buffs e itens conjurados que a tua personagem deve ter, lidos do seu spellbook, mostrados a cinzento e desvanecidos no ecrã enquanto faltam, em dois grupos (Essenciais e Utilidade) com sítio e aspeto próprios.",
	["Action bars, experience bar, queue timer and dark mode, each on its own page."] =
		"Barras de ações, barra de experiência, temporizador da fila e modo escuro, cada um na sua página.",
	["Import / Export page: share your settings with a code, and keep backups to put back later."] =
		"Página Importar / Exportar: partilha as tuas definições com um código, e guarda cópias para repor mais tarde.",
	["In combat the game may hide your buffs from addons: the missing buffs icons then stay as they were last known."] =
		"Em combate o jogo pode esconder os teus buffs dos addons: os ícones dos buffs em falta ficam então como estavam da última vez.",
	["In combat the game doesn't let addons change clickable buttons: an icon that shows during a fight becomes clickable when it ends."] =
		"Em combate o jogo não deixa os addons mudar botões clicáveis: um ícone que aparece durante um combate passa a ser clicável quando ele acaba.",
	-- Supplies
	["Supplies"] = "Mantimentos",
	["Food and drink macros"] = "Macros de comida e bebida",
	["Macros of this character that eat and drink the best food and drink in your bags, bought, looted or conjured. Tick the ones you want: the addon makes each macro for you. Then click its \"Pick up\" and click an empty slot of an action bar to place it. That's all: the addon keeps it up to date by itself as your bags change (the strongest you can use; when it runs out, the next one)."] =
		"Macros desta personagem que comem e bebem a melhor comida e bebida das tuas bags, comprada, de loot ou conjurada. Marca as que queres: o addon cria cada macro por ti. Depois carrega no seu \"Pegar\" e clica num lugar vazio de uma barra de ações para a pôr lá. É só isso: o addon mantém-na atualizada sozinho à medida que as bags mudam (a mais forte que podes usar; quando acaba, a seguinte).",
	["Pick up"] = "Pegar",
	["The icon of this macro on your action bar: the food's or the drink's."] = "O ícone desta macro na tua barra de ações: o da comida ou o da bebida.",
	["Puts the macro on your mouse: click an empty slot of an action bar to place it there. No need to open the macros window."] =
		"Põe a macro no rato: clica num lugar vazio de uma barra de ações para a pôr lá. Não precisas de abrir a janela das macros.",
	["Food only"] = "Só comida",
	["Drink only"] = "Só bebida",
	["Food and drink"] = "Comida e bebida",
	["Eats the best food in your bags (health)."] = "Come a melhor comida das tuas bags (vida).",
	["Drinks the best drink in your bags (mana)."] = "Bebe a melhor bebida das tuas bags (mana).",
	["Eats and drinks at once, each the best you have: both bars fill together while you sit."] =
		"Come e bebe ao mesmo tempo, cada uma a melhor que tens: as duas barras enchem juntas enquanto estás sentado.",
	["KE Food"] = "KE Comida",
	["KE Drink"] = "KE Água",
	["KE Food+Drink"] = "KE Comida+Água",
	["Kept for this character only: a warrior may want only the food, a mage all three. A macro unticked is deleted. With nothing in your bags, a mage's macro conjures more (your highest rank); anyone else's says there's none."] =
		"Guardado só para esta personagem: um warrior pode querer só a comida, um mage as três. Uma macro desmarcada é apagada. Sem nada nas bags, a macro de um mage conjura mais (o teu rank mais alto); a dos outros diz que não há.",
	["(Not in combat: Blizzard's API doesn't let addons change macros during a fight. They follow when it ends, and nobody can eat or drink in combat anyway.)"] =
		"(Não em combate: a API da Blizzard não deixa os addons mudar macros durante um combate. Atualizam-se quando ele acaba, e em combate ninguém pode comer nem beber.)",
	["Food with a buff"] = "Comida com buff",
	["Use food with a buff too"] = "Usar também comida com buff",
	["Food that makes you well fed (more stamina, spirit...) is usually kept for raids and dungeons. Off, the macros leave it in your bags."] =
		"A comida que te deixa well fed (mais stamina, spirit...) costuma ser guardada para raids e dungeons. Desligado, as macros deixam-na nas bags.",
	["Now"] = "Agora",
	["What the macros use now:"] = "O que as macros usam agora:",
	["Food"] = "Comida",
	["Drink"] = "Bebida",
	["none in your bags"] = "nenhuma nas bags",
	["Open the macros window"] = "Abrir a janela das macros",
	["To drag the macros to your action bars (also with /macro)."] = "Para arrastares as macros para as barras de ações (também com /macro).",
	["No food in your bags."] = "Não tens comida nas bags.",
	["No drink in your bags."] = "Não tens bebida nas bags.",
	["No food or drink in your bags."] = "Não tens comida nem bebida nas bags.",
	["Supplies: no room for its macros. Free a slot in this character's macros (/macro), then type /reload."] =
		"Mantimentos: não há espaço para as macros. Liberta um lugar nas macros desta personagem (/macro) e escreve /reload.",
	["Supplies (new page): macros that eat and drink the best food and drink in your bags, kept up to date by the addon: food only, drink only, or both at once. A mage's conjures more when there's none."] =
		"Mantimentos (página nova): macros que comem e bebem a melhor comida e bebida das tuas bags, mantidas atualizadas pelo addon: só comida, só bebida, ou as duas de uma vez. A de um mage conjura mais quando não há.",
	-- Proc alerts
	["Proc Alerts"] = "Alertas de procs",
	["Proc alerts"] = "Alertas de procs",
	["When one of your procs happens (e.g. Fingers of Frost), the game's spell alert art shows on the sides of your character, as in the newer game. It works in combat too: when the game hides an aura from addons, the game itself shows the art."] =
		"Quando um dos teus procs acontece (por exemplo, Fingers of Frost), a arte dos alertas de feitiços do jogo aparece dos lados da tua personagem, como no jogo mais recente. Funciona também em combate: quando o jogo esconde uma aura dos addons, é o próprio jogo que mostra a arte.",
	["Show proc alerts"] = "Mostrar os alertas de procs",
	["The game's own spell alerts are on (Options > Combat > Spell Alert Opacity): some procs would show twice."] =
		"Os alertas de feitiços do próprio jogo estão ligados (Opções > Combate > Spell Alert Opacity): alguns procs iam aparecer duas vezes.",
	["Turn off the game's spell alerts"] = "Desligar os alertas do jogo",
	["Sets the game's Spell Alert Opacity to off. It can be turned on again in the game's options."] =
		"Desliga a Spell Alert Opacity do jogo. Pode voltar a ser ligada nas opções do jogo.",
	["The SpellActivationOverlay addon is on: with both, the alerts show twice. Turn one of them off."] =
		"O addon SpellActivationOverlay está ligado: com os dois, os alertas aparecem duas vezes. Desliga um deles.",
	["Procs of your class (%s)"] = "Procs da tua classe (%s)",
	["No proc alerts for your class yet."] = "Ainda não há alertas de procs para a tua classe.",
	["Tick the ones to show."] = "Marca os que queres mostrar.",
	["Look"] = "Aspeto",
	["The size of the art, from half to twice the game's."] = "O tamanho da arte, de metade ao dobro da do jogo.",
	["Distance between the sides"] = "Distância entre os lados",
	["How far apart the left and right art are: more keeps them away from your character."] =
		"A distância entre a arte da esquerda e a da direita: mais afasta-a da tua personagem.",
	["Height"] = "Altura",
	["How see-through the art is: lower is more faded."] = "Quão transparente é a arte: mais baixo, mais desvanecida.",
	["Animation"] = "Animação",
	["How the art moves while the proc is there. Some procs always stay still, as in the game."] =
		"Como a arte se mexe enquanto o proc está ativo. Alguns procs ficam sempre parados, como no jogo.",
	["None"] = "Nenhuma",
	["Pulse"] = "Pulsar",
	["Breathe"] = "Respirar",
	["Blink"] = "Piscar",
	["Float"] = "Flutuar",
	["Speed (one cycle)"] = "Velocidade (um ciclo)",
	["How long one cycle lasts: less is faster. The game's own spell alerts take 1 second."] =
		"Quanto dura um ciclo: menos é mais rápido. Os alertas de feitiços do próprio jogo demoram 1 segundo.",
	["Strength"] = "Intensidade",
	["How much it changes: how much it grows (Pulse), fades (Breathe, Blink) or rises (Float)."] =
		"Quanto muda: quanto cresce (Pulsar), desvanece (Respirar, Piscar) ou sobe (Flutuar).",
	["Appear softly"] = "Aparecer suavemente",
	["The art fades in when the proc comes, instead of showing at once."] =
		"A arte surge aos poucos quando o proc chega, em vez de aparecer de repente.",
	["Proc alerts: animations to pick (pulse, breathe, blink or float), with their speed and strength, and the art can appear softly."] =
		"Alertas de procs: animações à escolha (pulsar, respirar, piscar ou flutuar), com velocidade e intensidade, e a arte pode aparecer suavemente.",
	["Test"] = "Testar",
	["Shows each proc of your class in turn, for a few seconds, with its name. The options shrink to their title bar meanwhile (+ brings them back)."] =
		"Mostra cada proc da tua classe à vez, durante uns segundos, com o nome. Entretanto, as opções encolhem até à barra do título (o + volta a abri-las).",
	["Proc alerts: none for your class yet."] = "Alertas de procs: ainda não há para a tua classe.",
	["Proc Alerts (new page): the game's spell alert art on the sides of your character when a proc happens, in combat too. For now the mage's: Missile Barrage, Clearcasting, Fingers of Frost and Heating Up."] =
		"Alertas de procs (página nova): a arte dos alertas de feitiços do jogo dos lados da tua personagem quando um proc acontece, também em combate. Para já os do mage: Missile Barrage, Clearcasting, Fingers of Frost e Heating Up.",
	["Options: the pages in a new order, the simplest first."] = "Opções: as páginas numa nova ordem, as mais simples primeiro.",
	-- Proc alerts, phase 2
	["Tick the ones to show. \"Test\" beside a proc keeps its alert on the screen while you set its look below (drag this window aside to see it): \"Close test\", or closing the options, ends it."] =
		"Marca os que queres mostrar. \"Testar\" ao lado de um proc deixa o alerta dele fixo no ecrã enquanto afinas o aspeto em baixo (arrasta esta janela para o lado para o veres): \"Fechar teste\", ou fechar as opções, termina-o.",
	["Close test"] = "Fechar teste",
	["Test all"] = "Testar todos",
	["Keeps this proc's alert on the screen, at its most stacks, to set its look. Click \"Close test\" or close the options to end it."] =
		"Deixa o alerta deste proc fixo no ecrã, com o máximo de stacks, para afinares o aspeto. Carrega em \"Fechar teste\" ou fecha as opções para o terminar.",
	["when usable"] = "quando disponível",
	["Shown while this ability can be used (e.g. after a kill, a parry or a dodge)."] =
		"Aparece enquanto esta habilidade pode ser usada (por exemplo, depois de uma morte, de um parry ou de um dodge).",
	["Proc alerts for every class: druid, hunter, paladin, priest, rogue, shaman, warlock and warrior, and abilities that become usable (Victory Rush, Riposte, Mongoose Bite). \"Test\" beside a proc keeps it on the screen while you set the look."] =
		"Alertas de procs para todas as classes: druid, hunter, paladin, priest, rogue, shaman, warlock e warrior, e habilidades que ficam disponíveis (Victory Rush, Riposte, Mongoose Bite). \"Testar\" ao lado de um proc deixa-o fixo no ecrã enquanto afinas o aspeto.",
	-- Proc alerts, phase 3
	["button glows"] = "o botão brilha",
	["Its button on your action bars glows while this ability can be used."] =
		"O botão desta habilidade nas tuas barras de ações brilha enquanto ela pode ser usada.",
	["\"Button glows\": while the ability is ready, its button on the game's action bars gets a moving gold outline (also a macro that casts it)."] =
		"\"O botão brilha\": enquanto a habilidade está pronta, o botão dela nas barras de ações do jogo ganha um contorno dourado animado (também uma macro que a lance).",
	["Alert"] = "Aviso",
	["How this ability warns you when it's ready: its art on the screen, its button glowing on your action bars, or both."] =
		"Como esta habilidade te avisa quando está pronta: a arte no ecrã, o botão a brilhar nas tuas barras de ações, ou os dois.",
	["Art"] = "Imagem",
	["Button"] = "Botão",
	["Both"] = "Ambos",
	["Proc alerts: drag to move"] = "Alertas de procs: arrasta para mover",
	["Shows the alerts with a green frame: drag it where you want, then click again (closing the options also ends it)."] =
		"Mostra os alertas com uma moldura verde: arrasta-a para onde quiseres e clica outra vez (fechar as opções também termina).",
	["Puts the alerts back in the middle of the screen."] = "Põe os alertas outra vez no meio do ecrã.",
	["Glowing buttons: an ability's button on your action bars glows while it can be used (Ice Barrier, Overpower, Execute, Revenge, Counterattack, Holy Shock, Exorcism, Hammer of Wrath, Stormstrike). Each ability with art can warn by its art, its button or both. The alerts can be moved anywhere on the screen."] =
		"Botões a brilhar: o botão de uma habilidade nas tuas barras de ações brilha enquanto ela pode ser usada (Ice Barrier, Overpower, Execute, Revenge, Counterattack, Holy Shock, Exorcism, Hammer of Wrath, Stormstrike). Cada habilidade com arte pode avisar pela imagem, pelo botão ou pelos dois. Os alertas podem ser movidos para qualquer sítio do ecrã.",
	["Proc alerts: a smoother pulse of the art."] = "Alertas de procs: a arte pulsa de forma mais suave.",
	["Proc alerts now:"] = "Alertas de procs agora:",
	["what the proc alerts know now"] = "o que os alertas de procs sabem agora",
	["Missing buffs no longer record an error every time the game hides your auras in combat."] =
		"Os buffs em falta já não registam um erro sempre que o jogo esconde as tuas auras em combate.",
	["/ke procscan all: finds the spells of every proc of every class, to set them right for WoW Forever."] =
		"/ke procscan all: encontra os feitiços de todos os procs de todas as classes, para os acertar no WoW Forever.",
	["Proc alerts: Fingers of Frost now shows in combat (one charge on the left, two on the right)."] =
		"Alertas de procs: o Fingers of Frost já aparece em combate (uma carga à esquerda, duas à direita).",
	["Kept in the addon's saved data: type /reload so the game writes it down."] = "Guardado nos dados do addon: escreve /reload para o jogo o gravar.",
	["Two diagnostic commands used only once (/ke procscan armor and fof) are gone."] = "Saíram dois comandos de diagnóstico usados uma só vez (/ke procscan armor e fof).",
	-- Error messages
	["Error Messages"] = "Mensagens de erro",
	["Error messages"] = "Mensagens de erro",
	["The red messages the game shows in the middle of the screen, like \"Spell is not ready yet\" when a button is pressed again and again. Pick the ones to hide: only the text is hidden, the game's sound still plays. Useful messages, like a full bag, always show."] =
		"As mensagens vermelhas que o jogo mostra no meio do ecrã, como \"Spell is not ready yet\" quando carregas várias vezes num botão. Escolhe as que queres esconder: só o texto fica escondido, o som do jogo continua a tocar. As mensagens úteis, como as bags cheias, aparecem sempre.",
	["Filter the error messages"] = "Filtrar as mensagens de erro",
	["Messages to hide"] = "Mensagens a esconder",
	["Not ready yet"] = "Ainda não está pronto",
	["\"Spell is not ready yet\", \"Ability is not ready yet\", an item still cooling down."] =
		"\"Spell is not ready yet\", \"Ability is not ready yet\", um item ainda em cooldown.",
	["Not enough mana, rage or energy"] = "Sem mana, rage ou energy suficiente",
	["\"Not enough mana\", \"Not enough rage\", \"Not enough energy\", combo points."] =
		"\"Not enough mana\", \"Not enough rage\", \"Not enough energy\", combo points.",
	["Out of range"] = "Fora de alcance",
	["\"Out of range\", \"Target too close\"."] = "\"Out of range\", \"Target too close\".",
	["Not in line of sight"] = "Fora da linha de visão",
	["\"Target not in line of sight\"."] = "\"Target not in line of sight\".",
	["Facing the wrong way"] = "Virado para o lado errado",
	["\"You are facing the wrong way!\", \"Target needs to be in front of you\"."] =
		"\"You are facing the wrong way!\", \"Target needs to be in front of you\".",
	["No target or wrong target"] = "Sem alvo ou alvo errado",
	["\"You have no target\", \"Invalid target\", \"Your target is dead\"."] = "\"You have no target\", \"Invalid target\", \"Your target is dead\".",
	["Another action in progress"] = "Outra ação em curso",
	["\"Another action is in progress\", \"You can't do that right now\"."] = "\"Another action is in progress\", \"You can't do that right now\".",
	["Can't do that while moving"] = "Não dá enquanto te mexes",
	["\"Can't do that while moving\"."] = "\"Can't do that while moving\".",
	["Hide every error message"] = "Esconder todas as mensagens de erro",
	["Every red message of the game, the useful ones too."] = "Todas as mensagens vermelhas do jogo, também as úteis.",
	["When and how"] = "Quando e como",
	["Only in combat"] = "Só em combate",
	["Out of combat every message shows, as in the game."] = "Fora de combate aparecem todas as mensagens, como no jogo.",
	["Silence the voice of the messages"] = "Calar a voz das mensagens",
	["Your character no longer says \"Not enough mana\" and the like, for every message, hidden or not. (The game's own setting: turned back on when this is off.)"] =
		"A tua personagem deixa de dizer \"Not enough mana\" e afins, em todas as mensagens, escondidas ou não. (É uma opção do próprio jogo: volta a ficar ligada quando desligas esta.)",
	["Error Messages (new page): hide the game's red messages you don't want, like \"Spell is not ready yet\" (their sound still plays), and silence their voice."] =
		"Mensagens de erro (página nova): esconde as mensagens vermelhas do jogo que não queres, como \"Spell is not ready yet\" (o som continua a tocar), e cala a voz delas.",

	-- Release notes 0.10.2
	["Trainer: spells you can't learn (talents you don't have, other specializations' spells, like Pyroblast for a frost mage) no longer show in the list nor in the chat."] =
		"Treinador: os feitiços que não podes aprender (talentos que não tens, feitiços de outras especializações, como o Pyroblast para um mage frost) já não aparecem na lista nem no chat.",

	-- Release notes 0.10.1
	["Proc alerts: the test of Fingers of Frost shows both sides, as two charges do in the game."] =
		"Alertas de procs: o teste do Fingers of Frost mostra os dois lados, como duas cargas fazem no jogo.",
	["Proc alerts: Heating Up no longer shows three wings of different sizes: it's one that gets stronger with each stack."] =
		"Alertas de procs: o Heating Up já não mostra três asas de tamanhos diferentes: é uma só, que ganha força a cada stack.",
	["Proc alerts: \"Place on the screen\" is now right after turning the alerts on."] =
		"Alertas de procs: \"Sítio no ecrã\" vem agora logo a seguir a ligar os alertas.",

	-- Trainer (Modules\Trainer.lua, Options\Pages\Trainer.lua)
	["Trainer"] = "Treinador",
	["Choose the spells to learn"] = "Escolher os feitiços a aprender",
	["At your class trainer, each spell you can learn gets a box. Tick the ones you want and click \"Learn ticked\", at the top of the window: only those are learned, one after another. Nothing is learned without your tick, and the game's Train button works as always."] =
		"No treinador da tua classe, cada feitiço que podes aprender ganha uma caixa. Marca os que queres e carrega em \"Aprender marcados\", no topo da janela: só esses são aprendidos, um a seguir ao outro. Nada é aprendido sem a tua marca, e o botão Treinar do jogo funciona como sempre.",
	["New spells"] = "Feitiços novos",
	["Tell me when I reach the level of new spells"] = "Avisar quando chego ao nível de feitiços novos",
	["When you level up, the chat lists the spells waiting at your trainer for that level. They're read at each visit to your trainer: visit it once after turning this on."] =
		"Quando sobes de nível, o chat diz os feitiços que esse nível traz no teu treinador. São lidos em cada visita ao treinador: visita-o uma vez depois de ligares isto.",
	["Waiting at your trainer"] = "À tua espera no treinador",
	["Nothing known yet: visit your class trainer once."] = "Ainda não se sabe nada: visita uma vez o treinador da tua classe.",
	["You can learn now: %s."] = "Podes aprender já: %s.",
	["Nothing to learn at your level."] = "Nada para aprender no teu nível.",
	["Level %d: %s."] = "Nível %d: %s.",
	["(From your last visit to your trainer.)"] = "(Da tua última visita ao treinador.)",
	["Learn ticked"] = "Aprender marcados",
	["Learn ticked (%d)"] = "Aprender marcados (%d)",
	["Learning..."] = "A aprender...",
	["Tick the spells you want to learn, then click here: they're learned one after another."] =
		"Marca os feitiços que queres aprender e depois carrega aqui: são aprendidos um a seguir ao outro.",
	["Total: %s"] = "Total: %s",
	["Not enough money for all of them: those you can't pay are left ticked."] =
		"Não tens dinheiro para todos: os que não consegues pagar ficam marcados.",
	["Learn this spell"] = "Aprender este feitiço",
	["Ticked spells are learned with the \"Learn ticked\" button, at the top of the window."] =
		"Os feitiços marcados são aprendidos com o botão \"Aprender marcados\", no topo da janela.",
	["New at your trainer (level %d): %s."] = "Novo no teu treinador (nível %d): %s.",
	["Show a Trainer tab in the spellbook"] = "Mostrar uma aba Treinador no spellbook",
	["One more tab in your spellbook, after the game's: a click on it shows the spells still to learn at your class trainer, by level, with their cost. They're read at each visit to your trainer: visit it once after turning this on."] =
		"Mais uma aba no teu spellbook, a seguir às do jogo: ao carregares nela, vês os feitiços que ainda tens para aprender no treinador da tua classe, por nível, com o custo. São lidos em cada visita ao treinador: visita-o uma vez depois de ligares isto.",
	["Trainer: the spells still to learn"] = "Treinador: os feitiços que faltam aprender",
	["Spells to learn"] = "Feitiços para aprender",
	["From your last visit to your trainer: %s."] = "Da tua última visita ao treinador: %s.",
	["From your last visit to your trainer."] = "Da tua última visita ao treinador.",
	["Nothing known yet: visit your class trainer once and its spells show here."] =
		"Ainda não se sabe nada: visita uma vez o treinador da tua classe e os feitiços dele aparecem aqui.",
	["Nothing left to learn at your trainer."] = "Já não há nada para aprender no teu treinador.",
	["Level %d: you can learn these now"] = "Nível %d: podes aprender estes já",
	["Level %d"] = "Nível %d",
	["Level %d, at your class trainer: %s"] = "Nível %d, no treinador da tua classe: %s",
	["A Trainer tab in the spellbook (Trainer page): the spells still to learn at your trainer, by level, with their cost."] =
		"Uma aba Treinador no spellbook (página Treinador): os feitiços que ainda tens para aprender no treinador, por nível, com o custo.",
	["New ranks on the action bars"] = "Ranks novos nas barras de ação",
	["Put new ranks on the action bars"] = "Pôr os ranks novos nas barras de ação",
	["When you learn a new rank of a spell, it takes the place of the rank before it on your action bars. Lower ranks you keep on purpose stay, and macros aren't touched. Not in combat: then when the fight ends."] =
		"Quando aprendes um rank novo de um feitiço, ele fica no lugar do rank anterior nas tuas barras de ação. Os ranks mais baixos que lá tens de propósito ficam, e as macros não são mexidas. Não em combate: nesse caso, quando o combate acaba.",
	["%s (Rank %d) put on your action bars in place of Rank %d."] = "%s (rank %d) foi posto nas tuas barras de ação no lugar do rank %d.",
	["New ranks on the action bars (Trainer page): a new rank you learn takes the place of the one before on your bars."] =
		"Ranks novos nas barras de ação (página Treinador): um rank novo que aprendes fica no lugar do anterior nas tuas barras.",

	-- Quest sparkles (Modules\QuestSparkles.lua, Options\Pages\QuestSparkles.lua)
	["Quest Sparkles"] = "Brilho das quests",
	["Quest item sparkles"] = "Brilho nos itens de quest",
	["Quest items you can loot sparkle, so they're easy to spot: on the ground, on objects and on creatures. It's a setting of the game that its graphics presets turn off: the addon keeps it on, at login and after any change of the graphics."] =
		"Os itens de quest que podes apanhar brilham, para os veres facilmente: no chão, em objetos e em criaturas. É uma opção do próprio jogo que as predefinições de gráficos desligam: o addon mantém-na ligada, ao entrar e depois de qualquer mudança nos gráficos.",
	["Make quest items sparkle"] = "Fazer brilhar os itens de quest",
	["Turning this off takes effect after restarting the game (a /reload isn't enough)."] =
		"Desligar isto só tem efeito depois de reiniciares o jogo (um /reload não chega).",
	["Quest item sparkles: restart the game to remove the ones already shown (a /reload isn't enough)."] =
		"Brilho nos itens de quest: reinicia o jogo para tirar os que já aparecem (um /reload não chega).",

	-- FPS and latency (Modules\Performance.lua, Options\Pages\Performance.lua)
	["FPS and Latency"] = "FPS e latência",
	["FPS and latency"] = "FPS e latência",
	["A small text on the screen with your frames per second and the latency (ping) of your connection, updated every second. The mouse goes through it."] =
		"Um pequeno texto no ecrã com os teus FPS (imagens por segundo) e a latência (ping) da tua ligação, atualizado a cada segundo. O rato passa através dele.",
	["Show the FPS and latency"] = "Mostrar os FPS e a latência",
	["Shows the text with a green frame: drag it where you want, then click again (closing the options also ends it)."] =
		"Mostra o texto com uma moldura verde: arrasta-o para onde quiseres e depois carrega outra vez (fechar as opções também termina).",
	["Puts the text back in its first place, near the top of the screen."] = "Põe o texto no sítio inicial, perto do topo do ecrã.",
	["What to show"] = "O que mostrar",
	["Show"] = "Mostrar",
	["FPS only"] = "Só os FPS",
	["Latency only"] = "Só a latência",
	["Latency"] = "Latência",
	["World"] = "Mundo",
	["Home"] = "Casa",
	["Home and world"] = "Casa e mundo",
	["World: your connection to the game world, where fights happen (the one that matters most). Home: your connection to the realm, for the chat, friends and guild."] =
		"Mundo: a tua ligação ao mundo do jogo, onde acontecem os combates (a que mais importa). Casa: a tua ligação ao reino, para o chat, os amigos e a guild.",
	["Color by value"] = "Cores conforme o valor",
	["Green when good, yellow when so-so, red when bad: FPS under 60 and under 30, latency over 100 and over 200 ms."] =
		"Verde quando está bom, amarelo quando está mais ou menos, vermelho quando está mau: FPS abaixo de 60 e abaixo de 30, latência acima de 100 e acima de 200 ms.",
	["Text size"] = "Tamanho do texto",
	["Text color"] = "Cor do texto",
	["Dark background with a border"] = "Fundo escuro com moldura",
	["FPS and latency: drag to move"] = "FPS e latência: arrasta para mover",

	-- Release notes 0.10.0
	["Trainer (new page): tick the spells you want at your class trainer and learn only those. And the chat tells you when you reach the level of new spells."] =
		"Treinador (página nova): marca os feitiços que queres no treinador da tua classe e aprende só esses. E o chat avisa quando chegas ao nível de feitiços novos.",
	["FPS and Latency (new page): your FPS and ping on the screen, where you want them, colored by how good they are."] =
		"FPS e latência (página nova): os teus FPS e o ping no ecrã, onde quiseres, com cores conforme estão bons ou maus.",
	["Quest Sparkles (new page): quest items you can loot keep sparkling, even after a change of the graphics."] =
		"Brilho das quests (página nova): os itens de quest que podes apanhar continuam a brilhar, mesmo depois de mudares os gráficos.",
}
