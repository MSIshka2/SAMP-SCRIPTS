// === КОНФИГУРАЦИЯ ИНВЕНТАРЯ ===
const INVENTORY_CONFIG = {
    totalCells: 60, // Общее количество ячеек
    cellsPerRow: 10, // Ячеек в одном ряду
    maxCells: 100 // Максимально возможное количество ячеек
};

let currentContextMenuItemId = null;
let isContextMenuOpen = false;

const ITEM_DATABASE = {
    // Ресурсы
    'хлопок': 'https://png.klev.club/uploads/posts/2024-04/png-klev-club-d4jc-p-khlopok-png-9.png',
    'подарок 2023': 'https://png.pngtree.com/png-clipart/20221224/original/pngtree-beautiful-gift-for-2023-png-image_8801343.png',
    'золото': 'https://pngicon.ru/file/uploads/slitki-zolota.png',
    'медаль ведьмы': 'https://main-cdn.sbermegamarket.ru/big1/hlr-system/175595057/600000113099b0.png',
    'nvidia rtx 2080ti': 'https://www.nvidia.com/content/dam/en-zz/Solutions/geforce/news/geforce-rtx-2080-ti-reviews/geforce-rtx-2080-founders-edition-article-1200x630-ogimage.png',
    'nvidia rtx 3090ti': 'https://www.nvidia.com/content/dam/en-zz/Solutions/geforce/ampere/rtx-3090/geforce-rtx-3090-shop-630-d@2x.png',
    'nvidia rtx a5000': 'https://kvan.tech/upload/iblock/de1/trukzf8wbiowne8aayax6zrtblizpxd0.png',
    'серебро': 'https://foni.papik.pro/uploads/posts/2024-10/foni-papik-pro-spv5-p-kartinki-serebro-na-prozrachnom-fone-11.png',
    'лён': 'https://png.pngtree.com/png-vector/20240314/ourmid/pngtree-flax-seeds-and-blooming-plant-png-image_11955360.png',
    'металл': 'https://smkmet.ru/WP/wp-content/uploads/2024/01/pngegg43.png',
    'рубли': 'https://upload.wikimedia.org/wikipedia/commons/1/18/Russia-Coin-1-2009-a.png',
    'талон репутации': 'https://cdn-icons-png.flaticon.com/512/11503/11503123.png',
    'карточка победителя': 'https://static.vecteezy.com/system/resources/previews/033/256/102/non_2x/voucher-3d-icon-png.png',
    'буст x4 payday': 'https://arz-wiki.com/wp-content/uploads/2024/01/7351-1.png',
    'пикачу в шляпе': 'https://attic.sh/z2xyadbu5r5thuj8b644pdp3iaap',
    'спанч боб': 'https://upload.wikimedia.org/wikipedia/ru/3/3f/%D0%93%D1%83%D0%B1%D0%BA%D0%B0_%D0%91%D0%BE%D0%B1_%D0%BF%D0%B5%D1%80%D1%81%D0%BE%D0%BD%D0%B0%D0%B6.png',
    'лунтик': 'https://i.pinimg.com/originals/bf/94/b4/bf94b41ea663882ea77b28a6b26b3d46.png',
    'рюкзак шахтера': 'https://media.fortniteapi.io/images/940110b5e84b02cf5c12960f8d285e22/full_featured.png',
    'веном': 'https://wallpapers.com/images/hd/glowing-eyes-venom-png-sph-wpvdqudo7sx9p2e0.jpg',
    'посох солнца': 'https://cfcdn.lordswm.com/i/artifacts/sun_staff_b.png',
    'магнит репутации': 'https://png.pngtree.com/png-clipart/20220823/original/pngtree-vector-magnets-png-image_8466732.png',
    'зелье ведьмы': 'https://png.pngtree.com/png-clipart/20231024/original/pngtree-halloween-witch-potion-in-a-glass-jar-png-image_13406933.png',
    'ангельское кольцо': 'https://polinka.top/uploads/posts/2023-06/1685602996_polinka-top-p-nimb-kartinka-krasivo-61.png',
    'кредитный счёт': 'https://mirklimata-rostov.ru/upload/medialibrary/a11/po_schety.png',
    'день рождение': 'https://grizly.club/uploads/posts/2023-08/1692767842_grizly-club-p-kartinki-kolpak-na-den-rozhdeniya-bez-fona-4.png',
    'охлаждающая жидкость': 'https://cdn-icons-png.flaticon.com/512/10732/10732812.png',
    'ягодка': 'https://foni.papik.pro/uploads/posts/2024-09/foni-papik-pro-ezkd-p-kartinki-klubnika-na-prozrachnom-fone-3.png',
    'бананчик': 'https://pngicon.ru/file/uploads/banan.png',
    'бумбокс': 'https://ru.jbl.com/dw/image/v2/BFND_PRD/on/demandware.static/-/Sites-masterCatalog_Harman/default/dwb7c53bef/JBL_Boombox_Black_Hero-1605x1605.PNG?sw=800&sh=800',
    'камень': 'https://foni.papik.pro/uploads/posts/2024-10/foni-papik-pro-waio-p-kartinki-kamen-na-prozrachnom-fone-1.png',
    'бронза': 'https://vikings.help/users/vikings/imgExtCatalog/big/m033.png',
    'пчёлка': 'https://png.pngtree.com/png-clipart/20220123/original/pngtree-bee-png-image_7166500.png',
    'дельфин на спину': 'https://foni.papik.pro/uploads/posts/2024-09/foni-papik-pro-h0m3-p-kartinki-delfin-na-prozrachnom-fone-29.png',
    'визажист': 'https://cdn-icons-png.flaticon.com/512/4515/4515759.png',
    'дракон': 'https://png.pngtree.com/png-vector/20240326/ourmid/pngtree-flying-fire-dragon-fire-dragon-png-image_12206567.png',
    'попугай кеша': 'https://grizly.club/uploads/posts/2023-02/1675506859_grizly-club-p-klipart-popugai-kesha-1.png',
    'девушка на спину': 'https://arz-wiki.com/wp-content/uploads/2022/11/1728-1.png',
    'кровавая накидка': 'https://png.pngtree.com/png-vector/20240726/ourmid/pngtree-crimson-cape-of-enchantment-flowing-png-image_13223628.png',
    'плащ бога': 'https://png.klev.club/uploads/posts/2024-04/png-klev-club-lvfv-p-plashch-png-2.png',
    'нло на плечо': 'https://cdn-icons-png.flaticon.com/512/190/190276.png',
    'мумия': 'https://png.pngtree.com/png-vector/20231012/ourmid/pngtree-jumping-mummy-halloween-character-png-image_10235236.png',
    'бог любви': 'https://png.pngtree.com/png-vector/20240108/ourmid/pngtree-valentines-day-angel-cupid-angel-with-bow-and-arrows-symbol-of-png-image_11416275.png',
    'олень на плечо': 'https://arz-wiki.com/wp-content/uploads/2022/11/1562-1.png',
    'улыбчивый смайлик': 'https://cdn-icons-png.flaticon.com/512/10942/10942081.png',
    'довольный смайлик': 'https://png.klev.club/uploads/posts/2024-05/png-klev-club-rr2k-p-schastlivii-smailik-png-15.png',
    'флиртующий смайлик': 'https://cdn-icons-png.flaticon.com/512/599/599656.png',
    'лазерный меч': 'https://png.klev.club/uploads/posts/2024-04/png-klev-club-o0ee-p-svetovoi-mech-png-6.png',
    'космонавт': 'https://free-png.ru/wp-content/uploads/2022/05/free-png.ru-30.png',
    'купидон': 'https://free-png.ru/wp-content/uploads/2022/01/free-png.ru-327.png',
    'винни пух': 'https://pngicon.ru/file/uploads/vinni-pukh-v-png.png',
    'сияние ангела': 'https://foni.papik.pro/uploads/posts/2024-09/foni-papik-pro-ja41-p-kartinki-siyanie-na-prozrachnom-fone-3.png',
    'царский интерьер': 'https://царьсвет.рф/uploadedFiles/eshopimages/big/79238-5-bslwt-sf.png',
    'новогодний интерьер': 'https://kira-scrap.ru/KATALOG/ZIMA/16/07122021_razdelitnovog-22.png',
    'золотой жетон': 'https://png.pngtree.com/png-vector/20220617/ourmid/pngtree-golden-badge-soldier-tag-dog-png-image_5180599.png',
    'плеер MP3': 'https://cdn-icons-png.flaticon.com/512/486/486724.png',
    'зомби дед': 'https://cdn.creazilla.com/cliparts/41441/zombie-clipart-original.png',
    'спартанец': 'https://png.klev.club/uploads/posts/2024-04/thumbs/png-klev-club-b3yq-p-spartanets-png-15.png',
    'смерть': 'https://nklk.ru/dll_image_temp/4931_8.png',
    'дарт вейдер': 'https://free-png.ru/wp-content/uploads/2022/01/free-png.ru-425.png',
    'донат кейс': 'https://easydonate.s3.easyx.ru/images/products/d9/d1/d9d1b44358a72c5affb1a977afabf22f9cca209af5ebab7e7d5e184362d502f6.png',
    'лотырейный билет': 'https://png.pngtree.com/png-vector/20230227/ourmid/pngtree-golden-ticket-png-image_6621563.png',
    'таракашка': 'https://png.pngtree.com/png-clipart/20230518/original/pngtree-cockroach-png-image_9164554.png',
    'феечка': 'https://foni.papik.pro/uploads/posts/2024-09/foni-papik-pro-1agu-p-kartinki-feya-na-prozrachnom-fone-1.png',
    'ведьма': 'https://cdn-icons-png.flaticon.com/512/218/218200.png',
    'конфеты': 'https://free-png.ru/wp-content/uploads/2022/05/free-png.ru-257.png',
    'майнкрафт': 'https://upload.wikimedia.org/wikipedia/ru/e/e7/Steve_%28Minecraft%29.png',
    'черепашка': 'https://png.klev.club/uploads/posts/2024-04/png-klev-club-4y19-p-cherepashka-png-17.png',
    'смешарик': 'https://png.klev.club/uploads/posts/2024-04/png-klev-club-4iev-p-yezhik-smeshariki-png-1.png',
    'стич': 'https://avatanplus.com/files/resources/original/56ddc173a32f3153523babd4.png',
    'кролик': 'https://static.wikia.nocookie.net/shararam-smeshi/images/0/03/%D0%9A%D1%80%D0%BE%D1%88.png/revision/latest?cb=20170726182144&path-prefix=ru',
    'подарок 2022': 'https://cdn.culture.ru/images/b5a87e4d-9bdb-515c-84c2-36010bd50e66',
    'ангел': 'https://cdn-icons-png.flaticon.com/512/6190/6190680.png',
    'hello kitty': 'https://pluspng.com/img-png/hello-kitty-png-hd-hello-kitty-sitting-with-flowers-1330.png',
    'bitcoin (btc)': 'https://png.pngtree.com/png-vector/20250109/ourmid/pngtree-bitcoin-currency-illustration-png-image_15110187.png',
    'влюбчивый смайлик': 'https://emojio.ru/images/apple-b/1f60d.png',
    'nvidia gtx 1080ti': 'https://images.nvidia.com/geforce-com/international/images/nvidia-geforce-gtx-1080-ti/GeForce_GTX_1080ti_3qtr_top_left.png',
    'сонник': 'https://png.klev.club/uploads/posts/2024-04/png-klev-club-y0al-p-sonik-png-10.png',
    'смазка для разгона': 'https://arz-wiki.com/wp-content/uploads/2023/01/6061.png',
    'свадебный подарок': 'https://cdn-icons-png.flaticon.com/512/3906/3906133.png',
    'туалетомен': 'https://static.wikia.nocookie.net/votv-ru/images/b/bb/ToiletPaperRoll.png/revision/latest?cb=20250428191125&path-prefix=ru',
    'крик': 'https://avatanplus.com/files/resources/original/577c11a76a2eb155bca4f60b.png',
    'коронавирус': 'https://www.labquest.ru/upload/iblock/452/5tm91qhcosmls00wp9ej2yol6kln0fwd/shutterstock_1691591317_1.png',
    'красный angry birds': 'https://static.wikia.nocookie.net/fnaf-fanon-animatronics/images/1/1f/%D0%9A%D1%80%D0%B0%D1%81%D0%BD%D0%B0%D1%8F_%D0%BF%D1%82%D0%B8%D1%86%D0%B0.png/revision/latest?cb=20220407071450&path-prefix=ru',
    'черный angry birds': 'https://www.nicepng.com/png/full/309-3090893_angry-birds-black-black-angry-bird-png.png',
    'the sims': 'https://freepngimg.com/save/webp/114871-sims-photos-the-diamond-free-transparent-image-hq',
    'плюшевый мишка': 'https://png.pngtree.com/png-vector/20240128/ourmid/pngtree-teddy-bear-png-with-ai-generated-png-image_11557602.png',
    'набор ресурсов': 'https://gspics.org/images/2024/10/07/IInUyN.png',
    'какашечка': 'https://free-png.ru/wp-content/uploads/2021/05/free-png.ru-52.png',
    'сияние демона': 'https://png.pngtree.com/png-clipart/20220123/original/pngtree-red-shining-light-effect-element-png-image_7161779.png',
    'для взрослых 18+': 'https://pngicon.ru/file/uploads/18plus.png',
    'кузнечик': 'https://imgpng.ru/d/grasshopper_PNG12.png',
    'люкс интерьер': 'https://png.pngtree.com/png-vector/20230801/ourmid/pngtree-cute-living-room-with-a-couch-vector-png-image_6818522.png',
    'элитный интерьер': 'https://png.pngtree.com/png-vector/20240219/ourmid/pngtree-gold-and-black-luxury-frame-border-with-space-for-text-png-image_11555725.png',
    'vip интерьер': 'https://oykk.ru/sites/default/files/vip.png',
    'фбр гитарист': 'https://upload.wikimedia.org/wikipedia/commons/c/c1/Patch_of_the_FBI_Police.png',
    'коп гитарист': 'https://cdn-icons-png.flaticon.com/512/2563/2563376.png',
    'тоторо': 'https://free-png.ru/wp-content/uploads/2022/07/free-png.ru-696.png',
    'игрушки': 'https://png.pngtree.com/png-vector/20240913/ourmid/pngtree-kids-toys-png-image_13394244.png',
    'копатыч': 'https://static.wikia.nocookie.net/smesharikiarhives/images/0/0a/%D0%9A%D0%BE%D0%BF%D0%B0%D1%82%D1%8B%D1%87_%D0%A2%D0%97.png/revision/latest?cb=20200929163704&path-prefix=ru',
    'крипер': 'https://upload.wikimedia.org/wikipedia/ru/4/49/Creeper_%28Minecraft%29.png',
    'патрик': 'https://avatanplus.com/files/resources/original/5ccade870184e16a78753f5e.png',
    'чебурашка': 'https://png.klev.club/uploads/posts/2024-03/png-klev-club-p-cheburashka-png-22.png',
    'микки маус': 'https://free-png.ru/wp-content/uploads/2021/07/free-png.ru-33.png',
    'лицензия на охоту': 'https://o-n-r.ru/upload/medialibrary/4e0/4e0efd2cf5aee38c1142d7ed393bd7d6.png',
    'тушка оленя': 'https://arz-wiki.com/wp-content/uploads/2022/11/778-1.png',
    'удочка': 'https://cdn-icons-png.flaticon.com/512/4596/4596986.png',
    'снасти': 'https://s1.iconbird.com/ico/2013/7/386/w256h2561372774006dobber2.png',
    'наживка': 'https://png.pngtree.com/png-vector/20231004/ourmid/pngtree-fish-hook-bait-png-image_10065046.png',
    'рыба': 'https://foni.papik.pro/uploads/posts/2024-09/foni-papik-pro-sfjs-p-kartinki-riba-na-prozrachnom-fone-1.png',
    'подарок 2024': 'https://png.pngtree.com/png-clipart/20221221/original/pngtree-3d-gift-box-wrapped-golden-ribbon-vector-on-transparent-background-png-image_8790223.png',
    'финн': 'https://upload.wikimedia.org/wikipedia/ru/7/7b/%D0%A4%D0%B8%D0%BD%D0%BD.png',
    'джейк': 'https://upload.wikimedia.org/wikipedia/ru/1/1b/%D0%94%D0%B6%D0%B5%D0%B9%D0%BA.png',
    'бимо': 'https://img.icons8.com/?size=512&id=108832&format=png',
    'гюнтер': 'https://avatanplus.com/files/resources/original/58230da0c932415848ed3c38.png',
    'стэн марш': 'https://upload.wikimedia.org/wikipedia/ru/9/9e/Stan.png',
    'брофловски': 'https://static.wikia.nocookie.net/southpark/images/9/95/Kyle-broflovski.png/revision/latest?cb=20190411033301',
    'крэйг': 'https://upload.wikimedia.org/wikipedia/ru/0/07/Craig_Tucker.png',
    'шеф макэлрой': 'https://upload.wikimedia.org/wikipedia/ru/0/04/Jerome_%C2%ABChef%C2%BB_McElroy.png',
    'слизень': 'https://ru.minecraft.wiki/images/%D0%A1%D0%BB%D0%B8%D0%B7%D0%B5%D0%BD%D1%8C_JE3_BE2.png?c5fbc',
    'дракон края': 'https://static.wikia.nocookie.net/zlodei/images/c/c1/%D0%94%D1%80%D0%B0%D0%BA%D0%BE%D0%BD%D0%9A%D1%80%D0%B0%D1%8F.png/revision/latest?cb=20230922065025&path-prefix=ru',
    'страж': 'https://static.wikia.nocookie.net/minecraft_ru_gamepedia/images/7/7e/%D0%A1%D1%82%D1%80%D0%B0%D0%B6.png/revision/latest?cb=20210410154042',
    'белый медведь': 'https://pngicon.ru/file/uploads/belmedv.png',
    'кися': 'https://static.wikia.nocookie.net/minecraft_ru_gamepedia/images/a/ac/%D0%A7%D1%91%D1%80%D0%BD%D0%BE-%D0%B1%D0%B5%D0%BB%D0%B0%D1%8F_%D0%BA%D0%BE%D1%88%D0%BA%D0%B0.png/revision/latest?cb=20220327172345',
};

