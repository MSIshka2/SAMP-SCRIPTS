script_author("Harry_Pattersone")
script_version("0.5")

require 'lib.moonloader'
require 'lib.sampfuncs'
local imgui = require 'mimgui'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local bit = require 'bit'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local cp = encoding.CP1251
local inicfg = require('inicfg')
local Matrix3X3 = require "matrix3x3"
local Vector3D = require "vector3d"
local vkeys = require('vkeys')
local json = require 'cjson'
local effil = require 'effil'

require "strings"

local IniFilename = 'FtAdminTools.ini'
local ini = inicfg.load({
    settings = 
    {
        lvladmin = 12,
        acladmin = 0,
        aclfound = false,
        fdadmin = "Нет",
        fd2admin = "Нет",
        autoaterror = false,
        autounmute = false,
        clickwarp = false,
        farchat = false,
        clearhouse = false,
        flyhack = false,
        invadm = false,
        coloradm  = 0,
        nameadm = 0,
        autonosave = false,
        intot = 0,
        intdo = 0,
        prizint = 0,
        prizvopros = 0,
        tagint = "",
        tagvopros = "",
        commandpriz = "",
        commandvopros = "",
        codeexit = "",
        codeexitvopros = "",
        voprosvopros = "",
    },
    clicker =
    {
        newgame = false,
        countoil = 0,
        oneclick = 1,
        upgradeclick = 1,
        upgrade1 = 0,
        upgrade2 = 0,
        zavod1 = 0,
        disel = 0,
        autoclick1 = 0,
    }

}, IniFilename)
inicfg.save(ini, IniFilename)


local ffi = require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local json = require("cjson")
local http = require("socket.http")
local requests = require 'requests'
local effil = require 'effil'
local https = require("ssl.https")


local renderAdminTools = new.bool()
local reconWindowTools = new.bool()
local reconStatsTools = new.bool()
local RINFO = new.bool()
local busAdminTools = new.bool()
local statsAdminTools = new.bool()
local offstatsAdminTools = new.bool()
local viktorinaAdminTools = new.bool()
local voprosAdminTools = new.bool()
local tpmenuAdminTools = new.bool()
local addtpAdminTools = new.bool()
local reportAdminTools = new.bool()
local gameAdminTools = new.bool()


local tab = 5
local show_loading = false
local loading_animation_angle = 0
local ipData = {}
local vpnData = {}
local keys = {
	onfoot = {},
	vehicle = {}
}
isSpectating = false
local rInfo = {
	state = false,
    id = -1,
    gethereid = -1,
    nickname = '',
    ped = -1,
}
local font = {}
local lastHouseData = { nick = nil, houseid = nil, typehouse = nil, waitingForGeton = false }


local banTime = new.int(16)
local banReason = new.char[128]("")
local banIPReason = new.char[128]("")
local jailTime = new.int(16)
local jailReason = new.char[128]("")
local kickReason = new.char[128]("")
local warnReason = new.char[128]("")
local lwarnReason = new.char[128]("")
local awarnReason = new.char[128]("")
local muteTime = new.int(16)
local amuteTime = new.int(16)
local muteReason = new.char[128]("")
local amuteReason = new.char[128]("")
local jokeChoose = new.int(16)
local autoantierror = new.bool(ini.settings.autoaterror)
local autounmute = new.bool(ini.settings.autounmute)
local clickwarp = new.bool(ini.settings.clickwarp)
local farchat = new.bool(ini.settings.farchat)
local flyhack = new.bool(ini.settings.flyhack)
local invadm = new.bool(ini.settings.invadm)
local autonosave = new.bool(ini.settings.autonosave)
local intot = new.int(ini.settings.intot)
local intdo = new.int(ini.settings.intdo)
local prizint = new.int(ini.settings.prizint)
local prizvopros = new.int(ini.settings.prizvopros)
local tagint = new.char[128](ini.settings.tagint)
local tagvopros = new.char[128](ini.settings.tagvopros)
local commandpriz = new.char[128](ini.settings.commandpriz)
local commandvopros = new.char[128](ini.settings.commandvopros)
local codeexit = new.char[128](ini.settings.codeexit)
local codeexitvopros = new.char[128](ini.settings.codeexitvopros)
local voprosvopros = new.char[128](ini.settings.voprosvopros)
local nametp = new.char[128]("")
local inttp = new.int(0)
local vwtp = new.int(0)

----

local comboColor = new.int(ini.settings.coloradm)
local item_color = {'Голубой', 'Зеленыый', 'Синий', 'Сиреневый', 'Красный', 'Оранжевый', 'Синий 2', 'Оранжевый 2', 'Серый', 'Томатный', 'Томатный 2', 'Глубокий розовый', 'Циан', 'Лаймово-зеленый', 'Золотой', 'Сине-фиолетовый', 'Багровый', 'Небесно-голубой', 'Ярко-розовый', 'Ярко-зеленый', 'Оранжево-красный', 'Темно-фиолетовый', 'Мятный', 'Темно-пурпурный', 'Доджер-синий', 'Персиковый'}
local ImColors = imgui.new['const char*'][#item_color](item_color)

local comboName = new.int(ini.settings.nameadm)
local item_name = {'Гл. администратор', 'No Name', 'Unknown', 'User', 'Admin', 'Jesus', 'Satana', 'Andrey_Holkin[0]', "Раб Denis'а Angelov'а", 'BingBot', 'Ривердейл'}
local ImNames = imgui.new['const char*'][#item_name](item_name)

local blue = "{319AFF}"
local lightblue = "{8cb3d9}"
local green = "{00ff00}"
local red = "{ff0000}"
local yellow = "{FFCD00}"
local purple = "{9370db}"
local white = "{ffffff}"
local darkpurple = "{a86cfc}"
local darkpink = "{cc3370}"
local orange = "{ff6600}"
local darkblue = "{4466cc}"
local darkred = "{b92228}"
local lightbrown = "{d2a679}"
local lime = "{ccff00}"
local cyan = "{00cc99}"
local lightgreen = "{00cc66}"
local lightred = "{FF6666}"
local pink = "{ff99cc}"
local lightgray = "{cecece}"
local black = "{000000}"
local brown = "{a47259}"
local lightyellow = "{d5ff80}"

local items = {
    [346] = lightyellow .. "Лён", [347] = blue .. "Хлопок", [348] = white .. "Бумбокс", [362] = white .. "Камень", [363] = pink .. "Золото", [364] = purple .. "Серебро", [539] = yellow .. "Бронза",
    [540] = lightbrown .. "Металл", [546] = white .. "Карточка победителя", [549] = yellow .. "Грибочки", [588] = yellow .. "Пчёлка", [589] = lightblue .. "Дельфин на спину", [590] = darkpurple .. "Визажист", [591] = orange .. "Дракон",
    [592] = darkpurple .. "Попугай Кеша", [593] = red .. "Девушка на спину", [594] = red .. "Кровавая накидка", [595] = yellow .. "Плащ бога", [596] = darkblue .. "НЛО на плечо", [597] = red .. "Мумия",
    [598] = darkred .. "Бог любви", [599] = lightbrown .. "Олень на плечо", [600] = lightblue .. "Улыбчивый смайлик", [601] = lightblue .. "Довольный смайлик", [602] = lightblue .. "Флиртующий смайлик",
    [603] = yellow .. "Лазерный меч", [604] = lime .. "Космонавт", [605] = cyan .. "Купидон", [606] = lightbrown .. "Винни Пух", [607] = green .. "Пучеглаз", [608] = yellow .. "Бананчик",
    [609] = yellow .. "Посох солнца", [610] = yellow .. "Магнит репутации", [612] = orange .. "Царский интерьер", [616] = lightgreen .. "Ангельское кольцо", [619] = lightgreen .. "Новогодний интерьер",
    [625] = lightgreen .. "Сияние ангела", [626] = red .. "Золотой жетон", [627] = yellow .. "Рюкзак шахтёра", [629] = red .. "Повышение админки", [630] = orange .. "Медаль ведьмы",
    [631] = yellow .. "Сохранение оружия после релога", [633] = yellow .. "День рождения", [634] = lightred .. "Карта АДМИНКА №12", [635] = lightred .. "Карта АДМИНКА №13", [636] = lightred .. "Карта АДМИНКА №14",
    [637] = lightred .. "Карта Confident", [638] = lightred .. "Карта Анти-Снятие", [639] = lightred .. "Карта Анти-Jail", [640] = lightred .. "Карта Верификация", [641] = red .. "Карточный сундук",
    [642] = yellow .. "Плеер MP3", [643] = yellow .. "Спанч Боб", [644] = yellow .. "Зомби дед", [645] = yellow .. "Спартанец", [646] = yellow .. "Зеленая смерть", [647] = yellow .. "Дарт Вейдер",
    [648] = yellow .. "Негр с гробом", [649] = red .. "Донат кейс", [650] = orange .. "Лотырейный билет", [651] = red .. "Блокировка инвентаря", [652] = yellow .. "Таракашка", [653] = yellow .. "Феечка",
    [654] = orange .. "Ведьма", [655] = orange .. "Конфеты", [656] = orange .. "Зелье ведьмы", [657] = orange.. "Майнкрафт", [658] = lightblue .. "Черепашка", [659] = lightblue .. "Смешарик",
    [660] = lightblue .. "Стич", [661] = lightblue .. "Кролик", [662] = lightblue .. "Подарок 2022", [663] = yellow .. "Ангел", [664] = yellow .. "Hello Kitty", [665] = red .. "Bitcoin (BTC)",
    [666] = darkpink .. "Влюбчивый смайлик", [667] = lime .. "NVIDIA GTX 1080Ti", [668] = lime .. "NVIDIA RTX 2080Ti", [669] = lime .. "NVIDIA RTX 3090Ti", [670] = red .. "NVIDIA RTX A5000",
    [671] = red .. "Охлаждающая жидкость", [672] = red .. "Смазка для разгона", [673] = pink .. "Свадебный подарок", [674] = yellow .. "Пикачу в шляпе", [675] = yellow .. "Веном", [676] = lightgray .. "Туалетомен",
    [677] = lightblue .. "Сонник", [678] = lightgray .. "Крик", [679] = lightgreen .. "Коронавирус", [680] = yellow .. "Красный Angry Birds", [681] = yellow .. "Черный Angry Birds", [682] = green .. "The Sims",
    [683] = yellow .. "Плюшевый мишка", [684] = red .. "Набор ресурсов", [685] = brown .."Какашечка", [686] = orange .. "Сияние демона", [687] = lightgray .. "Для взрослых 18+", [688] = lime .. "Кузнечик",
    [689] = yellow .. "Люкс интерьер", [690] = yellow .. "Элитный интерьер", [691] = yellow .. "VIP интерьер", [692] = red .. "Рубли", [693] = red .. "Кредитный счёт", [694] = lightblue .. "Подарок 2023",
    [695] = yellow .. "ФБР гитарист", [696] = yellow .. "Коп гитарист", [697] = yellow .. "Тоторо", [698] = yellow .. "Игрушки", [699] = lime .. "Копатыч", [700] = lime .. "Крипер", [701] = lime .. "Лунтик",
    [702] = lime .. "Патрик", [703] = lime .. "Чебурашка", [704] = lime .. "Микки маус", [705] = yellow .. "Лицензия на охоту", [706] = yellow .. "Тушка оленя", [707] = lightblue .. "Удочка", [708] = lightblue .. "Снасти",
    [709] = lightblue .. "Наживка", [710] = yellow .. "Рыба", [711] = orange .. "Halloween №1", [712] = orange .. "Halloween №2", [713] = orange .. "Halloween №3", [714] = lightblue .. "Подарок 2024",
    [715] = purple .. "Финн", [716] = purple .. "Джейк", [717] = purple .."БиМО", [718] = purple .. "Гюнтер", [719] = purple .. "Ягодка", [720] = purple .. "Стэн Марш", [721] = purple .. "Брофловски",
    [722] = purple .. "Маккоромик", [723] = purple .. "Крэйг", [724] = purple .. "Шеф Макэлрой", [725] = purple .. "Слизень", [726] = purple .. "Дракон края", [727] = purple .. "Страж",
    [728] = purple .. "Белый медведь", [729] = purple .. "Кися", [730] = pink .. "Буст x2 PayDay", [731] = pink .. "Буст x3 PayDay", [732] = pink .. "Буст x4 PayDay", [733] = pink .. "Буст x2 Активность",
    [734] = pink .. "Буст x3 Активность", [735] = pink .. "Буст x4 Активность", [736] = red .. "VIP очки"
}

local rulesText = ([[
1. Основные 
    1.1 - Запрещено использовать вредительские CLEO или читы, наказуемо* баном аккаунта до 7 дн. 
    1.2 - Запрещен намеренный DeathMatch (DM) - намеренное убийство, наказуемо тюрьмой до 15 м. 
    1.3 - Запрещено убивать игроков на спавне (на месте, где они появляются), наказуемо тюрьмой до 20 м. 
    1.4 - Запрещены убийства наездом или стрельбы из авто без причины, наказуемо тюрьмой до 15 м. 
    1.5 - Запрещено использование недоработок сервера для создания неудобств, наказуемо баном аккаунта до 7 дн. 
    1.6 - Запрещено использование недоработок сервера с целью личной выгоды, наказуемо баном аккаунта до 14 дн. 
    1.7 - Запрещено передавать игровой аккаунт (если имеется админка 14+ уровня), наказуемо баном аккаунта до 14 дн. 
    1.8 - Запрещен обман игроков с целью личной выгоды, наказуемо баном аккаунта до 7 дн. или баном чата до 120 минут* 
    1.9 - Запрещена любая провокация* ст. администрации, наказуемо баном аккаунта до 7дн. или бан чата на 60 минут.

2. Процесс общения
    2.1 - Запрещен частый мат и оскорбление других игроков, наказуемо баном чата до 30 м.
    2.2 - Запрещено оскорбление/упоминание родных игроков, наказуемо баном чата до 300 м.
    2.3 - Запрещены угрозы другим игрокам (не относящиеся к игровому процессу), наказуемо баном чата до 60 м.
    2.4 - Запрещена любая реклама сторонних ресурсов, наказуемо баном чата до 90 минут или баном аккаунта до 7 дн.
    2.5 - Запрещено флудить (написание одинаковых сообщений больше 5 раз), наказуемо баном чата до 15 м.
    2.6 - Запрещено оскорбление сервера или главного администратора, наказуемо баном чата до 120 м.

3. Администрация
    - Необходимо сообщать администрации сервера о любых случаях нарушения данных правил
    - Администрация по правилам выбирает штрафные санкции для каждого конкретного случая
    - Санкции могут применяться сразу после нарушения или через время (например, после рассмотрения жалобы)
    - Если штрафная санкция была применена к Вам ошибочно, свяжитесь с vk.com/andreylolkek

4. Для старшей администрации
    4.1 - Если игрок Вас оскорбил в легкой форме (дурак, тупой и тд), наказывать нет необходимости
    4.2 - Если игрок Вас оскорбил в средней форме (с исп. нецензуры), наказывать необходимо по п. 2.6
    4.3 - Если игрок Вас оскорбил в тяжелой форме (с упом. родных), наказывать необходимо по п. 2.2
    4.4 - Если игрок Вас оскорбил в любой форме и использует вредительское ПО, наказывать необходимо по п. 1.1
    4.5 - Если игрок получил от Вас бан / выговор / бан чата / тюрьму и снял за репутацию/обошел иным путем, а затем вновь начинает нарушать, то
    Вы в праве наказать повторно (но уже с x2 сроком), но при условии, что снятое наказание было выдано за п. 1.1, 1.2, 1.5, 1.7, 1.8, 2.2, 2.4, 2.6 (ВАЖНО)

5. Особые примечания
    5.1 - Ст. администратор превыше игроков, нарушения правил в сторону администратора (кроме п. 2.2) не наказываются
    5.2 - Ст. администратор обязан следить за помехой игровому процессу для других игроков, а не для себя
    5.3 - Ст. администратор обязан иметь доказательства на штрафные санкции (п. 1.1, 1.5, 1.7, 1.8, 1.9, 2.2, 4.1, 4.2, 4.3, 4.4, 4.5)
    5.4 - Ст. администратор не должен наказывать игроков только по 1 нарушению (п. 1.2, 1.3, 1.4, 1.5, 1.6, 1.8), необходимо проследить за повторением

6. Система выговоров
    6.1 - Если ст. администратор начинает угрожать / оскорблять игроков, то он получит выговор или бан чата до 300 минут*
    6.2 - Ст. администратор не должен конфликтовать с игроками, серьезные конфликты наказываются выговором
    6.3 - Ст. администратор - приоритетный пользователь, запрещено вести себя неподобающе (в случае нарушения выговор)
    6.4 - Если ст. администратор проявляет неуважение к другим ст. администраторам, то есть вероятность получить БЧ до 300 м.
    6.5 - Если ст. администратор обходит наказание от гл. администратора, то наказание будет применено по п. 1.6

* - Вид наказания может быть применен по наличию степени нарушения (легкое, среднее, среднее-многочисленное, тяжелое)
*1.1: Не наказуемо если было использовано в безлюдных местах, а так же не создавало помеху игрокам и игровому процессу в целом.
*1.9: К провокациям относятся, пробуждение специальных действий со стороны старшего администратора без каких либо оснований.
На первый раз выдать устное предупреждение, если после предупреждения игрок и дальше продолжает заниматься провокациями, то следует выдать бан чата на 60 минут, затем бан аккаунта.
]])

local nakText = ([[
    1. Игровой чат
        1.1 - Оскорбление = 60 минут
        1.2 - Упоминание родных = 300 минут
        1.3 - Флуд = 5-15 минут
        1.4 - Реклама = 30дн бана/бан IP
        1.5 - Капс = 5-15 минут
        1.6 - Неадекват = 30 минут
    2. A-чат
        2.1 - Оскорбление = 60 минут
        2.2 - Упоминание родных = 300 минут
        2.3 - Флуд = 5-15 минут
        2.4 - Реклама = 30дн бана/бан IP
        2.5 - Капс = 5-15 минут
        2.6 - Неадекват = 30 минут
    3. Читы
        3.1 - Читы на работе = 300 минут jail
        3.2 - Читы на DM = dkick, повторное 30 минут jail
        3.2 - Вред. читы = бан 7дн/30дн/бан IP
    4. Боты
        4.1 - Убийство ботов Harry_Test и [Bot]Denis_Test = 300мин jail
        4.2 - Использование ракбота в целях фарма rep = ЧС
        4.3 - Ломание ботов = -respect
        4.4 - Оск ботов = 300 минут
    5. Другое
        5.1 - Убийство без причины(DM), SK, TK = 30 минут jail
        5.2 - DB = 30 минут jail

    Старший администратор вправе удвоить наказание в случае повторения нарушения. Старший администратор всегда прав!
]])

local ACL1Text = ([[
    {ffffff}Команды AclRule 1.0
        {ffd700}/atops {ffffff}- рейтинг основателей
        {ffd700}/zpanel {ffffff}- панель ст. админа 
        {ffd700}/ripmans {ffffff}- игроки с вечным баном 
        {ffd700}/rconsay {ffffff}- RCON чат
        {ffd700}/offgivedonate {ffffff}- выдать донат очки оффлайн
        {ffd700}/offalvladmin {ffffff}- выдать админку (до 13) оффлайн
        {ffd700}/case(on/off) {ffffff}- вкл/выкл кейсы/подарки
        {ffd700}/rating(on/off) {ffffff}- вкл/выкл рейтинги 
        {ffd700}/agiverub {ffffff}- выдача рублей
        {ffd700}/apanel {ffffff}- панель основателей
        {ffd700}/(а)(un)dostup {ffffff}- снять/выдать фд1/2
        {ffd700}/(un)glava {ffffff}- выдача 16 лвл
        {ffd700}/givecmd {ffffff}- выдача команд
        {ffd700}/(un)farmer {ffffff}- снять/поставить ограничение'
]])
local ACL2Text = ([[
    {ffffff}Команды AclRule 2.0
        {ffd700}/antierror {ffffff}- снять ошибку безопастности
        {ffd700}/offawarn {ffffff}- выдать аварн оффлайн
        {ffd700}/offleader {ffffff}- снять лидера оффлайн
        {ffd700}/jetpack {ffffff}- получить джетпак
        {ffd700}/offgiverub {ffffff}- выдача рублей оффлайн
        {ffd700}/(on/off)prom {ffffff}- вкл/выкл ввод промокодов
        {ffd700}/offleader {ffffff}- список лидеров оффлайн
        {ffd700}/geton {ffffff}- последний вход игрока
    {ffffff}Команды AclRule 2.2
        {ffd700}/cuff {ffffff}- теперь доступна
        {ffd700}/aquest {ffffff}- вкл/выкл квест у игрока
        {ffd700}/title {ffffff}- выдача титулов
        {ffd700}/giveclist {ffffff}- выдать радужный клист
        {ffd700}/getakk {ffffff}- посмотреть пароль игрока
        {ffd700}/(un)osnova {ffffff}- снять/выдать AclRule 1.0 (нужен пин тому, кому хочешь выдать)
]])

local ACL3Text = ([[
    {ffffff}Команды AclRule 3.0
        {ffd700}/setpass {ffffff}- сменить пароль у игрока
        {ffd700}/atp {ffffff}- принудительная телепортация игроков
        {ffd700}/giveitems {ffffff}- выдать аксессуары
        {ffd700}/setarm {ffffff}- изменение брони
        {ffd700}/setcarhp {ffffff}- изменение хп у машины
        {ffd700}/settime {ffffff}- изменение времени
        {ffd700}/setweather {ffffff}- изменение погоды
]])
local ACL4Text = ([[
    {ffffff}Команды AclRule 4.0
        {ffd700}/gifts {ffffff}- логи подарков
        {ffd700}/addgift {ffffff}- выдача подарков
        {ffd700}/testmp {ffffff}- мероприятие Угадай Цифру
        {ffd700}/abanip {ffffff}- быстрый banip
        {ffd700}/nosave {ffffff}- не сохранять аккаунт
        {ffd700}/asms {ffffff}- предупреждение от модератора
        {ffd700}/asetint {ffffff}- изменить int у игрока
        {ffd700}/asetvw {ffffff}- изменить виртуальный мир у игрока
        {ffd700}/inter {ffffff}- тп в интерьеры
        {ffd700}/pmall {ffffff}- ответ от админа всем
        {ffd700}/savemans {ffffff}- игроки с запретом на сохранение
]])
local ACL5Text = ([[
    {ffffff}Команды AclRule 5.0
        {ffd700}/setduel {ffffff}- изменить настройки дуэли у игрока
        {ffd700}/present2 {ffffff}- пикап с подарком (/time)
        {ffd700}/present1 {ffffff}- изменить таймер подарка (/time)
        {ffd700}/giveblow {ffffff}- выдача салюта игрока
        {ffd700}/givepoints {ffffff}- выдача поинтов
        {ffd700}/competition {ffffff}- настройки голосования за семью
        {ffd700}/afk {ffffff}- игроки в афк
        {ffd700}/break {ffffff}- поставить ограждение
        {ffd700}/akick {ffffff}- выгнать из семьи
        {ffd700}/fbanlist {ffffff}- список ограниченных семей
        {ffd700}/fban {ffffff}- ограничить семью
        {ffd700}/unfban {ffffff}- снять ограничение у семьи
        {ffd700}/startvirus {ffffff}- начать зомби апокалипсис
        {ffd700}/zombieoff {ffffff}- выключить зомби апокалипсис
]])
local ACL6Text = ([[
    {ffffff}Команды AclRule 6.0
        {ffd700}/module {ffffff}- модули сервера
        {ffd700}/aip {ffffff}- список online aclrules
        {ffd700}/sp(t/a) {ffffff}- говорить за игрока(обычный/админ чат)
        {ffd700}/sp(me,s) /me, /s от имени игрока
        {ffd700}/test(kick/ban) {ffffff}- шуточный кик/бан
        {ffd700}/gocoord {ffffff}- тп по координатам
        {ffd700}/lego {ffffff}- режим лего
        {ffd700}/hbject {ffffff}- создание обьектов на игроке
        {ffd700}/eplayers {ffffff}- игроки с непройденной регистрацией
        {ffd700}/offadmins {ffffff}- список админов 15+ оффлайн
        {ffd700}/tempfamily {ffffff}- вступить в любую семью
        {ffd700}/allfamily {ffffff}- список всех семей
        {ffd700}/asetsex {ffffff}- изменить пол игроку
        {ffd700}/abonus {ffffff}- бонус без ограничений во времени
        {ffd700}/addzone {ffffff}- создание зз
        {ffd700}/temproom {ffffff}- вступить в приватную комнату
]])
local ACL7Text = ([[
    {ffffff}Команды AclRule 7.0
        {ffd700}Значок (А) в ooc чате
        {ffd700}/vdelete {ffffff}- testcmd
        {ffd700}/set(klass/poscar/cena) {ffffff}-  доступен на лег домах
        {ffd700}/asellhouse {ffffff}- доступен на лег домах
        {ffd700}/delpos {ffffff}- доступен на лег домах
        {ffd700}/savehouse {ffffff}- доступен на лег домах
]])
local ACL8Text = ([[
    {ffffff}Команды AclRule 8.0
        {ffd700}/addexp {ffffff}- выдача опыта семье
        {ffd700}/oi {ffffff}- мини-троллинг
        {ffd700}/uptop {ffffff}- принудительное обновление рейтинга
        {ffd700}/addbiz {ffffff}- создать бизнес
        {ffd700}/klad {ffffff}- тп к кладу
        {ffd700}/server {ffffff}- статистика сервера
        {ffd700}/settings {ffffff}- настройки цен
]])
local ACL9Text = ([[
    {ffffff}Команды AclRule 9.0
        {ffd700}/fixmysql {ffffff}- исправление чтения бд на русский язык
        {ffd700}/reloadnews {ffffff}- перезагрузка новостной ленты
        {ffd700}/unawarn {ffffff}- снятие аварнов
        {ffd700}/addquest {ffffff}- доступность квестов
        {ffd700}/age {ffffff}- поставить др игроку
        {ffd700}/gzcolor {ffffff}- изменение цвета квадратиков
        {ffd700}/mtest {ffffff}- АLT+ПКМ на расстоянии
        {ffd700}/prizeyear {ffffff}- красивый текст
        {ffd700}/aobj2 {ffffff}- уебищные обьекты самому себе
        {ffd700}/iinfo {ffffff}- название предмета
        {ffd700}/bank {ffffff}- работает на расстоянии
        {ffd700}/setsale {ffffff}- распродажа админок
    {ffffff}Доп. команды к AclRule 9.0
        {ffd700}/unrip {ffffff}- снять рип
        {ffd700}/giverep {ffffff}- выдать репутацию
        {ffd700}/addreps {ffffff}- выдать репутацию всем онлайн игрокам
        {ffd700}/arep {ffffff}- изменение репутации у игрока
        {ffd700}/giveactivity {ffffff}- выдать активность
        {ffd700}/apassword {ffffff}- пароль на сервер
        {ffd700}/confident {ffffff}- выдать Confident
        {ffd700}/averify {ffffff}- выдать/снять верификацию
        {ffd700}/createprom {ffffff}- создать промокод
        {ffd700}/additem {ffffff}- выдать предмет
        {ffd700}/delitem {ffffff}- удалить предмет
        {ffd700}/anti(jail/sniat) {ffffff}- выдать услугу анти-джаил/снятие
        {ffd700}/offosnova {ffffff}- выдача AclRule оффлайн
        {ffd700}/ajail {ffffff}- посадить/выпустить в безлимитную тюрьму
]])
local ACL10Text = ([[
    {ffffff}Команды AclRule 10.0
        {ffd700}/note {ffffff}- сделать запись в /show
        {ffd700}/auc {ffffff}>> Административный раздел
        {ffd700}/reloadtasks {ffffff}- перезагрузка /tasks
        {ffd700}/lsd {ffffff}- пикапы в виде таблеток
        {ffd700}/offrepedit {ffffff}- изменение репутация в оффе
        {ffd700}/repedit {ffffff}- изменение репутации в онлайне
        {ffd700}/editcode {ffffff}- изменить PIN-код
        {ffd700}Команды изменения домов/бизов {ffffff}- доступны
        {ffd700}/pkick {ffffff}- кикнуть с ПБ
        {ffd700}/givekill {ffffff}- выдать очки дм
]])


--== Vars ==--
local icolors = {}
local sizeX, sizeY = getScreenResolution()
keyToggle = VK_F5
secondaryKey = VK_B
positionX = 10
positionY = sizeY/2
pagesize = 13
messagesMax = 500
blacklist = {
	'На паузе %d+:%d+',
	'На паузе %d+ сек.',
    '%+%d+ активн%. %+ %d+ бонус',
	'+%d hp'
}
playerColor = nil
local giveitemstate = false
local idgiveitem = -1
local ditemstate = false
local finditem = "nil"
local itemsht
local dunjailstate = false
local flySpeed = 40
local busRace1 = false
local busRace2 = false
local busRace3 = false
local REP = 0
local points = 0
local checkpoints = 0
local allcheckpoints = 0
local countrace = 0
local cursorEnabled = false
local statstext = "nil"
local offstatstext = "nil"
local statstitle = "nil"
local offstatstitle = "nil"
local vikstr = 0
local successint = 0
local successvopros = ""
local voprosstr = 0
local sizebutton = nil
local aclFound = false
local teleports = {}
local teleportsFilePath = "teleports.json"
local reportid, reportnick, reporttext, reportsuccess = "", "", "", false

--== AdminMenu ==--
local dialogcolor = false
local dialogname = false
local dialoginv = false
local aint, avw, resultiv = "", "", false

--== IP ==--
local ip, port = sampGetCurrentServerAddress()
local ipcondition = ip ~= "46.174.54.87" and ip ~= "46.174.54.127"
local ipFatality = "46.174.54.87"
local ipBing =  "46.174.54.127"

--== Notifications ==--
local notifications = {}
local modal_notifications = {}
local next_id = 1
local modal_next_id = 1
local default_duration = 5.0
local error_data = "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x54\x00\x00\x00\x54\x08\x06\x00\x00\x00\x1C\x6B\x10\xC1\x00\x00\x01\x37\x69\x43\x43\x50\x41\x64\x6F\x62\x65\x20\x52\x47\x42\x20\x28\x31\x39\x39\x38\x29\x00\x00\x28\x91\x95\x8F\xBF\x4A\xC3\x50\x14\x87\xBF\x1B\x45\xC5\xA1\x56\x08\xE2\xE0\x70\x27\x51\x50\x6C\xD5\xC1\x8C\x49\x5B\x8A\x20\x58\xAB\x43\x92\xAD\x49\x43\x95\x62\x12\x6E\xAE\x7F\xFA\x10\x8E\x6E\x1D\x5C\xDC\x7D\x02\x27\x47\xC1\x41\xF1\x09\x7C\x03\xC5\xA9\x83\x43\x84\x0C\x05\x8B\xDF\xF4\x9D\xDF\x39\x1C\xCE\x01\xA3\x62\xD7\x9D\x86\x51\x86\xF3\x58\xAB\x76\xD3\x91\xAE\xE7\xCB\xD9\x17\x66\x98\x02\x80\x4E\x98\xA5\x76\xAB\x75\x00\x10\x27\x71\xC4\x18\xDF\xEF\x08\x80\xD7\x4D\xBB\xEE\x34\xC6\xFB\x7F\x32\x1F\xA6\x4A\x03\x23\x60\xBB\x1B\x65\x21\x88\x0A\xD0\xBF\xD2\xA9\x06\x31\x04\xCC\xA0\x9F\x6A\x10\x0F\x80\xA9\x4E\xDA\x35\x10\x4F\x40\xA9\x97\xFB\x1B\x50\x0A\x72\xFF\x00\x4A\xCA\xF5\x7C\x10\x5F\x80\xD9\x73\x3D\x1F\x8C\x39\xC0\x0C\x72\x5F\x01\x4C\x1D\x5D\x6B\x80\x5A\x92\x0E\xD4\x59\xEF\x54\xCB\xAA\x65\x59\xD2\xEE\x26\x41\x24\x8F\x07\x99\x8E\xCE\x33\xB9\x1F\x87\x89\x4A\x13\xD5\xD1\x51\x17\xC8\xEF\x03\x60\x31\x1F\x6C\x37\x1D\xB9\x56\xB5\xAC\xBD\xF5\x7F\xFE\x3D\x11\xD7\xF3\x65\x6E\x9F\x47\x08\x40\x2C\x3D\x17\x59\x41\x78\xA1\x2E\x7F\x55\x18\x3B\x93\xEB\x62\xC7\x70\x19\x0E\xEF\x61\x7A\x54\x64\xBB\x37\x70\xB7\x01\x0B\xB7\x45\xB6\x5A\x85\xF2\x16\x3C\x0E\x7F\x00\xC0\xC6\x4F\xFD\xF3\x53\x3F\xC8\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x2E\x23\x00\x00\x2E\x23\x01\x78\xA5\x3F\x76\x00\x00\x05\xD1\x69\x54\x58\x74\x58\x4D\x4C\x3A\x63\x6F\x6D\x2E\x61\x64\x6F\x62\x65\x2E\x78\x6D\x70\x00\x00\x00\x00\x00\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x62\x65\x67\x69\x6E\x3D\x22\xEF\xBB\xBF\x22\x20\x69\x64\x3D\x22\x57\x35\x4D\x30\x4D\x70\x43\x65\x68\x69\x48\x7A\x72\x65\x53\x7A\x4E\x54\x63\x7A\x6B\x63\x39\x64\x22\x3F\x3E\x20\x3C\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x3D\x22\x61\x64\x6F\x62\x65\x3A\x6E\x73\x3A\x6D\x65\x74\x61\x2F\x22\x20\x78\x3A\x78\x6D\x70\x74\x6B\x3D\x22\x41\x64\x6F\x62\x65\x20\x58\x4D\x50\x20\x43\x6F\x72\x65\x20\x35\x2E\x36\x2D\x63\x31\x34\x35\x20\x37\x39\x2E\x31\x36\x33\x34\x39\x39\x2C\x20\x32\x30\x31\x38\x2F\x30\x38\x2F\x31\x33\x2D\x31\x36\x3A\x34\x30\x3A\x32\x32\x20\x20\x20\x20\x20\x20\x20\x20\x22\x3E\x20\x3C\x72\x64\x66\x3A\x52\x44\x46\x20\x78\x6D\x6C\x6E\x73\x3A\x72\x64\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x77\x33\x2E\x6F\x72\x67\x2F\x31\x39\x39\x39\x2F\x30\x32\x2F\x32\x32\x2D\x72\x64\x66\x2D\x73\x79\x6E\x74\x61\x78\x2D\x6E\x73\x23\x22\x3E\x20\x3C\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x20\x72\x64\x66\x3A\x61\x62\x6F\x75\x74\x3D\x22\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x4D\x4D\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x6D\x6D\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x45\x76\x74\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x45\x76\x65\x6E\x74\x23\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x64\x63\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x70\x75\x72\x6C\x2E\x6F\x72\x67\x2F\x64\x63\x2F\x65\x6C\x65\x6D\x65\x6E\x74\x73\x2F\x31\x2E\x31\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x31\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x31\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x31\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x64\x65\x31\x61\x39\x35\x32\x37\x2D\x63\x32\x30\x64\x2D\x31\x31\x34\x30\x2D\x38\x62\x35\x33\x2D\x37\x65\x65\x66\x32\x33\x64\x39\x66\x39\x30\x66\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x61\x38\x30\x30\x38\x37\x33\x66\x2D\x32\x34\x61\x61\x2D\x38\x30\x34\x35\x2D\x62\x36\x38\x62\x2D\x31\x65\x62\x65\x35\x66\x36\x37\x62\x66\x37\x32\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x39\x39\x66\x36\x64\x38\x39\x62\x2D\x66\x36\x30\x32\x2D\x36\x63\x34\x63\x2D\x38\x38\x33\x32\x2D\x32\x65\x32\x32\x31\x61\x63\x32\x34\x38\x34\x38\x22\x20\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3D\x22\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3D\x22\x33\x22\x3E\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x63\x72\x65\x61\x74\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x39\x39\x66\x36\x64\x38\x39\x62\x2D\x66\x36\x30\x32\x2D\x36\x63\x34\x63\x2D\x38\x38\x33\x32\x2D\x32\x65\x32\x32\x31\x61\x63\x32\x34\x38\x34\x38\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x31\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x64\x65\x31\x61\x39\x35\x32\x37\x2D\x63\x32\x30\x64\x2D\x31\x31\x34\x30\x2D\x38\x62\x35\x33\x2D\x37\x65\x65\x66\x32\x33\x64\x39\x66\x39\x30\x66\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x31\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x52\x44\x46\x3E\x20\x3C\x2F\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x3E\x20\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x65\x6E\x64\x3D\x22\x72\x22\x3F\x3E\xFC\xB9\x6A\x9E\x00\x00\x0A\x78\x49\x44\x41\x54\x78\x9C\xED\x9D\x7D\x90\x55\x65\x1D\xC7\x3F\xF7\xDE\x5D\x96\xDD\x05\xB7\xC5\x68\x35\x34\xD6\x17\x42\x25\x68\xCC\x90\xC9\x66\x2A\xC7\x41\xAB\x35\x93\x36\x21\x83\xB1\x17\xD4\x30\x17\xD3\xDE\x5F\x4C\x2A\xA5\x4C\x93\x14\x8A\xB2\x0C\x9D\x98\xA1\xC0\x97\x4A\x47\x8C\x35\x51\x62\x22\x25\x6B\x13\x9D\x34\x95\x81\x52\x16\x15\xE2\x5E\xDE\x5A\x71\xEF\xDD\xDB\x1F\xDF\x73\xD8\xBB\x97\xFB\x72\x9E\xF3\x3C\xE7\xDE\xBD\xE4\x77\x66\x87\xE1\x9C\xF3\x7B\x9E\x73\xBF\xF7\x77\x9E\x97\xDF\xEF\xFB\x3B\x37\x96\xCD\x66\x79\x1D\xEE\x10\xCB\x4E\x9F\x5E\xED\x7B\xC8\x45\x0C\x68\x02\xDE\x00\xB4\x00\xA3\x81\x06\xA0\x1E\xC8\x02\x69\xE0\x00\xB0\x17\xD8\x0D\xEC\x02\x5E\xF5\xCE\x55\x1F\xDD\xDD\xD4\x55\xB1\xFB\x38\xD0\x0A\x4C\x00\xA6\x78\x7F\xC7\x03\x6D\xC0\x58\x44\x68\x13\x1C\x72\x8F\xFD\xC0\x7F\x81\x24\xB0\x13\xE8\x05\x9E\x05\x9E\x00\x9E\x02\x9E\x07\xF6\x45\x7F\xFB\x85\x51\x69\x42\x13\x40\x3B\xF0\x3E\xE0\x4C\x60\x2A\x70\x1C\xF2\xC0\xA0\xA8\x47\x64\xB7\x78\x6D\xE5\x62\x2F\xF0\x0C\xB0\x01\x78\x10\x78\x14\xF8\x8F\xC5\xFD\x1A\xA3\x52\x84\xB6\x02\xE7\x00\x9D\x88\xC8\x23\x23\xEA\x67\x34\xFA\x92\xA6\x02\x97\x03\xFF\x04\x56\x03\x77\x01\x3D\xC8\xBB\x23\x45\xD4\x84\xBE\x05\xF8\x04\x30\x07\x78\x6B\xC4\x7D\xE5\xA3\x0E\x98\xE4\xFD\xCD\x43\x1E\xBB\x0C\x58\x0B\xF4\x45\xD9\x69\x14\x38\x06\xF8\x0C\x30\x17\x38\x3A\xA2\x3E\x4C\x30\x1A\xF8\x08\x70\x2E\xF0\x30\xB0\x18\x11\xEC\xDC\x63\xE3\x8E\xDB\x6B\x46\x44\x3E\x02\x5C\xCD\xF0\x20\x33\x17\x23\xD0\xD0\xB3\x0A\xF8\x39\x30\xD9\x75\x07\x2E\x09\x7D\x07\xF0\x6B\x60\x29\x70\x82\xC3\x76\xA3\x40\x33\x1A\x8A\xEE\x07\xE6\x03\xA3\x5C\x35\xEC\x82\xD0\x7A\x34\x01\xDC\x87\x1E\x29\xD7\x5E\x1F\x25\x8E\x05\x16\xA1\xB1\xF5\x64\x17\x0D\xDA\x7E\xF8\x36\xE4\x91\x8B\x80\x37\xDB\xDF\x4E\x55\x50\x07\x5C\x00\xAC\x04\x3E\x64\xDB\x98\x0D\xA1\x27\x03\x77\x00\x17\xA3\xB1\xA9\xD6\x31\x19\xF8\x19\xD0\x85\x76\x6C\xA1\x10\x96\xD0\xD3\x80\xDB\x81\xF7\x87\xED\x78\x98\xE2\x28\xE0\x3A\x60\x01\x21\x57\x40\x61\x08\x3D\x1D\xCD\x90\xD3\xC2\x74\x58\x03\x68\x01\xBE\x00\x2C\x24\x04\xA9\xA6\x06\x53\xD1\x63\xF1\x76\xD3\x8E\x6A\x0C\xA3\x80\xCF\x22\x87\xFB\x2A\x90\x09\x6A\x68\xE2\xA1\x13\x80\x5B\x38\xFC\xC9\xF4\x31\x0A\xB8\x04\xF8\x86\x89\x51\x50\x42\x5B\x10\x99\xEF\x32\xBC\xA9\x5A\x47\x0B\x9A\xA4\x2E\x0D\x6A\x10\x94\xD0\xEB\x51\x50\xE3\xFF\x11\x63\x81\xAF\x01\x67\x05\xB9\x38\x08\xA1\x5D\xC0\x4C\x60\xA4\xC5\x4D\xD5\x3A\xDA\x81\x6B\x81\x71\xE5\x2E\x2C\x47\xE8\x34\xE0\xF3\xC0\x18\xFB\x7B\xAA\x79\x9C\x0A\x5C\x53\xEE\xA2\x52\x84\xD6\x01\xDF\x02\xC6\x3B\xBA\xA1\xD7\x80\xFD\x8E\xDA\x32\xC1\xD3\xC0\x4B\x0E\xDA\x19\x89\x22\x56\x33\x4B\x5D\x54\x8A\xD0\xF9\x68\x12\x72\xB1\x37\xDF\x06\x5C\x81\x66\xCD\x4A\x92\xFA\x7B\xE0\x6C\x14\x08\x79\xDE\x41\x7B\x47\xA2\x35\xEA\x9B\x8A\x5D\x50\x8C\xAC\x13\xD1\x3A\xAC\xC5\xC1\x4D\xF4\x02\x5F\x07\x6E\x45\xD1\xA8\x79\x28\x27\x14\x35\xEE\x43\x9F\xE1\x45\xA0\xDB\xEB\xF7\x1F\x96\x6D\xC6\x50\xC0\x7A\x7E\xB1\x0B\x8A\x11\x7A\x15\x0A\x12\xDB\xE2\xDF\x68\x0C\xFE\xA5\xF7\xFF\x2C\xF0\x2B\x14\x78\x8E\x32\x91\x76\x17\x8A\x80\x6D\xC9\x39\xF6\x90\xD7\xEF\xDF\x2C\xDB\x6E\x46\x19\x88\x93\x0A\x9D\x2C\x44\xE8\x14\xE0\x3C\xEC\x67\xF5\x2D\xC0\x95\x28\x8A\x93\x8B\x0C\x70\x27\xFA\x70\x51\xA4\x22\x56\x7A\xFD\xBE\x50\xE0\xDC\xA3\x28\x98\xF3\x67\xCB\x3E\xDA\x80\x4F\x17\x3A\x51\x88\xD0\x8B\x81\x37\x5A\x76\xB8\x19\x3D\x16\xBF\x29\x72\x3E\x03\xDC\x83\xC6\x36\x97\x8F\xFF\x72\x44\xE6\xB6\x12\xD7\xF4\xA0\x85\xFA\x43\x16\xFD\x34\xA2\x84\x63\x7B\xFE\x89\x7C\x42\x27\x62\xEF\x9D\x4F\xA0\xC9\xE7\xFE\x32\xD7\xA5\x11\xA9\x73\x70\xF3\xF8\xDF\x8A\x86\x97\x20\x33\xFA\x53\x68\x92\x7C\xD8\xA2\xBF\xA3\x80\x59\xF9\x07\xF3\x09\xFD\x28\x25\x66\xB0\x80\x78\x10\xE5\x94\x82\x20\x83\x26\x8F\x8F\x23\x25\x48\x58\x2C\x46\xBB\x99\x9D\x06\x36\xE3\x51\x56\x36\x2C\x46\x02\x33\x90\x18\xE3\x20\x72\x09\x6D\x06\x3A\x90\xF4\xC5\x06\xF3\xD1\xAC\x1E\x34\x48\x9B\x06\x1E\x00\x66\x13\x8E\xD4\x45\x28\x7E\x99\x34\xB0\xE9\x00\x96\x60\x97\xFB\x8A\x03\xA7\x20\xD1\xC6\x90\x83\x3E\xDE\x09\xBC\x0D\xFB\x75\x67\x03\xF0\x4D\x94\xF5\x0C\x8A\x34\xB0\x06\x79\xEA\x1E\x03\xBB\xEF\x03\xDF\x06\x52\x06\x36\x1D\xC0\xCD\xB8\x49\x24\x36\xA0\x2C\xEA\x41\xE4\x92\xF7\x01\xDC\xA5\x32\x1A\x50\xD8\x6B\x81\x81\x4D\x1A\xAD\x17\x3B\x09\xE6\x6D\xD7\xA0\xFD\xB5\xC9\x17\x70\x1E\x1A\x1E\x4E\x34\xB0\x29\x85\x7A\x14\x34\x3A\xB8\x35\xF7\x09\xAD\x03\xDE\x8D\x99\xC6\xA8\x1C\x1A\x50\x70\xF6\x3A\x03\x9B\x34\x9A\x28\x3A\x81\x1D\x25\xAE\xFB\x12\x70\x23\x66\xBB\xAE\x19\xC8\x33\x8F\x37\xB0\x29\x87\x98\xD7\xDE\xA9\xFE\x01\x9F\xD0\x93\x90\x54\xC6\x75\x0A\x78\x24\x9A\x79\x17\x1A\xD8\x64\x80\x3F\x22\x52\x5F\x2E\x70\xFE\x4A\x34\xFE\xBD\x6A\xD0\xE6\x0C\x34\xD6\x1E\x67\x60\x13\x14\xF5\xC8\x19\x81\x41\x02\x27\x03\x47\x44\xD0\x19\x68\xCD\x76\x15\xF0\x5D\x03\x9B\x0C\xF0\x27\x94\xDE\xF5\x3D\x35\x8D\x76\x3F\x4B\x91\x46\x34\x28\x7C\x32\xDB\x0D\x6C\x4C\x90\x40\x59\x8C\x38\x0C\x12\x3A\xC9\x3B\x11\x15\x1A\x91\x67\x5D\x6F\x60\x33\x80\x48\x3D\x1F\x45\x8C\x2E\x43\x6B\x4D\x13\x3D\x52\x27\xF0\x43\xA2\x23\x13\xC4\xE1\x44\xBC\xCD\x50\x1D\x83\xD3\x7F\xD4\x8A\x8F\x46\xB4\x98\xAE\x03\xBE\x18\xD0\x66\x00\x69\x3D\xCF\xC0\x6C\x26\x07\x85\xD9\x7E\x80\xD4\x21\x51\x22\xE6\xF5\x31\x0E\x78\x25\x8E\x92\x51\xED\x58\x24\xF7\x0D\xD0\x88\x3C\xED\x26\x43\xBB\x94\xE1\xF5\xB3\xBC\x3E\xA2\x26\xD3\x47\x23\x5E\x30\x29\x8E\x42\x74\xAD\x54\x86\x50\xD0\xCE\xE2\x32\xF4\x28\x46\x81\x0B\x90\x67\xBA\x88\x96\x05\x45\x8C\x1C\x42\xC7\x20\x2F\xAD\x14\xA1\xA0\x6F\xF4\x52\xDC\x93\x3A\x0B\x2D\x8D\x2A\x49\xA6\x8F\x63\x61\xD0\x43\xAB\xA1\x4D\x6A\x42\xA4\xDE\xE2\xA8\xBD\xD9\x5E\x5B\xD5\x10\xAD\xC5\x50\x76\x94\x38\xF2\x96\x6A\x55\x83\x34\xA1\x70\xE1\x12\xCB\x76\x66\xA3\xA5\x51\x9B\xF5\x1D\x85\x43\x0C\xA9\xA4\x89\x23\xEF\xAC\xA6\xA6\xD3\x27\xF5\xB6\x90\xF6\xEF\x05\x6E\xC0\x3E\x4A\x66\x8B\x11\x20\x22\x87\x43\xD1\x54\x9A\xF0\x99\xC9\x1E\xE0\x0F\x98\x2D\xF6\xA3\x40\x0C\x44\x68\x3F\x06\x62\xA8\x08\xB0\x1B\xED\xA2\x4C\xA2\x53\xB9\xD8\x83\x22\xFF\xB7\x11\x61\x75\x47\x00\x64\x40\x84\xEE\x47\x39\xF3\x6A\x20\x85\x76\x4F\xDF\x73\xD0\x56\x17\xF0\x23\xAA\x53\x45\x97\xC5\x0B\xD4\xC4\xD1\x37\x5C\x8D\xC7\x25\x85\xC6\x3E\x93\xED\x68\x39\x7C\x19\xCD\xF4\x7B\x1D\xB6\x19\x14\x49\x10\xA1\x49\xEF\x06\x2A\x39\x96\xA6\x10\x99\x2E\x3C\x33\x1F\x57\xA3\xC0\xB3\x4D\x4A\xC5\x14\x59\x60\x3B\x88\xD0\x14\x8A\xE8\x54\x8A\xD0\x24\x22\x32\x0A\x32\x7D\x2C\x44\xC1\xE7\x5D\x11\xF6\x91\x8B\x2C\xD2\x20\x10\x47\x63\xCE\x66\x14\x88\x88\x1A\x3E\x99\x37\x18\xD8\xC4\x50\x32\xCD\x34\x1A\x76\x13\xF2\xD6\x57\x0C\xED\xC2\x20\x4D\x0E\xA1\x59\x54\x64\x1A\x35\xA1\x29\x34\x5E\xDE\x68\x60\x13\x47\x9A\xFE\x47\x10\x41\xA6\x19\x85\x9F\xA0\x6C\xA8\x0B\xB1\x58\x31\x64\xBD\xF6\x5F\x84\xC1\x05\xFD\x93\x44\xBB\x74\x4A\xA1\x54\x88\x89\x67\xC6\x91\x9C\xF2\x6E\x14\x69\xFF\x1C\x0A\x7A\x98\x66\x65\x97\x21\x81\x57\x29\xF1\x83\x0D\x06\xD0\x13\xFE\x12\x0C\x25\x74\x3B\xD1\x8C\xA3\x49\x94\x99\x34\x09\xD9\x25\x50\x5A\xE1\xB7\x0C\x15\xB9\x5E\x81\x82\x1F\x4D\x87\x9A\x94\xC4\x0A\xF4\x85\x6C\x35\xB4\x0B\x82\x01\xE0\xEF\x78\x2B\x25\x9F\xD0\xAD\xC0\x26\xDC\x7B\x69\x12\x69\x4C\x6F\x36\xB0\x49\x00\xEF\x41\x32\x9E\x42\xDB\xC9\x79\x5E\x7B\xA6\xF5\x99\x77\x23\x35\xDE\x73\x86\x76\xE5\x90\x46\x39\x30\x60\x90\xD0\x2C\x1A\xA7\x5C\x96\x3B\xA7\x90\x67\x2E\x36\xB0\xF1\xC9\x5C\x45\xE9\x97\x14\x5C\x82\x48\x35\x95\x5B\x3E\x80\x1B\x59\xA3\x8F\x2C\xF0\x2F\xE0\x71\xFF\x40\x6E\x50\x64\x1D\x66\xEA\x8B\x52\xD8\x83\x72\xF2\x26\xA1\xB9\x04\xCA\x71\xDF\x49\x30\xB1\xDA\x5C\xF4\x65\x99\xCA\xD5\xD7\x22\x52\x9F\x34\xB4\x2B\x04\xDF\x3B\xB7\xFB\x07\x72\x09\xDD\x84\x64\x7E\xB6\x5E\x9A\x04\xBE\x82\xB9\x67\x9E\x8D\xC8\x34\x79\x7D\xC6\x45\xC0\x8F\xF1\x62\x91\x06\x58\x8F\xEA\xFA\x7B\x0C\xED\xF2\x71\x00\xB8\x37\xF7\x40\x2E\xA1\x03\x68\x12\x30\xC9\x77\x17\xC2\x4F\xBD\xBF\xA0\xA8\x43\x65\xE1\x2B\xD1\xEB\x85\x4C\xF1\x31\xB4\x87\x37\x8D\x85\x1E\x81\x17\xC3\x0C\x89\x01\xA4\x34\x5C\x97\x7B\x30\x3F\x0E\xBA\x06\xA5\x6C\x6D\xD6\xA4\x17\xA2\xBC\x4E\x10\x24\x90\xD6\x68\x39\x76\x1F\x6E\x26\xF2\xD4\xA0\x6F\x90\x38\x13\x05\xA4\x6D\x24\x39\x7D\xC8\x09\x86\x04\x63\xF2\x09\xDD\x81\xE4\xD4\x36\x22\xD8\x76\x14\x81\xBF\xA8\xCC\x75\x09\xA4\x35\xB2\x25\xD3\x47\x27\x5A\xC8\x97\xCB\x27\x4D\x43\x9B\x8B\x53\x2C\xFA\xCA\xA2\xB5\xE7\xAA\xFC\x13\x85\x22\xF5\x2B\xF0\xB6\x51\x16\x68\x43\x8B\xF0\xB9\x45\xCE\x27\x50\x89\x8A\x2B\x32\x7D\x7C\x18\x0D\x37\xC5\x4A\x81\xA6\x20\xCF\x3C\xCD\xB2\x9F\xFD\xA8\x6E\xE0\x10\xA9\x50\x21\x42\xB7\xA1\x0F\x6A\x1B\x02\x1B\x8B\x76\x46\x5D\x79\xC7\x13\x68\xDC\xBB\x03\x69\x52\x5D\xA3\x03\x29\x4C\xF2\x45\x61\x13\xD1\x52\xEB\x0C\xCB\xF6\xB3\x48\x01\x7D\x7B\xA1\x93\xC5\x72\x49\xBF\x40\xFB\x7B\x5B\x8C\x01\xBE\x83\xB6\x7E\x3E\x2E\x44\xF5\xF6\xA6\xBB\x1D\x13\x9C\x83\x3C\x75\x82\xF7\xFF\x71\xE8\x89\x71\x51\xAF\x9A\x44\x5F\x4C\xC1\x48\x56\xB1\x6C\xE7\x0E\xF4\x2D\x9F\x80\x44\x10\x36\x68\x45\x01\x8A\x11\x68\x11\xBC\x14\x65\x5A\xA3\xC6\x74\x34\x56\x2E\x44\x22\xB3\x73\x1D\xB4\x79\x00\xF8\x1D\x87\x56\xB6\x1C\x44\xA9\xB7\x33\x26\xD0\xF6\xEF\x83\xB8\x11\x92\x0D\xA0\xAD\xAD\x4B\x0D\x6A\x10\xF4\x21\xC7\x71\xD1\xEF\x26\x34\xF6\x6F\x2E\x78\xB6\xBB\xBB\x64\xFA\x38\x83\x82\xB4\x5B\x4A\x5C\x63\x82\x38\x95\x27\x13\xF4\x34\xB8\xE8\xF7\x65\xB4\x95\x2E\x4C\xA6\x87\x72\xF9\xF8\xBF\xA0\xF5\x9D\xAB\x2D\x69\xAD\x62\x2F\x1A\xF7\xEF\x29\x77\x61\x10\x81\xC3\x12\x54\xFA\x52\xAD\xCC\x68\xB5\xD1\x8F\x6A\xAE\x02\x49\xDB\x83\x10\x9A\x41\xA9\x84\x0D\x16\x37\x55\xCB\x58\x87\x56\x29\x81\x32\xC3\x41\x25\x38\x2F\xA0\x42\x81\x4D\x21\x6F\xAA\x56\xB1\x01\xAD\xA3\x7B\x83\x1A\x98\x68\x9A\x1E\x47\xCB\x1F\x17\x75\xE7\xB5\x80\x8D\x28\x43\x60\xB4\x1E\x37\x15\x89\xAD\x46\xEE\x5F\x72\xA6\x3B\x0C\xB0\x11\x89\x82\xFF\x6A\x6A\x18\x46\x75\x77\x2F\xFA\xE6\x9E\x0D\x61\x5B\x0B\x58\x8B\x45\x5D\x7D\x58\x19\xE3\x6A\xE0\x53\xA8\xFE\xFC\x70\x41\x3F\x0A\x78\x7C\x12\xED\xD5\x43\xC1\x46\x17\xBA\x01\x85\xE8\x56\xA2\x54\x40\x2D\x63\x17\xDA\xC4\x5C\x4E\xE1\x17\x17\x04\x86\xAD\xD0\xF6\x39\x94\x4A\x58\x40\xE9\x52\xC2\xE1\x8C\x1E\xF4\x76\x86\x6B\x71\xA0\xDC\x73\xA1\x5C\xF6\xF5\x9D\x9D\xA8\xF8\x75\x38\x08\x78\x83\x20\x85\x92\x88\xE7\xA3\x80\x87\x13\xB8\x94\x82\xAF\x47\xA9\x88\x2E\xDC\x84\xFE\xA2\xC2\x6B\x68\x0E\xE8\x44\x25\x93\xB6\xC1\xF4\x21\x70\xAD\xAD\xDF\x8D\xC2\x73\x67\xA1\x4A\xE4\x67\x1C\xB7\x6F\x83\x3E\xF4\xB6\x89\x39\xA8\xFC\x66\x2D\x11\x3C\x4D\x51\x55\x7F\x6C\x43\x1A\xCD\xE5\xA8\x78\x75\x26\x7A\xC1\x41\x94\x41\xE5\x62\xD8\x89\x88\x5C\x81\xC4\x1C\x91\x2A\x9C\xA3\x2E\xA7\xE9\x45\xD1\xAA\x65\x88\xD0\x0E\x14\xF8\x9D\x48\x34\xE9\x0F\x1F\xBB\xD0\x64\xB3\x06\x8D\xEB\x4F\x53\xA1\xE0\x4E\xA5\xEA\x93\xFA\xD0\x18\xBB\x1E\x45\x6D\x26\xA1\xB7\xE5\x9E\x8E\x4A\xCB\x8F\x41\xB2\x9A\x30\x71\xCB\x7E\x14\x5E\xDC\x8A\xD6\x8F\x1B\x81\xC7\xD0\x70\x63\xAB\x31\x30\x46\x35\x0A\xBE\xF6\xA1\x0F\xFC\x18\x12\xD3\x36\xA3\xEA\xB7\xF1\x28\x05\x7D\x34\x4A\xF0\xB5\x32\xF8\x7B\x4A\x75\x28\xE2\x7F\x00\x65\x1C\x53\x68\x99\xD6\x8B\xD2\x2A\x5B\xD1\x30\xB3\x87\x2A\xAF\x32\xAA\xF9\x7B\x4A\xA0\x0F\xBF\x0F\x6D\x63\xFD\xAD\xAC\xFF\x23\x55\x8D\xDE\xBF\xF5\x0C\x0A\x83\xFB\x11\xA9\x7D\x88\xD8\x61\xB7\xA1\x88\xBD\xFE\x13\x6A\x6E\xF1\x3F\x15\xC5\x18\xCF\x05\x94\xA9\xFF\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"
local info_data = "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x54\x00\x00\x00\x54\x08\x06\x00\x00\x00\x1C\x6B\x10\xC1\x00\x00\x01\x37\x69\x43\x43\x50\x41\x64\x6F\x62\x65\x20\x52\x47\x42\x20\x28\x31\x39\x39\x38\x29\x00\x00\x28\x91\x95\x8F\xBF\x4A\xC3\x50\x14\x87\xBF\x1B\x45\xC5\xA1\x56\x08\xE2\xE0\x70\x27\x51\x50\x6C\xD5\xC1\x8C\x49\x5B\x8A\x20\x58\xAB\x43\x92\xAD\x49\x43\x95\x62\x12\x6E\xAE\x7F\xFA\x10\x8E\x6E\x1D\x5C\xDC\x7D\x02\x27\x47\xC1\x41\xF1\x09\x7C\x03\xC5\xA9\x83\x43\x84\x0C\x05\x8B\xDF\xF4\x9D\xDF\x39\x1C\xCE\x01\xA3\x62\xD7\x9D\x86\x51\x86\xF3\x58\xAB\x76\xD3\x91\xAE\xE7\xCB\xD9\x17\x66\x98\x02\x80\x4E\x98\xA5\x76\xAB\x75\x00\x10\x27\x71\xC4\x18\xDF\xEF\x08\x80\xD7\x4D\xBB\xEE\x34\xC6\xFB\x7F\x32\x1F\xA6\x4A\x03\x23\x60\xBB\x1B\x65\x21\x88\x0A\xD0\xBF\xD2\xA9\x06\x31\x04\xCC\xA0\x9F\x6A\x10\x0F\x80\xA9\x4E\xDA\x35\x10\x4F\x40\xA9\x97\xFB\x1B\x50\x0A\x72\xFF\x00\x4A\xCA\xF5\x7C\x10\x5F\x80\xD9\x73\x3D\x1F\x8C\x39\xC0\x0C\x72\x5F\x01\x4C\x1D\x5D\x6B\x80\x5A\x92\x0E\xD4\x59\xEF\x54\xCB\xAA\x65\x59\xD2\xEE\x26\x41\x24\x8F\x07\x99\x8E\xCE\x33\xB9\x1F\x87\x89\x4A\x13\xD5\xD1\x51\x17\xC8\xEF\x03\x60\x31\x1F\x6C\x37\x1D\xB9\x56\xB5\xAC\xBD\xF5\x7F\xFE\x3D\x11\xD7\xF3\x65\x6E\x9F\x47\x08\x40\x2C\x3D\x17\x59\x41\x78\xA1\x2E\x7F\x55\x18\x3B\x93\xEB\x62\xC7\x70\x19\x0E\xEF\x61\x7A\x54\x64\xBB\x37\x70\xB7\x01\x0B\xB7\x45\xB6\x5A\x85\xF2\x16\x3C\x0E\x7F\x00\xC0\xC6\x4F\xFD\xF3\x53\x3F\xC8\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x2E\x23\x00\x00\x2E\x23\x01\x78\xA5\x3F\x76\x00\x00\x05\xD1\x69\x54\x58\x74\x58\x4D\x4C\x3A\x63\x6F\x6D\x2E\x61\x64\x6F\x62\x65\x2E\x78\x6D\x70\x00\x00\x00\x00\x00\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x62\x65\x67\x69\x6E\x3D\x22\xEF\xBB\xBF\x22\x20\x69\x64\x3D\x22\x57\x35\x4D\x30\x4D\x70\x43\x65\x68\x69\x48\x7A\x72\x65\x53\x7A\x4E\x54\x63\x7A\x6B\x63\x39\x64\x22\x3F\x3E\x20\x3C\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x3D\x22\x61\x64\x6F\x62\x65\x3A\x6E\x73\x3A\x6D\x65\x74\x61\x2F\x22\x20\x78\x3A\x78\x6D\x70\x74\x6B\x3D\x22\x41\x64\x6F\x62\x65\x20\x58\x4D\x50\x20\x43\x6F\x72\x65\x20\x35\x2E\x36\x2D\x63\x31\x34\x35\x20\x37\x39\x2E\x31\x36\x33\x34\x39\x39\x2C\x20\x32\x30\x31\x38\x2F\x30\x38\x2F\x31\x33\x2D\x31\x36\x3A\x34\x30\x3A\x32\x32\x20\x20\x20\x20\x20\x20\x20\x20\x22\x3E\x20\x3C\x72\x64\x66\x3A\x52\x44\x46\x20\x78\x6D\x6C\x6E\x73\x3A\x72\x64\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x77\x33\x2E\x6F\x72\x67\x2F\x31\x39\x39\x39\x2F\x30\x32\x2F\x32\x32\x2D\x72\x64\x66\x2D\x73\x79\x6E\x74\x61\x78\x2D\x6E\x73\x23\x22\x3E\x20\x3C\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x20\x72\x64\x66\x3A\x61\x62\x6F\x75\x74\x3D\x22\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x4D\x4D\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x6D\x6D\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x45\x76\x74\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x45\x76\x65\x6E\x74\x23\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x64\x63\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x70\x75\x72\x6C\x2E\x6F\x72\x67\x2F\x64\x63\x2F\x65\x6C\x65\x6D\x65\x6E\x74\x73\x2F\x31\x2E\x31\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x33\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x33\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x33\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x65\x62\x66\x62\x66\x31\x66\x63\x2D\x35\x61\x36\x32\x2D\x30\x37\x34\x31\x2D\x62\x37\x65\x31\x2D\x39\x36\x61\x62\x32\x62\x61\x30\x64\x33\x32\x35\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x65\x35\x65\x61\x30\x33\x31\x63\x2D\x34\x61\x66\x32\x2D\x63\x31\x34\x33\x2D\x38\x35\x65\x39\x2D\x34\x61\x66\x64\x62\x34\x63\x39\x38\x31\x39\x36\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x36\x65\x65\x64\x64\x63\x61\x38\x2D\x38\x66\x38\x32\x2D\x38\x39\x34\x35\x2D\x61\x37\x66\x36\x2D\x33\x62\x32\x34\x35\x62\x35\x62\x64\x31\x38\x64\x22\x20\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3D\x22\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3D\x22\x33\x22\x3E\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x63\x72\x65\x61\x74\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x36\x65\x65\x64\x64\x63\x61\x38\x2D\x38\x66\x38\x32\x2D\x38\x39\x34\x35\x2D\x61\x37\x66\x36\x2D\x33\x62\x32\x34\x35\x62\x35\x62\x64\x31\x38\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x33\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x65\x62\x66\x62\x66\x31\x66\x63\x2D\x35\x61\x36\x32\x2D\x30\x37\x34\x31\x2D\x62\x37\x65\x31\x2D\x39\x36\x61\x62\x32\x62\x61\x30\x64\x33\x32\x35\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x30\x3A\x33\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x52\x44\x46\x3E\x20\x3C\x2F\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x3E\x20\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x65\x6E\x64\x3D\x22\x72\x22\x3F\x3E\xA3\x67\x03\x7C\x00\x00\x08\xA8\x49\x44\x41\x54\x78\x9C\xED\x9D\x7B\x8C\x5C\x55\x1D\xC7\x3F\xE7\xCE\x6C\x5B\xB6\xDD\x47\xEB\x52\xD1\x8A\x80\x15\x64\x49\x05\xC4\x6A\x5B\x24\x35\x94\x4A\x8D\x10\x45\x93\x6A\x7C\xF1\x88\x26\x48\x14\x0D\xD1\xE0\x83\xF8\xC2\x44\x6D\x34\xF2\x4F\x01\x13\x01\x53\xC5\xC6\x06\x0C\x8F\x56\x89\x58\x01\x45\x8A\xB6\xD0\x85\x96\x4A\x5B\x5E\xB5\xB4\xBB\xA5\xB0\xD0\xED\xB4\xDB\xEE\xEE\xCC\x3D\xFE\xF1\xDB\xB9\x73\x67\xE6\xDE\x3B\xF7\xCE\x9C\x7B\xEF\xCC\x32\x9F\x64\x93\xBB\x77\xCF\x39\xF7\xB7\xDF\x39\xCF\xDF\x3D\xE7\x37\x4A\x6B\x4D\x1B\x73\x58\x69\x1B\x30\xD5\xC8\x16\x2F\xB4\xD6\xE4\x26\xF2\xFC\x6B\x78\x98\x75\xFB\xF6\x73\x24\xAF\x92\xB4\xE3\x34\xA0\x1F\x58\x00\x9C\x01\x9C\x02\x9C\x08\xF4\x01\x27\xB8\xD2\xE5\x81\x09\xE0\x30\x70\x08\x18\x04\x5E\x00\xFE\x0B\x3C\x03\xEC\x02\x8E\x24\x63\xB2\x8D\x9D\xD9\x4E\x21\xFB\x28\xDA\x1A\x62\xFD\xB9\x0F\x00\x2E\x41\x8F\xE6\x0B\x6C\x79\xE3\x10\xF7\x0E\x1E\x48\x42\xCC\x59\xC0\x42\xE0\x23\xC0\x85\xC0\x39\x40\x67\x84\xFC\xF3\x7C\xEE\xEF\x01\x36\x01\x1B\x81\x47\x80\x97\xEA\xB6\xB0\x26\x16\xCA\x3E\x15\xCB\x7E\x99\x82\x7A\xDD\xB9\xEB\x08\xBA\x33\x77\x84\x7B\x06\x87\x18\x1E\xB7\xE3\xB3\x01\xCE\x07\x3E\x0B\x5C\x82\xD4\x4A\xD3\x9C\x3A\xF9\xF3\x39\xA4\xA6\xFE\x1B\x58\x07\xDC\x0F\x1C\x34\xFD\x30\xA5\xBB\x51\xF6\x7C\x94\xB5\xC7\xB9\xE7\xF4\xA1\x1B\x86\x0E\x30\x74\x3C\x6F\xFA\x99\x20\x35\xEF\x2A\xE0\xB1\xC9\x9F\xAF\x11\x8F\x98\x95\xCC\x02\x96\x03\xBF\x01\x9E\x06\x56\x03\x67\x9B\x7D\x84\x42\xD9\xF3\x50\xF6\x3B\x9C\x3B\x8E\xA0\x3B\x72\xA3\x66\x9F\x05\x19\xE0\x8B\xC0\x16\xE0\x0E\xA4\x76\xA6\xC5\x49\xC0\x57\x81\xCD\x93\xB6\x18\xFB\x40\x95\x9E\x85\x65\x97\x8A\x73\x04\xB5\xCD\xCE\x9E\x96\x01\xFF\x00\x7E\x07\x9C\x65\xB4\xE4\xC6\x98\x8E\xB4\x96\x27\x80\x1B\x81\x9E\xC6\x8B\xB4\x50\xF6\xC9\xAE\xDF\xCC\x72\x22\x70\x0B\x32\x28\x7C\xC8\x70\xD9\x26\x99\x03\x7C\x1F\x78\x1C\xE9\xCF\x1B\x42\xE9\xD2\xE7\x62\x52\xD0\x4B\x91\x41\xE0\x1A\x20\xD1\x39\x57\x03\xF4\x03\x1B\x90\x4A\x30\xAB\xFE\x62\x32\xCE\x95\x29\x41\xBF\x09\xDC\x07\xBC\xCB\x50\x79\x49\x73\x0D\xF0\x20\xF0\xEE\x46\x0B\x6A\x54\xD0\x4E\xE0\x36\xE0\x97\x06\xCA\x4A\x9B\x25\xC8\xDC\xF5\xC2\x46\x0A\x69\x44\x84\xB9\xC0\x5F\x80\x2F\x35\x62\x40\x93\x31\x0F\xF9\x9F\xAE\xAC\xB7\x80\x6C\xED\x24\x9E\xBC\x05\x58\x0F\x7C\xB0\xDE\x07\x87\x60\x08\x78\x18\x78\x11\x38\x8A\x2C\x43\x17\x00\x4B\x29\x5F\x8E\x9A\x66\x06\xF0\xDB\xC9\x67\xDC\x1A\x35\x73\x3D\x82\x76\x03\x7F\x22\x3E\x31\xC7\x80\x9F\x22\xFF\xCC\xAB\x1E\x7F\xEF\x07\xBE\x07\x7C\x21\xA6\xE7\x17\x59\x0D\x8C\x00\x6B\xA3\x64\x8A\x2A\x68\x27\x70\x37\xF0\xE1\x88\xF9\xC2\x62\x23\xCD\xED\x8F\x01\x69\x9E\x45\x16\x0C\x47\x80\xAF\xC4\x64\x07\x48\x77\x78\x07\x90\x43\x5A\x63\xE8\x4C\x51\xB8\x0D\x71\x68\xC4\xC5\xBD\x04\x8B\xE9\xE6\xDB\xC0\xBE\xF8\x4C\x01\x64\x21\xF0\x07\x22\xB4\xC6\x28\x82\x5E\x87\x38\x36\xE2\x24\x4A\xF3\x3A\x0C\xFC\x39\x2E\x43\x5C\x74\x01\xBF\x07\x7A\xC3\x24\x0E\x2B\xE8\x62\xE0\x67\x75\x1A\x14\x96\x3C\xD2\x9C\xA3\xF0\x78\x1C\x86\x78\x70\x06\xD2\xA7\xD6\x24\x8C\xA0\x3D\xC0\xED\x48\xF5\x8F\x93\x31\x64\x34\x8F\xC2\x70\x1C\x86\xF8\xF0\x79\xC4\x0F\x10\x48\x18\x41\x57\x91\x8C\x83\x23\x0B\x74\x44\xCC\x13\xE7\xF4\xC9\x8B\x9B\x80\xF9\x41\x09\x6A\x09\xBA\x18\xF8\xB2\x31\x73\x82\x99\x0E\xBC\x33\x62\x1E\xC3\xFE\xCD\x9A\xF4\x50\xA3\xEB\x0B\x12\xD4\x42\x6A\x67\x26\x20\x8D\x69\x2E\x8D\x98\xFE\x63\xB1\x58\x11\xCC\x4A\x02\x66\x3A\x41\x82\x7E\x02\x59\x95\x24\xC9\x55\xC0\x7B\x42\xA6\xBD\x02\x38\x2F\x46\x5B\x82\xF8\x31\x3E\x15\xCD\x4F\x50\x0B\x99\xE7\x25\x4D\x2F\x70\x17\x70\x66\x8D\x74\x97\x00\x37\xC7\x6E\x8D\x3F\x4B\x80\x15\x5E\x7F\xF0\x5B\x29\x2D\x07\x16\xC5\x66\x4E\x30\xEF\x45\xA6\x43\x6B\x80\x07\x80\xBD\xC8\x0A\x6A\x06\x32\x38\x7E\x1C\xF8\x34\xE9\x7B\xB7\xAE\x43\x1C\x29\x65\x78\x09\xAA\x80\xEB\x63\x37\x27\x98\x5E\xE0\x1B\x93\x3F\x13\x80\x46\x6C\x4D\x5B\x44\x37\x17\x21\x35\xB5\x6C\x2E\xEC\x65\xE0\xFB\x90\x77\x42\xCD\x42\x07\x30\x8D\xE6\x12\x13\xA4\xE2\x7D\xBD\xF2\xA6\x97\x91\x2B\x69\x9D\x57\x18\x69\xB3\x02\xF1\x0B\x3B\x54\x0A\x3A\x0D\xF8\x64\x62\xE6\xB4\x3E\xB3\xA9\x18\x9C\x2A\x05\x3D\x17\x59\xB7\xB6\x09\xCF\x65\xEE\x5F\x2A\x07\xA5\x65\xA4\xD3\xDC\x47\x91\x81\x27\x0A\x1A\x69\x51\xD3\xCC\x9B\x13\x89\x25\x88\x47\x2A\x07\xD5\x82\xC6\xE5\x38\x0E\x62\x10\x19\x31\xA3\x6E\x5D\xD1\xC0\xD5\xC0\x0D\xC6\x2D\x8A\xC6\xDB\x90\xA9\xDE\x26\x28\x17\xB4\x1B\x69\xF2\x49\xF3\x32\xB0\xB3\xCE\xBC\xC6\x37\x80\xD5\xC9\x22\x26\x05\x75\xF7\xA1\xF3\x81\xB7\xA6\x60\xCC\xDE\x06\xF2\xD6\xFB\x92\xD1\x34\xEF\x2F\x5E\xB8\x05\x3D\x9D\x74\xFA\xCF\xFF\xA5\xF0\x4C\xD3\x38\xFE\x07\xCB\xEB\x66\xC2\x3C\x93\xD2\x73\x4D\xE2\x6C\x00\x76\x0B\x7A\x4A\x0A\x86\x80\xBC\x6B\x8F\xEA\x07\x6D\x36\x66\x14\x2F\xDC\x82\xBE\x3D\x05\x43\x00\xBE\x05\x6C\x47\xDE\xF5\x5F\x46\xF2\x5E\x78\x13\x38\x53\x3E\xB7\xA0\xFD\x29\x18\x52\xA4\x1B\xF8\x14\x70\x0F\xF2\x2A\x39\xED\xB9\x65\xDD\xB8\x05\xED\x4A\xCD\x8A\x72\x96\x22\xFB\x37\x5B\x12\xB7\xA0\xCD\x72\x02\x6C\x3C\x6D\x03\x1A\xA1\xD9\x5C\x62\x2D\x8F\x5B\xD0\xB6\xCB\xCE\x00\x6E\x41\x27\x52\xB3\x62\x0A\xE1\x16\x74\x30\x35\x2B\xA6\x10\x6E\x41\x77\xA5\x66\x45\xEB\xE3\x74\x97\x6E\x41\xA7\xC2\x9A\x3A\x2D\x0A\xC5\x0B\xB7\xA0\xBB\x53\x30\x64\xAA\xF0\x4A\xF1\xA2\x2D\xA8\x19\x9E\x2F\x5E\xB8\x05\x7D\x0E\x39\x83\xDE\x26\x3A\x03\xC5\x0B\xB7\xA0\x07\x91\x83\xFC\x6D\xA2\xB3\xB9\x78\x51\xB9\x52\xDA\x94\xB0\x21\x53\x81\x11\x60\x6B\xF1\x97\x4A\x41\x1F\x4A\xD6\x96\x29\xC1\x00\x3E\x83\x12\x48\x0D\x7D\x85\x36\x51\x28\x3B\x72\x53\x29\xE8\x08\xF0\xD7\xE4\x6C\x69\x79\xC6\x90\xD3\xCC\x0E\x5E\xDE\xA6\xB0\xE7\x84\xDA\xC0\x7F\xA8\x98\x6E\x7A\x09\xFA\x70\x65\xA2\x36\xBE\x54\x6D\xFA\xF5\x12\xF4\x38\xF0\xAB\xF8\x6D\x69\x79\x9E\x45\x5E\xD7\x94\xE1\xE7\x60\x5E\x4B\xFC\xC7\xFE\x5A\x9D\x5F\xE3\xF1\x76\xC1\x4F\xD0\x1C\x21\x4F\x8E\xBD\x49\xD9\x87\x04\xA8\xA9\x22\xE8\x15\xC8\xAD\x48\xA4\xAE\xA4\xE9\x20\xFC\xDB\x83\xB4\xB6\xE2\xDC\x88\xCF\x32\x3D\x48\xD0\xC3\x48\xE4\x98\xA4\x79\x89\xC9\xAD\x81\x21\xD8\x13\xA3\x1D\x7E\x6C\x45\x0E\x54\x78\x52\xEB\x13\x5E\x8B\x6C\x19\xBC\xC0\xA4\x45\x15\x3C\x0A\x3C\x85\x44\x6E\x78\x11\x59\x17\x87\x0D\x08\x78\x17\xF2\x01\x9C\x89\x04\xB7\x3A\x0D\xD9\x1A\x79\x72\x50\xA6\x06\xD0\xC0\x77\x08\x78\x33\xEB\x08\x3A\x77\xFA\x34\x0E\x8E\x55\xA5\xB3\x91\x43\xFE\x8F\x61\x24\x68\x94\x27\xD7\x23\xE1\x89\xEA\x41\x23\x91\xCB\xB6\xB8\xEE\xDD\x82\x44\xB9\x89\x83\x9B\x80\xBF\x05\x25\x70\x9A\xFC\xC2\xD9\x3D\x58\xCA\xB3\xEB\xDA\x81\x84\x11\x8A\x8B\x19\xB5\x93\x44\x22\xAE\x7E\x75\x80\x10\x5D\x60\x49\xD0\x39\x3D\xF4\x77\xF9\xC6\x82\xBA\x1D\x89\x6C\xF0\x66\x65\x14\x09\xDD\x51\x73\x97\xB5\x23\xE8\xFC\x99\x9D\x2C\x9B\x3B\x87\x79\x27\xF8\x56\x98\x6B\x91\x4D\x5D\xA6\x29\xD4\x4E\x12\x89\x38\xE2\x75\x5E\x0B\x6C\x0B\x93\xD0\x69\x1E\x33\xB3\x59\xCE\xEE\xE9\x66\xB4\x60\xB3\x7E\xF0\x00\x07\xC7\xAA\x5E\xD3\xBF\x81\x1C\x09\xDC\x88\x7F\x40\xD4\x7A\xE8\xC2\xEC\xBE\x2A\xD3\x81\x12\x7E\x82\x04\x73\x09\x85\x23\xA8\x02\x7A\x3B\xB2\x2C\x9E\xD3\x8B\xD6\x05\xEE\x1F\x1C\xE2\xB5\xF1\xAA\xED\x4E\x3B\x91\x23\xD8\x0F\x22\x81\x03\x4D\xB0\x06\xF1\xDA\x98\xA2\xD7\x60\x59\xAB\x80\x1F\x44\xC9\x50\xD6\x81\x5B\x4A\xD1\xDB\x91\xE5\x82\xBE\x3E\xB4\xCA\xB3\x6E\xEF\x10\xA3\x85\xAA\x53\xCC\x4F\x21\x35\xF5\x3E\x64\x1B\x62\xA3\xF4\x19\x28\x23\x0E\x56\x23\x53\xA4\x10\x94\x7A\x99\xAA\x89\xBD\xA5\x14\xDD\x1D\x59\x3E\x30\xBB\x8F\xD3\xBB\x66\xA2\xBC\x37\xE5\x3D\x82\x9C\xA7\xF7\x0A\x54\x35\x15\xB8\x19\xE9\x37\x43\xA1\x55\x29\x54\x8A\xE7\x4A\x49\x01\xDD\xD9\x0E\x4E\x9A\x3E\x13\xE5\x3D\x95\x02\x11\x75\x39\x21\x3B\xEB\x16\xC1\x06\xBE\x8B\x84\x35\x0E\x89\x46\x5B\x25\x3F\x92\xEF\xD2\xD3\x52\x8A\xCE\x6C\x07\x2A\x78\x59\xBD\x0D\x59\x99\x84\x8E\xBC\xD5\xC4\x1C\x02\x3E\x03\xFC\x3C\x5A\xB6\x02\xB6\x55\x8A\x8E\x14\xB8\x3F\x34\xE4\xE6\xD1\xD7\x90\xED\xDC\xAB\x68\x9E\x4D\xBB\x51\xD9\x8A\xB4\xB6\xBB\xA3\x65\xD3\x68\xF5\x3A\xDA\x2A\x1D\xB5\xF2\xD5\x6C\xDC\xB6\x99\xD0\x1A\x3B\xDC\x57\x5B\xE4\x91\x0E\xFC\x62\x64\xD0\x6A\x15\xC6\x91\xC0\x85\x4B\x81\x27\xA3\x65\xD5\xC8\x97\x03\xBC\x80\x56\x23\xCE\x5D\x4F\x41\x35\x70\xAC\x60\x33\x9A\x2F\x44\xAD\x72\x1B\x11\x47\xCA\x8F\x10\x6F\x55\x33\xF3\x10\x72\xB6\xF5\x06\xA2\x07\xE0\x02\x40\xAB\x1C\xDA\xDA\x05\xAA\xE4\x03\xF1\xAD\xA1\xC7\x0A\x05\x46\x26\xEA\xDA\x83\x7B\x14\x89\x1A\xB3\x08\xB8\x13\xA9\xBD\xCD\xC4\x6E\x24\x86\xDF\x45\xD4\xED\x94\xD1\x40\x01\x9D\xD9\x8D\xB6\x06\x09\x9C\x36\x01\xD8\x5A\x73\xBC\x60\x93\xCB\x37\xB4\x2A\xDC\x89\x84\xA5\x3C\x1F\x09\xC6\x97\xD0\x77\x74\xF8\x32\x80\xC4\xB2\x5F\x48\xC3\x6F\x76\x35\xDA\x7A\x15\x3B\xB3\xAD\x6C\xCA\x04\x3E\x9E\x19\x8D\xF4\xA1\xC7\x0A\x46\x96\xD9\x5B\x80\xCB\x91\x80\xD1\x2B\x91\x91\xF4\x1C\x13\x05\x87\x60\x18\x59\xD5\xAD\x01\xFE\x8E\x91\xD6\xA2\xD1\x2A\x87\x9D\x79\x02\x5B\xED\xA7\xD2\x75\xE0\xEB\xEA\x92\x2E\xD7\xE8\xA0\xFD\x3C\x12\xE6\xEC\x17\x48\x3C\xCE\x15\xC0\x47\x91\x23\xE5\x26\x0F\x7A\xED\x43\xE6\xC8\x1B\x80\x7F\x22\xA1\x87\xCD\xA1\x8E\x61\x67\xB6\x61\x67\x76\x80\xAA\x5E\x31\x7B\x0A\xAA\x80\x8C\xA2\xD6\x1C\xB4\x5E\xF2\xC8\x96\x9F\x4D\xC0\x0F\x91\x13\x7C\xE7\x21\xC2\x2E\x40\xBE\x1C\xA5\x8F\x70\xB3\xB6\x51\x60\x3F\xB2\x9D\x7D\x00\x19\xA9\xB7\x13\xDB\xB6\xCC\x02\xB6\xB5\x0B\x3B\xBB\x19\xAD\x72\x78\xCD\x12\x55\xFB\x1B\xBF\xCC\xD2\x3E\xF8\x65\x98\xFF\x03\x7C\xB3\xE1\x5B\xCC\x68\x2D\x36\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"
local success_data = "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x4D\x00\x00\x00\x4D\x08\x06\x00\x00\x00\xE3\x09\xE9\xB0\x00\x00\x01\x37\x69\x43\x43\x50\x41\x64\x6F\x62\x65\x20\x52\x47\x42\x20\x28\x31\x39\x39\x38\x29\x00\x00\x28\x91\x95\x8F\xBF\x4A\xC3\x50\x14\x87\xBF\x1B\x45\xC5\xA1\x56\x08\xE2\xE0\x70\x27\x51\x50\x6C\xD5\xC1\x8C\x49\x5B\x8A\x20\x58\xAB\x43\x92\xAD\x49\x43\x95\x62\x12\x6E\xAE\x7F\xFA\x10\x8E\x6E\x1D\x5C\xDC\x7D\x02\x27\x47\xC1\x41\xF1\x09\x7C\x03\xC5\xA9\x83\x43\x84\x0C\x05\x8B\xDF\xF4\x9D\xDF\x39\x1C\xCE\x01\xA3\x62\xD7\x9D\x86\x51\x86\xF3\x58\xAB\x76\xD3\x91\xAE\xE7\xCB\xD9\x17\x66\x98\x02\x80\x4E\x98\xA5\x76\xAB\x75\x00\x10\x27\x71\xC4\x18\xDF\xEF\x08\x80\xD7\x4D\xBB\xEE\x34\xC6\xFB\x7F\x32\x1F\xA6\x4A\x03\x23\x60\xBB\x1B\x65\x21\x88\x0A\xD0\xBF\xD2\xA9\x06\x31\x04\xCC\xA0\x9F\x6A\x10\x0F\x80\xA9\x4E\xDA\x35\x10\x4F\x40\xA9\x97\xFB\x1B\x50\x0A\x72\xFF\x00\x4A\xCA\xF5\x7C\x10\x5F\x80\xD9\x73\x3D\x1F\x8C\x39\xC0\x0C\x72\x5F\x01\x4C\x1D\x5D\x6B\x80\x5A\x92\x0E\xD4\x59\xEF\x54\xCB\xAA\x65\x59\xD2\xEE\x26\x41\x24\x8F\x07\x99\x8E\xCE\x33\xB9\x1F\x87\x89\x4A\x13\xD5\xD1\x51\x17\xC8\xEF\x03\x60\x31\x1F\x6C\x37\x1D\xB9\x56\xB5\xAC\xBD\xF5\x7F\xFE\x3D\x11\xD7\xF3\x65\x6E\x9F\x47\x08\x40\x2C\x3D\x17\x59\x41\x78\xA1\x2E\x7F\x55\x18\x3B\x93\xEB\x62\xC7\x70\x19\x0E\xEF\x61\x7A\x54\x64\xBB\x37\x70\xB7\x01\x0B\xB7\x45\xB6\x5A\x85\xF2\x16\x3C\x0E\x7F\x00\xC0\xC6\x4F\xFD\xF3\x53\x3F\xC8\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x2E\x23\x00\x00\x2E\x23\x01\x78\xA5\x3F\x76\x00\x00\x06\xC9\x69\x54\x58\x74\x58\x4D\x4C\x3A\x63\x6F\x6D\x2E\x61\x64\x6F\x62\x65\x2E\x78\x6D\x70\x00\x00\x00\x00\x00\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x62\x65\x67\x69\x6E\x3D\x22\xEF\xBB\xBF\x22\x20\x69\x64\x3D\x22\x57\x35\x4D\x30\x4D\x70\x43\x65\x68\x69\x48\x7A\x72\x65\x53\x7A\x4E\x54\x63\x7A\x6B\x63\x39\x64\x22\x3F\x3E\x20\x3C\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x3D\x22\x61\x64\x6F\x62\x65\x3A\x6E\x73\x3A\x6D\x65\x74\x61\x2F\x22\x20\x78\x3A\x78\x6D\x70\x74\x6B\x3D\x22\x41\x64\x6F\x62\x65\x20\x58\x4D\x50\x20\x43\x6F\x72\x65\x20\x35\x2E\x36\x2D\x63\x31\x34\x35\x20\x37\x39\x2E\x31\x36\x33\x34\x39\x39\x2C\x20\x32\x30\x31\x38\x2F\x30\x38\x2F\x31\x33\x2D\x31\x36\x3A\x34\x30\x3A\x32\x32\x20\x20\x20\x20\x20\x20\x20\x20\x22\x3E\x20\x3C\x72\x64\x66\x3A\x52\x44\x46\x20\x78\x6D\x6C\x6E\x73\x3A\x72\x64\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x77\x33\x2E\x6F\x72\x67\x2F\x31\x39\x39\x39\x2F\x30\x32\x2F\x32\x32\x2D\x72\x64\x66\x2D\x73\x79\x6E\x74\x61\x78\x2D\x6E\x73\x23\x22\x3E\x20\x3C\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x20\x72\x64\x66\x3A\x61\x62\x6F\x75\x74\x3D\x22\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x4D\x4D\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x6D\x6D\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x45\x76\x74\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x45\x76\x65\x6E\x74\x23\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x64\x63\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x70\x75\x72\x6C\x2E\x6F\x72\x67\x2F\x64\x63\x2F\x65\x6C\x65\x6D\x65\x6E\x74\x73\x2F\x31\x2E\x31\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x33\x3A\x32\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x31\x39\x3A\x33\x39\x3A\x35\x31\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x31\x39\x3A\x33\x39\x3A\x35\x31\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x36\x32\x39\x39\x35\x33\x62\x34\x2D\x66\x33\x66\x38\x2D\x31\x37\x34\x37\x2D\x62\x39\x62\x39\x2D\x30\x34\x34\x31\x66\x31\x36\x61\x38\x66\x39\x63\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x37\x61\x64\x37\x30\x30\x37\x63\x2D\x39\x32\x39\x61\x2D\x61\x39\x34\x64\x2D\x61\x31\x32\x38\x2D\x30\x39\x66\x63\x35\x30\x37\x37\x65\x38\x62\x35\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x64\x61\x64\x63\x36\x30\x39\x37\x2D\x35\x65\x38\x32\x2D\x37\x37\x34\x61\x2D\x62\x32\x63\x30\x2D\x31\x64\x65\x34\x39\x63\x64\x30\x64\x61\x36\x65\x22\x20\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3D\x22\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3D\x22\x33\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x49\x43\x43\x50\x72\x6F\x66\x69\x6C\x65\x3D\x22\x41\x64\x6F\x62\x65\x20\x52\x47\x42\x20\x28\x31\x39\x39\x38\x29\x22\x3E\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x63\x72\x65\x61\x74\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x64\x61\x64\x63\x36\x30\x39\x37\x2D\x35\x65\x38\x32\x2D\x37\x37\x34\x61\x2D\x62\x32\x63\x30\x2D\x31\x64\x65\x34\x39\x63\x64\x30\x64\x61\x36\x65\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x33\x3A\x32\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x35\x66\x33\x62\x38\x64\x64\x39\x2D\x38\x36\x62\x30\x2D\x64\x65\x34\x34\x2D\x39\x34\x63\x35\x2D\x38\x62\x39\x30\x35\x61\x37\x36\x63\x33\x65\x63\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x33\x3A\x32\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x36\x32\x39\x39\x35\x33\x62\x34\x2D\x66\x33\x66\x38\x2D\x31\x37\x34\x37\x2D\x62\x39\x62\x39\x2D\x30\x34\x34\x31\x66\x31\x36\x61\x38\x66\x39\x63\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x31\x39\x3A\x33\x39\x3A\x35\x31\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x52\x44\x46\x3E\x20\x3C\x2F\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x3E\x20\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x65\x6E\x64\x3D\x22\x72\x22\x3F\x3E\x3A\xD1\x4C\xBF\x00\x00\x09\x56\x49\x44\x41\x54\x78\x9C\xE5\xDC\x69\x90\x9C\x55\x15\x06\xE0\xA7\x7B\x26\x84\x6C\xB2\x84\x28\x26\x04\x09\x18\x40\x40\x10\x50\x64\x11\x11\xDC\x08\xA2\xB8\x80\x16\x58\x05\x8A\x0B\xBB\x5B\x70\x2D\xFD\xE3\x52\x6E\x45\x95\x94\xA5\x96\x10\x45\x4B\xB0\x44\x41\x7F\xC8\x92\x02\x15\x54\x40\x91\x98\x88\xAC\x91\x1D\x03\x09\x10\x12\xC0\xEC\x99\xCC\xF8\xE3\x9D\xCE\x8C\x43\xCF\x4C\x7F\xDD\x5F\xCF\x22\x6F\x6A\x2A\x55\xDD\x7D\xEF\x77\xFB\xF4\x59\xDE\x7B\xCE\xB9\xB7\xE2\x71\x23\x85\x69\x98\x81\xA9\x78\x19\xDE\x86\x63\x30\x0B\xD5\x02\xF3\xAC\xC7\x5D\xB8\x0A\x7F\xC6\x2A\xFC\x07\x2B\xB1\xB1\xC4\xF5\x0E\x8A\x4A\x9B\x85\x36\x11\x3B\x62\x26\xDE\x8C\x0F\x8B\x90\x2A\xE8\x44\x47\x93\xF3\xF6\x60\x73\xEF\xFF\x3D\xB8\x19\x0B\xB0\x48\x84\xF8\x1C\xBA\x5A\x59\xF8\x50\x68\x97\xD0\x26\x63\x57\x1C\x85\x33\xF1\x2A\x6C\xD1\xBC\x90\x86\x43\xB7\x68\xEB\x26\x2C\xC4\x25\xB8\x0D\x4F\x8A\x70\x4B\x45\xD9\x42\x9B\x88\xBD\xF1\x0E\x7C\x04\xB3\x4B\x9D\xBD\x18\xFE\x82\x1F\xE2\x77\x78\x42\x89\x9A\x57\x96\xD0\x3A\x31\x17\xC7\xE1\x3C\xF1\x59\x63\x05\x37\x88\xE9\xDE\x88\xE5\x62\xCE\x2D\xA1\x0C\xA1\x4D\xC7\x3C\x7C\x06\xAF\x6C\x79\xB6\xF6\xA0\x0B\xBF\xC5\xF7\x44\x03\xD7\xB5\x32\x59\x2B\x42\xAB\xE0\xD5\x38\x0B\xEF\x13\x3F\x36\xD6\xF1\x30\x2E\xC2\xCF\xB0\xAC\xD9\x49\x9A\x15\x5A\x87\x98\xE2\x57\x70\x40\xB3\x0F\x1F\x25\x74\xE1\x72\x7C\x5D\xA8\x4B\x61\x74\x98\x5F\x78\xCC\x34\x9C\x82\xAF\x62\x9F\x66\x1E\x3A\xCA\xA8\x62\x7F\xEC\x8E\xC7\xF1\xA8\x82\x7E\xAE\xA8\xA6\xCD\xC0\xB9\x38\x1B\x3B\x15\x1A\x39\x36\xF1\x0F\x7C\x0B\xBF\x56\x80\x18\x17\xD1\xB4\x97\xE2\xF3\x12\x1D\xB7\x2B\xB6\xB6\x31\x8B\x9D\x71\x10\x9E\xC1\xDD\xC2\x25\x87\x45\xA3\x42\x9B\x2E\x02\x3B\xC3\xF8\x70\xF8\x45\xB0\x83\x98\xEB\xD3\xE2\xE3\xBA\x87\x1B\xD0\xC8\x9E\x6F\x2A\xCE\x11\xB2\x3A\xA9\x95\xD5\x8D\x61\xCC\xC1\xE7\x70\x6C\x23\x1F\x1E\x4E\x68\x1D\x78\x37\x3E\x8E\x29\xAD\xAD\x6B\xCC\x63\x6F\x7C\x5A\x68\xD4\x90\x18\x4A\x68\x15\xBC\x05\x5F\x94\x4D\xF7\x0B\x01\x47\xE0\x0B\x86\x61\x05\x43\x09\x6D\x3F\xE1\x61\x73\x4B\x5C\xD4\x58\x47\x07\x8E\x97\x60\x37\x63\xB0\x0F\x0D\x26\xB4\xED\xC5\xE9\x1F\x5C\xFA\xB2\xC6\x3E\x26\xE0\x24\xC9\xF7\x75\xD6\xFB\x40\x3D\xA1\x75\x8A\x43\x3C\xAD\x7D\xEB\x1A\xF3\x98\x8E\x0F\x09\x1D\x79\x1E\xEA\x09\x6D\x36\x3E\x2B\x51\xF3\x85\x8C\xC3\x64\x4F\xFD\x3C\x4E\x3A\x50\x68\xDB\xE0\xED\xC6\xDF\x7E\xB2\x1D\xE8\x90\x40\x78\x88\x01\x72\x1A\x28\xB4\x39\xF8\x84\x44\xCE\xF1\x8E\x5A\x4A\x7C\x9D\xE6\x13\x90\xFB\xE2\x44\x03\xB6\x8C\xFD\x1D\xDD\x44\xBC\x4B\x04\x37\xDE\xB1\x0A\x4B\xF1\x10\xD6\xE2\x45\x78\x8D\x7C\xB7\x22\x0A\x51\xA3\x5D\x57\xE1\x6A\xBD\xBB\x85\xFE\x42\x9B\x29\xB9\xB1\xF1\x8E\x65\xB8\x12\x57\x48\xFE\xAC\x4B\x14\xE2\x68\x7C\x13\x2F\x2E\x38\xDF\x6E\x78\x2B\x6E\xC2\x6A\xFA\xCC\x73\x42\xEF\xA4\xBB\xB6\xB8\xE0\xD1\xC6\xBF\x25\xC9\xF8\x0D\xF9\x92\xCB\xB0\x02\x8F\x88\x10\x7F\xA9\x81\xBD\x65\x1D\x1C\x23\x91\xB4\x42\x9F\xD0\xA6\xE0\xA3\x4A\xC8\x9F\x8F\x22\x56\x4B\x46\x76\x81\x08\xAA\x22\xCE\x7C\xA2\xEC\x99\xD7\x8B\x99\xAD\x6C\x62\xEE\x57\xE0\x48\x09\x94\xAA\xBD\x7F\x3B\x4B\x94\x18\xAF\x01\x60\x13\x7E\x83\x9F\x48\xF1\xA4\x86\x2D\x62\x9E\x5D\xF2\xDD\x96\xE2\x9E\x26\x9F\xB1\xA7\xF0\x37\x55\xC9\xC4\x1E\xAF\xC1\x5C\x52\xAB\xA8\x94\xFF\xBB\xF4\xE0\x7A\x29\xD7\xDD\xB7\xF5\x31\x7D\xA8\x09\x6E\x8B\xD4\x41\x17\x69\xEE\xBB\x1E\xD2\xFB\xD7\x51\x95\x70\xFA\x41\x83\x6C\x19\xCA\x42\xA5\xF7\x5F\x4F\xF9\x1E\xE0\xAF\xB8\x10\x4B\xFA\xBD\x56\xAB\xBC\x1B\xF0\xDA\x06\xC9\x99\x6D\x6A\xE2\x39\x7B\xC8\x86\x7E\x52\xA7\x6C\x4C\xDB\x4A\x33\xDA\xA0\x5D\x44\x08\xB7\xE3\x3B\xD2\x96\xD0\x48\x25\xBD\x22\x41\xAF\x48\xEF\x48\x7F\xCC\xC0\x94\x4E\xB1\xD5\xB6\x9A\x66\x1B\xB4\xAB\x1B\x0F\x8A\x49\x5E\x6B\xF8\x3A\x66\x8F\x08\x6A\xAE\x6C\x8D\xB6\x69\xF2\xB9\xB3\xB1\x5B\x55\x92\x6E\x6D\x33\xCD\x9A\x59\x96\x8C\xA7\xA4\x5F\xE3\x0A\xE9\x18\x6A\x04\xB3\xF0\x49\x89\x82\xCD\x2E\xE8\x20\x1C\xDE\x29\x19\xCB\x09\x4D\x4E\x52\x43\x8F\x84\xF4\x95\xE2\x2F\xA6\x8A\x2A\x6F\x6D\x78\x29\xD1\x9F\xAD\xC2\xCF\xF1\x53\xC9\xEB\x37\x82\xE9\x92\xEA\x7A\xBF\xD6\xBE\xEB\xF6\xD8\xAF\x53\x02\x41\x2B\xDD\x3C\x5B\xC4\x54\x6E\xC4\x1D\xF2\xCB\xCF\x90\x2C\xC1\xA1\x3D\x7A\x76\xAE\xA8\x94\xA5\x6A\x6B\x85\x6B\x5D\x84\xC7\x1A\x1C\x33\x45\x52\xF6\x67\x28\x27\x65\x3F\xB3\xB3\xC5\x89\x36\x4B\x4B\xD3\xC5\xF8\x83\x74\xE7\x6C\x91\x5F\xF3\x1A\x59\xEC\x69\x3D\x7A\xF6\x68\x71\xA1\x84\x36\xDC\x82\x1F\xE0\xDE\x06\xC7\x74\xE0\x70\xA9\x71\x94\x55\xA7\xDD\xBE\x53\x6B\x79\xB3\xDB\x71\x81\x14\x5B\xFB\xA3\x4B\x42\xFB\x32\x31\xDB\xB3\xB5\x1E\xA1\xEF\xC4\xF7\x85\x62\x34\x8A\xFD\xA5\x92\x56\x66\x27\xC0\xA4\x1A\xB9\x6D\x06\xAB\xA4\x81\xEE\xBA\x7E\xAF\x0D\x34\xC3\x67\xF1\x23\xD1\xC4\x46\xCD\xA9\x1E\x96\x8A\xC0\x16\x16\x18\xF3\x72\x31\xC9\x79\x75\xD6\xD5\x0A\x3A\xAA\x9A\x77\x8C\x6B\xA4\x0F\xA2\x56\xCE\x1F\x6C\x61\xAB\x25\xD2\x15\x71\xDC\xFD\xB1\x1C\x97\x8A\x36\x6F\x68\x70\xCC\x4E\xD2\x6F\x72\xA2\xE6\xE9\xC5\x60\x98\xD0\x2C\xC9\xA3\x3E\xE3\x1E\x2C\x3C\xAE\x10\xE7\x7D\xA9\x38\xF3\x46\xB1\x46\x84\x75\x99\xC6\x05\x3E\x49\x0A\x23\xA7\xE9\xDD\x2B\x96\x8C\x89\x55\xCD\x13\xDB\xC9\x52\x0F\x6D\x54\xF5\x1F\x91\x0C\xC4\x95\x1A\xEF\x83\xBD\x4E\x36\xE1\x0F\x15\x58\xD7\x9B\x70\xAA\x74\x05\xB5\x03\x1D\x55\x8D\xAB\xFC\x40\x4C\xC7\xEB\x15\xEB\x7E\xBC\x13\xDF\x95\x2C\xE8\x70\xB8\x59\xB4\x73\x51\x81\xF9\x0F\x93\xA0\x73\x68\x81\x31\x85\x51\xD5\x5C\x52\xAE\x36\xF6\x08\xC9\xF6\xEE\x59\x60\xDC\x62\x89\xB8\x0B\x0D\x6E\xCE\xF7\x08\xB5\xB8\xA1\xC0\xBC\xFB\x0A\xB5\x38\xBA\xC0\x98\x66\x50\xA9\x6A\xED\xC0\xC2\x76\x38\x41\xDA\xDE\x77\x69\x70\x4C\x37\x6E\x15\xC1\xFD\xA9\xCE\xFB\x8F\x8B\x86\x5D\xAD\xF1\x6C\xC4\x6C\xF9\xF1\xE6\x49\xD2\xB1\x9D\xE8\xEA\x30\xDF\x89\xFA\x0E\x44\x34\x83\xC9\xFA\x0A\x16\x77\x69\xAC\x09\xB8\x5B\x28\xC8\x93\x92\x83\xDF\xA5\x77\xFC\xB3\x12\x65\x2F\xE9\x7D\xAF\x11\xEC\x28\x59\xE7\x76\x39\xFE\x81\x58\xD1\x61\xBE\xC3\x84\xFC\xB5\xB2\x27\x9B\x22\xBC\x68\xB3\x70\xAA\x46\x04\xB7\x45\x82\xC3\x7A\xEC\x25\xFB\xBA\x85\x92\xEA\x79\xA0\xF7\x33\xC3\xFD\x90\x93\x71\xB2\x10\xD8\x91\x3A\xB3\xF0\x40\xA7\xFC\xE2\x9B\xB5\xD6\x7B\x56\x91\x6A\xD6\x99\x42\x29\x2E\x13\xF2\x3B\x1C\x36\xCA\x5E\x72\x1B\xC9\xC3\x5F\x2F\xFB\xD8\xDA\x9C\x43\x61\xA2\x98\xE3\x59\xA2\xAD\x23\x85\x67\x3A\x95\x77\x08\xAB\x22\x87\x2E\xCE\xEB\x9D\xF3\x72\x31\xB7\xE1\xB0\x5A\x68\xC5\xC4\xDE\x71\x35\x0A\x34\x54\x4A\x64\x82\xA4\x78\xCE\x95\x00\xD0\x0A\xDF\x2C\x82\x2E\x3C\x5A\xA3\x1C\x65\x9E\x59\x9A\x2B\x51\xEC\x38\x7D\xFB\xDA\x8A\xA1\x35\x67\x8B\x98\x74\x23\x9C\xB1\x53\xCE\x5A\x9D\x2B\x82\x6B\x6B\x9A\x7E\x00\x1E\xC2\x6D\x55\x49\xE8\x35\x4B\x3B\x06\xC3\x3E\x22\xB8\x37\x8A\x06\x0D\xB5\x5B\x28\x8A\x39\xC2\xC5\x8E\xD5\xBE\x03\x6A\x83\xE1\x5E\x2C\xAE\x8A\x4F\x7B\x42\xF9\x35\xCF\xD7\x8A\xE0\x8E\x50\x9E\xF9\xBC\x04\xA7\x0B\xCD\x69\x37\xB5\xA8\x87\x55\x78\xAC\x2A\x2A\x77\xAD\xF6\xD4\x09\x8E\xC2\x7C\x11\x5C\xAB\xD8\x0E\xEF\x95\x68\xB9\x43\x09\xF3\x15\xC5\x26\x91\xD5\x9A\xAA\xE4\xBC\x7E\xA1\x3D\x85\xE2\xAA\x98\xE8\x39\x06\x69\x90\x6B\x10\xDB\x4A\x3F\xC5\xE9\x46\xEF\x84\xDF\xDD\x72\x92\x79\x5D\x55\x22\xC2\x52\x21\x93\xED\x68\x4B\x98\x28\x3D\x6F\x1F\x13\x5A\xD1\x0C\x8E\x14\x3F\xB6\x7F\x59\x8B\x6A\x02\xFF\xD4\x7B\xCE\xA0\xE6\x6B\xD6\x09\x13\x6F\x57\x5B\xC2\x64\xBC\x47\x4C\x75\xAF\x82\x63\x0F\x11\x81\xBD\xCE\xC8\x51\x8B\x81\xD8\x88\xBF\x1B\xD0\x35\xB4\x41\x2A\x3C\xED\x3C\x38\x3F\x55\x7C\xD2\xF9\x1A\xDF\xE0\xEF\x25\x84\x79\x9E\x91\x8F\x94\xFD\xB1\x44\xB2\x2E\x9B\xE8\x13\x5A\x8F\x38\xB9\x81\xB9\xFE\xB2\x31\x4D\x8A\xB5\x5F\x90\x26\xBB\xA1\x30\x4B\x4E\xC9\xBC\xD3\xE8\x44\xCA\x1A\x36\x4B\x91\xE8\x5F\xB5\x17\xFA\x9F\x8D\xDA\x2C\xD9\xD1\x93\xB5\x97\x30\xD6\xCE\xB9\xEF\x21\x11\xFB\x09\xCF\xDF\xAB\xD6\xB6\x64\x1F\x30\x44\x3F\xFF\x08\x61\x91\xE4\x00\xB7\x26\x42\x07\x1E\x28\x7B\x4A\xDA\xAE\xDA\x7D\x7E\xA0\x53\xF6\x8B\x07\x88\xF6\x75\x8B\xDF\x9B\xD9\xFB\xEC\x53\xA5\xB0\x3B\xB3\xCD\xEB\x18\x0E\x1B\xF1\x63\xD9\x1F\x6F\x4D\x53\xD5\x3B\xEF\x79\xB0\x24\xFF\x9A\xAD\x52\x15\xC5\x5A\x89\x4A\xCB\x65\xE3\xBE\xAB\x68\xE1\xB6\x23\xF4\xFC\xA1\x70\x03\x3E\x25\xE7\x42\xB7\xA2\x9E\x19\xDE\x2D\x59\xD3\xF3\x8D\x4C\xB4\x9A\x22\x11\x72\xAC\x61\x15\x7E\xA5\x4E\x13\x60\x3D\xA1\xAC\x97\x6E\x9C\x5B\xDA\xBC\xA8\xB1\x8C\x6E\x71\xFE\xD7\xA8\xC3\x28\x06\xD3\xA4\x87\xA5\x51\x6E\x75\xDB\x96\x35\xB6\x71\xBB\x64\x8F\x1F\xA9\xF7\xE6\x60\x42\xEB\x16\xE7\xF7\x6D\xD1\xBC\x17\x12\x56\x88\xA5\xDD\x34\xD8\x07\x86\xF2\x59\x1B\xF4\xDD\x61\xD1\xB6\xCB\x8E\xC6\x18\x9E\x15\x7F\x7E\xB9\x21\x8A\x3A\xC3\x39\xFA\xA7\x45\xDB\x8A\xF4\x50\x8C\x57\x6C\x96\x26\xC1\x05\x72\x11\xC0\xA0\x68\x24\x3A\xDE\x2F\x87\x19\x6E\x6B\x79\x59\x63\x17\x5B\x24\x3D\x76\x21\xC3\x5F\xBA\xD1\x28\xA5\xB8\x19\x5F\x92\x7A\xE5\xFF\x1B\x7A\xC4\x92\xBE\x26\x4D\x89\xC3\xA2\xC8\xBD\x1C\x0F\x48\x54\x9D\x63\x6C\xDD\x5A\xD5\x0A\xBA\x84\x56\x7C\x59\x01\x4B\x2A\x7A\x6D\xCE\x83\x42\xF6\xA6\x4B\xA6\x62\xB4\x52\x35\x65\x60\x8D\xBE\x3B\x87\x16\x17\x19\xD8\xCC\x5D\x43\xCB\x24\x55\xB2\xAD\x5C\x0E\x30\x92\xD5\xA0\xB2\xF0\x94\xD0\x8A\x0B\x34\xDE\x8A\xBA\x15\xCD\x08\x8D\x44\xD5\x25\xC2\x96\x77\x31\xBE\xAE\xA0\x58\x22\x55\xFC\x8B\x35\xE0\xF4\xEB\xA1\xD5\x4B\xE7\xA6\xE1\x0D\x72\x48\xFE\x84\x96\x66\x6A\x3F\xD6\x48\x53\xCD\x02\x21\xAE\xCD\xB6\x98\x95\x72\x53\x5F\x45\xFC\xDB\x49\x72\x0A\xF7\xC8\x96\x67\x2C\x17\x1B\x45\x48\x57\xF7\xFE\xDD\xA7\xC5\x5A\x48\x99\x17\x69\x4E\x92\xC2\xC7\x29\xD2\x8D\x38\xDA\x77\xAB\x75\x4B\x31\xE4\x3A\x21\xAD\x77\x68\x41\xBB\xFA\xA3\xEC\xDB\x47\x2B\x92\x69\x3D\x40\x9A\xEB\x8E\x91\xA2\xF1\x48\x62\x13\xFE\x86\xDF\xE3\x8F\xD2\x7D\xB9\x52\x89\x95\xB6\x76\xDD\x73\x5B\x95\x3C\xD9\x81\x62\xAE\xBB\x89\x16\x1E\xA8\xF5\x23\x45\xF5\xB0\x4A\x68\xC3\xFD\xC2\x27\x6F\x15\xCD\x7A\x4E\xF9\x2D\x17\x6D\xBF\x51\xB9\x22\x35\x81\x59\xD2\x9F\x7B\xA4\x70\xBC\x4E\x39\x80\xBF\xBB\xDC\x64\x50\x43\xED\x92\x5F\xB2\x17\xEC\xF0\xBF\x5C\xB0\x5B\x08\xE9\x5A\xA9\x2D\x2C\x97\x4D\xF6\x32\xD1\xAE\xC5\xD2\x66\xB1\x56\x1B\x8F\x96\x57\x7A\x7A\xC6\xF3\xB1\xF5\xD1\xC1\x7F\x01\xED\xE5\x0A\xEF\x37\x63\xAE\xF6\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"
local warn_data = "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x4D\x00\x00\x00\x4D\x08\x06\x00\x00\x00\xE3\x09\xE9\xB0\x00\x00\x01\x37\x69\x43\x43\x50\x41\x64\x6F\x62\x65\x20\x52\x47\x42\x20\x28\x31\x39\x39\x38\x29\x00\x00\x28\x91\x95\x8F\xBF\x4A\xC3\x50\x14\x87\xBF\x1B\x45\xC5\xA1\x56\x08\xE2\xE0\x70\x27\x51\x50\x6C\xD5\xC1\x8C\x49\x5B\x8A\x20\x58\xAB\x43\x92\xAD\x49\x43\x95\x62\x12\x6E\xAE\x7F\xFA\x10\x8E\x6E\x1D\x5C\xDC\x7D\x02\x27\x47\xC1\x41\xF1\x09\x7C\x03\xC5\xA9\x83\x43\x84\x0C\x05\x8B\xDF\xF4\x9D\xDF\x39\x1C\xCE\x01\xA3\x62\xD7\x9D\x86\x51\x86\xF3\x58\xAB\x76\xD3\x91\xAE\xE7\xCB\xD9\x17\x66\x98\x02\x80\x4E\x98\xA5\x76\xAB\x75\x00\x10\x27\x71\xC4\x18\xDF\xEF\x08\x80\xD7\x4D\xBB\xEE\x34\xC6\xFB\x7F\x32\x1F\xA6\x4A\x03\x23\x60\xBB\x1B\x65\x21\x88\x0A\xD0\xBF\xD2\xA9\x06\x31\x04\xCC\xA0\x9F\x6A\x10\x0F\x80\xA9\x4E\xDA\x35\x10\x4F\x40\xA9\x97\xFB\x1B\x50\x0A\x72\xFF\x00\x4A\xCA\xF5\x7C\x10\x5F\x80\xD9\x73\x3D\x1F\x8C\x39\xC0\x0C\x72\x5F\x01\x4C\x1D\x5D\x6B\x80\x5A\x92\x0E\xD4\x59\xEF\x54\xCB\xAA\x65\x59\xD2\xEE\x26\x41\x24\x8F\x07\x99\x8E\xCE\x33\xB9\x1F\x87\x89\x4A\x13\xD5\xD1\x51\x17\xC8\xEF\x03\x60\x31\x1F\x6C\x37\x1D\xB9\x56\xB5\xAC\xBD\xF5\x7F\xFE\x3D\x11\xD7\xF3\x65\x6E\x9F\x47\x08\x40\x2C\x3D\x17\x59\x41\x78\xA1\x2E\x7F\x55\x18\x3B\x93\xEB\x62\xC7\x70\x19\x0E\xEF\x61\x7A\x54\x64\xBB\x37\x70\xB7\x01\x0B\xB7\x45\xB6\x5A\x85\xF2\x16\x3C\x0E\x7F\x00\xC0\xC6\x4F\xFD\xF3\x53\x3F\xC8\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x2E\x23\x00\x00\x2E\x23\x01\x78\xA5\x3F\x76\x00\x00\x06\xC9\x69\x54\x58\x74\x58\x4D\x4C\x3A\x63\x6F\x6D\x2E\x61\x64\x6F\x62\x65\x2E\x78\x6D\x70\x00\x00\x00\x00\x00\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x62\x65\x67\x69\x6E\x3D\x22\xEF\xBB\xBF\x22\x20\x69\x64\x3D\x22\x57\x35\x4D\x30\x4D\x70\x43\x65\x68\x69\x48\x7A\x72\x65\x53\x7A\x4E\x54\x63\x7A\x6B\x63\x39\x64\x22\x3F\x3E\x20\x3C\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x3D\x22\x61\x64\x6F\x62\x65\x3A\x6E\x73\x3A\x6D\x65\x74\x61\x2F\x22\x20\x78\x3A\x78\x6D\x70\x74\x6B\x3D\x22\x41\x64\x6F\x62\x65\x20\x58\x4D\x50\x20\x43\x6F\x72\x65\x20\x35\x2E\x36\x2D\x63\x31\x34\x35\x20\x37\x39\x2E\x31\x36\x33\x34\x39\x39\x2C\x20\x32\x30\x31\x38\x2F\x30\x38\x2F\x31\x33\x2D\x31\x36\x3A\x34\x30\x3A\x32\x32\x20\x20\x20\x20\x20\x20\x20\x20\x22\x3E\x20\x3C\x72\x64\x66\x3A\x52\x44\x46\x20\x78\x6D\x6C\x6E\x73\x3A\x72\x64\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x77\x33\x2E\x6F\x72\x67\x2F\x31\x39\x39\x39\x2F\x30\x32\x2F\x32\x32\x2D\x72\x64\x66\x2D\x73\x79\x6E\x74\x61\x78\x2D\x6E\x73\x23\x22\x3E\x20\x3C\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x20\x72\x64\x66\x3A\x61\x62\x6F\x75\x74\x3D\x22\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x4D\x4D\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x6D\x6D\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x45\x76\x74\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x45\x76\x65\x6E\x74\x23\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x64\x63\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x70\x75\x72\x6C\x2E\x6F\x72\x67\x2F\x64\x63\x2F\x65\x6C\x65\x6D\x65\x6E\x74\x73\x2F\x31\x2E\x31\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x33\x3A\x32\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x32\x31\x3A\x31\x33\x3A\x34\x30\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x32\x31\x3A\x31\x33\x3A\x34\x30\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x66\x36\x64\x34\x61\x63\x61\x33\x2D\x64\x62\x30\x36\x2D\x31\x61\x34\x34\x2D\x61\x37\x66\x38\x2D\x34\x39\x64\x33\x61\x31\x66\x61\x32\x65\x33\x30\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x30\x34\x62\x66\x62\x64\x31\x65\x2D\x35\x36\x32\x66\x2D\x62\x34\x34\x32\x2D\x38\x38\x37\x31\x2D\x32\x31\x38\x35\x62\x33\x31\x39\x65\x38\x39\x39\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x64\x61\x64\x63\x36\x30\x39\x37\x2D\x35\x65\x38\x32\x2D\x37\x37\x34\x61\x2D\x62\x32\x63\x30\x2D\x31\x64\x65\x34\x39\x63\x64\x30\x64\x61\x36\x65\x22\x20\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3D\x22\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3D\x22\x33\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x49\x43\x43\x50\x72\x6F\x66\x69\x6C\x65\x3D\x22\x41\x64\x6F\x62\x65\x20\x52\x47\x42\x20\x28\x31\x39\x39\x38\x29\x22\x3E\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x63\x72\x65\x61\x74\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x64\x61\x64\x63\x36\x30\x39\x37\x2D\x35\x65\x38\x32\x2D\x37\x37\x34\x61\x2D\x62\x32\x63\x30\x2D\x31\x64\x65\x34\x39\x63\x64\x30\x64\x61\x36\x65\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x33\x3A\x32\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x35\x66\x33\x62\x38\x64\x64\x39\x2D\x38\x36\x62\x30\x2D\x64\x65\x34\x34\x2D\x39\x34\x63\x35\x2D\x38\x62\x39\x30\x35\x61\x37\x36\x63\x33\x65\x63\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x30\x30\x3A\x32\x33\x3A\x32\x33\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x66\x36\x64\x34\x61\x63\x61\x33\x2D\x64\x62\x30\x36\x2D\x31\x61\x34\x34\x2D\x61\x37\x66\x38\x2D\x34\x39\x64\x33\x61\x31\x66\x61\x32\x65\x33\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x35\x2D\x30\x38\x2D\x32\x32\x54\x32\x31\x3A\x31\x33\x3A\x34\x30\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x39\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x52\x44\x46\x3E\x20\x3C\x2F\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x3E\x20\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x65\x6E\x64\x3D\x22\x72\x22\x3F\x3E\x6F\xB3\x18\x9D\x00\x00\x05\x5D\x49\x44\x41\x54\x78\x9C\xED\xDC\x5B\xA8\x54\x55\x1C\xC7\xF1\xCF\x8C\x47\xAD\x34\xD3\xB2\xD4\x8A\x34\x0A\xA9\xE8\x5E\x16\x96\xA0\x24\x25\x21\xA6\xDD\x48\x09\xA4\xFB\x85\xA2\x7B\xA2\x95\x61\x65\x92\x76\x37\x82\xE8\x21\xE8\x29\xF2\xA5\x87\xA0\x22\x2A\xBA\x50\xBD\x75\x79\x08\xA2\xA4\x92\x0A\xBA\xD3\x95\x2E\x50\xA7\x87\xE5\xA1\x73\xE6\xCC\x9E\x33\x7B\xEF\xB5\xF6\x3E\x87\xE6\x0B\x07\xCE\xAC\x99\xF5\x5F\xFF\xF9\xCD\xBE\xFC\xD7\x7F\xFD\xD7\x6E\xF4\xF7\xF7\xEB\x91\x8F\x66\xDD\x0E\x8C\x45\x7A\xA2\x15\xA0\xCF\xCF\x2B\xEA\xF6\x61\x80\x69\x58\x85\x73\x30\x07\xFD\x68\x60\x07\x9E\xC1\xD3\xF8\xBA\x2E\xE7\x06\xD3\xE8\xFF\x69\x79\xDD\x3E\xC0\x72\x6C\xC1\xDC\x0E\x9F\xD9\x81\x35\xD8\x56\x89\x47\x1D\xE8\xAB\xDB\x01\xAC\xC4\x93\x98\x30\xC2\xE7\x66\x0B\x47\xDB\x9E\x78\x2C\xB5\x53\x9D\xA8\xFB\x9A\x76\x1C\x9E\x30\xB2\x60\x83\x79\x14\x8B\xD3\xB8\xD3\x1D\x75\x8A\xD6\x87\x87\xB0\x6B\xCE\x7E\x4D\x6C\xC5\xE4\xD8\x0E\xE5\x71\xA0\x2E\xAE\xC3\x82\x82\x7D\x0F\xC3\xFA\x78\xAE\xE4\xA3\x2E\xD1\xE6\xE2\xD6\x92\x36\xAE\xC1\xF1\x11\x7C\xC9\x4D\x5D\xA2\x6D\xC1\xD4\x92\x36\x76\xC1\x83\x18\x5F\xDA\x9B\x9C\xD4\x21\xDA\x2A\x21\xC4\x88\xC1\x02\x5C\x1E\xC9\x56\xD7\x54\x1D\xA7\x4D\xC5\x3B\x38\x30\xA2\xCD\x6F\x71\x0C\xBE\x8C\x68\xB3\x23\x55\x1F\x69\xB7\x88\x2B\x18\xEC\x8D\xBB\x22\xDB\xEC\x48\x95\xA2\xCD\xC3\xB5\x89\x6C\x5F\x80\x25\x89\x6C\x0F\xA3\x2A\xD1\x06\x62\xB2\x3C\x41\x6C\x1E\x1A\x78\x40\x45\xB1\x5B\x55\xA2\x5D\x89\x93\x12\x8F\x71\x18\x6E\x4E\x3C\x06\xAA\x11\x6D\x26\xD6\x55\x30\x0E\xE1\xF4\x3F\x24\xF5\x20\x55\x88\x76\x37\x66\x55\x30\x0E\xEC\x81\xFB\x52\x0F\x92\x5A\xB4\xB3\x71\x61\xE2\x31\x5A\x59\x2A\x71\xEC\x96\x52\xB4\xE9\xC2\xC5\xB9\x91\x70\x8C\x2C\x36\x09\xA9\xA4\x24\xA4\x14\xED\x36\x1C\x90\xD0\x7E\x27\xF6\x14\x2E\x0B\x49\x48\x25\xDA\x3C\x5C\x56\xD2\xC6\x77\xF8\xB5\x44\xFF\x95\x38\xAD\xA4\x0F\x6D\x49\x21\xDA\x78\xE1\xB4\xCC\x9B\x27\x1B\xE0\x05\x21\xC9\x78\x08\x0E\xC7\x66\x61\xBD\x20\x2F\xE3\x70\xBF\x04\xB1\x5B\x0A\xD1\xAE\x50\x3C\x4F\xF6\x3A\xCE\xC4\x2B\xF8\x5E\x58\x17\x58\x8B\x67\x0B\xDA\x3B\x5C\x58\x57\x88\x4A\x6C\xD1\x66\x63\x43\x89\xFE\x5B\xF1\x47\x9B\xF6\xE7\x4B\xD8\xBC\x11\x47\x94\xE8\x3F\x8C\xD8\xA2\xDD\x21\x5C\x84\x8B\xF2\x49\x46\xFB\x7B\xF8\xA7\xA0\xCD\xDD\x84\x9B\x42\xB4\xBB\x78\x4C\xD1\x96\x60\x75\x49\x1B\x59\x5F\xEC\x6B\xFC\x59\xC2\xEE\x32\x21\x8F\x17\x85\x58\xA2\x4D\x16\xB2\xA8\xA9\x62\xB2\x18\x76\x37\x0B\x69\xA4\xD2\xC4\x12\x6D\x1D\x0E\x8D\x64\xAB\x1D\x31\xAA\x74\xF6\xC7\xC6\x08\x76\xA2\x88\x76\x24\xAE\x8F\x60\x87\xF0\xC5\xDA\x31\x5E\x1C\x5F\x2F\xC6\xC2\xB2\x46\xCA\x3A\x32\x01\x0F\x2B\x1E\x93\xB5\xB2\x4B\x46\xFB\xBE\x98\x18\xC1\xFE\x38\x11\xD6\x4C\xCB\x8A\x76\x15\x16\x95\xB4\x31\x98\x99\x19\xED\x73\x22\x8E\x71\xA4\x92\xA9\xAA\x32\xA2\x1D\x2C\xFE\x82\x6D\x56\xB8\x12\x3B\xAA\xBF\x1E\xC7\x16\xED\x5C\x54\xB4\x86\xB0\x76\x39\xAD\xE8\xC0\x19\x4C\xCA\x68\xCF\xBA\xD6\x15\x65\x57\x61\xAA\x57\x68\xCD\xB4\xA8\x68\x4B\x85\xE9\x4E\x6C\xB2\xB2\x22\x53\x12\x8C\xB5\x10\xE7\x17\xE9\x58\x44\xB4\xC9\x42\xBE\x2A\x05\x59\xA1\x45\xAA\x14\xD3\x46\xCC\xC8\xDB\xA9\x88\x68\x6B\x44\x9E\xCB\x0D\x62\xAF\x8C\xF6\xDD\x12\x8D\xB7\x9F\x02\x73\xE5\xBC\xA2\x1D\x2D\x4C\x80\x53\xD1\x4E\xB4\x09\xB2\xEF\xAA\x31\xB8\x44\xCE\x08\x20\x8F\x68\x4D\x61\xD1\x22\xD5\xAF\x4E\xB8\x30\xB7\x56\x67\x8E\x4F\x3C\x66\x9F\x90\x77\xCB\x8A\x11\x87\x91\x47\xB4\x55\xD2\x57\x20\xCE\x10\x56\x94\x06\xB3\x97\xEC\xD3\x36\x16\xC7\xCA\x91\x69\xEE\x56\xB4\xBD\x71\x4F\x21\x77\xCA\x33\x51\x35\xE5\x54\x1B\x74\x59\x67\xD2\xAD\x68\xF7\x88\x1F\x2B\xB5\x63\xA2\xE1\x53\xB2\x99\xE2\x4C\xA1\x46\x62\x9A\x50\x3A\x31\x62\x46\xA5\x1B\xD1\xCE\xC1\x45\x25\x1D\xEA\x96\x29\x86\x4F\x99\x52\xDE\x04\x5A\x39\x43\x17\x6B\xA6\x23\x89\x36\x45\xF5\xA7\xE5\x09\x2D\xAF\x17\x55\x3C\xFE\x06\x23\xFC\x50\x23\x89\xB6\x16\x07\xC5\xF2\xA6\x4B\x56\x63\x9F\x9D\xFF\xCF\x11\xAF\x6A\xB2\x5B\x66\xE0\xCE\x4E\x1F\xE8\x54\x09\x79\x1C\xDE\x10\x2F\xED\x93\x87\x4F\xB1\x5D\xA8\x04\xDA\xAF\x86\xF1\xFF\x16\xD2\xF7\x2F\xB7\x7B\x33\x4B\xB4\x3E\xBC\x24\x42\xC2\x6E\x0C\xF3\x3E\x4E\xC6\x6F\xAD\x6F\x64\x9D\x9E\x97\xF8\x7F\x0B\x06\x47\xE1\x86\x76\x6F\xB4\x3B\xD2\x66\x08\x4B\x66\x55\xDE\xB5\x46\x2B\x3F\x0B\x97\xA9\xED\x83\x1B\xDB\x1D\x69\x9B\xD4\x2B\xD8\x67\x42\x45\xE3\x0A\xE1\x88\x7F\xB7\x46\x5F\xA6\xE0\xDE\xD6\xC6\xD6\x23\xED\x54\xA1\x96\xA2\xAE\x4D\x19\xDB\x71\x0A\x3E\x1F\xD4\x36\x15\xCF\x61\x7E\x1D\x0E\xED\x64\xA5\xB0\x03\x10\x43\xC5\x99\x24\x64\x33\xEB\xDC\x2F\xF5\x88\xA1\x82\xC1\x8F\xC2\x96\xA0\xBF\x2B\xF7\xE6\x3F\x36\x0B\xF5\x76\x18\x2A\xD0\x8D\x42\xC1\x48\x9D\xEC\xC8\x68\xFF\x48\xB9\x15\xF6\xB2\xCC\xC6\xED\x03\x2F\x06\x44\x9B\x2B\xEC\x8A\xAB\x9B\xE9\x19\xED\xB3\xA4\x2B\xA7\xEF\x96\x4B\xED\xAC\x86\x6A\x0A\x13\xD4\x07\xC5\x5F\x24\x29\xC2\x15\x86\x07\xD3\x0D\xA1\xAA\xB2\xEE\x5D\xD0\x03\x1B\xD8\x26\x34\xFA\x7F\x5A\x3E\x1F\x6F\xD5\xEC\xD0\x60\x5E\x15\x56\xBA\x3E\x17\x96\xF4\xAE\xC6\xB9\x75\x3A\xD4\xC2\xB2\x3E\x15\x6E\x8F\xE9\x92\x45\x3B\xFF\x06\x9E\x96\x30\xDA\x38\xBD\x29\xFD\x4E\x92\xA2\x8C\x46\xC1\xE0\xC4\xA6\xE1\xE9\xE5\x1E\x9D\xD9\xBD\x29\xBB\xFA\xB0\x47\x7B\xBE\x68\xCA\x48\x7F\xF4\xC8\xE4\xB5\xA6\x30\x6D\xFA\xA5\x6E\x4F\xC6\x08\x7F\x60\x5B\x13\x5F\xE0\xF1\x9A\x9D\x19\x2B\x3C\x85\x0F\x07\x66\x04\xEB\x85\xF8\xA8\x47\x36\xEF\xE2\x26\xFE\x9B\x46\xFD\x8E\xF3\xF0\x62\x5D\x1E\x8D\x72\xDE\xC6\x59\xF8\x81\xA1\x13\xF6\x6F\x84\x12\xAA\xEB\xF0\x41\xE5\x6E\x8D\x4E\x3E\x16\x1E\x56\xB0\x58\xC8\xF3\x21\x7B\x8D\x60\xBA\x10\xF4\x1E\x2F\xCC\x05\xFF\x4F\xCF\x40\x6C\xE0\x2F\xE1\x51\x18\x6F\xE2\xAB\x61\x1F\xE8\x3D\x13\x32\x3F\x75\x3F\x0A\x6C\x4C\xD2\x13\xAD\x00\x3D\xD1\x0A\xD0\x13\xAD\x00\x3D\xD1\x0A\xD0\x13\xAD\x00\x3D\xD1\x0A\xD0\x13\xAD\x00\xFF\x02\xD9\xE2\xB1\x19\xB8\x7C\xCE\xAF\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"
local style_colors = {
    error = {
        main = imgui.ImVec4(0.15, 0.15, 0.15, 1),
        accent = imgui.ImVec4(1, 0.27, 0.27, 1),
        text = imgui.ImVec4(1, 1, 1, 1),
        title = imgui.ImVec4(1, 1, 1, 1),
        icon = "error"
    },
    info = {
        main = imgui.ImVec4(0.15, 0.15, 0.15, 1),
        accent = imgui.ImVec4(0.16, 0.71, 0.96, 1),
        text = imgui.ImVec4(1, 1, 1, 1),
        title = imgui.ImVec4(1, 1, 1, 1),
        icon = "info"
    },
    success = {
        main = imgui.ImVec4(0.15, 0.15, 0.15, 1),
        accent = imgui.ImVec4(0, 0.9, 0, 1),
        text = imgui.ImVec4(1, 1, 1, 1),
        title = imgui.ImVec4(1, 1, 1, 1),
        icon = "success"
    },
    warn = {
        main = imgui.ImVec4(0.15, 0.15, 0.15, 1),
        accent = imgui.ImVec4(1, 0.95, 0.3, 1),
        text = imgui.ImVec4(1, 1, 1, 1),
        title = imgui.ImVec4(1, 1, 1, 1),
        icon = "warn"
    }
}

function AddNotification(title, text, style, duration)
    style = style or "info"
    duration = duration or default_duration
    
    local notification = {
        id = next_id,
        title = title or "",
        text = text or "",
        style = style,
        creation_time = os.clock(),
        duration = duration
    }
    
    table.insert(notifications, notification)
    next_id = next_id + 1
    
    return notification.id
end

function AddModalNotification(title, text, button, style, duration)
    style = style or "info"
    duration = duration or default_duration
    button = button or "Закрыть"
    
    local modal = {
        id = modal_next_id,
        title = title or "",
        text = text or "",
        button = button,
        style = style,
        creation_time = os.clock(),
        duration = duration,
        visible = imgui.new.bool(true)
    }
    
    table.insert(modal_notifications, modal)
    modal_next_id = modal_next_id + 1
    
    return modal.id
end

function RenderNotifications()
    if #notifications == 0 then return end

    local sw, sh = getScreenResolution()
    local dl = imgui.GetBackgroundDrawList()
    local current_time = os.clock()
    local padding = 10
    local start_y = sh - 120
    
    for i = #notifications, 1, -1 do
        local notif = notifications[i]
        local elapsed = current_time - notif.creation_time
        
        if elapsed > notif.duration then
            table.remove(notifications, i)
            goto continue
        end
        
        local colors = style_colors[notif.style] or style_colors.info
        
        local width = 300
        local accent_width = 15
        local height = 80
        local radius = height / 2
        
        local pos_x = sw - width - padding
        local pos_y = start_y
        
        start_y = start_y - height - padding
        
        local main_min = imgui.ImVec2(pos_x, pos_y)
        local main_max = imgui.ImVec2(pos_x + width - accent_width, pos_y + height)
        
        local accent_min = imgui.ImVec2(pos_x + width - accent_width + 4, pos_y)
        local accent_max = imgui.ImVec2(pos_x + width - 4, pos_y + height)
        
        dl:AddRectFilled(main_min, main_max, imgui.GetColorU32Vec4(colors.main), 5, 1 + 8)
        
        dl:AddRectFilled(accent_min, accent_max, imgui.GetColorU32Vec4(colors.accent), 0, 0)
        
        local center_y = pos_y + height / 2
        local circle_center = imgui.ImVec2(pos_x, center_y)
        dl:AddCircleFilled(circle_center, radius, imgui.GetColorU32Vec4(colors.main), 24)
        
        local icon_window_size = radius * 2
        imgui.SetNextWindowPos(imgui.ImVec2(pos_x - radius, pos_y))
        imgui.SetNextWindowSize(imgui.ImVec2(icon_window_size, icon_window_size))
        imgui.Begin("NotificationIcon_" .. notif.id, nil, 
            imgui.WindowFlags.NoTitleBar +
            imgui.WindowFlags.NoResize +
            imgui.WindowFlags.NoMove +
            imgui.WindowFlags.NoScrollbar +
            imgui.WindowFlags.NoSavedSettings +
            imgui.WindowFlags.NoFocusOnAppearing +
            imgui.WindowFlags.NoNav +
            imgui.WindowFlags.NoBackground
        )
        
        local texture
        if colors.icon == "error" and error_img then
            texture = error_img
        elseif colors.icon == "info" and info_img then
            texture = info_img
        elseif colors.icon == "success" and success_img then
            texture = success_img
        elseif colors.icon == "warn" and warn_img then
            texture = warn_img
        end
        
        if texture then
            local image_size = imgui.ImVec2(32, 32)
            local image_pos = imgui.ImVec2(
                (icon_window_size - image_size.x) / 2,
                (icon_window_size - image_size.y) / 2
            )
            imgui.SetCursorPos(image_pos)
            imgui.Image(texture, image_size)
        end
        
        imgui.End()
        
        local progress = 1.0 - (elapsed / notif.duration)
        local progress_height = 3
        local progress_y = pos_y + height - progress_height
        
        local progress_min = imgui.ImVec2(pos_x + radius - 45, progress_y)
        local progress_max = imgui.ImVec2(pos_x + width - accent_width - 5, progress_y + progress_height)
        local progress_fill_max = imgui.ImVec2(progress_min.x + (progress_max.x - progress_min.x) * progress, progress_y + progress_height)
        
        dl:AddRectFilled(progress_min, progress_fill_max, imgui.GetColorU32Vec4(colors.accent), 0, 0)
        
        imgui.SetNextWindowPos(imgui.ImVec2(pos_x, pos_y))
        imgui.SetNextWindowSize(imgui.ImVec2(width - accent_width, height))
        imgui.Begin("NotificationText_" .. notif.id, nil, 
            imgui.WindowFlags.NoTitleBar +
            imgui.WindowFlags.NoResize +
            imgui.WindowFlags.NoMove +
            imgui.WindowFlags.NoScrollbar +
            imgui.WindowFlags.NoSavedSettings +
            imgui.WindowFlags.NoFocusOnAppearing +
            imgui.WindowFlags.NoNav +
            imgui.WindowFlags.NoBackground
        )
        
        imgui.SetWindowFontScale(1.2)
        imgui.SetCursorPos(imgui.ImVec2(30, 12))
        imgui.TextColored(colors.title, notif.title)
        
        imgui.SetWindowFontScale(1.0)
        imgui.SetCursorPos(imgui.ImVec2(30, 35))
        imgui.TextColored(colors.text, notif.text)
        
        imgui.End()
        
        ::continue::
    end
end

function RenderModalNotifications()
    if #modal_notifications == 0 then return end

    local sw, sh = getScreenResolution()
    local current_time = os.clock()
    local dl = imgui.GetBackgroundDrawList()
    
    local has_active_modals = false
    for _, modal in ipairs(modal_notifications) do
        if modal.visible[0] then
            has_active_modals = true
            break
        end
    end
    
    if has_active_modals then
        local overlay_min = imgui.ImVec2(0, 0)
        local overlay_max = imgui.ImVec2(sw, sh)
        dl:AddRectFilled(overlay_min, overlay_max, imgui.GetColorU32Vec4(imgui.ImVec4(0, 0, 0, 0.6)), 0)
    end
    
    for i = #modal_notifications, 1, -1 do
        local modal = modal_notifications[i]
        local elapsed = current_time - modal.creation_time
        
        if elapsed > modal.duration and modal.visible[0] then
            modal.visible[0] = false
            table.remove(modal_notifications, i)
            goto continue
        end
        
        if modal.visible[0] then
            local colors = style_colors[modal.style] or style_colors.info
            
            local window_width = 390
            local window_height = 230
            local window_pos = imgui.ImVec2(sw / 2 - window_width / 2, sh / 2 - window_height / 2)
            local corner_radius = 10.0
            
            local window_min = window_pos
            local window_max = imgui.ImVec2(window_pos.x + window_width, window_pos.y + window_height)
            
            dl:AddRectFilled(window_min, window_max, imgui.GetColorU32Vec4(colors.main), corner_radius, 1 + 2)
            
            local progress = 1.0 - (elapsed / modal.duration)
            local progress_height = 3
            local progress_width = window_width
            local progress_pos = imgui.ImVec2(window_pos.x, window_pos.y + window_height - progress_height)
            
            local progress_bg_min = progress_pos
            local progress_bg_max = imgui.ImVec2(progress_pos.x + progress_width, progress_pos.y + progress_height)
            dl:AddRectFilled(progress_bg_min, progress_bg_max, imgui.GetColorU32Vec4(imgui.ImVec4(0.3, 0.3, 0.3, 1.0)), 0)
            
            local progress_fill_width = progress_width * progress
            local progress_fill_max = imgui.ImVec2(progress_pos.x + progress_fill_width, progress_pos.y + progress_height)
            dl:AddRectFilled(progress_pos, progress_fill_max, imgui.GetColorU32Vec4(colors.accent), 0)
            
            imgui.SetNextWindowPos(window_pos)
            imgui.SetNextWindowSize(imgui.ImVec2(window_width, window_height))
            imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
            imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
            
            if imgui.Begin("##modal_notification_" .. modal.id, modal.visible, 
                imgui.WindowFlags.NoResize + 
                imgui.WindowFlags.NoCollapse + 
                imgui.WindowFlags.NoTitleBar +
                imgui.WindowFlags.NoMove +
                imgui.WindowFlags.NoScrollbar +
                imgui.WindowFlags.NoBackground
            ) then
                imgui.NewLine()
                imgui.SetCursorPosX((window_width - imgui.CalcTextSize(modal.title).x) / 2)
                imgui.TextColored(colors.title, modal.title)
                imgui.NewLine()
                
                local texture
                if colors.icon == "error" and error_img then
                    texture = error_img
                elseif colors.icon == "info" and info_img then
                    texture = info_img
                elseif colors.icon == "success" and success_img then
                    texture = success_img
                elseif colors.icon == "warn" and warn_img then
                    texture = warn_img
                end
                
                if texture then
                    imgui.SetCursorPosX((window_width - 42) / 2)
                    imgui.Image(texture, imgui.ImVec2(42, 42))
                end
                
                imgui.NewLine()
                
                imgui.SetCursorPosX((window_width - imgui.CalcTextSize(modal.text).x) / 2)
                imgui.TextColored(colors.text, modal.text)
                imgui.NewLine()
                
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(colors.accent.x * 1.2, colors.accent.y * 1.2, colors.accent.z * 1.2, colors.accent.w - 0.25))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(colors.accent.x * 1.2, colors.accent.y * 1.2, colors.accent.z * 1.2, colors.accent.w - 0.25))
                imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(colors.accent.x * 0.8, colors.accent.y * 0.8, colors.accent.z * 0.8, colors.accent.w - 0.25))
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))
                
                imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 8.0)
                
                imgui.SetCursorPosX((window_width - 160) / 2)
                if imgui.Button(modal.button, imgui.ImVec2(160, 30)) then
                    modal.visible[0] = false
                end
                
                imgui.PopStyleVar()
                imgui.PopStyleColor(4)
                imgui.End()
            end
            
            imgui.PopStyleColor(2)
            
            if not modal.visible[0] then
                table.remove(modal_notifications, i)
            end
        end
        
        ::continue::
    end
end

function isItemList(item)
    if items[item] then
        return true, items[item]
    else
        return false, nil
    end
end

local tabs = {
    'Основное',
    'Настройки',
    'Правила сервера',
    'Таблица наказаний',
    'Информация',
}

function checkadminka(nick)
    if ini.settings.aclfound then return end

    sampSendChat("/adminka " .. nick) -- ACL6+ 
    lua_thread.create(function()
        wait(1000)
        if not ini.settings.aclfound then
            sampSendChat("/giveblow") -- ACL5
            wait(1000)
            if not ini.settings.aclfound then
                sampSendChat("/asetint") -- ACL4
                wait(1000)
                if not ini.settings.aclfound then
                    sampSendChat("/setarm") -- ACL3
                    wait(1000)
                    if not ini.settings.aclfound then
                       sampSendChat("/antierror") -- ACL2
                        wait(1000)
                        if not ini.settings.aclfound then
                            sampSendChat("/zpanel") -- ACL1
                            wait(1000)
                            if not ini.settings.aclfound then
                                sampSendChat('/setpref') -- FD2
                                wait(1000)
                                if not ini.settings.aclfound then
                                    sampSendChat('/ahelp') -- FD1
                                    wait(1000)
                                    if not ini.settings.aclfound then
                                        sampSendChat('/admins') -- LVLADMIN
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
    s = tostring(s):lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- ё
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function lowers(str)
    -- Используем правильную таблицу преобразования
    local result = ""
    
    for i = 1, #str do
        local char = str:sub(i, i)
        local byte = string.byte(char)
        
        -- Английские буквы A-Z
        if byte >= 65 and byte <= 90 then  -- A-Z
            result = result .. string.char(byte + 32)  -- a-z
        -- Русские буквы А-Я (кроме Ё)
        elseif byte >= 192 and byte <= 223 and byte ~= 208 then  -- А-Я (кроме Ё)
            result = result .. string.char(byte + 32)
        -- Буква Ё
        elseif byte == 168 then  -- Ё
            result = result .. string.char(184)  -- ё
        -- Все остальные символы без изменений
        else
            result = result .. char
        end
    end
    
    return result
end

function utext(text)
    text = u8:decode(text)
    return text
end

function find(s, p)
    return string.rlower(s):find(string.rlower(p))
end

function match(s, p)
	return string.rlower(s):match(string.rlower(p))
end

function ACM(text, color)
    color = color:match("%{(.+)%}")
    newcolor = "0x"..color
    text = sampAddChatMessage(text, newcolor)
    return text
end

function msgScript(prefix, text, color)
    --ACM(utext("{00FF7F}[A-TP] {ffffff}Телепорт успешно сохранен!"), "{00FF7F}")
    if text:find(utext("%{......%}")) then
        ACM(utext(string.format("%s[%s] %s", color, prefix, text)), color)
    else
        ACM(utext(string.format("%s[%s] {ffffff}%s", color, prefix, text)), color)
    end
end

function getCarSpeed( vehicleTarget, kilometersBool ) -- if "kilometersBool" is true, return km/h
    if not vehicleTarget or type( vehicleTarget ) ~= 'number' then return false end
    if not doesVehicleExist( vehicleTarget ) then return false end
    local x, y, z = getCarSpeedVector( vehicleTarget )
    if not x or not y or not z then x, y, z = 0, 0, 0 end
    local kmh = math.floor( (math.sqrt( (x*x) + (y*y) + (z*z) ) * 180) / 100 ) -- KM/H
    local mph = math.floor( (math.sqrt( (x*x) + (y*y) + (z*z) ) * 180) / 1.609344 / 100 ) -- MPH
    if kilometersBool then return true, kmh else return true, mph end
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4
    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end
    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end
    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], text[i])
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end
        end
    end
    render_text(text)
end

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(text).x/2)
end

function MinimalistVerticalMenu(items, current)
    local button_padding = 5
    local button_height = 162
    local button_width  = 240
    local active_line_width = 3

    for i, item in ipairs(items) do
        local is_selected = (current == i)

        local color_normal        = imgui.ImVec4(0.13, 0.16, 0.19, 0.0)
        local color_hovered       = imgui.ImVec4(0.40, 0.40, 0.40, 0.25)
        local color_active        = imgui.ImVec4(0.60, 0.60, 0.60, 0.55)
        local color_selected_bg   = imgui.ImVec4(0.40, 0.40, 0.40, 0.85)
        local color_text          = imgui.ImVec4(0.85, 0.85, 0.88, 0.80)
        local color_text_selected = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
        local color_accent        = imgui.ImVec4(0.70, 0.70, 0.70, 1.00)

        imgui.PushStyleColor(imgui.Col.Text, is_selected and color_text_selected or color_text)
        imgui.PushStyleColor(imgui.Col.Button, is_selected and color_selected_bg or color_normal)
        imgui.PushStyleColor(imgui.Col.ButtonHovered, color_hovered)
        imgui.PushStyleColor(imgui.Col.ButtonActive, color_active)
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 20)
        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, button_padding))

        if imgui.Button(item, imgui.ImVec2(button_width, button_height)) then
            current = i
        end

        if is_selected then
            local draw_list = imgui.GetWindowDrawList()
            local min = imgui.GetItemRectMin()
            local max = imgui.GetItemRectMax()
            draw_list:AddRectFilled(imgui.ImVec2(min.x, min.y), imgui.ImVec2(min.x + active_line_width, max.y), imgui.ColorConvertFloat4ToU32(color_normal), 20, 4)
        end

        imgui.PopStyleColor(4)
        imgui.PopStyleVar(2)
    end
    return current
end

function imgui.Hint(str_id, hint, delay)
    local hovered = imgui.IsItemHovered()
    local animTime = 0.2
    local delay = delay or 0.00
    local show = true

    if not allHints then allHints = {} end
    if not allHints[str_id] then
        allHints[str_id] = {
            status = false,
            timer = 0
        }
    end

    if hovered then
        for k, v in pairs(allHints) do
            if k ~= str_id and os.clock() - v.timer <= animTime  then
                show = false
            end
        end
    end

    if show and allHints[str_id].status ~= hovered then
        allHints[str_id].status = hovered
        allHints[str_id].timer = os.clock() + delay
    end

    if show then
        local between = os.clock() - allHints[str_id].timer
        if between <= animTime then
            local s = function(f)
                return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
            end
            local alpha = hovered and s(between / animTime) or s(1.00 - between / animTime)
            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)
            imgui.SetTooltip(hint)
            imgui.PopStyleVar()
        elseif hovered then
            imgui.SetTooltip(hint)
        end
    end
end

function MinimalistSeparator()
    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()
    local width = imgui.GetContentRegionAvail().x
    draw_list:AddLine(
        imgui.ImVec2(p.x, p.y),
        imgui.ImVec2(p.x + width, p.y),
        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.25, 0.25, 0.25, 1.00))
    )
    imgui.Dummy(imgui.ImVec2(0, 1))
end

function MinimalistSectionHeader(text)
    imgui.Spacing()
    imgui.PushFont(font_18)
    imgui.Text(text)
    imgui.PopFont()
    MinimalistSeparator()
    imgui.Spacing()
end

function MinimalistIconButton(icon, label, size)
    size = size or imgui.ImVec2(120, 35)
    local color_normal   = imgui.ImVec4(0.18, 0.18, 0.18, 1.00)
    local color_hovered  = imgui.ImVec4(0.25, 0.25, 0.25, 1.00)
    local color_active   = imgui.ImVec4(0.35, 0.35, 0.35, 1.00)
    
    imgui.PushStyleColor(imgui.Col.Button, color_normal)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, color_hovered)
    imgui.PushStyleColor(imgui.Col.ButtonActive, color_active)
    imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
    
    local result = imgui.Button(string.format("%s  %s", icon, label), size)
    
    imgui.PopStyleVar()
    imgui.PopStyleColor(3)
    
    return result
end

function loadTeleports()
    local file = io.open(teleportsFilePath, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content and content ~= "" then
            teleports = decodeJson(content) or {}
        end
    end
end

function saveTeleports()
    local lines = {}
    table.insert(lines, "[")
    
    for i, tp in ipairs(teleports) do
        local line = string.format(
            '  {"name":"%s","x":%d,"y":%d,"z":%d,"interior":%d,"virtualWorld":%d}',
            tostring(tp.name or "Unnamed"):gsub('"', ''),
            tonumber(tp.x),
            tonumber(tp.y),
            tonumber(tp.z),
            tonumber(tp.interior) or 0,
            tonumber(tp.virtualWorld) or 0
        )
        
        if i < #teleports then
            line = line .. ","
        end
        
        table.insert(lines, line)
    end
    
    table.insert(lines, "]")
    
    local file = io.open(teleportsFilePath, "w")
    if file then
        file:write(table.concat(lines, "\n"))
        file:close()
        return true
    end
    return false
end

function imgui.ReconPopup(popup_id, labels, buffers, types, button_labels, callbacks)
    if imgui.BeginPopupModal(popup_id, nil, imgui.WindowFlags.AlwaysAutoResize) then

        for i, buf in ipairs(buffers) do

            local label = labels[i]
            local buf_type = types[i]

            if buf_type == 'int' then
                imgui.Text(label)
                imgui.InputInt("##".. label, buf)
            elseif buf_type == "string" then
                imgui.Text(label)
                imgui.InputTextMultiline("##"..label, buf, sizeof(buf))
            end
        end

        for i=1, #button_labels do
            if imgui.Button(button_labels[i]) then
                if callbacks[i] then callbacks[i]() end
                imgui.CloseCurrentPopup()
            end
            if i < #button_labels then imgui.SameLine() end
        end

        imgui.EndPopup()
    end
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function emul_rpc(hook, parameters)
    local bs_io = require 'samp.events.bitstream_io'
    local handler = require 'samp.events.handlers'
    local extra_types = require 'samp.events.extra_types'
    local hooks = {

        --[[ Outgoing rpcs
        ['onSendEnterVehicle'] = { 'int16', 'bool8', 26 },
        ['onSendClickPlayer'] = { 'int16', 'int8', 23 },
        ['onSendClientJoin'] = { 'int32', 'int8', 'string8', 'int32', 'string8', 'string8', 'int32', 25 },
        ['onSendEnterEditObject'] = { 'int32', 'int16', 'int32', 'vector3d', 27 },
        ['onSendCommand'] = { 'string32', 50 },
        ['onSendSpawn'] = { 52 },
        ['onSendDeathNotification'] = { 'int8', 'int16', 53 },
        ['onSendDialogResponse'] = { 'int16', 'int8', 'int16', 'string8', 62 },
        ['onSendClickTextDraw'] = { 'int16', 83 },
        ['onSendVehicleTuningNotification'] = { 'int32', 'int32', 'int32', 'int32', 96 },
        ['onSendChat'] = { 'string8', 101 },
        ['onSendClientCheckResponse'] = { 'int8', 'int32', 'int8', 103 },
        ['onSendVehicleDamaged'] = { 'int16', 'int32', 'int32', 'int8', 'int8', 106 },
        ['onSendEditAttachedObject'] = { 'int32', 'int32', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 116 },
        ['onSendEditObject'] = { 'bool', 'int16', 'int32', 'vector3d', 'vector3d', 117 },
        ['onSendInteriorChangeNotification'] = { 'int8', 118 },
        ['onSendMapMarker'] = { 'vector3d', 119 },
        ['onSendRequestClass'] = { 'int32', 128 },
        ['onSendRequestSpawn'] = { 129 },
        ['onSendPickedUpPickup'] = { 'int32', 131 },
        ['onSendMenuSelect'] = { 'int8', 132 },
        ['onSendVehicleDestroyed'] = { 'int16', 136 },
        ['onSendQuitMenu'] = { 140 },
        ['onSendExitVehicle'] = { 'int16', 154 },
        ['onSendUpdateScoresAndPings'] = { 155 },
        ['onSendGiveDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },
        ['onSendTakeDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },]]

        -- Incoming rpcs
        ['onInitGame'] = { 139 },
        ['onPlayerJoin'] = { 'int16', 'int32', 'bool8', 'string8', 137 },
        ['onPlayerQuit'] = { 'int16', 'int8', 138 },
        ['onRequestClassResponse'] = { 'bool8', 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 128 },
        ['onRequestSpawnResponse'] = { 'bool8', 129 },
        ['onSetPlayerName'] = { 'int16', 'string8', 'bool8', 11 },
        ['onSetPlayerPos'] = { 'vector3d', 12 },
        ['onSetPlayerPosFindZ'] = { 'vector3d', 13 },
        ['onSetPlayerHealth'] = { 'float', 14 },
        ['onTogglePlayerControllable'] = { 'bool8', 15 },
        ['onPlaySound'] = { 'int32', 'vector3d', 16 },
        ['onSetWorldBounds'] = { 'float', 'float', 'float', 'float', 17 },
        ['onGivePlayerMoney'] = { 'int32', 18 },
        ['onSetPlayerFacingAngle'] = { 'float', 19 },
        --['onResetPlayerMoney'] = { 20 },
        --['onResetPlayerWeapons'] = { 21 },
        ['onGivePlayerWeapon'] = { 'int32', 'int32', 22 },
        --['onCancelEdit'] = { 28 },
        ['onSetPlayerTime'] = { 'int8', 'int8', 29 },
        ['onSetToggleClock'] = { 'bool8', 30 },
        ['onPlayerStreamIn'] = { 'int16', 'int8', 'int32', 'vector3d', 'float', 'int32', 'int8', 32 },
        ['onSetShopName'] = { 'string256', 33 },
        ['onSetPlayerSkillLevel'] = { 'int16', 'int32', 'int16', 34 },
        ['onSetPlayerDrunk'] = { 'int32', 35 },
        ['onCreate3DText'] = { 'int16', 'int32', 'vector3d', 'float', 'bool8', 'int16', 'int16', 'encodedString4096', 36 },
        --['onDisableCheckpoint'] = { 37 },
        ['onSetRaceCheckpoint'] = { 'int8', 'vector3d', 'vector3d', 'float', 38 },
        --['onDisableRaceCheckpoint'] = { 39 },
        --['onGamemodeRestart'] = { 40 },
        ['onPlayAudioStream'] = { 'string8', 'vector3d', 'float', 'bool8', 41 },
        --['onStopAudioStream'] = { 42 },
        ['onRemoveBuilding'] = { 'int32', 'vector3d', 'float', 43 },
        ['onCreateObject'] = { 44 },
        ['onSetObjectPosition'] = { 'int16', 'vector3d', 45 },
        ['onSetObjectRotation'] = { 'int16', 'vector3d', 46 },
        ['onDestroyObject'] = { 'int16', 47 },
        ['onPlayerDeathNotification'] = { 'int16', 'int16', 'int8', 55 },
        ['onSetMapIcon'] = { 'int8', 'vector3d', 'int8', 'int32', 'int8', 56 },
        ['onRemoveVehicleComponent'] = { 'int16', 'int16', 57 },
        ['onRemove3DTextLabel'] = { 'int16', 58 },
        ['onPlayerChatBubble'] = { 'int16', 'int32', 'float', 'int32', 'string8', 59 },
        ['onUpdateGlobalTimer'] = { 'int32', 60 },
        ['onShowDialog'] = { 'int16', 'int8', 'string8', 'string8', 'string8', 'encodedString4096', 61 },
        ['onDestroyPickup'] = { 'int32', 63 },
        ['onLinkVehicleToInterior'] = { 'int16', 'int8', 65 },
        ['onSetPlayerArmour'] = { 'float', 66 },
        ['onSetPlayerArmedWeapon'] = { 'int32', 67 },
        ['onSetSpawnInfo'] = { 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 68 },
        ['onSetPlayerTeam'] = { 'int16', 'int8', 69 },
        ['onPutPlayerInVehicle'] = { 'int16', 'int8', 70 },
        --['onRemovePlayerFromVehicle'] = { 71 },
        ['onSetPlayerColor'] = { 'int16', 'int32', 72 },
        ['onDisplayGameText'] = { 'int32', 'int32', 'string32', 73 },
        --['onForceClassSelection'] = { 74 },
        ['onAttachObjectToPlayer'] = { 'int16', 'int16', 'vector3d', 'vector3d', 75 },
        ['onInitMenu'] = { 76 },
        ['onShowMenu'] = { 'int8', 77 },
        ['onHideMenu'] = { 'int8', 78 },
        ['onCreateExplosion'] = { 'vector3d', 'int32', 'float', 79 },
        ['onShowPlayerNameTag'] = { 'int16', 'bool8', 80 },
        ['onAttachCameraToObject'] = { 'int16', 81 },
        ['onInterpolateCamera'] = { 'bool', 'vector3d', 'vector3d', 'int32', 'int8', 82 },
        ['onGangZoneStopFlash'] = { 'int16', 85 },
        ['onApplyPlayerAnimation'] = { 'int16', 'string8', 'string8', 'bool', 'bool', 'bool', 'bool', 'int32', 86 },
        ['onClearPlayerAnimation'] = { 'int16', 87 },
        ['onSetPlayerSpecialAction'] = { 'int8', 88 },
        ['onSetPlayerFightingStyle'] = { 'int16', 'int8', 89 },
        ['onSetPlayerVelocity'] = { 'vector3d', 90 },
        ['onSetVehicleVelocity'] = { 'bool8', 'vector3d', 91 },
        ['onServerMessage'] = { 'int32', 'string32', 93 },
        ['onSetWorldTime'] = { 'int8', 94 },
        ['onCreatePickup'] = { 'int32', 'int32', 'int32', 'vector3d', 95 },
        ['onMoveObject'] = { 'int16', 'vector3d', 'vector3d', 'float', 'vector3d', 99 },
        ['onEnableStuntBonus'] = { 'bool', 104 },
        ['onTextDrawSetString'] = { 'int16', 'string16', 105 },
        ['onSetCheckpoint'] = { 'vector3d', 'float', 107 },
        ['onCreateGangZone'] = { 'int16', 'vector2d', 'vector2d', 'int32', 108 },
        ['onPlayCrimeReport'] = { 'int16', 'int32', 'int32', 'int32', 'int32', 'vector3d', 112 },
        ['onGangZoneDestroy'] = { 'int16', 120 },
        ['onGangZoneFlash'] = { 'int16', 'int32', 121 },
        ['onStopObject'] = { 'int16', 122 },
        ['onSetVehicleNumberPlate'] = { 'int16', 'string8', 123 },
        ['onTogglePlayerSpectating'] = { 'bool32', 124 },
        ['onSpectatePlayer'] = { 'int16', 'int8', 126 },
        ['onSpectateVehicle'] = { 'int16', 'int8', 127 },
        ['onShowTextDraw'] = { 134 },
        ['onSetPlayerWantedLevel'] = { 'int8', 133 },
        ['onTextDrawHide'] = { 'int16', 135 },
        ['onRemoveMapIcon'] = { 'int8', 144 },
        ['onSetWeaponAmmo'] = { 'int8', 'int16', 145 },
        ['onSetGravity'] = { 'float', 146 },
        ['onSetVehicleHealth'] = { 'int16', 'float', 147 },
        ['onAttachTrailerToVehicle'] = { 'int16', 'int16', 148 },
        ['onDetachTrailerFromVehicle'] = { 'int16', 149 },
        ['onSetWeather'] = { 'int8', 152 },
        ['onSetPlayerSkin'] = { 'int32', 'int32', 153 },
        ['onSetInterior'] = { 'int8', 156 },
        ['onSetCameraPosition'] = { 'vector3d', 157 },
        ['onSetCameraLookAt'] = { 'vector3d', 'int8', 158 },
        ['onSetVehiclePosition'] = { 'int16', 'vector3d', 159 },
        ['onSetVehicleAngle'] = { 'int16', 'float', 160 },
        ['onSetVehicleParams'] = { 'int16', 'int16', 'bool8', 161 },
        --['onSetCameraBehind'] = { 162 },
        ['onChatMessage'] = { 'int16', 'string8', 101 },
        ['onConnectionRejected'] = { 'int8', 130 },
        ['onPlayerStreamOut'] = { 'int16', 163 },
        ['onVehicleStreamIn'] = { 164 },
        ['onVehicleStreamOut'] = { 'int16', 165 },
        ['onPlayerDeath'] = { 'int16', 166 },
        ['onPlayerEnterVehicle'] = { 'int16', 'int16', 'bool8', 26 },
        ['onUpdateScoresAndPings'] = { 'PlayerScorePingMap', 155 },
        ['onSetObjectMaterial'] = { 84 },
        ['onSetObjectMaterialText'] = { 84 },
        ['onSetVehicleParamsEx'] = { 'int16', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 24 },
        ['onSetPlayerAttachedObject'] = { 'int16', 'int32', 'bool', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 113 }

    }
    local handler_hook = {
        ['onInitGame'] = true,
        ['onCreateObject'] = true,
        ['onInitMenu'] = true,
        ['onShowTextDraw'] = true,
        ['onVehicleStreamIn'] = true,
        ['onSetObjectMaterial'] = true,
        ['onSetObjectMaterialText'] = true
    }
    local extra = {
        ['PlayerScorePingMap'] = true,
        ['Int32Array3'] = true
    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
        if not handler_hook[hook] then
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
                    if extra[p] then extra_types[p]['write'](bs, parameters[i])
                    else bs_io[p]['write'](bs, parameters[i]) end
                end
            end
        else
            if hook == 'onInitGame' then handler.on_init_game_writer(bs, parameters)
            elseif hook == 'onCreateObject' then handler.on_create_object_writer(bs, parameters)
            elseif hook == 'onInitMenu' then handler.on_init_menu_writer(bs, parameters)
            elseif hook == 'onShowTextDraw' then handler.on_show_textdraw_writer(bs, parameters)
            elseif hook == 'onVehicleStreamIn' then handler.on_vehicle_stream_in_writer(bs, parameters)
            elseif hook == 'onSetObjectMaterial' then handler.on_set_object_material_writer(bs, parameters, 1)
            elseif hook == 'onSetObjectMaterialText' then handler.on_set_object_material_writer(bs, parameters, 2) end
        end
        raknetEmulRpcReceiveBitStream(hook_table[#hook_table], bs)
        raknetDeleteBitStream(bs)
    end
end

function setCharAlpha(ped, alpha)
    SetRwObjectAlpha = ffi.cast("int(__thiscall *)(int pentity, int alpha)",0x5332C0)
    local pplayer = getCharPointer(ped)
    if pplayer == nil then return end
    SetRwObjectAlpha(pplayer,alpha)
end

function sampev.onSendPlayerSync(data)
	if spec then
		local sync = samp_create_sync_data('spectator')
		sync.position = data.position
        sync.keysData = data.keysData
		sync.send()
		return false
	end

    if active then
        for i = 0, 2 do
            data.quaternion[i] = 0
        end
        data.upDownKeys = 65408
        data.keysData = 8
        data.animationId = 1538
        data.animationFlags = 32770

        local heading = getCharHeading(PLAYER_PED)

        data.moveSpeed.x = 0
        data.moveSpeed.y = 0
    end
end

function sampev.onRemoveBuilding(modelId, position, radius)
    return false
end

function onSendPacket(id, bitStream, priority, reliability, orderingChannel)
	if nopPlayerSync and id == 207 then return false end
	if nopPlayerSync and id == 204 then return false end
end

function initializeRender()
    font = renderCreateFont("Tahoma", 10, FCR_BOLD + FCR_BORDER)
    font2 = renderCreateFont("Arial", 8, FCR_ITALICS + FCR_BORDER)
end

function rotateCarAroundUpAxis(car, vec)
    local mat = Matrix3X3(getVehicleRotationMatrix(car))
    local rotAxis = Vector3D(mat.up:get())
    vec:normalize()
    rotAxis:normalize()
    local theta = math.acos(rotAxis:dotProduct(vec))
    if theta ~= 0 then
        rotAxis:crossProduct(vec)
        rotAxis:normalize()
        rotAxis:zeroNearZero()
        mat = mat:rotate(rotAxis, -theta)
    end
    setVehicleRotationMatrix(car, mat:get())
end

function readFloatArray(ptr, idx)
    return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
end

function writeFloatArray(ptr, idx, value)
    writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
end

function getVehicleRotationMatrix(car)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
        local mat = readMemory(entityPtr + 0x14, 4, false)
        if mat ~= 0 then
            local rx, ry, rz, fx, fy, fz, ux, uy, uz
            rx = readFloatArray(mat, 0)
            ry = readFloatArray(mat, 1)
            rz = readFloatArray(mat, 2)

            fx = readFloatArray(mat, 4)
            fy = readFloatArray(mat, 5)
            fz = readFloatArray(mat, 6)

            ux = readFloatArray(mat, 8)
            uy = readFloatArray(mat, 9)
            uz = readFloatArray(mat, 10)
            return rx, ry, rz, fx, fy, fz, ux, uy, uz
        end
    end
end

function setVehicleRotationMatrix(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
        local mat = readMemory(entityPtr + 0x14, 4, false)
        if mat ~= 0 then
            writeFloatArray(mat, 0, rx)
            writeFloatArray(mat, 1, ry)
            writeFloatArray(mat, 2, rz)

            writeFloatArray(mat, 4, fx)
            writeFloatArray(mat, 5, fy)
            writeFloatArray(mat, 6, fz)

            writeFloatArray(mat, 8, ux)
            writeFloatArray(mat, 9, uy)
            writeFloatArray(mat, 10, uz)
        end
    end
end

function displayVehicleName(x, y, gxt)
    x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
    useRenderCommands(true)
    setTextWrapx(640.0)
    setTextProportional(true)
    setTextJustify(false)
    setTextScale(0.23, 0.8)
    setTextDropshadow(0, 0, 0, 0, 0)
    setTextColour(255, 0, 0, 230)
    setTextEdge(1, 0, 0, 0, 100)
    setTextFont(1)
    displayText(x, y, gxt)
end

function createPointMarker(x, y, z)
    pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
end

function removePointMarker()
    if pointMarker then
        removeUser3dMarker(pointMarker)
        pointMarker = nil
    end
end

function getCarFreeSeat(car)
    if doesCharExist(getDriverOfCar(car)) then
        local maxPassengers = getMaximumNumberOfPassengers(car)
        for i = 0, maxPassengers do
            if isCarPassengerSeatFree(car, i) then
                return i + 1
            end
        end
        return nil
    else
        return 0
    end
end

function jumpIntoCar(car)
    local seat = getCarFreeSeat(car)
    if not seat then return false end
    if seat == 0 then warpCharIntoCar(playerPed, car)
    else warpCharIntoCarAsPassenger(playerPed, car, seat - 1)
    end
    restoreCameraJumpcut()
    return true
end

function teleportPlayer(x, y, z)
    if isCharInAnyCar(playerPed) then
        setCharCoordinates(playerPed, x, y, z)
    end
    setCharCoordinatesDontResetAnim(playerPed, x, y, z)
end

function setCharCoordinatesDontResetAnim(char, x, y, z)
    if doesCharExist(char) then
        local ptr = getCharPointer(char)
        setEntityCoordinates(ptr, x, y, z)
    end
end

function setEntityCoordinates(entityPtr, x, y, z)
    if entityPtr ~= 0 then
        local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
        if matrixPtr ~= 0 then
            local posPtr = matrixPtr + 0x30
            writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
            writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
            writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
        end
    end
end

function showCursorClickWarp(toggle)
    if toggle then
      sampSetCursorMode(3)
      cursorEnabled = true
    else
      sampToggleCursor(false)
      sampSetCursorMode(0)
      cursorEnabled = false
    end
end

function haversine(lat1, lon1, lat2, lon2)
    local R = 6371
    local dLat = math.rad(lat2 - lat1)
    local dLon = math.rad(lon2 - lon1)

    local a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) *
              math.sin(dLon / 2) * math.sin(dLon / 2)
    
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c
end

function asyncHttpRequest(method, url, args, resolve, reject)
    local request_thread = effil.thread(function(method, url, args)
        local requests = require"requests"
        local result, response = pcall(requests.request, method, url, args)
        if result then
            response.json, response.xml = nil, nil
            return true, response
        else
            return false, response
        end
    end)(method, url, args)

    if not resolve then
        resolve = function() end
    end
    if not reject then
        reject = function() end
    end
    lua_thread.create(function()
        local runner = request_thread
        while true do
            local status, err = runner:status()
            if not err then
                if status == "completed" then
                    local result, response = runner:get()
                    if result then
                        resolve(response)
                    else
                        reject(response)
                    end
                    return
                elseif status == "canceled" then
                    return reject(status)
                end
            else
                return reject(err)
            end
            wait(0)
        end
    end)
end

function getGorod(ip, resolve, reject)
    resolve = resolve or function() end
    reject = reject or function() end

    if not ip or ip == "" or ip == "N/A" then
        local err_res = { city = "N/A", country = "N/A", region = "N/A", isp = "N/A", latitude = "N/A", longitude = "N/A" }
        reject(err_res, "Ошибка: Неправильный Айпи адрес")
        return
    end

    if ipData[ip] then
        resolve(ipData[ip])
        return
    end

    local url = string.format("https://ipwho.is/%s?lang=ru", ip)

    asyncHttpRequest("GET", url, {}, function(response)
        if response.status_code ~= 200 then
            local err_res = { city = "Ошибка", country = "Ошибка", region = "Ошибка", isp = "Ошибка", latitude = "Ошибка", longitude = "Ошибка" }
            reject(err_res, "Ошибка: Не удалось получить данные. Код ответа: " .. tostring(response.status_code))
            return
        end

        local data = response.text or response.body or ""
        local success, parsedData = pcall(json.decode, data)
        
        if not success or not parsedData then
            local err_res = { city = "Ошибка", country = "Ошибка", region = "Ошибка", isp = "Ошибка", latitude = "Ошибка", longitude = "Ошибка" }
            reject(err_res, "Ошибка: Не удалось разобрать JSON. Данные ответа: " .. tostring(data))
            return
        end

        local result = {
            region = parsedData.region or "Неизвестный регион",
            country = parsedData.country or "Неизвестная страна",
            city = parsedData.city or "Неизвестный город",
            isp = parsedData.connection and parsedData.connection.isp or "Неизвестная организация",
            latitude = parsedData.latitude or "Неизвестная широта",
            longitude = parsedData.longitude or "Неизвестная долгота"
        }

        ipData[ip] = result
        resolve(result)
    end, function(err)
        local err_res = { city = "Ошибка", country = "Ошибка", region = "Ошибка", isp = "Ошибка", latitude = "Ошибка", longitude = "Ошибка" }
        reject(err_res, "Внутренняя ошибка запроса: " .. tostring(err))
    end)
end

function getVPN(ip, resolve, reject)
    resolve = resolve or function() end
    reject = reject or function() end

    if not ip or ip == "" or ip == "N/A" then
        local err_res = { proxy = "N/A", type = "N/A", risk = "N/A" }
        reject(err_res, "Ошибка: Неправильный Айпи адрес")
        return
    end

    if vpnData[ip] then
        resolve(vpnData[ip])
        return
    end

    local url = string.format("https://proxycheck.io/v2/%s?key=422p28-2r1189-49240e-900390&vpn=1&risk=1", ip)

    asyncHttpRequest("GET", url, {}, function(response)
        if response.status_code ~= 200 then
            local err_res = { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" }
            reject(err_res, "Ошибка: Не удалось получить данные. Код ответа: " .. tostring(response.status_code))
            return
        end

        local data = response.text or response.body or ""
        local success, parsedData = pcall(json.decode, data)
        
        if not success or not parsedData then
            local err_res = { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" }
            reject(err_res, "Ошибка: Не удалось разобрать JSON. Проверьте данные ответа: " .. tostring(data))
            return
        end

        local currentIpData = parsedData[ip]
        if not currentIpData then
            local err_res = { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" }
            reject(err_res, "Ошибка: В ответе отсутствуют данные для указанного IP.")
            return
        end

        local result = {
            proxy = currentIpData.proxy or "Неизвестный vpn",
            type = currentIpData.type or "Неизвестный тип",
            provider = currentIpData.provider or "Неизвестный провайдер",
            risk = currentIpData.risk or "Неизвестный риск",
        }

        vpnData[ip] = result
        resolve(result)
    end, function(err)
        local err_res = { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" }
        reject(err_res, "Внутренняя ошибка запроса: " .. tostring(err))
    end)
end

function viktorina()
    lua_thread.create(function ()
        if ini.settings.commandpriz == "trep" or ini.settings.commandpriz == 'giverep' then
            sampSendChat(string.format(utext('/a [%s] Начинается викторина! Угадайте число от %s до %s!'), utext(ini.settings.tagint), ini.settings.intot, ini.settings.intdo))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответы писать только в /a! Приз: %s реп'), utext(ini.settings.tagint), ini.settings.prizint))
            vikstr = 1
        elseif ini.settings.commandpriz == "additem" then
            sampSendChat(string.format(utext('/a [%s] Начинается викторина! Угадайте число от %s до %s!'), utext(ini.settings.tagint), ini.settings.intot, ini.settings.intdo))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответы писать только в /a! Приз: Предмет ID %s'), utext(ini.settings.tagint), ini.settings.prizint))
            vikstr = 1
        else
            sampSendChat(string.format(utext('/a [%s] Начинается викторина! Угадайте число от %s до %s!'), utext(ini.settings.tagint), ini.settings.intot, ini.settings.intdo))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответы писать только в /a! Приз: Неизвестно'), utext(ini.settings.tagint)))
            vikstr = 1
        end
    end)
end

function vopros()
    lua_thread.create(function ()
        if ini.settings.commandvopros == "trep" or ini.settings.commandvopros == 'giverep' then
            sampSendChat(string.format(utext('/a [%s] %s?'), utext(ini.settings.tagvopros), utext(ini.settings.voprosvopros)))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответ писать только в /a! Приз: %s реп'),utext( ini.settings.tagvopros), ini.settings.prizvopros))
            voprosstr = 1
        elseif ini.settings.commandvopros == "additem" then
            sampSendChat(string.format(utext('/a [%s] %s?'), utext(ini.settings.tagvopros), utext(ini.settings.voprosvopros)))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответ писать только в /a! Приз: Предмет ID %s'), utext(ini.settings.tagvopros), ini.settings.prizvopros))
            voprosstr = 1
        else
            sampSendChat(string.format(utext('/a [%s] %s?'), utext(ini.settings.tagvopros), utext(ini.settings.voprosvopros)))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответ писать только в /a! Приз: Неизвестно'), utext(ini.settings.tagvopros)))
            voprosstr = 1
        end
    end)
end

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local path = getFolderPath(0x14) .. '\\comicbd.ttf'
    imgui.GetIO().Fonts:Clear()
    imgui.GetIO().Fonts:AddFontFromFileTTF(path, 18.0, nil, glyph_ranges)
    font_16 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 16.0, nil, glyph_ranges)
    font_17 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 16.0, nil, glyph_ranges)
    font_18 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 18.0, nil, glyph_ranges)
    font_21 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 21.0, nil, glyph_ranges)
    font_22 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 22.0, nil, glyph_ranges)
    font_23 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 23.0, nil, glyph_ranges)
    font_24 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 24.0, nil, glyph_ranges)
    font_25 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 25.0, nil, glyph_ranges)
    font_40 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 40.0, nil, glyph_ranges)
    error_img = imgui.CreateTextureFromFileInMemory(imgui.new("const char*", error_data), #error_data)
    info_img = imgui.CreateTextureFromFileInMemory(imgui.new("const char*", info_data), #info_data)
    success_img = imgui.CreateTextureFromFileInMemory(imgui.new("const char*", success_data), #success_data)
    warn_img = imgui.CreateTextureFromFileInMemory(imgui.new("const char*", warn_data), #warn_data)
    SoftBlueTheme()
    theme[1].change()
    sW, sH = getScreenResolution()
    u32 = imgui.ColorConvertFloat4ToU32
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true

end)

imgui.OnFrame(
    function() return true end,
    function(self)
        local has_active_modals = false
        for _, modal in ipairs(modal_notifications) do
            if modal.visible[0] then
                has_active_modals = true
                break
            end
        end
        
        self.HideCursor = not has_active_modals
        
        if not isSampAvailable() then return end
        if not sampIsLocalPlayerSpawned() then return end
        
        RenderNotifications()
        RenderModalNotifications()
    end
)

local newadmintools = imgui.OnFrame(
    function() return renderAdminTools[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX * 0.65, sizeY * 0.65), imgui.Cond.FirstUseEver)
        imgui.Begin("##Admin", renderAdminTools, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild("LeftPanel", imgui.ImVec2(270, 0), true)
        tab = MinimalistVerticalMenu(tabs, tab)
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("RightPanel", imgui.ImVec2(0, 0), true)
        if tab == 1 then
            MinimalistSectionHeader("Админ-Панель")
            imgui.PushFont(font_17)

            imgui.Text(string.format(
                "Ваш уровень админки: %s | ACL: %s | FD1: %s | FD2: %s",
                ini.settings.lvladmin, ini.settings.acladmin, ini.settings.fdadmin, ini.settings.fd2admin
            ))
            imgui.Spacing()
            if imgui.Button(">> Проверить <<") then
                local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
                local nick = sampGetPlayerNickname(id)
                checkadminka(nick)
            end
            imgui.Spacing()
            local acl = tonumber(ini.settings.acladmin) or 0
            if acl >= 1 then
                MinimalistSectionHeader("Команды ACL")

                if imgui.TreeNodeStr("Команды ACL") then

                    local function renderACL(level, title, text)
                        if acl >= level and imgui.TreeNodeStr(title) then
                            imgui.BeginChild(title .. "Child", imgui.ImVec2(500, 250), true)
                            for line in text:gmatch("[^\n]+") do
                                imgui.TextColoredRGB(line)
                            end
                            imgui.EndChild()
                            imgui.TreePop()
                        end
                    end

                    if acl == 1 then
                        renderACL(1, "ACL1", ACL1Text)
                    elseif acl == 2 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                    elseif acl == 3 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                    elseif acl == 4 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                    elseif acl == 5 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                    elseif acl == 6 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                    elseif acl == 7 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                        renderACL(7, "ACL7", ACL7Text)
                    elseif acl == 8 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                        renderACL(7, "ACL7", ACL7Text)
                        renderACL(8, "ACL8", ACL8Text)
                    elseif acl == 9 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                        renderACL(7, "ACL7", ACL7Text)
                        renderACL(8, "ACL8", ACL8Text)
                        renderACL(9, "ACL9", ACL9Text)
                    elseif acl == 10 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                        renderACL(7, "ACL7", ACL7Text)
                        renderACL(8, "ACL8", ACL8Text)
                        renderACL(9, "ACL9", ACL9Text)
                        renderACL(10, "ACL10", ACL10Text)
                    end
                    imgui.TreePop()
                end
            end
            imgui.EndChild()
            imgui.PopFont()
        end
        if tab == 2 then
            MinimalistSectionHeader("Настройки")
            imgui.BeginChild("SettingsTab", imgui.ImVec2(0, 0), true)
            if imgui.Checkbox('Включить Auto-AntiError', autoantierror) then
                ini.settings.autoaterror = autoantierror[0]
                inicfg.save(ini, IniFilename)
            end
            imgui.Hint("hintAError", "Автоматически снимает ошибку безопасности.")
            if imgui.Checkbox('Включить Auto-Unmute', autounmute) then
                ini.settings.autounmute = autounmute[0]
                inicfg.save(ini, IniFilename)
            end
            imgui.Hint("hintUnmute", "Автоматически снимает Ваш мут.")
            if imgui.Checkbox("Clickwarp", clickwarp) then
                ini.settings.clickwarp = clickwarp[0]
                inicfg.save(ini, IniFilename)
            end
            imgui.Hint("hintClickWarp", "Стандартный кликварп на колёсико.")
            if imgui.Checkbox("FarChat", farchat) then
                ini.settings.farchat = farchat[0]
                bubbleBox:toggle(ini.settings.farchat)
                inicfg.save(ini, IniFilename)
            end
            imgui.Hint("hintFarChat", "Позволяет видеть текст каждого в зоне стрима.")
            if imgui.Checkbox("FlyHack", flyhack) then
                ini.settings.flyhack = flyhack[0]
                inicfg.save(ini, IniFilename)
            end
            imgui.Hint("hintFlyHack", "Позволяет летать как в собейте(ну почти). Активация на клавишу 'Ю'")
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            local nick = sampGetPlayerNickname(id)
            if nick == "Denis_Angelov" or nick == "Harry_Pattersone" or nick == "Navalny_Vandal" or nick == "navalny_vandal" then
                if imgui.Checkbox("Invisible Admin-Chat", invadm) then
                    ini.settings.invadm = invadm[0]
                    inicfg.save(ini, IniFilename)
                    sampSendChat('/adminmenu')
                    dialoginv = true
                end
                imgui.Hint("hintInvAC", "Скрывает Ваш ник и ID в /a")
                if invadm[0] then
                    if imgui.Combo('Color Adm Chat', comboColor, ImColors, #item_color) then
                        ini.settings.coloradm = comboColor[0]
                        inicfg.save(ini, IniFilename)
                        sampSendChat('/adminmenu')
                        dialogcolor = true
                    end
                    if imgui.Combo('Name Adm Chat', comboName, ImNames, #item_name) then
                    ini.settings.nameadm = comboName[0]
                    inicfg.save(ini, IniFilename)
                    sampSendChat('/adminmenu')
                    dialogname = true
                    end
                end
            end
            if imgui.Checkbox("Auto-NoSave", autonosave) then
                ini.settings.autonosave = autonosave[0]
                inicfg.save(ini, IniFilename)
            end
            imgui.Hint("hintNoSave", "Автоматически прописывает /nosave и выходит из игры если Вас посадили.")
            imgui.SameLine()
            imgui.TextColoredRGB("{ff0000}Можно получить AWARN!")
            imgui.Spacing()
            MinimalistSeparator()
            imgui.Spacing()
            if imgui.Button("Настроить викторину") then
                viktorinaAdminTools[0] = not viktorinaAdminTools[0]
                renderAdminTools[0] = not renderAdminTools[0]
            end
            if imgui.Button("Настроить вопрос") then
                voprosAdminTools[0] = not voprosAdminTools[0]
                renderAdminTools[0] = not renderAdminTools[0]
            end
            imgui.EndChild()
        end
        if tab == 3 then
            MinimalistSectionHeader("Правила сервера")
            imgui.PushFont(font_17)
            imgui.BeginChild('RulesFatality', imgui.ImVec2(0, 0), true, imgui.WindowFlags.HorizontalScrollbar)
            for line in rulesText:gmatch("[^\n]+") do
                imgui.Text(line)
            end
            imgui.EndChild()
            imgui.PopFont()
        end
        if tab == 4 then
            MinimalistSectionHeader("Таблица наказаний")
            imgui.PushFont(font_17)
            imgui.BeginChild('NakFatality', imgui.ImVec2(0, 0), true, imgui.WindowFlags.HorizontalScrollbar)
            for line in nakText:gmatch("[^\n]+") do
                imgui.Text(line)
            end
            imgui.EndChild()
            imgui.PopFont()
        end
        if tab == 5 then
            MinimalistSectionHeader("Информация о скрипте")
            imgui.PushFont(font_18)
            imgui.BeginChild('InfoScript', imgui.ImVec2(0,0), true)
            if ip == ipFatality then
                imgui.TextColoredRGB((
                [[ 
                                                                                                                {808080}[Скрипт]

                    {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    {ffffff}Название скрипта: {00ADB5}AdminTools for Fatality NRP
                    {ffffff}Автор скрипта: {ff0000}Harry_Pattersone
                    {ffffff}Версия скрипта: {00ADB5}0.6
                    {ffffff}Описание скрипта: {00ADB5}Данный скрипт упрощает администрирование на Fatality NRP, 
                                                    {00ADB5}а также добавляет новые функции и интерфейсы.
                    {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                                                            {808080}[Функционал]
                    {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    {ffffff}Открыть данное меню: {ff0000}/at
                    {ffffff}Список коротких команд: 
                            {ffff00}/osk {808080}[id/nick] {ffffff}| быстрый mute(offmute) за osk в обычном чате;
                            {ffff00}/aosk {808080}[id] {ffffff}| быстрый mute за osk в A-чате;
                            {ffff00}/sosk {808080}[id/nick] [номер] {ffffff}| быстрый mute(offmute) за Оск. Сервера;
                            {ffff00}/cheat {808080}[id/nick] [номер] {ffffff}| наказания за читы(Чит на работе, Вред.читы(бан, banip), Чит на DM(dkick, jail));
                            {ffff00}/offcheat {808080}[nick] [номер] {ffffff}| наказания за читы в оффлайн(Чит на работе, Вред.читы, Читы на DM);
                            {ffff00}/ur {808080}[id/nick] [номер] {ffffff}| быстрый mute(offmute) за У.Р в обычном чате;
                            {ffff00}/aur {808080}[id] [номер] {ffffff}| быстрый мут за У.Р в A-чате;
                            {ffff00}/giveitem {808080}[id] [название предмета] [кол-во] {ffffff}| быстрая выдача предмета по его названию;
                            {ffff00}/ditem {808080}[id] [название предмета] [кол-во] {ffffff}| быстрое удаление предмета по его названию;
                            {ffff00}/clearhouse {ffffff}| система авто-продажи дома(бета); {ff0000}[Может крашнуть]
                            {ffff00}/dunjail {ffffff}| быстрый выход из jail через Донат; {ff0000}[Может не сработать с 1 раза]
                            {ffff00}/inv {ffffff}| Инвиз(не видно даже на карте); {ff0000}[Умеет кое-что ещё, но тссс...]
                            {ffff00}/flip {ffffff}| Та команда которую Ревков не может сделать.
                    {ffffff}Список измененных команд:
                            {ffff00}/hp {808080}[без аргумента/id] {ffffff}| теперь команда без аргумента вылечит вас;
                            {ffff00}/hpall {ffffff}| теперь команда вылечит всех в зоне стрима, включая Вас;
                            {ffff00}/gun {808080}[id] {ffffff}| выдаст Deagle, M4, Shotgun игроку;
                            {ffff00}/gun {808080}[id] [idgun | название] {ffffff}| выдаст оружие с 1 патроном;
                            {ffff00}/gun {808080}[id] [idgun | название] [ammo] {ffffff}| выдаст оружие с указанным кол-вом патронов;
                            {ffff00}/slap {808080}[id/up/down] {ffffff}| {808080}[id игрока] {ffffff} слапнет игрока обычно, {808080}[up] {ffffff}слапнет Вас обычно, {808080}[down] {ffffff}слапнет Вас вниз.
                    {ffffff}Список горячих клавиш:
                            {ffff00}ПКМ+Shift {ffffff}| откроет круговое меню;
                            {ffff00}Колёсико мыши {ffffff}| clickwarp;
                            {ffff00}B+MINUS {ffffff}| прокрутить дальний чат вниз;
                            {ffff00}B+PLUS {ffffff}| прокрутить дальний чат вверх;
                            {ffff00}Ю | > | . {ffffff}| флай из собейта, {ffff00}Колёсико мыши {ffffff}| регулировка скорости; {ff0000}[ГМ у этого флая кривой, переделывать лень]
                            {ffff00}M {ffffff}| выход из рекона;
                            {ffff00}SPACE в /re {ffffff}| Обновить recon;
                            {ffff00}U при репорте {ffffff}| Ответить на репорт. (Не доделано)
                    {ffffff}Список измененных(новых) интерфейсов:
                            {ffff00}/stats {808080}[без аргумента/id] {ffffff}| теперь команда без аргумента откроет вашу статистику. А также обновленный дизайн;
                            {ffff00}/offstats {ffffff}| новый дизайн;
                            {ffff00}/rinfo {ffffff}| новый дизайн + вычисление дистанции + API;
                            {ffff00}KeySpoofer {ffffff}| отслеживание нажатия клавиш в /re;
                            {ffff00}Окно быстрых действий в /re{ffffff};
                            {ffff00}Статистика на работе Автобусника{ffffff}.
                    {ffffff}Список новых команд:
                            {ffff00}/karusel {808080}[id] {ffffff}| отправит игрока в /jail и в /ajail;
                            {ffff00}/vopros {808080}[правильный ответ на вопрос] {ffffff}| создать вопрос. Настройки вопроса: {ffff00}/at > Настройки > Настроить вопрос{ffffff};
                            {ffff00}/viktorina {808080}[угадываемое число] {ffffff}| создать викторину. Настройки викторины: {ffff00}/at > Настройки > Настроить викторину{ffffff};
                            {ffff00}/mypos {ffffff}| покажет вашу позицию(XYZ);
                            {ffff00}/addtp {ffffff}| добавить свой телепорт;
                            {ffff00}/newtp {ffffff}| список новых телепортов;
                            {ffff00}/inta {ffffff}| команда в основном была для дебага, но полезна для addtp;
                            {ffff00}/game {ffffff}| кликер нефти (Не доделан).
                    {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                ]]))
            elseif ip == ipBing then
                imgui.TextColoredRGB((
                [[ 
                                                                                                                {808080}[Скрипт]

                    {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    {ffffff}Название скрипта: {00ADB5}AdminTools for Bing NRP
                    {ffffff}Автор скрипта: {ff0000}Harry_Pattersone
                    {ffffff}Версия скрипта: {00ADB5}0.6
                    {ffffff}Описание скрипта: {00ADB5}Данный скрипт упрощает администрирование на Bing NRP, 
                                                    {00ADB5}а также добавляет новые функции и интерфейсы.
                    {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                                                            {808080}[Функционал]
                    {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    {ffffff}Открыть данное меню: {ff0000}/at
                    {ffffff}Список коротких команд: 
                            {ffff00}/osk {808080}[id/nick] {ffffff}| быстрый mute(offmute) за osk в обычном чате;
                            {ffff00}/aosk {808080}[id] {ffffff}| быстрый mute за osk в A-чате;
                            {ffff00}/sosk {808080}[id/nick] [номер] {ffffff}| быстрый mute(offmute) за Оск. Сервера;
                            {ffff00}/cheat {808080}[id/nick] [номер] {ffffff}| наказания за читы(Чит на работе, Вред.читы(бан, banip), Чит на DM(dkick, jail));
                            {ffff00}/offcheat {808080}[nick] [номер] {ffffff}| наказания за читы в оффлайн(Чит на работе, Вред.читы, Читы на DM);
                            {ffff00}/ur {808080}[id/nick] [номер] {ffffff}| быстрый mute(offmute) за У.Р в обычном чате;
                            {ffff00}/aur {808080}[id] [номер] {ffffff}| быстрый мут за У.Р в A-чате;
                            {ffff00}/giveitem {808080}[id] [название предмета] [кол-во] {ffffff}| быстрая выдача предмета по его названию;
                            {ffff00}/ditem {808080}[id] [название предмета] [кол-во] {ffffff}| быстрое удаление предмета по его названию;
                            {ffff00}/clearhouse {ffffff}| система авто-продажи дома(бета); {ff0000}[Может крашнуть]
                            {ffff00}/dunjail {ffffff}| быстрый выход из jail через Донат; {ff0000}[Может не сработать с 1 раза]
                            {ffff00}/inv {ffffff}| Инвиз(не видно даже на карте); {ff0000}[Умеет кое-что ещё, но тссс...]
                            {ffff00}/flip {ffffff}| Та команда которую Ревков не может сделать.
                    {ffffff}Список измененных команд:
                            {ffff00}/hp {808080}[без аргумента/id] {ffffff}| теперь команда без аргумента вылечит вас;
                            {ffff00}/hpall {ffffff}| теперь команда вылечит всех в зоне стрима, включая Вас;
                            {ffff00}/gun {808080}[id] {ffffff}| выдаст Deagle, M4, Shotgun игроку;
                            {ffff00}/gun {808080}[id] [idgun | название] {ffffff}| выдаст оружие с 1 патроном;
                            {ffff00}/gun {808080}[id] [idgun | название] [ammo] {ffffff}| выдаст оружие с указанным кол-вом патронов;
                            {ffff00}/slap {808080}[id/up/down] {ffffff}| {808080}[id игрока] {ffffff} слапнет игрока обычно, {808080}[up] {ffffff}слапнет Вас обычно, {808080}[down] {ffffff}слапнет Вас вниз.
                    {ffffff}Список горячих клавиш:
                            {ffff00}ПКМ+Shift {ffffff}| откроет круговое меню;
                            {ffff00}Колёсико мыши {ffffff}| clickwarp;
                            {ffff00}B+MINUS {ffffff}| прокрутить дальний чат вниз;
                            {ffff00}B+PLUS {ffffff}| прокрутить дальний чат вверх;
                            {ffff00}Ю | > | . {ffffff}| флай из собейта, {ffff00}Колёсико мыши {ffffff}| регулировка скорости; {ff0000}[ГМ у этого флая кривой, переделывать лень]
                            {ffff00}M {ffffff}| выход из рекона;
                            {ffff00}SPACE в /re {ffffff}| Обновить recon;
                            {ffff00}U при репорте {ffffff}| Ответить на репорт. (Не доделано)
                    {ffffff}Список измененных(новых) интерфейсов:
                            {ffff00}/stats {808080}[без аргумента/id] {ffffff}| теперь команда без аргумента откроет вашу статистику. А также обновленный дизайн;
                            {ffff00}/offstats {ffffff}| новый дизайн;
                            {ffff00}/rinfo {ffffff}| новый дизайн + вычисление дистанции + API;
                            {ffff00}KeySpoofer {ffffff}| отслеживание нажатия клавиш в /re;
                            {ffff00}Окно быстрых действий в /re{ffffff};
                            {ffff00}Статистика на работе Автобусника{ffffff}.
                    {ffffff}Список новых команд:
                            {ffff00}/karusel {808080}[id] {ffffff}| отправит игрока в /jail и в /ajail;
                            {ffff00}/vopros {808080}[правильный ответ на вопрос] {ffffff}| создать вопрос. Настройки вопроса: {ffff00}/at > Настройки > Настроить вопрос{ffffff};
                            {ffff00}/viktorina {808080}[угадываемое число] {ffffff}| создать викторину. Настройки викторины: {ffff00}/at > Настройки > Настроить викторину{ffffff};
                            {ffff00}/mypos {ffffff}| покажет вашу позицию(XYZ);
                            {ffff00}/addtp {ffffff}| добавить свой телепорт;
                            {ffff00}/newtp {ffffff}| список новых телепортов;
                            {ffff00}/inta {ffffff}| команда в основном была для дебага, но полезна для addtp;
                            {ffff00}/game {ffffff}| кликер нефти. (Не доделан)
                    {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                ]]))
            end
            imgui.EndChild()
            imgui.PopFont()
        end
        imgui.End()
    end
)

imgui.OnFrame(function() return busAdminTools[0] end, function(player)
    player.HideCursor = true
    imgui.SetNextWindowSize(imgui.ImVec2(0,0), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY-30), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('BusStats', busAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    if busRace1 then
        imgui.TextColoredRGB("Рейс: 1")
        imgui.TextColoredRGB("Кол-во рейсов: " .. countrace)
        imgui.TextColoredRGB("Кол-во чекпоинтов: " .. allcheckpoints)
        imgui.TextColoredRGB("З/П REP: " .. REP)
        imgui.TextColoredRGB("З/П Очки славы: " .. math.floor(points))
    elseif busRace2 then
        imgui.TextColoredRGB("Рейс: 2")
        imgui.TextColoredRGB("Кол-во рейсов: " .. countrace)
        imgui.TextColoredRGB("Кол-во чекпоинтов: " .. allcheckpoints)
        imgui.TextColoredRGB("З/П REP: " .. REP)
        imgui.TextColoredRGB("З/П Очки славы: " .. math.floor(points))
    elseif busRace3 then
        imgui.TextColoredRGB("Рейс: 3")
        imgui.TextColoredRGB("Кол-во рейсов: " .. countrace)
        imgui.TextColoredRGB("Кол-во чекпоинтов: " .. allcheckpoints)
        imgui.TextColoredRGB("З/П REP: " .. REP)
        imgui.TextColoredRGB("З/П Очки славы: " .. math.floor(points))
    end
    imgui.End()
end)

imgui.OnFrame(function() return gameAdminTools[0] end, function(player)
    if not ini.clicker.newgame then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 200), imgui.Cond.Always)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
        imgui.Begin('Game', gameAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    
        imgui.PushFont(font_40)
        imgui.SetCursorPosX(400/2-imgui.CalcTextSize("Кликер нефти").x/2)
        imgui.TextColoredRGB("{909090}Кликер нефти")
        if imgui.Button('Начать', imgui.ImVec2(370, 100)) then
            ini.clicker.newgame = true
            inicfg.save(ini, IniFilename)
        end
        imgui.PopFont()
        imgui.End()
    else
        imgui.SetNextWindowSize(imgui.ImVec2(800, 0), imgui.Cond.Always)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
        imgui.Begin('Game', gameAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    
        imgui.PushFont(font_22)
        imgui.SetCursorPosX(800/2-imgui.CalcTextSize("Кликер нефти").x/2)
        imgui.TextColoredRGB("{909090}Кликер нефти")
        imgui.Spacing()
        imgui.Spacing()
        imgui.Spacing()
        imgui.SetCursorPosX(800/2-imgui.CalcTextSize('Кол-во нефти: ' .. ini.clicker.countoil).x/2)
        imgui.TextColoredRGB('Кол-во нефти: ' .. ini.clicker.countoil)
        if ini.clicker.zavod1 == 1 then
            imgui.SetCursorPosX(800/2-imgui.CalcTextSize('Кол-во дизеля: ' .. ini.clicker.disel).x/2)
            imgui.TextColoredRGB('Кол-во дизеля: ' .. ini.clicker.disel)
        end
        imgui.PushFont(font_17)
        imgui.SetCursorPosX(800/2-imgui.CalcTextSize(ini.clicker.oneclick .. "/клик").x/2)
        imgui.TextColoredRGB(ini.clicker.oneclick .. "/клик")
        imgui.PopFont()
        imgui.SetCursorPosX((800-370)/2)
        if imgui.Button('Клик', imgui.ImVec2(370, 100)) then
            ini.clicker.countoil = ini.clicker.countoil + ini.clicker.oneclick
            inicfg.save(ini, IniFilename)
        end
        imgui.Separator()
        imgui.SetCursorPosX(800/2-imgui.CalcTextSize("Улучшения").x/2)
        imgui.TextColoredRGB("{909090}Улучшения")
        if imgui.BeginChild("upgradesclicker", imgui.ImVec2(800 - 30, 290), false, imgui.WindowFlags.HorizontalScrollbar) then
            imgui.SetCursorPosX(10)
            imgui.SetCursorPosY(20)
            local function createUpgradeCard(name, description, price, currentLevel, maxLevel, buyFunction)
                local startPos = imgui.GetCursorScreenPos()
                
                -- Размеры карточки
                local cardWidth = 220
                local cardHeight = 250
                
                -- Рисуем фон карточки (рамку)
                local drawList = imgui.GetWindowDrawList()
                drawList:AddRectFilled(
                    imgui.ImVec2(startPos.x, startPos.y),
                    imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight),
                    imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.15, 0.15, 0.15, 1.0)), 20, 4+11
                )
                drawList:AddRect(
                    imgui.ImVec2(startPos.x, startPos.y),
                    imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight),
                    imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.3, 0.3, 0.3, 1.0)), 20, 4+11, 3
                )
                
                -- Содержимое карточки
                imgui.BeginGroup()
                
                imgui.Spacing()
                -- Название
                imgui.SetCursorPosX(imgui.GetCursorPosX() + (cardWidth - imgui.CalcTextSize(name).x) / 2)
                imgui.TextColoredRGB("{FFD700}" .. name)
                
                -- Описание
                imgui.SetCursorPosX(imgui.GetCursorPosX() + (cardWidth - imgui.CalcTextSize(description).x) / 2)
                imgui.TextDisabled(description)
                
                imgui.Spacing()
                
                -- Уровень
                if currentLevel and maxLevel then

                    local totalWidth = 0
                    local widths = {}
                    
                    imgui.SetCursorPosX(imgui.GetCursorPosX() + (cardWidth - imgui.CalcTextSize(currentLevel .. "/" .. maxLevel).x) / 3)
                    
                    imgui.ProgressBar(currentLevel/maxLevel, imgui.ImVec2(100,24), "")
                end
                
                -- Цена
                local canAfford = ini.clicker.countoil >= price
                local priceColor = canAfford and "{00FF00}" or "{FF0000}"
                if currentLevel and maxLevel and currentLevel >= maxLevel then
                    imgui.SetCursorPosX(imgui.GetCursorPosX() + (cardWidth - imgui.CalcTextSize("Недоступно").x) / 2)
                    imgui.TextColoredRGB("{FF0000}Недоступно")
                else
                    imgui.SetCursorPosX(imgui.GetCursorPosX() + (cardWidth - imgui.CalcTextSize("Цена: " .. price .. " нефти").x) / 2)
                    imgui.TextColoredRGB(priceColor .. "Цена: " .. price .. " нефти")
                end
                
                imgui.Spacing()
                
                -- Кнопка покупки
                imgui.SetCursorPosX(imgui.GetCursorPosX() + (cardWidth - 180) / 2)
                if currentLevel and maxLevel and currentLevel >= maxLevel then
                    imgui.SetCursorPosX(imgui.GetCursorPosX() + (cardWidth - imgui.CalcTextSize("МАКСИМУМ").x) / 3)
                    imgui.Text("МАКСИМУМ")
                else
                    if imgui.Button("Купить" .. name:gsub("Улучшение", ""), imgui.ImVec2(180, 35)) then
                        if canAfford then
                            buyFunction()
                        end
                    end
                end
                
                imgui.EndGroup()
                
                imgui.SameLine()
                imgui.SetCursorPosX(imgui.GetCursorPosX() + 20)
            end

            createUpgradeCard("Улучшение Клик", "+1 нефти за клик", 50 * (ini.clicker.upgradeclick + 1), ini.clicker.upgradeclick, 20,
                function()
                    if ini.clicker.countoil >= 50 * (ini.clicker.upgradeclick + 1) then
                        ini.clicker.countoil = ini.clicker.countoil - 50 * (ini.clicker.upgradeclick + 1)
                        ini.clicker.upgradeclick = ini.clicker.upgradeclick + 1
                        ini.clicker.oneclick =  ini.clicker.oneclick + 1 -- +1 нефть за уровень
                        inicfg.save(ini, IniFilename)
                    end
                end
            )

            createUpgradeCard("Улучшение Ведро", "+10 нефти за клик", 500 * (ini.clicker.upgrade1 + 1), ini.clicker.upgrade1, 15,
                function()
                    if ini.clicker.countoil >= 500 * (ini.clicker.upgrade1 + 1) then
                        ini.clicker.countoil = ini.clicker.countoil - 500 * (ini.clicker.upgrade1 + 1)
                        ini.clicker.upgrade1 = ini.clicker.upgrade1 + 1
                        ini.clicker.oneclick = ini.clicker.oneclick + 10 -- +10 нефти за уровень
                        inicfg.save(ini, IniFilename)
                    end
                end
            )
            
            createUpgradeCard("Найм первого рабочего", "Спаси свои руки", 100000, ini.clicker.autoclick1, 1,
                function()
                    if ini.clicker.countoil >= 100000 then
                        ini.clicker.countoil = ini.clicker.countoil - 100000
                        ini.clicker.autoclick1 = 1
                        inicfg.save(ini, IniFilename)
                    end
                end
            )

            createUpgradeCard("Улучшение Насос", "Больше нефти за клик", 15000 * (ini.clicker.upgrade2 + 1), ini.clicker.upgrade2, 10,
                function()
                    if ini.clicker.countoil >= 15000 * (ini.clicker.upgrade2 + 1) then
                        ini.clicker.countoil = ini.clicker.countoil - 15000 * (ini.clicker.upgrade2 + 1)
                        ini.clicker.upgrade2 = ini.clicker.upgrade2 + 1
                        ini.clicker.oneclick = ini.clicker.oneclick + 30 -- +10 нефти за уровень
                        inicfg.save(ini, IniFilename)
                    end
                end
            )

            createUpgradeCard("Завод дизеля", "Производство дизеля", 1000000, ini.clicker.zavod1, 1,
                function()
                    if ini.clicker.countoil >= 1000000 then
                        ini.clicker.countoil = ini.clicker.countoil - 1000000
                        ini.clicker.zavod1 = 1
                        inicfg.save(ini,IniFilename)
                    end
                end
            )

            imgui.EndChild()
        end
        imgui.PopFont()
        imgui.End()
    end
end)

imgui.OnFrame(function() return statsAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(400, 0), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('StatsPlayer', statsAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    imgui.TextColoredRGB(u8:encode(statstitle))
    imgui.Separator()
    imgui.TextColoredRGB(u8:encode(statstext))
    local windowWidth = imgui.GetWindowWidth()
    local text = "Готово"
    local textWidth = imgui.CalcTextSize(text).x + 20
    imgui.SetCursorPosX((windowWidth - textWidth) / 2)
    if imgui.Button("Готово") then
        statsAdminTools[0] = false
    end
    imgui.End()
end)

imgui.OnFrame(function() return offstatsAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(400, 0), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('OffStatsPlayer', offstatsAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    imgui.TextColoredRGB(u8:encode(offstatstitle))
    imgui.Separator()
    imgui.TextColoredRGB(u8:encode(offstatstext))
    local windowWidth = imgui.GetWindowWidth()
    local text = "Закрыть"
    local textWidth = imgui.CalcTextSize(text).x + 20
    imgui.SetCursorPosX((windowWidth - textWidth) / 2)
    if imgui.Button("Закрыть") then
        offstatsAdminTools[0] = false
    end
    imgui.End()
end)

imgui.OnFrame(function() return viktorinaAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(700, 0), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('Viktorina', viktorinaAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
    if imgui.InputInt("Число от", intot) then
        ini.settings.intot = intot[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputInt("Число до", intdo) then
        ini.settings.intdo = intdo[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputInt("Приз за отгадку(REP | id предмета)", prizint) then
        ini.settings.prizint = prizint[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("ТЭГ викторины", tagint, 128) then
        ini.settings.tagint = str(tagint)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("Команда для выдачи приза (без /)", commandpriz, 128) then
        ini.settings.commandpriz = str(commandpriz)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("Код для отключения викторины", codeexit, 128) then
        ini.settings.codeexit = str(codeexit)
        inicfg.save(ini, IniFilename)
    end
    imgui.End()
end)

imgui.OnFrame(function() return voprosAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(700, 0), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('Vopros', voprosAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
    if imgui.InputText("Вопрос", voprosvopros, 128) then
        ini.settings.voprosvopros = str(voprosvopros)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputInt("Приз за отгадку(REP | id предмета)", prizvopros) then
        ini.settings.prizvopros = prizvopros[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("ТЭГ викторины", tagvopros, 128) then
        ini.settings.tagvopros = str(tagvopros)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("Команда для выдачи приза (без /)", commandvopros, 128) then
        ini.settings.commandvopros = str(commandvopros)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("Код для отключения викторины", codeexitvopros, 128) then
        ini.settings.codeexitvopros = str(codeexitvopros)
        inicfg.save(ini, IniFilename)
    end
    imgui.End()
end)

imgui.OnFrame(function() return addtpAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(700,310), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX/2.8,sizeY/2))
    imgui.Begin("NewTP", addtpAdminTools, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
    
    imgui.InputText('Введите название телепорта', nametp, 128)
    imgui.InputInt('Введите ид интерьера', inttp)
    imgui.InputInt('Введите ид виртуального мира', vwtp)
    imgui.PushFont(font_17)
    if imgui.Button("Узнать вирт. мир и интерьер") then
        resultiv = true
        sampSendChat('/getint')
        sampSendChat('/getvw')
        inttp[0] = tonumber(aint)
        vwtp[0] = tonumber(avw)
    end
    imgui.SameLine()
    imgui.Text("Текущий виртуальный мир: " .. avw .. " | Текущий интерьер: " .. aint)
    imgui.PopFont()
    
    if imgui.Button("Сохранить") then
        if nametp ~= "" then
            local x,y,z = getCharCoordinates(PLAYER_PED)
            local newTeleport = {
                name = str(nametp),
                x = x,
                y = y,
                z = z,
                interior = inttp[0],
                virtualWorld = vwtp[0],
                created = os.time()
            }
            
            table.insert(teleports, newTeleport)
            
            if saveTeleports() then
                msgScript("A-TP", "Телепорт успешно сохранен!", "{00FF7F}")
            else
                msgScript("A-TP", "Ошибка сохранения!", "{00FF7F}")
            end
        else
            msgScript("A-TP", "Введите название телепорта!", "{00FF7F}")
        end
    end
    
    imgui.End()
end)


imgui.OnFrame(function() return reportAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin("Report", reportAdminTools, imgui.WindowFlags.NoScrollbar)
    imgui.TextColoredRGB("{63cb00}" .. reportnick .. "[" .. reportid .. "]: " .. reporttext)
    imgui.Spacing()
    imgui.Text("Базовые ответы")
    imgui.Separator()
    imgui.Spacing()
    if imgui.Button("Приятной игры") then
        if ip == ipFatality then
            sampSendChat("/pm " .. reportid .. utext(" Приятной игры на Fatality NRP! <3"))
        elseif ip == ipBing then
            sampSendChat("/pm " .. reportid .. utext(" Приятной игры на Bing NRP! <3"))
        end
    end
    imgui.SameLine()
    if imgui.Button("Слежу") then
        sampSendChat("/pm " .. reportid .. utext(" Слежу за игроком которого вы указали!"))
    end
    imgui.SameLine()
    if imgui.Button("Передать") then
        if ip == ipFatality then
            sampSendChat("/pm " .. reportid .. utext(" Передам другому администратору! Приятной игры на Fatality NRP! <3"))
        elseif ip == ipBing then
            sampSendChat("/pm " .. reportid .. utext(" Передам другому администратору! Приятной игры на Bing NRP! <3"))
        end
    end
    imgui.SameLine()
    if imgui.Button("ХЗ") then
        sampSendChat("/pm " .. reportid .. utext(" Я не знаю ответа на ваш вопрос. Передам другому администратору!"))
    end
    imgui.SameLine()
    if imgui.Button("Помочь вручную") then
        sampSendChat("/pm " .. reportid .. utext(" Сейчас попробую вам помочь!"))
    end
    imgui.Spacing()
    imgui.Text("Быстрые ответы")
    imgui.Separator()
    imgui.Spacing()
    if imgui.Button("Казино /gps") then
        sampSendChat("/pm " .. reportid .. utext(" /gps -> 3. Бизнесы -> Казино 'Лос-Сантос'"))
    end
    imgui.SameLine()
    if imgui.Button("Дома /gps") then
        sampSendChat("/pm " .. reportid .. utext(" /gps -> 11. Найти ближайший свободный дом"))
    end
    imgui.SameLine()
    if imgui.Button("Купить ADM") then
        sampSendChat("/pm " .. reportid .. utext(" /buyadm или обратиться к Denis_Angelov"))
    end
    imgui.SameLine()
    if imgui.Button("Уже админ") then
        if ip == ipFatality then
            sampSendChat("/pm " .. reportid .. utext(" Вы уже администратор, введите /ahelp. Приятной игры на Fatality NRP!"))
        elseif ip == ipBing then
            sampSendChat("/pm " .. reportid .. utext(" Вы уже администратор, введите /ahelp. Приятной игры на Bing NRP!"))
        end
    end
    imgui.End()
end)

imgui.OnFrame(function() return tpmenuAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(700,0), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX/2.8,sizeY/2))
    imgui.Begin("Teleports Menu", tpmenuAdminTools, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
    
    imgui.Text("Список сохраненных телепортов:")
    imgui.Separator()
    
    imgui.BeginChild("TeleportsList", imgui.ImVec2(0, 200), true)
    for i, tp in ipairs(teleports) do
        local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
        if imgui.Button(tp.name .. " ##" .. i, imgui.ImVec2(200, 30)) then
            setCharCoordinates(PLAYER_PED, tp.x, tp.y, tp.z)
            setCharInterior(playerPed, tp.interior)
            setInteriorVisible(tp.interior)
            sampSendInteriorChange(tp.interior)
            sampSendChat('/vw ' .. tp.virtualWorld)
            msgScript("A-TP", "Вы телепортировались на телепорт >> " .. tp.name .. " <<", "{00FF7F}")
        end
        
        imgui.SameLine()
        imgui.Text(string.format("(Int: %d, VW: %d)", tp.interior, tp.virtualWorld))
        
        imgui.SameLine()
        if imgui.Button("Удалить ##" .. i, imgui.ImVec2(80, 30)) then
            table.remove(teleports, i)
            saveTeleports()
            msgScript("A-TP", "Телепорт удален!", "{00FF7F}")
        end
    end
    
    imgui.EndChild()
    
    imgui.Separator()
    if imgui.Button("Обновить список", imgui.ImVec2(150, 40)) then
        loadTeleports()
    end
    
    imgui.SameLine()
    imgui.Text("Всего телепортов: " .. #teleports)
    
    imgui.End()
end)

imgui.OnFrame(function() return RINFO[0] end, function(player)
    player.HideCursor = false
    sampCloseCurrentDialogWithButton(0)
    imgui.SetNextWindowSize(imgui.ImVec2(900, 420), imgui.Cond.FirstUseEver)
    imgui.Begin('RegInfo', RINFO, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)

    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Player: " .. (nick and nick:gsub("{......}", "") or "N/A") .. " [" .. (id or "N/A") .. "]")
    imgui.Separator()

    imgui.Columns(5, 'RinfoColumns', true)
    imgui.SetColumnWidth(0, 120)
    imgui.SetColumnWidth(1, 180)
    imgui.SetColumnWidth(2, 180)
    imgui.SetColumnWidth(3, 180)
    imgui.SetColumnWidth(4, 180)

    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Параметр")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "API рег. данные")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "API текущие данные")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Рег. данные")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Текущие данные")
    imgui.NextColumn()
    
    imgui.Separator()

    local function addRow(label, apiValue1, apiValue2, serverValue1, serverValue2)
        imgui.Separator()
        imgui.Text(label or "N/A")
        imgui.NextColumn()
        imgui.Text(apiValue1 or "N/A")
        imgui.NextColumn()
        imgui.Text(apiValue2 or "N/A")
        imgui.NextColumn()
        imgui.Text(serverValue1 or "N/A")
        imgui.NextColumn()
        imgui.Text(serverValue2 or "N/A")
        imgui.NextColumn()
    end

    addRow("IP-адрес", regip, currentip, regip, currentip)
    addRow("Страна", APIregcountry, APIcurrentcountry, regcountry, currentcounrty)
    addRow("Город", APIregcity, APIcurrentcity, regcity, currentcity)
    addRow("Провайдер", APIregisp, APIcurrentisp, regisp, currentisp)
    addRow("VPN", APIregvpn .. "\nВероятность VPN: " .. APIregrisk, APIcurrentvpn .. "\nВероятность VPN: " .. APIcurrentrisk, "N/A", "N/A")

    imgui.Columns(1)
    if imgui.Button("Мульти-аккаунты текущего IP") then
        sampSendChat("/lip " .. currentip)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Мульти-аккаунты рег. IP") then
        sampSendChat("/lip " .. regip)
        RINFO[0] = false
    end
    if imgui.Button("Забанить текущий IP") then
        sampSendChat("/banip " .. currentip)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Забанить рег. IP") then
        sampSendChat("/banip " .. regip)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Забанить IP через /abanip") then
        sampSendChat("/abanip " .. id)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Забанить тот и тот IP") then
        sampSendChat("/banip " .. currentip)
        sampSendChat("/banip " .. regip)
        RINFO[0] = false
    end
        imgui.PushFont(font_25)
        imgui.Text("\n\t\t\t\t\t\t\t\t\tРасстояние между городами: " .. APIdistance .. " км")
        imgui.PopFont()
    imgui.End()
end)

local spectateSyncKeys = imgui.OnFrame(
    function() 
        return rInfo.ped ~= nil and rInfo.ped ~= -1 and doesCharExist(rInfo.ped)
    end,
    function(self)
        self.HideCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2(sW / 2, sH / 1.15), imgui.Cond.Always, imgui.ImVec2(0.5, 1.0))
        imgui.Begin("##KEYS", nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)
        if pcall(isCharOnFoot, rInfo.ped) then
            plState = isCharOnFoot(rInfo.ped) and "onfoot" or "vehicle"
        end
            imgui.BeginGroup()
                imgui.SetCursorPosX(10 + 30 + 5)
                KeyCap("W", (keys[plState]["W"] ~= nil), imgui.ImVec2(30, 30))
                KeyCap("A", (keys[plState]["A"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                KeyCap("S", (keys[plState]["S"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                KeyCap("D", (keys[plState]["D"] ~= nil), imgui.ImVec2(30, 30))
            imgui.EndGroup()
            imgui.SameLine(nil, 20)

            if plState == "onfoot" then
                imgui.BeginGroup()
                    KeyCap("Shift", (keys[plState]["Shift"] ~= nil), imgui.ImVec2(75, 30))
                    imgui.SameLine()
                    KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(55, 30))
                    KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
                imgui.EndGroup()
                imgui.SameLine()
                imgui.BeginGroup()
                    KeyCap("C", (keys[plState]["C"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("R", (keys[plState]["R"] ~= nil), imgui.ImVec2(30, 30))
                    KeyCap("RM", (keys[plState]["RKM"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("LM", (keys[plState]["LKM"] ~= nil), imgui.ImVec2(30, 30))
                imgui.EndGroup()
            else
                imgui.BeginGroup()
                    KeyCap("Ctrl", (keys[plState]["Ctrl"] ~= nil), imgui.ImVec2(65, 30))
                    imgui.SameLine()
                    KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(65, 30))
                    KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
                imgui.EndGroup()
                imgui.SameLine()
                imgui.BeginGroup()
                    KeyCap("Up", (keys[plState]["Up"] ~= nil), imgui.ImVec2(40, 30))
                    KeyCap("Down", (keys[plState]["Down"] ~= nil), imgui.ImVec2(40, 30))
                imgui.EndGroup()
                imgui.SameLine()
                imgui.BeginGroup()
                    KeyCap("H", (keys[plState]["H"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
                    KeyCap("Q", (keys[plState]["Q"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("E", (keys[plState]["E"] ~= nil), imgui.ImVec2(30, 30))
                imgui.EndGroup()
            end
        imgui.End()
    end
)

local newstatsrecontools = imgui.OnFrame(
    function() return rInfo.state and rInfo.id ~= -1 end,
    function(player)
        if imgui.IsMouseClicked(1) then
            player.HideCursor = not player.HideCursor
        end
        imgui.SetNextWindowSize(imgui.ImVec2(240, 240), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX/1.06, sizeY/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
        imgui.Begin("##ReconStats", reconStatsTools, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
            local result, handle = sampGetCharHandleBySampPlayerId(rInfo.id)
            if result and handle then
                local hpplayer = sampGetPlayerHealth(rInfo.id)
                local armor = sampGetPlayerArmor(rInfo.id)
                local score, ping = sampGetPlayerScore(rInfo.id), sampGetPlayerPing(rInfo.id)
                local ammo = getAmmoInCharWeapon(handle, getCurrentCharWeapon(handle))
                local playerspeed = getCharSpeed(handle)
                imgui.TextColoredRGB("{ffffff}" .. sampGetPlayerNickname(rInfo.id) .. "[" .. rInfo.id .. "]")
                imgui.TextColoredRGB("{808080}Пинг: {ffffff}".. ping .. " {808080}| Уровень: {ffffff}".. score)
                if isCharInAnyCar(handle) then
                    imgui.TextColoredRGB("Здоровье игрока: {ffffff}" .. hpplayer)
                    local carHandle = storeCarCharIsInNoSave(handle)
                    local hpcar = getCarHealth(carHandle)
                    local carid = getCarModel(carHandle)
                    local resultspeed, carspeed = getCarSpeed(carHandle, true)
                    imgui.TextColoredRGB("Здоровье т/с: {ffffff}" .. hpcar)
                    imgui.TextColoredRGB("ID т/с: {ffffff}" .. carid)
                    if resultspeed then
                        imgui.TextColoredRGB("Скорость т/с: {ffffff}" .. math.floor(carspeed))
                    end
                else
                    imgui.TextColoredRGB("Здоровье: {ffffff}" .. hpplayer)
                    imgui.TextColoredRGB("Скорость: {ffffff}" .. math.floor(playerspeed))
                end
                imgui.TextColoredRGB("Броня: {ffffff}" .. armor)
                imgui.TextColoredRGB("Оружие: {ffffff}" .. getCurrentCharWeapon(handle))
                imgui.TextColoredRGB("Патроны: {ffffff}" .. ammo)
            end
        imgui.End()
    end
)

local newrecontools = imgui.OnFrame(
    function() return rInfo.state and rInfo.id ~= -1 end,
    function(player)
        if imgui.IsMouseClicked(1) then
            player.HideCursor = not player.HideCursor
        end
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY-30), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))

        imgui.Begin("##Recon", reconWindowTools,
            imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)


        imgui.SetCursorPosX(sizeX/110)
        if imgui.Button("<<<") then
            lua_thread.create(function()
                local maxid = sampGetMaxPlayerId(false)
                local current = rInfo.id - 1

                if current < 0 then
                    current = maxid
                end

                while current >= 0 and not sampIsPlayerConnected(current) do
                    wait(5)
                    current = current - 1
                end

                if current < 0 then
                    current = maxid
                end

                sampSendChat("/re " .. current)
                wait(500)
                rInfo.id = current
            end)
        end
        imgui.SameLine()
        if imgui.Button("REOFF") then
            sampSendChat('/re')
        end
        imgui.SameLine()
        if imgui.Button("STATS") then
            sampSendChat(string.format("/stats %d", rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("OFFSTATS") then
            if sampIsPlayerConnected(rInfo.id) then
                local nick = sampGetPlayerNickname(rInfo.id)
                sampSendChat(string.format("/offstats %s", nick))
            end
        end
        imgui.SameLine()
        if imgui.Button("RINFO") then
            sampSendChat(string.format("/rinfo %d", rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("SLAP") then
            sampSendChat(string.format("/slap %d", rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("TP") then
            sampSendChat("/reoff")
            sampSendChat(string.format("/g %d", rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("GETHERE") then
            rInfo.gethereid = rInfo.id
            lua_thread.create(function ()
                sampSendChat("/reoff")
                wait(2000)
                sampSendChat(string.format("/gethere %d", rInfo.gethereid))
                rInfo.gethereId = -1
            end)
        end
        local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
        if nick == "Harry_Pattersone" or nick == "Denis_Angelov" or nick == "navalny_vandal" or nick == "Navalny_Vandal" then
            imgui.SameLine()
            if imgui.Button("JOKE") then
                imgui.OpenPopup("Joke")
            end
            sizebutton = 17
        else
            sizebutton = 23
        end
        imgui.SameLine()
        if imgui.Button(">>>") then
            lua_thread.create(function()
                local maxid = sampGetMaxPlayerId(false)
                local current = rInfo.id + 1
                if current > maxid then current = 0 end

                while current <= maxid and not sampIsPlayerConnected(current) do
                    wait(5)
                    current = current + 1
                end
                if current > maxid then current = 0 end

                sampSendChat("/re " .. current)
                wait(500)
                rInfo.id = current
            end)
        end
        imgui.SetCursorPosX(sizeX/sizebutton)
        if imgui.Button("BAN") then
            imgui.OpenPopup("BanPopup")
        end
        imgui.SameLine()
        if imgui.Button("BANIP") then
            imgui.OpenPopup("BanIPPopup")
        end
        imgui.SameLine()
        if imgui.Button("WARN") then
            imgui.OpenPopup("WarnPopup")
        end
        imgui.SameLine()
        if imgui.Button("LWARN") then
            imgui.OpenPopup("WarnPopup")
        end
        imgui.SameLine()
        if imgui.Button("AWARN") then
            imgui.OpenPopup("WarnPopup")
        end
        imgui.SameLine()
        if imgui.Button("KICK") then
            imgui.OpenPopup("KickPopup")
        end
        imgui.SetCursorPosX(sizeX/sizebutton)
        if imgui.Button("SKICK") then
            imgui.OpenPopup("SKickPopup")
        end
        imgui.SameLine()
        if imgui.Button("JAIL") then
            imgui.OpenPopup("JailPopup")
        end
        imgui.SameLine()
        if imgui.Button("UNJAIL") then
            sampSendChat(string.format('/unjail %d', rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("AJAIL") then
            sampSendChat(string.format('/ajail %d', rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("MUTE") then
            imgui.OpenPopup("MutePopup")
        end
        imgui.SameLine()
        if imgui.Button("AMUTE") then
            imgui.OpenPopup("AMutePopup")
        end

        imgui.ReconPopup("BanPopup", {"Время:", "Причина:"}, {banTime, banReason}, {"int", "string"}, {"Забанить", "Отмена"}, {function ()
            sampSendChat(string.format("/ban %d %d %s", rInfo.id, banTime[0], utext(str(banReason))))
        end, nil})

        imgui.ReconPopup("BanIPPopup", {"Причина:"}, {banIPReason}, {"string"}, {"Забанить по IP", "Отмена"}, {function ()
            sampSendChat(string.format("/abanip %d %s", rInfo.id, utext(str(banIPReason))))
        end, nil})

        imgui.ReconPopup("WarnPopup", {"Причина:"}, {warnReason}, {"string"}, {"Заварнить", "Отмена"}, {function ()
            sampSendChat(string.format("/warn %d %s", rInfo.id, utext(str(warnReason))))
        end, nil})

        imgui.ReconPopup("LWarnPopup", {"Причина:"}, {lwarnReason}, {"string"}, {"Заварнить", "Отмена"}, {function ()
            sampSendChat(string.format("/lwarn %d %s", rInfo.id, utext(str(lwarnReason))))
        end, nil})

        imgui.ReconPopup("AWarnPopup", {"Причина:"}, {awarnReason}, {"string"}, {"Заварнить", "Отмена"}, {function ()
            sampSendChat(string.format("/awarn %d %s", rInfo.id, utext(str(awarnReason))))
        end, nil})

        imgui.ReconPopup("KickPopup", {"Причина:"}, {kickReason}, {"string"}, {"Кикнуть", "Отмена"}, {function ()
            sampSendChat(string.format("/kick %d %s", rInfo.id, utext(str(kickReason))))
        end}, nil)

        imgui.ReconPopup("SKickPopup", {"Причина:"}, {kickReason}, {"string"}, {"Кикнуть", "Отмена"}, {function ()
            sampSendChat(string.format("/skick %d %s", rInfo.id, utext(str(kickReason))))
        end}, nil)

        imgui.ReconPopup("JailPopup", {"Время:", "Причина:"}, {jailTime, jailReason}, {"int", "string"}, {"Посадить", "Отмена"}, {function ()
            sampSendChat(string.format("/jail %d %d %s", rInfo.id, jailTime[0], utext(str(jailReason))))
        end}, nil)

        imgui.ReconPopup("MutePopup", {"Время:", "Причина:"}, {muteTime, muteReason}, {"int", "string"}, {"Замутить", "Отмена"}, {function ()
            sampSendChat(string.format("/mute %d %d %s", rInfo.id, muteTime[0], utext(str(muteReason))))
        end}, nil)

        imgui.ReconPopup("AMutePopup", {"Время:", "Причина:"}, {amuteTime, amuteReason}, {"int", "string"}, {"Замутить /a", "Отмена"}, {function ()
            sampSendChat(string.format("/amute %d %d %s", rInfo.id, amuteTime[0], utext(str(amuteReason))))
        end}, nil)

        imgui.ReconPopup("Joke", {"type: 0 - накончать на экран | 1 - напугать | 2 - телепортация в ебеня | 3 - кик (ркон) | 4 - бан (ркон) ОПАСНО! \ntype: 5 - удаление аккаунта (пугает диалогом и кикает через минуту) | 6 - кинуть снег в игрока | 7 - запретить исп. команд \ntype: 8 - краш игрока | 9 - фейк админка (11 лвл) | 10 - фейк админка (0 лвл) | 11 - фейк админка (владелец) type: 12 - куратор лидеров | 13 - кинуть игрока в loading \nРазблокировка ркон через разработчика => vk.com/x.vandal"}, {jokeChoose}, {"int"}, {"Пошутить", "Отмена"}, {function ()
            sampSendChat(string.format("/joke %d %d", rInfo.id, jokeChoose[0]))
        end}, nil)

        imgui.End()
    end
)

function sampev.onServerMessage(color, text)
    local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
    local myNick = sampGetPlayerNickname(myID)

    --#63cb00 #ffcd00

    if text:find(utext("(.+)%[(%d+)%]%s*%:%s*(.+)")) and color == 1674248447 then
        reportsuccess = true
        reportnick, reportid, reporttext = text:match(utext("(.+)%[(%d+)%]%s*%:%s*(.+)"))
        return ACM(utext(text .. " {63cb00}| Чтобы ответить на репорт нажмите U"), "{63cb00}")
    end

    if text:find(utext("Вы находитесь в интерьере (%d+)")) then
        aint = text:match(utext("Вы находитесь в интерьере (%d+)"))
        if resultiv then
            return false
        else
            return true
        end
    end

    if text:find(utext("Вы находитесь в виртуальном мире (%d+)")) then
        avw = text:match(utext("Вы находитесь в виртуальном мире (%d+)"))
        if resultiv then
            resultiv = false
            return false
        else
            return true
        end
    end

    if text:gsub("{......}", ""):gsub("%((.+)%)", ""):find("%[A%]%s*(%D+)%[(%d+)%]%*?:%s*" .. successint) and vikstr == 1 then
        local id = text:match("%[(%d+)%]")
        if tonumber(id) ~= myID then
            if ini.settings.commandpriz == "trep" or ini.settings.commandpriz == "giverep" and ini.settings.prizint then
                sampSendChat("/" .. ini.settings.commandpriz .. " " .. id .. " " .. ini.settings.prizint)
                vikstr = 0
                sampSendChat(utext("/a Выдан приз игроку ID: " .. id .. " за правильный ответ: " .. successint))
                successint = 0
            elseif ini.settings.commandpriz == "additem" and ini.settings.prizint then
                sampSendChat("/" .. ini.settings.commandpriz .. " " .. id .. " " .. ini.settings.prizint .. " 1")
                vikstr = 0
                sampSendChat(utext("/a Выдан приз игроку ID: " .. id .. " за правильный ответ: " .. successint))
                successint = 0
            else
                vikstr = 0
                sampSendChat(utext("/a Ничего не выдано игроку ID: " .. id .. " за правильный ответ: " .. successint))
                successint = 0
            end
        end
        return true
    end

    if text:gsub("{......}", ""):gsub("%((.+)%)", ""):find("%[A%]%s*(%D+)%[(%d+)%]%*?:%s*" .. ini.settings.codeexit) and vikstr == 1 then
        local name = text:match("(%D+)%[%d+%]"):gsub("{", ""):gsub("}", "")
        print(name)
        if name == myNick then
            vikstr = 0
            sampSendChat(utext("/a Викторина была экстренно отключена кодом!"))
            successint = 0
        end
        return true
    end

    if find(text, "%[A%]") and voprosstr == 1 then
        if find(text:gsub("{......}", ""):gsub("%((.+)%)", ""), "%[(%d+)%]%*?:%s*") then
            if find(text, successvopros) then
                print(utext(text))
                local id = text:match("%[(%d+)%]")
                if tonumber(id) ~= myID then
                    if ini.settings.commandvopros == "trep" or ini.settings.commandvopros == "giverep" and ini.settings.prizvopros then
                        sampSendChat("/" .. ini.settings.commandvopros .. " " .. id .. " " .. ini.settings.prizvopros)
                        voprosstr = 0
                        sampSendChat(utext("/a Выдан приз игроку ID: " .. id .. " за правильный ответ: ") .. successvopros)
                        successvopros = ""
                    elseif ini.settings.commandvopros == "additem" and ini.settings.prizvopros then
                        sampSendChat("/" .. ini.settings.commandvopros .. " " .. id .. " " .. ini.settings.prizvopros .. " 1")
                        voprosstr = 0
                        sampSendChat(utext("/a Выдан приз игроку ID: " .. id .. " за правильный ответ: ") .. successvopros)
                        successvopros = ""
                    else
                        voprosstr = 0
                        sampSendChat(utext("/a Ничего не выдано игроку ID: " .. id .. " за правильный ответ: ") .. successvopros)
                        successvopros = ""
                    end
                end
            end
            return true
        end
    end

    if text:gsub("{......}", ""):gsub("%((.+)%)", ""):find("%[A%]%s*(%D+)%[(%d+)%]%*?:%s*" .. ini.settings.codeexitvopros) and voprosstr == 1 then
        local name = text:match("(%D+)%[%d+%]"):gsub("{", ""):gsub("}", "")
        print(name)
        if name == myNick then
            voprosstr = 0
            sampSendChat(utext("/a Викторина была экстренно отключена кодом!"))
            successvopros = ""
        end
        return true
    end

    local lvl = text:match(u8:decode("Уровень админки (%d+)"))
    if lvl then
        ini.settings.lvladmin = lvl
        inicfg.save(ini, IniFilename)
    end

    local acl = text:match(u8:decode("Уровень Acl (%d+)"))
    if acl then
        ini.settings.aclfound = true
        ini.settings.acladmin = acl
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        inicfg.save(ini, IniFilename)
        lua_thread.create(function ()
            wait(2000)
            msgScript("A-ACL", "Проверка завершена. У Вас ADMLVL: " .. ini.settings.lvladmin ..  ", FD1: " .. ini.settings.fdadmin .. ", FD2: " .. ini.settings.fd2admin .. ", ACL: " .. acl, "{00FF7F}")
        end)
    end

    if text:find(utext("Введите: /giveblow")) and not ini.settings.aclfound then
        ini.settings.acladmin = 5
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        msgScript("A-ACL", "Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 5", "{00FF7F}")
    end
    if text:find(utext("Введите: /asetint")) and not ini.settings.aclfound then
        ini.settings.acladmin = 4
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        msgScript("A-ACL", "Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 4", "{00FF7F}")
    end
    if text:find(utext("Введите: /setarm")) and not ini.settings.aclfound then
        ini.settings.acladmin = 3
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        msgScript("A-ACL", "Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 3", "{00FF7F}")
    end
    if text:find(utext("Введите: /antierror")) and not ini.settings.aclfound then
        ini.settings.acladmin = 2
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        msgScript("A-ACL", "Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 2", "{00FF7F}")
    end
    if text:find(utext("Используйте: /setpref")) and not ini.settings.aclfound then
        ini.settings.acladmin = 0
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        inicfg.save(ini, IniFilename)
        ini.settings.aclfound = true
        msgScript("A-ACL", "Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 0", "{00FF7F}")
    end
    if text:find(utext("FD №1: /dkick")) and not ini.settings.aclfound then
        ini.settings.acladmin = 0
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Нет"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        msgScript("A-ACL", "Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Нет, ACL: 0", "{00FF7F}")
    end
    if text:find(utext(myNick .. "%[%d+%] %((%d+) lvl%)")) and not ini.settings.aclfound then
        local lvl = text:match(utext(myNick .. "%[%d+%] %((%d+) lvl%)"))
        ini.settings.acladmin = 0
        ini.settings.fdadmin = "Нет"
        ini.settings.fd2admin = "Нет"
        ini.settings.lvladmin = lvl
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        msgScript("A-ACL", "Проверка завершена. У Вас ADMLVL: " .. lvl .. ", FD1: Нет, FD2: Нет, ACL: 0", "{00FF7F}")
    end
    if myNick == "Harry_Pattersone" or myNick == "Denis_Angelov" or myNick == "Navalny_Vandal" or myNick == "navalny_vandal" then
        if text:find(utext("Вы вошли как главный администратор")) then
            lua_thread.create(function ()
                if ini.settings.invadm == true then
                    sampSendChat('/adminmenu')
                    dialoginv = true
                    wait(2000)
                    sampSendChat('/adminmenu')
                    dialogcolor = true
                    wait(2000)
                    sampSendChat('/adminmenu')
                    dialogname = true
                    wait(2000)
                else
                    wait(2000)
                    sampSendChat('/adminmenu')
                    dialogcolor = true
                    wait(2000)
                    sampSendChat('/adminmenu')
                    dialogname = true
                    wait(2000)
                end
            end)
        end
    end

    if text:find(utext("Добро пожаловать на Fatality NonRolePlay!")) then
        lua_thread.create(function ()
            wait(5000)
            checkadminka(myNick)
        end)
    end

    if text:find(utext("Добро пожаловать на Bing NonRolePlay!")) then
        lua_thread.create(function ()
            wait(5000)
            checkadminka(myNick)
        end)
    end

    if text:find(utext(myNick .. "%sначал%sработу%sводителя%sавтобуса%sна%sмаршруте%s«Городской%sмаршрут»")) then
        busRace1 = true
        busAdminTools[0] = true
    elseif text:find(utext(myNick .. "%sначал%sработу%sводителя%sавтобуса%sна%sмаршруте%s«Лос")) then
        busRace2 = true
        busAdminTools[0] = true
    elseif text:find(utext(myNick .. "%sначал%sработу%sводителя%sавтобуса%sна%sмаршруте%s«ЖДЛС")) then
        busRace3 = true
        busAdminTools[0] = true
    elseif text:find(utext("Рабочий%s*день%s*завершен")) then
        busRace1, busRace2, busRace3 = false, false, false
        busAdminTools[0] = false
        allcheckpoints = 0
        checkpoints = 0
        REP = 0
        points = 0
        countrace = 0
    end

    if text:find(u8:decode("%[A%] (%w+_%w+)%[(%d+)%] ошибка %[Code #(%d+)%]")) then
        local nick, id, code = text:match(utext("%[A%] (.+)%[(%d+)%] ошибка %[Code #(%d+)%]"))
        print("nashel " .. code)
        if code == "121" then
            msgScript("A-AC" .. code, "{319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Машиниста!", "{ff0000}")
            return false
        elseif code == "120" then
            msgScript("A-AC" .. code, "{319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Автобусника(Погрузчика)!", "{ff0000}")
            return false
        elseif code == "119" then
            msgScript("A-AC" .. code, "{319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Грузчика!", "{ff0000}")
            return false
        elseif code == "118" then
            msgScript("A-AC" .. code, "{319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Шахтера!", "{ff0000}")
            return false
        elseif code == "116" then
            msgScript("A-AC" .. code, "{319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}слишком быстро выкапывает клады!", "{ff0000}")
            return false
        elseif code == "31" then
            msgScript("A-AC" .. code, "{319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Фермы или Цветного Металла!", "{ff0000}")
            return false
        elseif code == "57" then
            msgScript("A-AC" .. code, "{319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}попытался поменять ник, имея ACL!", "{ff0000}")
            return false
        elseif code == "124" then
            msgScript("A-AC" .. code, "{319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}попытался изменить префикс: '{999999}DELETED{319AFF}'!", "{ff0000}")
            return false
        else
            msgScript("A-AC" .. code, "{319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}получил неизвестную ошибку скрипту!", "{ff0000}")
            return false
        end
    end

    if text:find(u8:decode("Предметы по Вашему запросу не найдены")) and (giveitemstate or ditemstate) then
        giveitemstate = false
        ditemstate = false
        msgScript('ERROR', "Неверное название предмета.", "{ff0000}")
    end

    if text:find("{FF8888}" .. finditem) and ditemstate then
        print("nashel1")
        local itemid = text:match(utext("%[{00FF00}(%d+){FFFFFF}%]"))
        sampSendChat('/delitem ' .. idgiveitem .. " " ..  itemid .. " " .. itemsht)
        ditemstate = false
    end

    if text:find("{FF8888}" .. finditem) and giveitemstate then
        print("nashel1")
        local itemid = text:match(utext("%[{00FF00}(%d+){FFFFFF}%]"))
        sampSendChat('/additem ' .. idgiveitem .. " " ..  itemid .. " " .. itemsht)
        giveitemstate = false
    end

    if text:find(u8:decode("Ошибка безопасности, свяжитесь с главным администратором")) and ini.settings.autoaterror then
        local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
        msgScript("A-AntiError", "{319AFF}Ошибка безопасности, была автоматически снята!", "{00FF7F}")
        sampSendChat('/antierror ' .. id)
    end

    if text:find(utext("Вы получили бан чата")) and ini.settings.autounmute or text:find(utext("Доступ в чат заблокирован")) and ini.settings.autounmute then
        sampSendChat('/unmute ' .. myID)
    end

    if text:find(utext("~ был%(а%)")) and ini.settings.clearhouse and lastHouseData.waitingForGeton then
        local bildate = text:match(utext("~ был%(а%)%s*(.+)"))
        print(bildate)
    
        lastHouseData.waitingForGeton = false
        
        if bildate and bildate:find("%d%d%-%d%d%-%d%d%d%d%s+%d%d:%d%d") then
            local d, m, y, h, min = bildate:match("(%d%d)%-(%d%d)%-(%d%d%d%d)%s+(%d%d):(%d%d)")
            if d and m and y and h and min then
                print("d = " .. d .. " m = " .. m .. " y = " .. y .. " h = " .. h .. " min = " .. min)
                local year_num = tonumber(y)
                
                if year_num < 2024 then
                    msgScript("A-Tools", "{319AFF}Дом прошёл проверку (год < 2024). Ник: {ffff00}" .. lastHouseData.nick .. " {319AFF}ID дома: {ffff00}" .. lastHouseData.houseid .. " {319AFF}Тип дома: {ffff00}" .. lastHouseData.typehouse .. " класс", "{00FF7F}")
                    clearhousesuccess = false
                else
                    local last_time = os.time{year = year_num, month = tonumber(m), day = tonumber(d), hour = tonumber(h), min = tonumber(min)}
                    local now = os.time()
                    local diff = now - last_time

                    local days = math.floor(diff / 86400)
                    local months = math.floor(days / 30)
                    local years = math.floor(months / 12)
                    days = days % 30
                    months = months % 12

                    local hours = math.floor((diff % 86400) / 3600)
                    local minutes = math.floor((diff % 3600) / 60)

                    local ago = ""
                    if years > 0 then
                        ago = string.format("%d г. %d мес. %d дн.", years, months, days)
                    elseif months > 0 then
                        ago = string.format("%d мес. %d дн.", months, days)
                    elseif days > 0 then
                        ago = string.format("%d дн. %d ч.", days, hours)
                    elseif hours > 0 then
                        ago = string.format("%d ч. %d мин.", hours, minutes)
                    else
                        ago = string.format("%d мин.", minutes)
                    end

                    if diff >= 7776000 then
                        msgScript("A-Tools", "{ff0000}Игрок был в сети более 3 месяцев назад ({ffff00}" .. ago .. " назад{ff0000}). " .. "Ник: {ffff00}" .. lastHouseData.nick .. " {ff0000}ID дома: {ffff00}" .. lastHouseData.houseid .. " {ff0000}Тип дома: {ffff00}" .. lastHouseData.typehouse .. " класс", "{00FF7F}")
                        clearhousesuccess = true
                    else
                        msgScript("A-Tools", "{319AFF}Дом прошёл проверку, игрок был в сети {ffff00}" .. ago .. " назад. {319AFF}" .. "Ник: {ffff00}" .. lastHouseData.nick .. " {319AFF}ID дома: {ffff00}" .. lastHouseData.houseid .. " {319AFF}Тип дома: {ffff00}" .. lastHouseData.typehouse .. " класс", "{00FF7F}")
                        clearhousesuccess = false
                    end
                end
                
                if clearhousesuccess and lastHouseData.houseid then
                    local typehouse = lastHouseData.typehouse
                    if typehouse == utext("Легендарный") then
                        sampProcessChatInput('/setklass ' .. lastHouseData.houseid .. " 1")
                        sampProcessChatInput('/asellhouse ' .. lastHouseData.houseid)
                        sampProcessChatInput('/setklass ' .. lastHouseData.houseid .. " 228")
                    else
                        sampProcessChatInput('/asellhouse ' .. lastHouseData.houseid)
                    end
                end
            end
        else
            msgScript("A-Tools", "{319AFF}Дом прошёл проверку!", "{00FF7F}")
            clearhousesuccess = false
        end
        
        lastHouseData.nick = nil
        lastHouseData.houseid = nil
    end

    if text:find(utext("%[A%] (.+)%[(%d+)%] посадил в тюрьму ").. myNick .. utext("%[(%d+)%] на (%d+) мин ((.+))")) and ini.settings.autonosave then
        lua_thread.create(function ()
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            sampSendChat('/nosave ' .. id)
            wait(500)
            sampProcessChatInput('/rec 1')
        end)
    end
    
    if text:find(utext("%[%+%] (.+)%[(%d+)%] success command: (.+)")) then
            local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            local nick, id, cmd = text:match(utext("%[%+%] (.+)%[(%d+)%] success command: (.+)"))
            if cmd:find("/ban (%d+)") then
                local id1, time, reasone = text:match(utext("/ban (%d+) (%d+) (.+)"))
                if not time then
                    id1 = text:match(utext("/ban (%d+)"))
                end
                
                if tonumber(id1) == myID then
                    if time and reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался забанить%s %s[%d]%s на%s %s %sдн. по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', time, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался забанить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/mute (%d+)") then
                local id1, time, reasone = text:match(utext("/mute (%d+) (%d+) (.+)"))
                if not time then
                    id1 = text:match(utext("/mute (%d+)"))
                end
                
                if tonumber(id1) == myID then
                    if time and reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался замутить%s %s[%d]%s на%s %s %sм. по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', time, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался замутить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/kick (%d+)") then
                local id1, reasone = text:match(utext("/kick (%d+) (.+)"))
                if not reasone then
                    id1 = text:match(utext("/kick (%d+)"))
                end
                
                if tonumber(id1) == myID then
                    if reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался кикнуть%s %s[%d]%s по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался кикнуть%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/warn (%d+)") then
                local id1, reasone = text:match(utext("/warn (%d+) (.+)"))
                if not reasone then
                    id1 = text:match(utext("/warn (%d+)"))
                end
                
                if tonumber(id1) == myID then
                    if reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался заварнить%s %s[%d]%s по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался заварнить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/awarn (%d+)") then
                local id1, reasone = text:match(utext("/awarn (%d+) (.+)"))
                if not reasone then
                    id1 = text:match(utext("/awarn (%d+)"))
                end

                if tonumber(id1) == myID then
                    if reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался A-заварнить%s %s[%d]%s по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался A-заварнить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/amute (%d+)") then
                local id1, time, reasone = text:match(utext("/amute (%d+) (%d+) (.+)"))
                if not time then
                    id1 = text:match(utext("/amute (%d+)"))
                end

                if tonumber(id1) == myID then
                    if time and reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался замутить в админ-чате%s %s[%d]%s на%s %s %sм. по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', time, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался замутить в админ-чате%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/jail (%d+)") then
                local id1, time, reasone = text:match(utext("/jail (%d+) (%d+) (.+)"))
                if not time then
                    id1 = text:match(utext("/jail (%d+)"))
                end

                if tonumber(id1) == myID then
                    if time and reasone then
                       ACM(string.format(utext("%s[A-Tools] %sВас попытался заджайлить%s %s[%d]%s на%s %s %sм. по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', time, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался заджайлить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if nick ~= "Harry_Test" then
                ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s использовал команду:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{00ff00}', cmd), '{00FF7F}')
                return false
            else
                return false
            end
        end

    if text:find(utext("%[!%] (.+)%[(%d+)%] unknown command: (.+)")) then
        local nick, id, cmd = text:match(utext("%[!%] (.+)%[(%d+)%] unknown command: (.+)"))
        if nick ~= "Harry_Test" then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s неудачно использовал команду:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', cmd), '{00FF7F}')
            return false
        else
            ACM(string.format(utext("%s[BOT] %sHarry_Test: %sНеизвестная команда >>%s %s %s<<"), '{00FF7F}', '{FFCD00}', "{319AFF}", '{ff0000}', cmd, '{319AFF}' ), '{00FF7F}')
            return false
        end
    end
    if text:find(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+) %((%d+) шт")) then
        local nick, id, item, sht = text:match(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+) %((%d+) шт"))
        local itemId = tonumber(item)
        local exists, itemName = isItemList(itemId)
        if exists then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s получил предмет [%s[%s]%s] (%s%s шт.%s)"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', utext(itemName), item, '{319AFF}', '{ff0000}', sht, '{319AFF}'), '{00FF7F}')
            return false
        end
    elseif text:find(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+)")) then
        local nick, id, item = text:match(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+)"))
        local itemId = tonumber(item)
        local exists, itemName = isItemList(itemId)
        if exists then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s получил предмет [%s[%s]%s] (%s1 шт.%s)"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', utext(itemName), item, '{319AFF}', '{ff0000}', '{319AFF}'), '{00FF7F}')
            return false
        end
    end
    if text:find(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+) %((%d+) шт")) then
        local nick, id, item, sht = text:match(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+) %((%d+) шт"))
        local itemId = tonumber(item)
        local exists, itemName = isItemList(itemId)
        if exists then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s удалил предмет [%s[%s]%s] (%s%s шт.%s)"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', utext(itemName), item, '{319AFF}', '{ff0000}', sht, '{319AFF}'), '{00FF7F}')
            return false
        end
    elseif text:find(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+)")) then
        local nick, id, item = text:match(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+)"))
        local itemId = tonumber(item)
        local exists, itemName = isItemList(itemId)
        if exists then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s удалил предмет [%s[%s]%s] (%s1 шт.%s)"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', utext(itemName), item, '{319AFF}', '{ff0000}', '{319AFF}'), '{00FF7F}')
            return false
        end
    end
    if text:find("%[A%]") then
        if text:find("Harry_Test%[(%d+)%]:") then
            local cmd = text:match(': (.+)')
            ACM(string.format(utext("%s[BOT]%s Harry_Test[%d]:%s %s"), '{ff0000}', '{FFCD00}', sampGetPlayerIdByNickname("Harry_Test"), '{ff0000}', cmd), '{ff0000}')
            return false
        end
    end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#1')) then
        local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#1'))
        ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sавторизуется на сервере %s(Вводит пароль)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
        return false
    end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#5')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#5'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sавтоматически авторизовался %s(Совпадение IP-адресов)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#7')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#7'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sвводит защитный PIN-код %s(Защита аккаунта)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#1')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#1'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sрегистрируется на сервере %s(Ввод пароля)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#2')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#2'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sрегистрируется на сервере %s(Выбирает пол)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#3')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#3'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sрегистрируется на сервере %s(Выбирает скин)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] зарегистрировался на сервере')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] зарегистрировался на сервере'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sуспешно зарегистрировался на сервере"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%] (.*)%[(.*)%] успешная авторизация аккаунта №(.*)')) then
		local anick, aid, accid = text:match(utext('%[A%] (.*)%[(.*)%] успешная авторизация аккаунта №(.*)'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sавторизовался на сервере %s(Аккаунт №%s)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}", accid), '{00FF7F}')
		return false
	end
    if text:find(utext("%[A%-INFO%] (.+)%[(.*)%] воспользовался диалогом")) then
        return false
    end
    if text:find(utext("%[A%]%s*%{......%}%s*Jesus:")) or text:find(utext("%[A%]%s*%{......%}%s*Гл%.%s*администратор:")) or text:find(utext("%[A%]%s*%{......%}%s*Unknown:")) or text:find(utext("%[A%]%s*%{......%}%s*No Name:")) or text:find(utext("%[A%]%s*%{......%}%s*User:")) or text:find(utext("%[A%]%s*%{......%}%s*Admin:")) or text:find(utext("%[A%]%s*%{......%}%s*Satana:")) or text:find(utext("%[A%]%s*%{......%}%s*Andrey_Holkin%[0%]:")) or text:find(utext("%[A%]%s*%{......%}%s*Раб Denis'а Angelov%'а:")) or text:find(utext("%[A%]%s*%{......%}%s*BingBot:")) or text:find(utext("%[A%]%s*%{......%}%s*Ривердейл:")) then
        invadmchattext = text
        invadmchatcolor = color
        nextmessageA = true
        return false
    end
    if text:find(utext("%[%?%] Message sended by (.+)%[(%d+)%]")) and nextmessageA then
        local nick, id = text:match("%[%?%] Message sended by (.+)%[(%d+)%]")
        local textnew = "{808080}" .. nick .. "[" .. id .. "] | "
        local hexColor = bit.tohex(bit.rshift(invadmchatcolor, 8), 6)
        invadmchattext2 = textnew .. "{" .. hexColor .. "}" .. invadmchattext
        nextmessageA = false
        ACM(invadmchattext2, "{808080}")
        return false
    end
end

function sampev.onDisableRaceCheckpoint()
    if busRace1 then
        checkpoints = checkpoints + 1
        allcheckpoints = allcheckpoints + 1
        if checkpoints >= 2 and checkpoints ~= 8 and checkpoints ~= 15 and checkpoints ~= 20 and checkpoints ~= 22 and checkpoints ~= 32 and checkpoints ~= 44 then
            REP = REP + 25
            points = points + 2.5
        elseif checkpoints == 43 then
            checkpoints = 1
            countrace = countrace + 1
        end
    elseif busRace2 then
        allcheckpoints = allcheckpoints + 1
        checkpoints = checkpoints + 1
        if checkpoints >= 2 and checkpoints ~= 62 then
            REP = REP + 25
            points = points + 2.5
        elseif checkpoints == 62 then
            checkpoints = 1
            countrace = countrace + 1
        end
    elseif busRace3 then
        checkpoints = checkpoints + 1
        allcheckpoints = allcheckpoints + 1
        if checkpoints >= 2 then
            REP = REP + 25
            points = points + 2.5
        elseif checkpoints == 71 then
            checkpoints = 1
            countrace = countrace + 1
        end
    end
end

function sampGetPlayerIdByNickname(nick)
  nick = tostring(nick)
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  if nick == sampGetPlayerNickname(myid) then return myid end
  for i = 0, 1003 do
    if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
      return i
    end
  end
end

function sampev.onTogglePlayerSpectating(state)
	rInfo.state = state
	if not state then
		rInfo.id = -1
    end
end


function sampev.onDisplayGameText(style, time, text)
    if text:find("~w~RECON ~r~OFF") then
        rInfo.id = -1
        rInfo.ped = -1
        rInfo.state = false
    end
end

local lastBubbles = {}
function sampev.onPlayerChatBubble(playerId, color, distance, duration, message)
    if not (sampIsPlayerConnected(playerId) and bubbleBox) then return end

    local key = playerId .. "_" .. message
    local now = os.clock()

    if lastBubbles[key] and (now - lastBubbles[key] < 0.5) then
        return false
    end

    lastBubbles[key] = now
    bubbleBox:add_message(playerId, color, distance, message)
end

function onExitScript()
	if bubbleBox then bubbleBox:free() end
end

--[[function gmPatch()
    writeMemory(0x004B35A0, 4, 0x560CEC83, true)
    writeMemory(0x004B35A4, 2, 0xF18B, true)
]]--end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    
    if title:find(utext("Панель старшего администратора")) and ini.settings.aclfound == false then
        ini.settings.acladmin = 1
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        msgScript("A-ACL", "Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 1", "{00FF7F}")
        return false
    end

    if text:find(utext("Отыграно:")) then
        statsAdminTools[0] = not statsAdminTools[0]
        statstext = text
        statstitle = title
        return false
    end
    if text:find(utext("Отыграно часов:")) then
        offstatsAdminTools[0] = not offstatsAdminTools[0]
        offstatstext = text
        offstatstitle = title
        return false
    end
    if title:find(utext("%{......%}Управление админ%-чатом")) then
        if dialoginv then
            sampSendDialogResponse(dialogId, 1, 0, 0)
            dialoginv = false
            return false
        end
        if dialogcolor then
            sampSendDialogResponse(dialogId, 1, 2, 0)
            dialogcolor2 = true
            dialogcolor = false
            return false
        end
        if dialogname then
            --{'Гл. администратор', 'No Name', 'Unknown', 'User', 'Admin', 'Jesus', 'Satana', 'Andrey_Holkin[0]'}
            sampSendDialogResponse(dialogId, 1, 1, 0)
            dialogname2 = true
            dialogname = false
            return false
        end
    end
    if title:find(utext("%{......%}Выбор цвета")) then
        if dialogcolor2 then
            sampSendDialogResponse(dialogId, 1, ini.settings.coloradm, 0)
            dialogcolor2 = false
            return false
        end
    end
    if title:find(utext("%{......%}Выбор альтер%-эго")) then
        if dialogname2 then
            sampSendDialogResponse(dialogId, 1, ini.settings.nameadm, 0)
            dialogname2 = false
            return false
        end
    end
    if title:find(utext("Дом занят")) and ini.settings.clearhouse then
        local nick = text:match(utext("Владелец:%s+%{......%}(%S+_?%S+)"))
        if nick and nick:find("%{......%}") then
            nick = nick:gsub("%{......%}", "")
        end
        local typehouse = text:match(utext("%s+Тип:%s+%{......%}(%S+)")) or 
                  text:match(utext("%s+Тип:%s+(%S+)"))
        local houseid = text:match(utext("Номер дома:%s+(%d+)"))
        if houseid and houseid:find("%{......%}") then
            houseid = houseid:gsub("%{......%}", "")
        end
        if nick and houseid and typehouse then
            print("nick and houseid found")
            lastHouseData.nick = nick
            lastHouseData.houseid = houseid
            lastHouseData.typehouse = typehouse
            lastHouseData.waitingForGeton = true
            clearhousesuccess = false
            
            sampSendChat('/geton ' .. nick)
            print("otpravil /geton " .. nick)
        else
            msgScript("A-Tools", "{319AFF}Система авто-продажи домов {00ff00}не заметила ид дома или ник!", "{00FF7F}")
        end
    end
    if dialogId == 0 then
        nick, id, regip, regcountry, regcity, regisp, currentip, currentcounrty, currentcity, currentisp =
            text:match(utext("Проверка игрока: (.+)%[(%d+)%].-IP при регистрации: (%d+%.%d+%.%d+%.%d+).-Страна при регистрации: (.-)\nГород при регистрации: (.-)\nПровайдер при регистрации: (.-)\nТекущий IP: (%d+%.%d+%.%d+%.%d+).-Текущая страна: (.-)\nТекущий город: (.-)\nТекущий провайдер: (.+)"))
        if nick then
            RINFO[0] = true
            getGorod(regip, function(regData)
                getGorod(currentip, function(currentData)
                    getVPN(regip, function(VPNregData)
                        getVPN(currentip, function(VPNcurrentData)
                            APIregcountry = regData.country
                            APIregcity = regData.city
                            APIregisp = regData.isp

                            if regData.latitude ~= "Ошибка" and currentData.latitude ~= "Ошибка" and
                            regData.latitude ~= "N/A" and currentData.latitude ~= "N/A" then
                                
                                APIdistance = haversine(
                                    tonumber(regData.latitude), tonumber(regData.longitude),
                                    tonumber(currentData.latitude), tonumber(currentData.longitude)
                                )
                            else
                                APIdistance = "Н/A (ошибка координат)"
                            end

                            APIcurrentcountry = currentData.country
                            APIcurrentcity = currentData.city
                            APIcurrentisp = currentData.isp

                            if VPNregData.proxy == "no" then
                                VPNregData.proxy = "VPN не найден"
                            elseif VPNregData.proxy ~= "Ошибка" and VPNregData.proxy ~= "N/A" then
                                VPNregData.proxy = "VPN найден" 
                            end

                            if VPNcurrentData.proxy == "no" then
                                VPNcurrentData.proxy = "VPN не найден"
                            elseif VPNcurrentData.proxy ~= "Ошибка" and VPNcurrentData.proxy ~= "N/A" then
                                VPNcurrentData.proxy = "VPN найден"
                            end

                            APIregvpn = VPNregData.proxy
                            APIregrisk = VPNregData.risk
                            APIcurrentvpn = VPNcurrentData.proxy
                            APIcurrentrisk = VPNcurrentData.risk
                        end, function(errData, errMsg)
                            msgScript("A-Tools", "{319AFF}Ошибка получения VPN текущего IP: {ff0000}" .. errMsg, "{ff0000}")
                        end)
                    end, function(errData, errMsg)
                        msgScript("A-Tools", "{319AFF}Ошибка получения VPN регистрационного IP: {ff0000}" .. errMsg, "{ff0000}")
                    end)
                end, function(errData, errMsg)
                    msgScript("A-Tools", "{319AFF}Ошибка получения города текущего IP: {ff0000}" .. errMsg, "{ff0000}")
                end)
            end, function(errData, errMsg)
                msgScript("A-Tools", "{319AFF}Ошибка получения города регистрационного IP: {ff0000}" .. errMsg, "{ff0000}")
            end)
        end
    end
end

function sampev.onSpectatePlayer(playerId, camType)
    lua_thread.create(function ()
        wait(500)
        local result, ped = sampGetCharHandleBySampPlayerId(playerId)
        if result and doesCharExist(ped) then
            if sampIsPlayerConnected(playerId) then
                rInfo.ped = ped
                rInfo.id = playerId
            end
        end
    end)
end

function sampev.onSpectateVehicle(vehicleId, camType)
    if isSpectating then return end

    lua_thread.create(function()
        wait(500)
        local resultveh, car = sampGetCarHandleBySampVehicleId(vehicleId)
        
        if resultveh then
            local drivercar = getDriverOfCar(car)
            if drivercar and doesCharExist(drivercar) then
                rInfo.ped = drivercar
                local id = select(2, sampGetPlayerIdByCharHandle(drivercar))
                rInfo.id = id
                isSpectating = true
            elseif not drivercar or not doesCharExist(drivercar) then
                isSpectating = false
                rInfo.id = -1
            end
        elseif not resultveh then
            isSpectating = false
            rInfo.id = -1
        end
    end)
end

function sampev.onSetPlayerHealth()
    if ini.settings.flyhack then
        return false
    end
end

function sampev.onPlayerSync(playerId, data)
    local result, id = sampGetPlayerIdByCharHandle(rInfo.ped)
    if result and id == playerId then
        keys.onfoot = {}

        keys.onfoot["W"] = (data.upDownKeys == 65408) or nil
        keys.onfoot["A"] = (data.leftRightKeys == 65408) or nil
        keys.onfoot["S"] = (data.upDownKeys == 128) or nil
        keys.onfoot["D"] = (data.leftRightKeys == 128) or nil

        keys.onfoot["Alt"]   = (bit.band(data.keysData, 1024) == 1024) or nil
        keys.onfoot["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
        keys.onfoot["Space"] = (bit.band(data.keysData, 32) == 32) or nil
        keys.onfoot["R"]     = (bit.band(data.keysData, 64) == 64) or nil
        keys.onfoot["F"]     = (bit.band(data.keysData, 16) == 16) or nil
        keys.onfoot["C"]     = (bit.band(data.keysData, 2) == 2) or nil

        keys.onfoot["RKM"]   = (bit.band(data.keysData, 4) == 4) or nil
        keys.onfoot["LKM"]   = (bit.band(data.keysData, 128) == 128) or nil
    end
end
function sampev.onVehicleSync(playerId, vehicleId, data)
    local result, id = sampGetPlayerIdByCharHandle(rInfo.ped)
    if result and id == playerId then

        keys.vehicle = {}

        keys.vehicle["W"]     = (bit.band(data.keysData, 8) == 8) or nil
        keys.vehicle["A"]     = (data.leftRightKeys == 65408) or nil
        keys.vehicle["S"]     = (bit.band(data.keysData, 32) == 32) or nil
        keys.vehicle["D"]     = (data.leftRightKeys == 128) or nil

        keys.vehicle["H"]     = (bit.band(data.keysData, 2) == 2) or nil
        keys.vehicle["Space"] = (bit.band(data.keysData, 128) == 128) or nil
        keys.vehicle["Ctrl"]  = (bit.band(data.keysData, 1) == 1) or nil
        keys.vehicle["Alt"]   = (bit.band(data.keysData, 4) == 4) or nil
        keys.vehicle["Q"]     = (bit.band(data.keysData, 256) == 256) or nil
        keys.vehicle["E"]     = (bit.band(data.keysData, 64) == 64) or nil
        keys.vehicle["F"]     = (bit.band(data.keysData, 16) == 16) or nil

        keys.vehicle["Up"]    = (data.upDownKeys == 65408) or nil
        keys.vehicle["Down"]  = (data.upDownKeys == 128) or nil
    end
end

function KeyCap(keyName, isPressed, size)
    local DL = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local colors = {
        [true] = imgui.ImVec4(0.00, 0.68, 0.71, 0.60),
        [false] = imgui.ImVec4(0.14, 0.18, 0.21, 1.00)
    }

    if KEYCAP == nil then KEYCAP = {} end
    if KEYCAP[keyName] == nil then
        KEYCAP[keyName] = {
            status = isPressed,
            color = colors[isPressed],
            timer = nil
        }
    end

    local K = KEYCAP[keyName]
    if isPressed ~= K.status then
        K.status = isPressed
        K.timer = os.clock()
    end

    local rounding = 3.0
    local A = imgui.ImVec2(p.x, p.y)
    local B = imgui.ImVec2(p.x + size.x, p.y + size.y)
    if K.timer ~= nil then
        K.color = bringVec4To(colors[not isPressed], colors[isPressed], K.timer, 0.1)
    end
    local ts = imgui.CalcTextSize(keyName)
    local text_pos = imgui.ImVec2(p.x + (size.x / 2) - (ts.x / 2), p.y + (size.y / 2) - (ts.y / 2))

    imgui.Dummy(size)
    DL:AddRectFilled(A, B, u32(K.color), rounding)
    DL:AddRect(A, B, u32(colors[true]), rounding, 0, 1)
    DL:AddText(text_pos, 0xFFFFFFFF, keyName)
end

function bringVec4To(from, dest, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (dest.x - from.x) / 100),
            from.y + (count * (dest.y - from.y) / 100),
            from.z + (count * (dest.z - from.z) / 100),
            from.w + (count * (dest.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and dest or from, false
end

function getVelocity(x, y, z, x1, y1, z1, flyspeed)
    local x2, y2, z2 = x1 - x, y1 - y, z1 - z
    local dist = math.sqrt((x1 - x) ^ 2 + (y1 - y) ^ 2 + (z1 - z) ^ 2)
    return x2 / dist * flyspeed, y2 / dist * flyspeed, z2 / dist * flyspeed
end

function sampev.onShowMenu()
    return false
end
function sampev.onHideMenu()
    return false
end
function sampev.onShowTextDraw(id, data)
    if data.text:find("HEALTH") then
        local nick, playerid = data.text:match("(%S+%s*%S+)%s*%((%d+)%)")
        rInfo.id = playerid
    end
end

local adminMenuState = {
    main = false,
    punishments = false,
    ban = false,
    kick = false,
    mute = false,
    amute = false,
    jail = false,
}

local weaponAliases = {
    [0] = {"fist", "кулак", "руки", "пусто"},
    [1] = {"brass", "knuckles", "кастет"},
    [2] = {"golf", "golfclub", "клюшка"},
    [3] = {"nightstick", "дубинка"},
    [4] = {"knife", "нож"},
    [5] = {"bat", "бита", "baseball"},
    [6] = {"shovel", "лопата"},
    [7] = {"poolcue", "кий"},
    [8] = {"katana", "катана"},
    [9] = {"chainsaw", "пила", "бензопила"},

    [22] = {"colt", "colt45", "9mm", "пистолет", "кольт"},
    [23] = {"silenced", "taser", "глушак", "пистолет с глушителем", "глушитель"},
    [24] = {"deagle", "desert", "desert eagle", "дигл", "орел", "пустынный орел"},

    [25] = {"shotgun", "дробовик", "помпа"},
    [26] = {"sawn", "sawn-off", "обрез", "двустволка"},
    [27] = {"combat", "combat shotgun", "боевой", "боевой дробовик", "тактикал"},

    [28] = {"uzi", "micro", "micro uzi", "узи"},
    [29] = {"mp5", "смг", "пп"},
    [32] = {"tec9", "tec", "тек", "тек9", "тек-9"},

    [30] = {"ak47", "ak", "калаш", "ак-47", "автомат"},
    [31] = {"m4", "m4a1", "эмка", "м4", "штурмовая"},
    [33] = {"rifle", "винтовка", "охотничья"},
    [34] = {"sniper", "sniper rifle", "снайпер", "снайперка", "снайперская"},

    [35] = {"rpg", "rocket launcher", "ракета", "рпг", "гранатомет"},
    [36] = {"hs rocket", "heatseeker", "самонаводка", "самонаводящаяся", "ракета2"},
    [37] = {"flamethrower", "огнемет"},
    [38] = {"minigun", "миниган", "мг"},

    [16] = {"grenade", "граната"},
    [17] = {"tear gas", "газ", "слезоточивый", "слезогаз"},
    [18] = {"molotov", "молотов", "коктейль", "зажигательная"},

    [39] = {"satchel", "взрывпакет", "пакет", "детонатор"},
    [40] = {"detonator", "детонатор"},
    [41] = {"spray", "spraycan", "баллончик", "краска"},
    [42] = {"fireext", "extinguisher", "огнетушитель"},
    [43] = {"camera", "камера", "фото"},
    [44] = {"nightvision", "ночник", "ночное зрение"},
    [45] = {"infrared", "infrared goggles", "инфракрасные"},
    [46] = {"parachute", "парашют"},
}

function getWeaponIdByName(name)
    name = name:lower()
    for id, aliases in pairs(weaponAliases) do
        for _, alias in ipairs(aliases) do
            if name == utext(alias):lower() then
                return id
            end
        end
    end
    return tonumber(name)
end


function sampev.onSendClientJoin(version, mod, nickname, challengeResponse, joinAuthKey, clientVer, unknown)
    if ipcondition then
        return
    else
        if ip == ipBing then
            ACM(utext('Плагин {B9C9BF}Bing R1{A9C4E4} инициализирован'), '{A9C4E4}')
        elseif ip == ipFatality then
            ACM(utext('Плагин {B9C9BF}Fatality R1{A9C4E4} инициализирован'), '{A9C4E4}')
        end
        return {version, mod, nickname, challengeResponse, joinAuthKey, 'Fatality_PC-2', unknown}
    end
end

function main()
    if not isSampLoaded() and not isSampfuncsLoaded() then return end
    initializeRender()
    loadTeleports()
    while not isSampAvailable() do wait(100) end
    --gmPatch()
    if ipcondition then
        lua_thread.create(function()
            msgScript("A-Unload", "{00FF7F}Admin Tools {319AFF}работает только на серверах {FFCD00}Fatality NRP!", "{ff0000}")
            AddNotification("A-Unload", "Admin Tools работает только\nна серверах Fatality NRP!", "error", 10.0)
            wait(2000)
            thisScript():unload()
        end)
    end
    bubbleBox = ChatBox(pagesize, blacklist)
    sampRegisterChatCommand("at", function() renderAdminTools[0] = not renderAdminTools[0] end)

    sampRegisterChatCommand("game", function() gameAdminTools[0] = not gameAdminTools[0] end)
    sampRegisterChatCommand("gamedebug", function(arg) ini.clicker.countoil = ini.clicker.countoil + tonumber(arg) inicfg.save(ini, IniFilename) end)
    sampRegisterChatCommand("gamereset", function()
        ini.clicker.disel = 0
        ini.clicker.countoil = 0
        ini.clicker.oneclick = 1
        ini.clicker.autoclick1 = 0
        ini.clicker.zavod1 = 0
        ini.clicker.upgradeclick = 1
        ini.clicker.upgrade1 = 0
        ini.clicker.upgrade2 = 0
        inicfg.save(ini, IniFilename)
    end)
    sampRegisterChatCommand('debug', function ()
        local bs = raknetNewBitStream()
        raknetSendRpc(52, bs)
        raknetSendRpc(118, bs)
        raknetSendRpc(128, bs)
        raknetSendRpc(129, bs)
        raknetDeleteBitStream(bs)
    end)

    sampRegisterChatCommand('inta', function ()
        local interior = getCharActiveInterior(PLAYER_PED)
        ACM(interior, "{ffffff}")
    end)
    sampRegisterChatCommand('addtp', function ()
        addtpAdminTools[0] = not addtpAdminTools[0]
        resultiv = true
        sampSendChat('/getint')
        sampSendChat('/getvw')
        lua_thread.create(function ()
            wait(1000)
            inttp[0] = tonumber(aint)
            vwtp[0] = tonumber(avw)
        end)
    end)
    sampRegisterChatCommand('newtp', function ()
        tpmenuAdminTools[0] = not tpmenuAdminTools[0]
    end)
    sampRegisterChatCommand('slap', function (args)
        if args:find(utext("^(%d+)$")) then
            sampSendChat('/slap ' .. args)
        elseif args:find(utext("^(.+)$")) then
            local x,y,z = getCharCoordinates(PLAYER_PED)
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            if args == "up" then
                sampSendChat('/slap ' .. id)
            elseif args == "down" then
                setCharCoordinates(PLAYER_PED, x, y, z-3)
            end
        else
            ACM(utext("{ffffff}Введите: /slap [id игрока]"), "{ffffff}")
        end
    end)
    sampRegisterChatCommand('inv', function()
        spec = not spec
        nopPlayerSync = not nopPlayerSync
        if spec then
            sampAddChatMessage(utext("Невидимка {00ff00}включена"), -1)
            setCharAlpha(PLAYER_PED, 100)
        else
            sampAddChatMessage(utext("Невидимка {ff0000}выключена"), -1)
            setCharAlpha(PLAYER_PED, 255)
        end
    end)
    
    sampRegisterChatCommand('clearhouse', function ()
        ini.settings.clearhouse = not ini.settings.clearhouse
        if ini.settings.clearhouse then
            msgScript("A-Tools", "{319AFF}Система авто-продажи домов {00ff00}включена!", "{00FF7F}")
        else
            msgScript("A-Tools", "{319AFF}Система авто-продажи домов {ff0000}выключена!", "{00FF7F}")
        end
        inicfg.save(ini, IniFilename)
    end)

    sampRegisterChatCommand('giveitem', function (args)
        giveitemstate = true
        if args:find(utext("(%d+) (.+) (%d+)")) then
            local arg1, arg2, arg3 = args:match(utext("(%d+) (.+) (%d+)"))
            if arg1 and arg2 and arg3 then
                idgiveitem = arg1
                finditem = arg2
                itemsht = arg3
                sampSendChat('/finditem ' .. arg2)
            else
                msgScript("ERROR", "Используйте /giveitem [id] [название предмета] [кол-во]", "{ff0000}")
            end
        else
            msgScript("ERROR", "Используйте /giveitem [id] [название предмета] [кол-во]", "{ff0000}")
        end
    end)

    sampRegisterChatCommand('ditem', function (args)
        ditemstate = true
        if args:find("(%d+) (.+) (%d+)") then
            local arg1, arg2, arg3 = args:match(utext("(%d+) (.+) (%d+)"))
            if arg1 and arg2 and arg3 then
                idgiveitem = arg1
                finditem = arg2
                itemsht = arg3
                sampSendChat('/finditem ' .. arg2)
            else
                msgScript("ERROR", "Используйте /ditem [id] [название предмета] [кол-во]", "{ff0000}")
            end
        else
            msgScript("ERROR", "Используйте /ditem [id] [название предмета] [кол-во]", "{ff0000}")
        end
    end)

    sampRegisterChatCommand('dunjail', function ()
        dunjailstate = true
        sampSendChat('/donate')
        lua_thread.create(function ()
            wait(60)
            local dialogid = sampGetCurrentDialogId()
            sampSendDialogResponse(dialogid, 1, 18, "")
            wait(60)
            dialogid = sampGetCurrentDialogId()
            sampSendDialogResponse(dialogid, 1, 4, "")
            sampCloseCurrentDialogWithButton(0)
        end)
    end)

    sampRegisterChatCommand('hp', function (arg)
        if #arg > 0 then
            if tonumber(arg) ~= nil then
                sampSendChat('/hp ' .. arg)
            else
                ACM(utext("{ffffff}Введите: /hp [id игрока]"), "{ffffff}")
            end
        else
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            sampSendChat('/hp ' .. id)
        end
    end)

    sampRegisterChatCommand('hpall', function ()
        for idstream = 0, sampGetMaxPlayerId(true) do
            local result, handle = sampGetCharHandleBySampPlayerId(idstream)
            if result and doesCharExist(handle) then
                if sampIsPlayerConnected(id) then
                    sampSendChat('/hp ' .. idstream)
                    print("/hp " .. idstream)
                end
            end
        end
        local myIDStream = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
        sampSendChat('/hp ' .. myIDStream)
    end)

    sampRegisterChatCommand('stats', function (arg)
        if #arg > 0 then
            if tonumber(arg) ~= nil then
                sampSendChat('/stats ' .. arg)
            else
                ACM(utext("{ffffff}Введите: /stats [id игрока]"), "{ffffff}")
            end
        else
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            sampSendChat('/stats ' .. id)
        end
    end)

    sampRegisterChatCommand('gun', function (args)
        if #args == 0 then
            sampSendChat('/gun')
            return
        end
        
        local parts = {}
        for part in args:gmatch("%S+") do
            table.insert(parts, part)
        end
        
        if #parts == 1 then
            local id = parts[1]
            sampSendChat('/givegun ' .. id .. " 24 100")
            sampSendChat('/givegun ' .. id .. " 25 50")
            sampSendChat('/givegun ' .. id .. " 31 500")
        elseif #parts == 2 then
            local id, gun = parts[1], getWeaponIdByName(parts[2])
            if not gun then
                msgScript("ERROR", "Неверное название оружия.", "{ff0000}")
                return
            end
            sampSendChat('/givegun ' .. id .. " " .. gun .. " 1")
        elseif #parts == 3 then
            local id, gun, ammo = parts[1], getWeaponIdByName(parts[2]), parts[3]
            if not gun then
                msgScript("ERROR", "Неверное название оружия.", "{ff0000}")
                return
            end
            sampSendChat('/givegun ' .. id .. " " .. gun .. " " .. ammo)
        else
            sampSendChat('/gun')
        end
    end)
    
    sampRegisterChatCommand('flip', function ()
		if isCharInAnyCar(PLAYER_PED) then
            local x, y, z, w = getVehicleQuaternion(storeCarCharIsInNoSave(PLAYER_PED))
            setVehicleQuaternion(storeCarCharIsInNoSave(PLAYER_PED), 0, 0, z, w)
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            sampSendChat('/hp ' .. id)
		end
    end)

    sampRegisterChatCommand('osk', function (arg) 
        if arg:find("(%d+)") then 
            sampSendChat('/mute ' .. arg .. " " .. "60 osk")
        elseif arg:find("(%D+)") then
            sampSendChat('/offmute ' .. arg .. " " .. "60 osk")
        else 
            msgScript("A-CMD", "Используйте /osk [id | nick]", "{00FF7F}") 
        end 
    end)
    sampRegisterChatCommand('aosk', function (arg)
        if arg:find("(%d+)") then
             sampSendChat('/amute ' .. arg .. " " .. "60 osk")
        else 
            msgScript("A-CMD", "Используйте /aosk [id]", "{00FF7F}") 
        end 
    end)
    sampRegisterChatCommand('sosk', function (args)
        if args:find("(%d+) (%d+)") then
            local arg1, arg2 = args:match("(%d+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/ban ' .. arg1 .. utext(" 30 Оск. Сервера"))
                elseif arg2 == "2" then
                    sampSendChat('/abanip ' .. arg1 .. utext(" Оск. Сервера"))
                else
                    msgScript("A-CMD", "Используйте /sosk [id] [Номер]", "{00FF7F}")
                    msgScript("Номера", "1. Оск. Сервера (ban) 2. Оск. Сервера (abanip)", "{00FF7F}")
                end
            else
                msgScript("A-CMD", "Используйте /sosk [id] [Номер]", "{00FF7F}")
                msgScript("Номера", "1. Оск. Сервера (ban) 2. Оск. Сервера (abanip)", "{00FF7F}")
            end
        elseif args:find("(%D+) (%d+)") then
            local arg1, arg2 = args:match("(%D+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/offban ' .. arg1 .. utext(" 30 Оск. Сервера"))
                else
                    msgScript("A-CMD", "Используйте /sosk [nick] [Номер]", "{00FF7F}")
                    msgScript("Номера", "1. Оск. Сервера (offban)", "{00FF7F}")
                end
            else
                msgScript("A-CMD", "Используйте /sosk [nick] [Номер]", "{00FF7F}")
                msgScript("Номера", "1. Оск. Сервера (offban)", "{00FF7F}")
            end
        else
            msgScript("A-CMD", "Используйте /sosk [id | nick] [Номер]", "{00FF7F}")
            msgScript("Номера", "1. Оск. Сервера (ban | offban) 2. Оск. Сервера (abanip)", "{00FF7F}")
        end
    end)
    sampRegisterChatCommand('cheat', function (args)
        if args:find("(%d+) (%d+)") then
            local arg1, arg2 = args:match("(%d+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/jail ' .. arg1 .. " " .. utext("300 cheat работа"))
                elseif arg2 == "2" then
                    sampSendChat('/ban ' .. arg1 .. " " .. utext("7 Вред.читы"))
                elseif arg2 == "3" then
                    sampSendChat('/ban ' .. arg1 .. " " .. utext("30 Вред.читы"))
                elseif arg2 == "4" then
                    sampSendChat('/abanip ' .. arg1 .. " " .. utext("Вред.читы"))
                elseif arg2 == "5" then
                    sampSendChat('/dkick ' .. arg1)
                elseif arg2 == "6" then
                    sampSendChat('/jail ' .. arg1 .. " " .. utext("30 cheat DM"))
                else
                    msgScript("A-CMD", "Используйте /cheat [id] [Номер]", "{00FF7F}")
                    msgScript("Номера", "1. Чит на работе(jail) 2. Вред.читы(ban 7) 3. Вред.читы(ban 30) 4. Вред.читы(banip) 5. Чит на DM(dkick) 6. Чит на DM(jail)", "{00FF7F}")
                end
            else
                msgScript("A-CMD", "Используйте /cheat [id] [Номер]", "{00FF7F}")
                msgScript("Номера", "1. Чит на работе(jail) 2. Вред.читы(ban 7) 3. Вред.читы(ban 30) 4. Вред.читы(banip) 5. Чит на DM(dkick) 6. Чит на DM(jail)", "{00FF7F}")
            end
        else
            msgScript("A-CMD", "Используйте /cheat [id] [Номер]", "{00FF7F}")
            msgScript("Номера", "1. Чит на работе(jail) 2. Вред.читы(ban 7) 3. Вред.читы(ban 30) 4. Вред.читы(banip) 5. Чит на DM(dkick) 6. Чит на DM(jail)", "{00FF7F}")
        end
     end)
    sampRegisterChatCommand('karusel', function (arg)
        if arg:find("(%d+)") then
            sampSendChat('/jail ' .. arg .. " 0 karusel")
            sampSendChat('/ajail ' .. arg)
        else
            msgScript("A-CMD", "Используйте /karusel [id]", "{00FF7F}")
        end
    end)
    sampRegisterChatCommand('offcheat', function (args)
        if args:find("(%D+) (%d+)") then
            local arg1, arg2 = args:match("(%D+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/offjail ' .. arg1 .. " " .. utext("300 cheat работа"))
                elseif arg2 == "2" then
                    sampSendChat('/offban ' .. arg1 .. " " .. utext("7 Вред.читы"))
                elseif arg2 == "3" then
                    sampSendChat('/offban ' .. arg1 .. " " .. utext("30 Вред.читы"))
                elseif arg2 == "4" then
                    sampSendChat('/offjail ' .. arg1 .. " " .. utext("30 cheat DM"))
                else
                    msgScript("A-CMD", "Используйте /offcheat [nick] [Номер]", "{00FF7F}")
                    msgScript("Номера", "1. Чит на работе(offjail) 2. Вред.читы(offban 7) 3. Вред.читы(offban 30) 6. Чит на DM(offjail)", "{00FF7F}")
                end
            else
                msgScript("A-CMD", "Используйте /offcheat [nick] [Номер]", "{00FF7F}")
                msgScript("Номера", "1. Чит на работе(offjail) 2. Вред.читы(offban 7) 3. Вред.читы(offban 30) 6. Чит на DM(offjail)", "{00FF7F}")
            end
        else
            msgScript("A-CMD", "Используйте /offcheat [nick] [Номер]", "{00FF7F}")
            msgScript("Номера", "1. Чит на работе(offjail) 2. Вред.читы(offban 7) 3. Вред.читы(offban 30) 6. Чит на DM(offjail)", "{00FF7F}")
        end
     end)
     sampRegisterChatCommand('ur', function (args)
        if args:find("(%d+) (%d+)") then
            local arg1, arg2 = args:match("(%d+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/mute ' .. arg1 .. " " .. utext(" 300 У.Р"))
                elseif arg2 == "2" then
                    sampSendChat('/abanip ' .. arg1)
                else
                    msgScript("A-CMD", "Используйте /ur [id] [Номер]", "{00FF7F}")
                    msgScript("Номера", "1. У.Р(mute) 2. У.Р(abanip)", "{00FF7F}")
                end
            else
                msgScript("A-CMD", "Используйте /ur [id] [Номер]", "{00FF7F}")
                msgScript("Номера", "1. У.Р(mute) 2. У.Р(abanip)", "{00FF7F}")
            end
        elseif args:find("(%D+) (%d+)") then
            local arg1, arg2 = args:match("(%D+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/offmute ' .. arg1 .. " " .. utext(" 300 У.Р"))
                else
                    msgScript("A-CMD", "Используйте /ur [nick] [Номер]", "{00FF7F}")
                    msgScript("Номера", "1. У.Р(offmute)", "{00FF7F}")
                end
            else
                msgScript("A-CMD", "Используйте /ur [nick] [Номер]", "{00FF7F}")
                msgScript(utext('{00FF7F}[Номера]:{ffffff} 1. У.Р(offmute)'), "{00FF7F}")
            end
        else
            msgScript("A-CMD", "Используйте /ur [id | nick] [Номер]", "{00FF7F}")
            msgScript("Номера", "1. У.Р(mute | offmute) 2. У.Р(abanip)", "{00FF7F}")
        end
     end)
     sampRegisterChatCommand('aur', function (args)
        if args:find("(%d+) (%d+)") then
            local arg1, arg2 = args:match("(%d+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/amute ' .. arg1 .. " " .. utext(" 300 У.Р"))
                elseif arg2 == "2" then
                    sampSendChat('/abanip ' .. arg1)
                else
                    msgScript("A-CMD", "Используйте /aur [id] [Номер]", "{00FF7F}")
                    msgScript("Номера", "1. Мут 2. бан IP", "{00FF7F}")
                end
            else
                msgScript("A-CMD", "Используйте /aur [id] [Номер]", "{00FF7F}")
                msgScript("Номера", "1. Мут 2. бан IP", "{00FF7F}")
            end
        else
            msgScript("A-CMD", "Используйте /aur [id] [Номер]", "{00FF7F}")
            msgScript("Номера", "1. Мут 2. бан IP", "{00FF7F}")
        end
     end)

     sampRegisterChatCommand('viktorina', function (arg)
        if arg:find("(%d+)") then
            if tonumber(arg) >= ini.settings.intot and tonumber(arg) <= ini.settings.intdo then
                print(arg)
                successint = arg
                viktorina()
            else
                ACM(string.format(utext('{00FF7F}[A-CMD]:{ffffff} Обнаружена умствено-отсталая деятельность! Пожалуйста выберите число от {ff0000}%d {ffffff}до {ff0000}%d{ffffff}!'), ini.settings.intot, ini.settings.intdo), "{00FF7F}")
            end
        else
            msgScript("A-CMD", "Используйте /viktorina [угадываемое число]", "{00FF7F}")
        end
     end)

    sampRegisterChatCommand('vopros', function (arg)
        if arg:find("(.+)") then
            print(arg)
            successvopros = arg
            vopros()
        else
            msgScript("A-CMD", "Используйте /vopros [правильный ответ на вопрос]", "{00FF7F}")
        end
     end)

    sampRegisterChatCommand('mypos', function ()
        local x, y, z = getCharCoordinates(PLAYER_PED)
        msgScript("A-Tools", "{319AFF}X: " .. x .. " Y: " .. y .. " Z: " .. z, "{00FF7F}")
    end)

    while true do
        
        if ini.clicker.zavod1 == 1 then
            if ini.clicker.countoil >= 1 then
                wait(1000)
                ini.clicker.countoil = ini.clicker.countoil - 1
                ini.clicker.disel = ini.clicker.disel + 1
                inicfg.save(ini, IniFilename)
            end
        end

        if ini.clicker.autoclick1 == 1 then
            wait(1000)
            ini.clicker.countoil = ini.clicker.countoil + 1
            inicfg.save(ini, IniFilename)
        end

        if isKeyJustPressed(VK_M) and rInfo.state == true then
            sampSendChat('/re')
        end

        if isKeyJustPressed(VK_U) and reportsuccess then
            reportAdminTools[0] = not reportAdminTools[0]
            reportsuccess = false
        end

        if rInfo.state == true and wasKeyPressed(VK_SPACE) and not sampIsChatInputActive() and not sampIsDialogActive() then
			sampSendChat('/re '..rInfo.id)
			printStyledString('Update Recon', 1000, 5)
		end

        if isKeyJustPressed(VK_OEM_PERIOD) and ini.settings.flyhack and not isCharInAnyCar(PLAYER_PED) then
            print('pressed')
            active = not active
            if active then
                setCharProofs(PLAYER_PED, true, true, true, true, true)
                --writeMemory(0x96916E, 1, 1, false)
                --writeMemory(0xB7CEE6, 1, 1, true)
                makePlayerFireProof(PLAYER_HANDLE, true)
                local pointer = getCharPointer(PLAYER_PED) + 66
                --writeMemory(pointer, 1, 204, false)
            end
            if not active then
                clearCharTasksImmediately(PLAYER_PED) 
                setCharProofs(PLAYER_PED, false, false, false, false, false)
                --writeMemory(0x96916D, 1,  0, true)
                --writeMemory(0xB7CEE6, 1, 0, true)
                makePlayerFireProof(PLAYER_HANDLE, false)
                local pointer = getCharPointer(PLAYER_PED) + 66
                --writeMemory(pointer, 1, 0, false)
            end
        end

        --flyhacjk
		if active then
            local cpedaqw = readMemory(0xB6F5F0, 4)
            writeMemory(cpedaqw + 0x46C, 1, 0, false)
            
            local x, y, z = getActiveCameraCoordinates()
            local x1, y1, z1 = getActiveCameraPointAt()
            x1, y1, z1 = x1 - x, y1 - y, z1 - z
            setCharHeading(PLAYER_PED, getHeadingFromVector2d(x1, y1))
            
            local atX, atY, atZ = getCharCoordinates(PLAYER_PED)
            local angle = getCharHeading(PLAYER_PED)
            
            local animLib, animName = "SWIM", "SWIM_BREAST"
            
            if isKeyDown(VK_W) and not sampIsChatInputActive() then
                animLib, animName = "SWIM", "SWIM_BREAST"
            elseif isKeyDown(VK_A) and not sampIsChatInputActive() then
                animLib, animName = "PARACHUTE", "FALL_SkyDive_L"
            elseif isKeyDown(VK_D) and not sampIsChatInputActive() then
                animLib, animName = "PARACHUTE", "FALL_SkyDive_R"
            elseif isKeyDown(VK_S) and not sampIsChatInputActive() then
                animLib, animName = "PARACHUTE", "FALL_skyDive"
            elseif isKeyDown(VK_SPACE) then
                animLib, animName = "PARACHUTE", "FALL_skyDive"
            end
            
            requestAnimation(animLib)
            taskPlayAnim(PLAYER_PED, animName, animLib, 4.0, true, true, true, false, -1)
            taskPlayAnim(PLAYER_PED, animName, animLib, 4.0, true, true, true, false, -1)
            
            local wheelDelta = getMousewheelDelta()
            if wheelDelta > 0 then
                flySpeed = math.min(flySpeed + 5, 100)
            elseif wheelDelta < 0 then
                flySpeed = math.max(flySpeed - 5, 10)
            end

            if isKeyDown(VK_W) and not sampIsChatInputActive() then
                atX1 = atX + (40 * math.sin(math.rad(-angle)))
                atY1 = atY + (40 * math.cos(math.rad(-angle)))
                atZ1 = atZ + (40 * z1)
                setCharVelocity(PLAYER_PED, getVelocity(atX, atY, atZ, atX1, atY1, atZ1, flySpeed))
                
            elseif isKeyDown(VK_A) and not sampIsChatInputActive() then
                local angle = angle + 90
                atX1 = atX + (40 * math.sin(math.rad(-angle)))
                atY1 = atY + (40 * math.cos(math.rad(-angle)))
                setCharVelocity(PLAYER_PED, getVelocity(atX, atY, atZ, atX1, atY1, atZ, flySpeed))
                
            elseif isKeyDown(VK_D) and not sampIsChatInputActive() then
                local angle = angle - 90
                atX1 = atX + (40 * math.sin(math.rad(-angle)))
                atY1 = atY + (40 * math.cos(math.rad(-angle)))
                setCharVelocity(PLAYER_PED, getVelocity(atX, atY, atZ, atX1, atY1, atZ, flySpeed))
                
            elseif isKeyDown(VK_S) and not sampIsChatInputActive() then
                angle = angle - 180
                atX1 = atX + (40 * math.sin(math.rad(-angle)))
                atY1 = atY + (40 * math.cos(math.rad(-angle)))
                atZ1 = atZ + (-(40 * z1))
                setCharVelocity(PLAYER_PED, getVelocity(atX, atY, atZ, atX1, atY1, atZ1, flySpeed))
                
            elseif isKeyDown(VK_SPACE) then
                setCharVelocity(PLAYER_PED, 0, 0, 0.35)
            end
        end

        --interactive
        local playerHandleColor = getNearCharToCenter(200)
        if playerHandleColor then
           r, i = sampGetPlayerIdByCharHandle(playerHandleColor)
           if r then
                playerColor = sampGetPlayerColor(i)
                if playerColor == 553648127 then
                    playerColor = 4294967295
                elseif playerColor == 2855350577 then
                    playerColor = 4281413937
                end
           end
        end

        if isKeyDown(VK_LSHIFT) and isKeyDown(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
            local X, Y = getScreenResolution()
            renderFigure2D(X/2, Y/2, 50, 200, playerColor)
            local x, y, z = getCharCoordinates(PLAYER_PED)
            local posX, posY = convert3DCoordsToScreen(x, y, z)
            renderDrawPolygon(X/2, Y/2, 7, 7, 40, 0, -1)
            local player = getNearCharToCenter(200)
            
            if player then
                local playerId = select(2, sampGetPlayerIdByCharHandle(player))
                local playerNick = sampGetPlayerNickname(playerId)
                local x2, y2, z2 = getCharCoordinates(player)
                local isScreen = isPointOnScreen(x2, y2, z2, 200)
                
                if isScreen then
                    local posX2, posY2 = convert3DCoordsToScreen(x2, y2, z2)
                    renderDrawLine(posX, posY - 50, posX2, posY2, 2.0, playerColor)
                    renderDrawPolygon(posX2, posY2, 10, 10, 40, 0, playerColor)
                    local distance = math.floor(getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
                    
                    renderFontDrawTextAlign(font, string.format('%s[%d]', playerNick, playerId), posX2, posY2-30, playerColor, 2)
                    renderFontDrawTextAlign(font, string.format(utext('Дистанция: %s'), distance), X/2, Y/2+210, playerColor, 2)
                    
                    local function resetMenuStates()
                        adminMenuState.punishments = false
                        adminMenuState.ban = false
                        adminMenuState.kick = false
                        adminMenuState.mute = false
                        adminMenuState.amute = false
                        adminMenuState.jail = false
                    end
                    
                    if isKeyJustPressed(VK_LCONTROL) then
                        if adminMenuState.ban or adminMenuState.kick or adminMenuState.mute or adminMenuState.amute or adminMenuState.jail then
                            adminMenuState.ban = false
                            adminMenuState.kick = false
                            adminMenuState.mute = false
                            adminMenuState.amute = false
                            adminMenuState.jail = false
                            adminMenuState.punishments = true
                        elseif adminMenuState.punishments then
                            resetMenuStates()
                        end
                    end
                    
                    if not adminMenuState.punishments and not adminMenuState.ban and not adminMenuState.kick and not adminMenuState.mute and not adminMenuState.amute and not adminMenuState.jail then
                        renderFontDrawTextAlign(font, utext('1 - Перейти в слежку\n2 - SLAP\n3 - Заспавнить\n4 - Выдать 100 HP\n5 - Телепортировать к себе\n6 - ТП к игроку\n7 - Наказания'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_7) then
                            adminMenuState.punishments = true
                        end
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat('/re '..playerId)
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat('/slap '..playerId)
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat('/spawn '..playerId)
                        elseif isKeyJustPressed(VK_4) then
                            sampSendChat('/sethp '..playerId..' 100')
                        elseif isKeyJustPressed(VK_5) then
                            sampSendChat('/gethere '..playerId)
                        elseif isKeyJustPressed(VK_6) then
                            sampSendChat('/g '..playerId)
                        end
                    
                    elseif adminMenuState.punishments and not adminMenuState.ban and not adminMenuState.kick and not adminMenuState.mute and not adminMenuState.amute and not adminMenuState.jail then
                        renderFontDrawTextAlign(font, utext('Наказания:\n1 - Бан\n2 - Кик\n3 - БанИП\n4 - Мут\n5 - АМут\n6 - Jail\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            adminMenuState.punishments = false
                            adminMenuState.ban = true
                        elseif isKeyJustPressed(VK_2) then
                            adminMenuState.punishments = false
                            adminMenuState.kick = true
                        elseif isKeyJustPressed(VK_3) then
                            adminMenuState.punishments = false
                            sampSendChat('/abanip ' .. playerId)
                        elseif isKeyJustPressed(VK_4) then
                            adminMenuState.punishments = false
                            adminMenuState.mute = true
                        elseif isKeyJustPressed(VK_5) then
                            adminMenuState.punishments = false
                            adminMenuState.amute = true
                        elseif isKeyJustPressed(VK_6) then
                            adminMenuState.punishments = false
                            adminMenuState.jail = true
                        end
                    
                    elseif adminMenuState.ban then
                        renderFontDrawTextAlign(font, utext('Вид бана:\n1 - 7 дней (Vred)\n2 - 30 дней (Реклама)\n3 - ЧСП\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/ban " .. playerId .. " 7 Vred")
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/ban " .. playerId .. utext(" 30 Реклама"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat("/ban " .. playerId .. utext(" 365 ЧСП"))
                            resetMenuStates()
                        end
                    
                    elseif adminMenuState.kick then
                        renderFontDrawTextAlign(font, utext('Причина кика:\n1 - Перезайди\n2 - !\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/kick " .. playerId .. utext(" Перезайди"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/kick " .. playerId .. " !")
                            resetMenuStates()
                        end
                    elseif adminMenuState.mute then
                        renderFontDrawTextAlign(font, utext('Причина мута:\n1 - Оск\n2 - Флуд\n3 - Капс\n4 - Реклама\n5 - У.Р\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/mute " .. playerId .. utext(" 60 Оск"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/mute " .. playerId .. utext(" 15 flood"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat("/mute " .. playerId .. utext(" 15 CAPS"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_4) then
                            sampSendChat("/mute " .. playerId .. utext(" 300 Реклама"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_5) then
                            sampSendChat("/mute " .. playerId .. utext(" 300 У.Р"))
                            resetMenuStates()
                        end
                    elseif adminMenuState.amute then
                        renderFontDrawTextAlign(font, utext('Причина мута:\n1 - Оск\n2 - Флуд\n3 - Капс\n4 - Реклама\n5 - У.Р\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/amute " .. playerId .. utext(" 60 Оск"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/amute " .. playerId .. utext(" 15 flood"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat("/amute " .. playerId .. utext(" 15 CAPS"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_4) then
                            sampSendChat("/amute " .. playerId .. utext(" 300 Реклама"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_5) then
                            sampSendChat("/amute " .. playerId .. utext(" 300 У.Р"))
                            resetMenuStates()
                        end
                    elseif adminMenuState.jail then
                        renderFontDrawTextAlign(font, utext('Причина jail:\n1 - Читы на работе\n2 - ДМ\n3 - Читы /dm\n4 - ДБ\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/jail " .. playerId .. utext(" 300 читы на работе"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/jail " .. playerId .. utext(" 30 ДМ"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat("/jail " .. playerId .. utext(" 30 Читы /dm"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_4) then
                            sampSendChat("/jail " .. playerId .. utext(" 30 ДБ"))
                            resetMenuStates()
                        end
                    end
                end
            end
        end

        --farchat
        bubbleBox:toggle(ini.settings.farchat)

		if bubbleBox.active then
			bubbleBox:draw(positionX, positionY)
			if is_key_check_available() and isKeyDown(VK_B) then
				if isKeyJustPressed(VK_OEM_MINUS) then
					bubbleBox:scroll(-1)
                elseif isKeyJustPressed(VK_OEM_PLUS) then
                    bubbleBox:scroll(1)
				end
			end
		end

        --clickwarp
        while isPauseMenuActive() do
            if cursorEnabled then
                showCursorClickWarp(false)
            end
            wait(100)
        end

        if isKeyDown(0x04) and ini.settings.clickwarp then
            cursorEnabled = not cursorEnabled
            showCursorClickWarp(cursorEnabled)
            while isKeyDown(0x04) do wait(80) end
        end
        if cursorEnabled then
            local mode = sampGetCursorMode()
            if mode == 0 then
                showCursor(true)
            end
            local sx, sy = getCursorPos()
            local sw, sh = getScreenResolution()
            -- is cursor in game window bounds?
            if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
                local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
                local camX, camY, camZ = getActiveCameraCoordinates()
                -- search for the collision point
                local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
                if result and colpoint.entity ~= 0 then
                    local normal = colpoint.normal
                    local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
                    local zOffset = 300
                    if normal[3] >= 0.5 then zOffset = 1 end
                    -- search for the ground position vertically down
                    local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3,
                    true, true, false, true, false, false, false)
                    if result then
                        pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)
            
                        local curX, curY, curZ  = getCharCoordinates(playerPed)
                        local dist              = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
                        local hoffs             = renderGetFontDrawHeight(font)
            
                        sy = sy - 2
                        sx = sx - 2
                        renderFontDrawText(font, string.format("%0.2fm", dist), sx, sy - hoffs, 0xEEEEEEEE)
            
                        local tpIntoCar = nil
                        if colpoint.entityType == 2 then
                            local car = getVehiclePointerHandle(colpoint.entity)
                            if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                                displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                                local color = 0xAAFFFFFF
                                if isKeyDown(0x02) then
                                    tpIntoCar = car
                                    color = 0xFF00FF00
                                end
                                renderFontDrawText(font2, "Hold right mouse button to teleport into the car", sx, sy - hoffs * 3, color)
                            end
                        end
            
                        createPointMarker(pos.x, pos.y, pos.z)
            
                        -- teleport!
                        if isKeyDown(0x01) then
                            if tpIntoCar then
                                if not jumpIntoCar(tpIntoCar) then
                                    -- teleport to the car if there is no free seats
                                    teleportPlayer(pos.x, pos.y, pos.z)
                                end
                            else
                                if isCharInAnyCar(playerPed) then
                                    local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                                    local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                                    rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                                    pos = pos - norm * 1.8
                                    pos.z = pos.z - 0.8
                                end
                                teleportPlayer(pos.x, pos.y, pos.z)
                            end
                            removePointMarker()
            
                            while isKeyDown(0x01) do wait(0) end
                            showCursorClickWarp(false)
                        end
                    end
                end
            end
        end
        wait(0)
        removePointMarker()
    end
end

ChatBox = function(pagesize, blacklist)
  local obj = {
    pagesize = pagesize,
		active = false,
		font = nil,
		messages = {},
		blacklist = blacklist,
		firstMessage = 0,
		currentMessage = 0,
  }

	function obj:initialize()
		if self.font == nil then
			self.font = renderCreateFont('Verdana', 8, FCR_BORDER + FCR_BOLD)
		end
	end

	function obj:free()
		if self.font ~= nil then
			renderReleaseFont(self.font)
			self.font = nil
		end
	end

	function obj:toggle(show)
		self:initialize()
		self.active = show
	end

  function obj:draw(x, y)
		local add_text_draw = function(text, color)
			renderFontDrawText(self.font, text, x, y, color)
			y = y + renderGetFontDrawHeight(self.font)
		end

		-- draw caption
    add_text_draw(utext("Дальний чат"), 0xFFE4D8CC)

		-- draw page indicator
		if #self.messages == 0 then return end
		local cur = self.currentMessage
		local to = cur + math.min(self.pagesize, #self.messages) - 1
		add_text_draw(string.format("%d/%d", to, #self.messages), 0xFFE4D8CC)

		-- draw messages
		x = x + 4
		for i = cur, to do
			local it = self.messages[i]
			add_text_draw(
				string.format("{E4E4E4}[%s] (%.1fm) {%06X}%s{D4D4D4}({EEEEEE}%d{D4D4D4}): {%06X}%s",
					it.time,
					it.dist,
					argb_to_rgb(it.playerColor),
					it.nickname,
					it.playerId,
					argb_to_rgb(it.color),
					it.text),
				it.color)
		end
  end

	function obj:add_message(playerId, color, distance, text)
		-- ignore blacklisted messages
		if self:is_text_blacklisted(text) then return end

		-- process only streamed in players
		local dist = get_distance_to_player(playerId)
		if dist ~= nil then
			color = bgra_to_argb(color)
			if dist > distance then color = set_argb_alpha(color, 0xA0)
			else color = set_argb_alpha(color, 0xF0)
			end
			table.insert(self.messages, {
				playerId = playerId,
				nickname = sampGetPlayerNickname(playerId),
				color = color,
				playerColor = sampGetPlayerColor(playerId),
				dist = dist,
				distLimit = distance,
				text = text,
				time = os.date('%X')})

			-- limit message list
			if #self.messages > messagesMax then
				self.messages[self.firstMessage] = nil
				self.firstMessage = #self.messages - messagesMax
			else
				self.firstMessage = 1
			end
			self:scroll(1)
		end
	end

	function obj:is_text_blacklisted(text)
		for _, t in pairs(self.blacklist) do
			if string.match(text, utext(t)) then
				return true
			end
		end
		return false
	end

	function obj:scroll(n)
		self.currentMessage = self.currentMessage + n
		if self.currentMessage < self.firstMessage then
			self.currentMessage = self.firstMessage
		else
			local max = math.max(#self.messages, self.pagesize) + 1 - self.pagesize
			if self.currentMessage > max then
				self.currentMessage = max
			end
		end
	end

  setmetatable(obj, {})
  return obj
end

function get_distance_to_player(playerId)
	if sampIsPlayerConnected(playerId) then
		local result, ped = sampGetCharHandleBySampPlayerId(playerId)
		if result and doesCharExist(ped) then
			local myX, myY, myZ = getCharCoordinates(playerPed)
			local playerX, playerY, playerZ = getCharCoordinates(ped)
			return getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
		end
	end
	return nil
end

function is_key_check_available()
  if not isSampfuncsLoaded() then
    return not isPauseMenuActive()
  end
  local result = not isSampfuncsConsoleActive() and not isPauseMenuActive()
  if isSampLoaded() and isSampAvailable() then
    result = result and not sampIsChatInputActive() and not sampIsDialogActive()
  end
  return result
end

function explode_argb(argb)
  local a = bit.band(bit.rshift(argb, 24), 0xFF)
  local r = bit.band(bit.rshift(argb, 16), 0xFF)
  local g = bit.band(bit.rshift(argb, 8), 0xFF)
  local b = bit.band(argb, 0xFF)
  return a, r, g, b
end

function join_argb(a, r, g, b)
  local argb = b  -- b
  argb = bit.bor(argb, bit.lshift(g, 8))  -- g
  argb = bit.bor(argb, bit.lshift(r, 16)) -- r
  argb = bit.bor(argb, bit.lshift(a, 24)) -- a
  return argb
end

function bgra_to_argb(bgra)
  local b, g, r, a = explode_argb(bgra)
  return join_argb(a, r, g, b)
end

function set_argb_alpha(color, alpha)
	  local _, r, g, b = explode_argb(color)
		return join_argb(alpha, r, g, b)
end

function get_argb_alpha(color)
	local alpha = explode_argb(color)
	return alpha
end

function argb_to_rgb(argb)
	return bit.band(argb, 0xFFFFFF)
end

function renderFigure2D(x, y, points, radius, color)
    local step = math.pi * 2 / points
    local render_start, render_end = {}, {}
    for i = 0, math.pi * 2, step do
        render_start[1] = radius * math.cos(i) + x
        render_start[2] = radius * math.sin(i) + y
        render_end[1] = radius * math.cos(i + step) + x
        render_end[2] = radius * math.sin(i + step) + y
        renderDrawLine(render_start[1], render_start[2], render_end[1], render_end[2], 1, color)
    end
end
function getNearCharToCenter(radius)
    local arr = {}
    local sx, sy = getScreenResolution()
    for _, player in ipairs(getAllChars()) do
        if select(1, sampGetPlayerIdByCharHandle(player)) and isCharOnScreen(player) and player ~= playerPed then
            local plX, plY, plZ = getCharCoordinates(player)
            local cX, cY = convert3DCoordsToScreen(plX, plY, plZ)
            local distBetween2d = getDistanceBetweenCoords2d(sx / 2, sy / 2, cX, cY)
            if distBetween2d <= tonumber(radius and radius or sx) then
                table.insert(arr, {distBetween2d, player})
            end
        end
    end
    if #arr > 0 then
        table.sort(arr, function(a, b) return (a[1] < b[1]) end)
        return arr[1][2]
    end
    return nil
end
function renderFontDrawTextAlign(font, text, x, y, color, align)
    if not align or align == 1 then
        renderFontDrawText(font, text, x, y, color)
    end
  
    if align == 2 then
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text) / 2, y, color)
    end
  
    if align == 3 then
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text), y, color)
    end
  end

function SoftBlueTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    style.WindowPadding      = imgui.ImVec2(16, 16)
    style.WindowRounding     = 20.0
    style.ChildRounding      = 4.0
    style.FramePadding       = imgui.ImVec2(12, 8)
    style.FrameRounding      = 20.0
    style.ItemSpacing        = imgui.ImVec2(8, 12)
    style.ItemInnerSpacing   = imgui.ImVec2(8, 8)
    style.IndentSpacing      = 22.0
    style.ScrollbarSize      = 12.0
    style.ScrollbarRounding  = 4.0
    style.GrabMinSize        = 12.0
    style.GrabRounding       = 6.0
    style.PopupRounding      = 10.0
    style.WindowTitleAlign   = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign    = imgui.ImVec2(0.5, 0.5)
    style.TabRounding        = 4.0
    style.ChildBorderSize    = 1.0
    style.FrameBorderSize    = 2.0
    style.WindowBorderSize   = 5.0
end

theme = {
    {
        change = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(0.93, 0.93, 0.93, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.62, 0.62, 0.62, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.40, 0.40, 0.40, 1.00)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.20, 0.20, 0.20, 0.85)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.25, 0.25, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.25, 0.25, 0.25, 0.75)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.25, 0.25, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.25, 0.25, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.40, 0.40, 0.40, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.80, 0.80, 0.80, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.20, 0.60, 0.86, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.40, 0.73, 0.93, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.30, 0.30, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.50, 0.50, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.15, 0.15, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.30, 0.30, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(0.40, 0.73, 0.93, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.10, 0.10, 0.10, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.30, 0.30, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.40, 0.40, 0.40, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.40, 0.40, 0.40, 0.35)
            imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = ImVec4(0.12, 0.12, 0.12, 0.75)


        end
    }
}