// === ФУНКЦИИ ДЛЯ УПРАВЛЕНИЯ ИНТЕРФЕЙСОМ ===

function updateFreeCellsCounter() {
    const freeCells = getFreeCells();
    const counterElement = document.getElementById('free-cells-count');
    if (counterElement) {
        counterElement.textContent = freeCells;
    }
}

/**
 * Обновляет значение прогресс-бара
 * @param {string} text1 - тип прогресс-бара ('health' или 'armor')
 * @param {string} text2 - значение от 0 до 100
 */
function updateProgress(text1, text2) {
    const progressText1 = document.querySelector('.progress-text1');
    const progressText2 = document.querySelector('.progress-text2');

    // Ограничиваем значение от 0 до 100
    progressText1.textContent = text1
    progressText2.textContent = text2
}

function findItemImage(itemName) {
    if (!itemName) return null;

    const lowerName = itemName.toLowerCase().trim();

    // 1. Прямое совпадение (высший приоритет)
    if (ITEM_DATABASE[lowerName]) {
        return ITEM_DATABASE[lowerName];
    }

    // 2. Поиск по точному частичному совпадению (только целые слова)
    for (const [key, imageUrl] of Object.entries(ITEM_DATABASE)) {
        // Разбиваем на слова и ищем точное совпадение слов
        const itemWords = lowerName.split(/\s+/);
        const keyWords = key.split(/\s+/);
        
        // Проверяем, содержит ли название предмета хотя бы одно целое слово из базы
        const hasExactMatch = keyWords.some(keyWord => 
            itemWords.includes(keyWord) && keyWord.length > 2 // игнорируем короткие слова
        );
        
        if (hasExactMatch) {
            return imageUrl;
        }
    }

    return null;
}

/**
 * Получает количество свободных ячеек в инвентаре
 * @returns {number} - количество свободных ячеек
 */
function getFreeCells() {
    const emptyCells = document.querySelectorAll('.inventory-cell:not(.filled)');
    return emptyCells.length;
}

function clearInventory() {
    const filledCells = document.querySelectorAll('.inventory-cell.filled');

    filledCells.forEach(cell => {
        cell.classList.remove('filled');
        cell.innerHTML = '';

        // Удаляем все обработчики событий через клонирование
        const newCell = cell.cloneNode(true);
        cell.parentNode.replaceChild(newCell, cell);
    });

    // Обновляем счетчик свободных ячеек
    updateFreeCellsCounter();

    console.log('Инвентарь очищен');
}

/**
 * Инициализирует инвентарь
 */
function initializeInventory() {
    createInventoryGrid();
    updateFreeCellsCounter();
}

/**
 * Создает сетку инвентаря
 */
function createInventoryGrid() {
    const grid = document.getElementById('inventory-grid');
    grid.innerHTML = '';

    for (let i = 0; i < INVENTORY_CONFIG.totalCells; i++) {
        const cell = document.createElement('div');
        cell.className = 'inventory-cell';
        cell.dataset.index = i;

        // Добавляем обработчик клика
        cell.addEventListener('click', function() {
            if (this.classList.contains('filled')) {
                removeItem(this);
            }
        });

        grid.appendChild(cell);
    }

    // Обновляем CSS для правильного отображения
    updateGridStyles();
}

/**
 * Обновляет имя игрока
 * @param {string} name - новое имя игрока
 */
function updatePlayerName(name) {
    const playerNameElement = document.querySelector('.player-name');
    playerNameElement.textContent = name;
}

/**
 * Обновляет аватар игрока
 * @param {string} imageUrl - URL нового аватара
 */
function updatePlayerAvatar(imageUrl) {
    const avatarElement = document.querySelector('.player-avatar');
    avatarElement.src = imageUrl;
}


/**
 * Обновляет стили сетки в зависимости от конфигурации
 */
function updateGridStyles() {
    const grid = document.getElementById('inventory-grid');
    grid.style.gridTemplateColumns = `repeat(${INVENTORY_CONFIG.cellsPerRow}, 1fr)`;
}

/**
 * Изменяет размер инвентаря
 * @param {number} newTotalCells - новое общее количество ячеек
 * @param {number} newCellsPerRow - новое количество ячеек в ряду
 */
function resizeInventory(newTotalCells, newCellsPerRow) {
    // Проверяем лимиты
    newTotalCells = Math.min(Math.max(newTotalCells, 1), INVENTORY_CONFIG.maxCells);
    newCellsPerRow = Math.min(Math.max(newCellsPerRow, 1), 12);

    // Сохраняем текущие предметы
    const currentItems = saveCurrentItems();

    // Обновляем конфигурацию
    INVENTORY_CONFIG.totalCells = newTotalCells;
    INVENTORY_CONFIG.cellsPerRow = newCellsPerRow;

    // Пересоздаем сетку
    createInventoryGrid();

    // Восстанавливаем предметы
    restoreItems(currentItems);
}

/**
 * Сохраняет текущие предметы из инвентаря
 * @returns {Array} массив предметов
 */
function saveCurrentItems() {
    const items = [];
    const cells = document.querySelectorAll('.inventory-cell.filled');

    cells.forEach(cell => {
        const itemText = cell.querySelector('.item-text') ? cell.querySelector('.item-text').textContent : '';
        const itemImage = cell.querySelector('.item-image') ? cell.querySelector('.item-image').src : '';
        const quantity = cell.querySelector('.item-quantity') ? cell.querySelector('.item-quantity').textContent : '1';

        items.push({
            text: itemText,
            imageUrl: itemImage,
            quantity: parseInt(quantity) || 1,
            index: parseInt(cell.dataset.index) || 0
        });
    });

    return items;
}

/**
 * Восстанавливает предметы в инвентарь
 * @param {Array} items - массив предметов для восстановления
 */
function restoreItems(items) {
    items.forEach(item => {
        // Проверяем, что индекс в пределах нового размера инвентаря
        if (item.index < INVENTORY_CONFIG.totalCells) {
            const cell = document.querySelector(`.inventory-cell[data-index="${item.index}"]`);
            if (cell) {
                fillCell(cell, item.imageUrl, item.text, item.quantity);
            }
        }
    });
}

/**
 * Заполняет ячейку предметом
 */
function fillCell(cell, imageUrl, text, quantity) {
    cell.classList.add('filled');

    if (imageUrl && isImageUrl(imageUrl)) {
        cell.innerHTML = `
            <img src="${imageUrl}" alt="Предмет" class="item-image" 
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='block'">
            <div class="item-text" style="display: none;">${escapeHtml(text)}</div>
            <span class="item-quantity">${quantity}</span>
        `;
    } else {
        cell.innerHTML = `
            <div class="item-text">${escapeHtml(text)}</div>
            <span class="item-quantity">${quantity}</span>
        `;
    }
}

/**
 * Экранирует HTML символы
 */
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Остальные функции (addItem, removeItem, updateFreeCellsCounter) остаются без изменений,
// но теперь они работают с динамически созданными ячейками

let contextMenuData = {
    title: "",
    description: "",
    btn1: "",
    btn2: ""
};

let pendingContextMenuPos = null;

function setContextMenuData(title, description, btn1, btn2) {
    contextMenuData = { title, description, btn1, btn2 };

    // Если есть сохранённая позиция ПКМ → открываем меню
    if (pendingContextMenuPos) {
        showContextMenu(pendingContextMenuPos.x, pendingContextMenuPos.y);
        pendingContextMenuPos = null; // сбрасываем после открытия
    }
}

function clearContextMenuData() {
    contextMenuData = {
        title: "",
        description: "",
        btn1: "",
        btn2: ""
    };
}

function showContextMenu(x, y) {
    const menu = document.getElementById("contextMenu");
    const itemName = document.getElementById("itemName");
    const itemDescription = document.getElementById("itemDescription");
    const btn1 = document.getElementById("contextBtn1");
    const btn2 = document.getElementById("contextBtn2");

    itemName.innerText = contextMenuData.title || "Без названия";
    itemDescription.innerText = contextMenuData.description || "Нет описания";
    btn1.innerText = contextMenuData.btn1 || "Действие 1";
    btn2.innerText = contextMenuData.btn2 || "Действие 2";

    menu.style.left = x + "px";
    menu.style.top = y + "px";
    menu.classList.add("show");
}

window.addEventListener("click", function(e) {
    const menu = document.getElementById("contextMenu");
    if (!menu.contains(e.target)) {
        menu.classList.remove("show");
        clearContextMenuData(); // очищаем данные при закрытии
    }
});
// === ИНИЦИАЛИЗАЦИЯ ===
document.addEventListener('DOMContentLoaded', function() {
    initializeInventory();
    console.log('Инвентарь инициализирован с', INVENTORY_CONFIG.totalCells, 'ячейками');
    document.getElementById("contextBtn1").addEventListener("click", function() {
        cef.sendDialog(10009, 1, 0)
        cef.sendDialog(10004, 1, 0)
        cef.sendChat("/i")
        cef.sendChat("/i")
        document.getElementById("contextMenu").classList.remove("show");
    });

    document.getElementById("contextBtn2").addEventListener("click", function() {
        cef.sendDialog(10009, 0, 0)
        cef.sendDialog(10004, 0, 0)
        cef.sendChat("/i")
        document.getElementById("contextMenu").classList.remove("show");
    });
});

/**
 * Добавляет предмет в первую свободную ячейку инвентаря
 * @param {string} imageUrlOrText - URL изображения или текст предмета
 * @param {number} quantity - количество предметов
 * @returns {boolean} - true если предмет добавлен, false если нет свободных ячеек
 */


function addItem(itemName, quantity = 1, id) {
    const emptyCell = document.querySelector('.inventory-cell:not(.filled)');
    if (!emptyCell) {
        console.warn('Нет свободных ячеек в инвентаре');
        return false;
    }

    emptyCell.classList.add('filled');
    const itemImageUrl = findItemImage(itemName);

    emptyCell.innerHTML = itemImageUrl ?
        `<img src="${itemImageUrl}" alt="${escapeHtml(itemName)}" class="item-image">
           <span class="item-quantity">${quantity}</span>
           <div class="item-name-tooltip">${escapeHtml(itemName)}</div>` :
        `<div class="item-text">${escapeHtml(itemName)}</div>
           <span class="item-quantity">${quantity}</span>`;

    // ПКМ → отправляем запрос в Lua, но меню пока не открываем
    emptyCell.addEventListener("contextmenu", function(e) {
        e.preventDefault();
        pendingContextMenuPos = { x: e.clientX, y: e.clientY };
        cef.sendDialog(10003, 1, id - 1); // твой вызов
    });

    updateFreeCellsCounter();
    return true;
}

function hideTextFallback(imgElement) {
    const textElement = imgElement.nextElementSibling;
    if (textElement && textElement.classList.contains('item-text')) {
        textElement.style.display = 'none';
    }
    console.log('Изображение загружено, текст скрыт');
}

/**
 * Показывает текстовый fallback при ошибке загрузки изображения
 * @param {HTMLElement} imgElement - элемент изображения
 * @param {string} itemName - название предмета
 */
function showTextFallback(imgElement, itemName) {
    imgElement.style.display = 'none';

    const textElement = imgElement.nextElementSibling;
    if (textElement && textElement.classList.contains('item-text')) {
        textElement.style.display = 'block';
        textElement.textContent = itemName;
    } else {
        // Создаем текстовый элемент если его нет
        const newTextElement = document.createElement('div');
        newTextElement.className = 'item-text';
        newTextElement.textContent = itemName;
        imgElement.parentNode.insertBefore(newTextElement, imgElement.nextSibling);
    }

    console.log('Ошибка загрузки изображения, показан текст');
}

function handleImageError(imgElement, itemName) {
    imgElement.style.display = 'none';

    // Создаем текстовый элемент вместо изображения
    const textElement = document.createElement('div');
    textElement.className = 'item-text';
    textElement.textContent = itemName;

    imgElement.parentNode.appendChild(textElement);
}

/**
 * Удаляет предмет из ячейки инвентаря
 * @param {HTMLElement} cell - ячейка для очистки
 */
function removeItem(cell) {
    if (cell.classList.contains('filled')) {
        cell.classList.remove('filled');
        cell.innerHTML = '';

        // Обновляем счетчик
        updateFreeCellsCounter();
    }
}