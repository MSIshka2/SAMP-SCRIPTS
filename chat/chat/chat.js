const messageHistory = [];
const mediaElementCache = {};
let historyIndex = -1;
let currentColor = "#FFFFFF";
let chats = JSON.parse(localStorage.getItem('customChats')) || [];
let defaultChat = { id: 'default', name: 'SAMP-CHAT', regex: '.*', active: true, isDefault: true };
let activeChatId = 'default';
let chatActive = false;
let autoScrollEnabled = {};
let scrollToBottomButtons = {};
const mentionPatternCache = new Map();
var uvedChat = false;
var uvedSound = false;
var uvedWindows = false;
var toggleCustomEmoji = false;
const replyMap = new Map();
const MAX_REPLY_MAP_SIZE = 50;

function getOffsetToMSK() {
    const now = new Date();
    // Получаем смещение UTC для локального времени (в минутах)
    const localOffset = now.getTimezoneOffset(); // отрицательное для восточных поясов
    // МСК = UTC+3, т.е. смещение МСК от UTC = -180 минут (т.к. getTimezoneOffset возвращает минуты, которые нужно вычесть, чтобы получить UTC)
    // Но проще: создаём дату в МСК через Intl
    const mskStr = new Intl.DateTimeFormat('ru-RU', {
        timeZone: 'Europe/Moscow',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    }).format(now);
    const [h, m, s] = mskStr.split(':').map(Number);
    const mskTotalMinutes = h * 60 + m;
    const localTotalMinutes = now.getHours() * 60 + now.getMinutes();
    return localTotalMinutes - mskTotalMinutes; // смещение в минутах
}
const offsetToMSK = getOffsetToMSK();

function toMSK(timeStr) {
    const [h, m, s] = timeStr.split(':').map(Number);
    let total = h * 60 + m - offsetToMSK;
    total = ((total % 1440) + 1440) % 1440;
    const nh = Math.floor(total / 60);
    const nm = total % 60;
    return `${String(nh).padStart(2, '0')}:${String(nm).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
}

function fromMSK(mskTimeStr) {
    const [h, m, s] = mskTimeStr.split(':').map(Number);
    let total = h * 60 + m + offsetToMSK;
    total = ((total % 1440) + 1440) % 1440;
    const nh = Math.floor(total / 60);
    const nm = total % 60;
    return `${String(nh).padStart(2, '0')}:${String(nm).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
}

function getNormalizedTime(timeStr) {
    if (!timeStr) return null;
    const parts = timeStr.split(':');
    if (parts.length < 3) return timeStr;
    let hours = parseInt(parts[0], 10);
    const minutes = parseInt(parts[1], 10);
    const seconds = parseInt(parts[2], 10);
    // Приводим к МСК
    hours = (hours - timezoneOffset + 24) % 24;
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
}


function findMessageByTime(time, chatId) {
    const chatlog = document.querySelector(`.chatlog[data-chat-id="${chatId}"]`);
    if (!chatlog) return null;
    
    const messages = chatlog.querySelectorAll('p');
    
    for (let i = messages.length - 1; i >= 0; i--) {
        const msg = messages[i];
        const cleanText = msg.textContent || msg.innerText;
        
        const timeMatch = cleanText.match(/^\[?(\d{2}:\d{2}:\d{2})\]?/);
        if (timeMatch && timeMatch[1] || timeMatch && timeMatch[0] === time) {
            console.log(msg.innerHTML)
            return msg.innerHTML;
        }
    }
    return null;
}

function formatReply(text, chatId = 'default') {
    if (!text) return text;
    
    const replyRegex = /\[R\](\d{2}:\d{2}:\d{2})\[R\]\[A\](.*?)/gs;
    
    return text.replace(replyRegex, (match, mskTime, replyText) => {
        // Ищем оригинальное сообщение в DOM
        const originalHTML = findMessageByTime(mskTime, chatId);
        
        if (originalHTML) {
            // Вставляем originalHTML напрямую (он уже содержит цветовые теги и форматирование)
            return `<span class="reply-block">↩ ${originalHTML}: <span class="reply-text">${replyText}</span></span>`;
        } else {
            // Fallback – показываем локальное время
            const localTime = fromMSK(mskTime);
            return `<span class="reply-block">↩ <span class="reply-time">${localTime}</span>: <span class="reply-text">${replyText}</span></span>`;
        }
    });
}


function escapeRegExp(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function getMentionPattern(nick, id) {
    const cacheKey = `${nick}_${id}`;
    
    if (!mentionPatternCache.has(cacheKey)) {
        const escapedNick = escapeRegExp(nick);
        const patterns = [
            `(@)(${id})(?=[^\\d]|$)`,
            `(@)(${escapedNick})(?=[^\\w]|$)`,
            `(${escapedNick})([,])`,
            `(@)(all)(?=[^\\d]|$)`,
            `(all)([,:])(?=\\s|$)`,
            `(@)(everyone)(?=[^\\w]|$)`,
            `(everyone)([,])(?=\\s|$)`
        ];
        
        const regex = new RegExp(patterns.join('|'), 'gi');
        mentionPatternCache.set(cacheKey, regex);
    }
    
    return mentionPatternCache.get(cacheKey);
}

function throttle(func, delay) {
    let lastCall = 0;
    return function(...args) {
        const now = Date.now();
        if (now - lastCall >= delay) {
            lastCall = now;
            return func.apply(this, args);
        }
    };
}

function createScrollToBottomButton(chatId) {
    const button = document.createElement('button');
    button.className = 'scroll-to-bottom-btn';
    button.innerHTML = '↓';
    button.title = 'Прокрутить в конец';
    button.dataset.chatId = chatId;

    button.addEventListener('mouseenter', () => {
        button.style.background = 'rgba(0, 0, 0, 0.5)';
        button.style.transform = 'scale(1.15)';
    });

    button.addEventListener('mouseleave', () => {
        button.style.background = 'rgba(0, 0, 0, 0.5)';
        button.style.transform = 'scale(1)';
    });

    button.addEventListener('click', () => {
        const chatlog = document.querySelector(`.chatlog[data-chat-id="${chatId}"]`);
        if (chatlog) {
            chatlog.scrollTo({
                top: chatlog.scrollHeight,
                behavior: 'smooth'
            });
            autoScrollEnabled[chatId] = true;
            button.style.display = 'none';
        }
    });

    // Добавляем кнопку в body, а не в chatlog
    document.body.appendChild(button);

    return button;
}

function setupScrollListener(chatId) {
    const chatlog = document.querySelector(`.chatlog[data-chat-id="${chatId}"]`);
    if (!chatlog) return;

    // Удаляем старый listener если есть
    chatlog.removeEventListener('scroll', chatlog._scrollListener);

    const scrollListener = throttle(() => {
        const button = scrollToBottomButtons[chatId];
        if (!button) return;

        const distanceFromBottom = chatlog.scrollHeight - chatlog.clientHeight - chatlog.scrollTop;

        if (distanceFromBottom <= 50) {
            // Пользователь внизу
            autoScrollEnabled[chatId] = true;
            button.style.display = 'none';
        } else if (distanceFromBottom > 100) {
            // Пользователь прокрутил достаточно вверх
            autoScrollEnabled[chatId] = false;
            if (chatId === activeChatId) {
                button.style.display = 'block';
            }
        }
        // В промежутке между 50-100px кнопка остается в том же состоянии
    }, 10);

    chatlog._scrollListener = scrollListener;
    chatlog.addEventListener('scroll', scrollListener, {passive: true});

    // Инициализируем состояние
    autoScrollEnabled[chatId] = true;
}

function openCloseChat(isActive, color, chatSize) {
    const chatInput = document.querySelector('.chat-input');
    const chatlogs = document.querySelector(`.chatlog[data-chat-id="${activeChatId}"]`);
    const langElement = document.querySelector('.input-language');
    const emojiMenu = document.getElementById('emoji-menu');
    const contextMenu = document.getElementById('contextMenu');
    const contextText = document.getElementById('contextMenuText');
    const calcResult = document.getElementById('calculation-result');
    const mediaModal = document.getElementById('mediaModal');


    if (isActive) {
        chatInput.style.display = 'block';
        chatInput.style.width = '46%';
        chatInput.focus();
        langElement.style.display = 'block';
        document.querySelectorAll('.chatlog[data-chat-id]').forEach(chat => {
            chat.style.backgroundColor = color;
            chat.style.width = chatSize + '%';
            chat.style.overflow = 'auto';
            chat.style.overflowX = 'hidden';
            chat.style.maxHeight = '40vh';
        });
        chatlogs.scrollTop = chatlogs.scrollHeight;
    } else {
        emojiMenu.style.display = 'none';
        chatInput.style.display = 'none';
        langElement.style.display = 'none';
        contextMenu.style.display = 'none';
        contextText.style.display = 'none';
        calcResult.style.display = 'none';
        mediaModal.style.display = 'none';
        document.querySelectorAll('.chatlog[data-chat-id]').forEach(chat => {
            chat.style.backgroundColor = 'rgba(0,0,0,0)';
            chat.style.width = '70%';
            chat.style.overflow = 'hidden';
            chat.style.maxHeight = '30vh';
            chat.scrollTop = chat.scrollHeight;
        });
    }

    chatActive = isActive;

}

function loadChats() {
    try {
        const savedChats = localStorage.getItem('customChats');
        if (savedChats) {
            const parsedChats = JSON.parse(savedChats);
            console.log('Parsed chats from localStorage:', parsedChats);
            
            // Убедимся, что это массив
            if (Array.isArray(parsedChats)) {
                chats = parsedChats;
                console.log(`Loaded ${chats.length} chats from localStorage`);
            } else {
                console.error('Saved chats is not an array, resetting');
                chats = [];
            }
        } else {
            console.log('No saved chats found in localStorage');
            chats = [];
        }
    } catch (error) {
        console.error('Error loading chats from localStorage:', error);
        chats = [];
    }
    
    // Убедимся, что у всех чатов есть обязательные поля
    chats.forEach(chat => {
        if (!chat.id) {
            console.warn('Chat without ID found, generating new ID');
            chat.id = 'chat-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
        }
        if (chat.active === undefined) chat.active = true;
        if (chat.isDefault === undefined) chat.isDefault = false;
        if (chat.hideFromDefault === undefined) chat.hideFromDefault = false;
    });
}


function saveChats() {
    localStorage.setItem('customChats', JSON.stringify(chats));
}

function saveChatHistory(chatId, messages) {
    let messagesToSave = messages;
    if (messages.length > 100) {
        messagesToSave = messages.slice(-100);
    }

    if (messagesToSave.length > 0) {
        localStorage.setItem(`chatHistory-${chatId}`, JSON.stringify(messagesToSave));
    } else {
        localStorage.removeItem(`chatHistory-${chatId}`);
    }
}

function loadChatHistory(chatId) {

    try {
        const key = `chatHistory-${chatId}`;
        const stored = localStorage.getItem(key);

        if (!stored) {
            return [];
        }

        const parsed = JSON.parse(stored);

        if (Array.isArray(parsed) && parsed.length > 0) {
            return parsed;
        } else {
            sendNotify(4, "Ошибка", "История чата не загружена, по причине 'Empty Data'");
            return [];
        }

    } catch (e) {
        sendNotify(4, "Ошибка", "История чата не загружена. Попробуйте перезапустить скрипны 'CTRL+R'");
        return [];
    }
}


function createChatLog(chatId) {
    const container = document.getElementById('chat-logs-container');
    if (document.querySelector(`.chatlog[data-chat-id="${chatId}"]`)) return;

    const log = document.createElement('div');
    log.className = 'chatlog';
    log.dataset.chatId = chatId;
    log.style.fontFamily = "Open Sans";
    log.style.fontSize = "14px";
    log.style.padding = "10px";
    log.style.fontWeight = 500;
    log.style.margin = "5px 0";
    log.style.textShadow = "1px 1px 1px #000, -1px -1px 2px #000, 0 0 4px rgba(0, 0, 0, 0.8)";
    log.style.lineHeight = 1.4;
    log.style.paintOrder = "stroke fill";
    log.style.webkitTextStroke = "0.2px black";
    log.style.letterSpacing = "0.3px";
    log.style.marginBottom = "10px";
    log.style.flexDirection = "column"
    log.style.display = chatId === activeChatId ? 'block' : 'none';
    container.appendChild(log);

    const scrollButton = createScrollToBottomButton(chatId);
    scrollToBottomButtons[chatId] = scrollButton;

    setupScrollListener(chatId);

    // Загружаем историю
    setTimeout(() => {
        const history = loadChatHistory(chatId);
        history.forEach(msg => {
            const p = document.createElement('p');
            p.innerHTML = msg;
            log.appendChild(p);
        });
        log.scrollTop = log.scrollHeight;
        autoScrollEnabled[chatId] = true;
    }, 0);
}

function sendNotify(id, zagl, text) {
    const logMessage = document.getElementById('logMessage');
    const imgElement = logMessage.querySelector('img');
    const zaglElement = document.getElementById('zagl');
    const textElement = document.getElementById('textMessage');

    zaglElement.textContent = zagl;
    textElement.textContent = text;

    switch (id) {
        case 1: // Предупреждение
            imgElement.src = "https://cdn-icons-png.flaticon.com/128/8376/8376179.png";
            break;
        case 2: // Внимание
            imgElement.src = "https://cdn-icons-png.flaticon.com/128/3756/3756730.png";
            break;
        case 3: // Успех
            imgElement.src = "https://cdn-icons-png.flaticon.com/128/190/190411.png";
            break;
        case 4: // Ошибка
            imgElement.src = "https://cdn-icons-png.flaticon.com/128/6711/6711656.png";
            break;
        case 5: // Информация
            imgElement.src = "https://cdn-icons-png.flaticon.com/128/807/807334.png";
            break;
        default: // По умолчанию (если id не распознан)
            imgElement.src = "https://cdn-icons-png.flaticon.com/128/8943/8943377.png";
    }

    logMessage.style.display = "block";
    logMessage.classList.remove("fadeOut"); // Убираем класс исчезновения (если был)
    logMessage.classList.add("fadeIn"); // Добавляем анимацию появления

    // Автоматическое скрытие через 3 секунды с плавным исчезновением
    setTimeout(() => {
        logMessage.classList.remove("fadeIn"); // Убираем анимацию появления
        logMessage.classList.add("fadeOut"); // Добавляем анимацию исчезновения

        // Полностью скрываем после завершения анимации
        setTimeout(() => {
            logMessage.style.display = "none";
        }, 300); // Должно совпадать с длительностью fadeOut (0.3s)
    }, 5000); // Время показа уведомления (5 секунды)
}

function toggleChat(id) {
    console.log('=== toggleChat DEBUG ===');
    console.log('Toggle ID:', id);
    console.log('All chats:', chats);
    console.log('Default chat ID:', defaultChat?.id);
    console.log('Active chat ID:', activeChatId);
    
    if (!id) {
        console.error('No chat ID provided');
        return;
    }

    // Проверяем, не пытаемся ли мы тогглить defaultChat
    if (id === defaultChat.id) {
        console.log('Trying to toggle default chat - ignoring');
        sendNotify(2, "Инфо", "Дефолтный чат всегда активен");
        return;
    }

    const chatIndex = chats.findIndex(chat => chat.id === id);
    console.log('Chat index found:', chatIndex);
    
    if (chatIndex === -1) {
        console.error(`Chat with id ${id} not found in chats array`);
        console.log('Available IDs:', chats.map(c => c.id));

        return;
    }

    // Переключаем активность
    chats[chatIndex].active = !chats[chatIndex].active;
    console.log(`Chat ${id} active state toggled to:`, chats[chatIndex].active);

    saveChats();
    
    console.log('=== END DEBUG ===');
}


function processIncomingMessage(text) {
    // Всегда добавляем сообщение в дефолтный чат целиком

    let shouldShowInDefault = true;

    // Проверяем все активные кастомные чаты
    const activeChats = chats.filter(c => c.active);

    activeChats.forEach(chat => {
        try {
            const regex = new RegExp(chat.regex);
            if (regex.test(text)) {
                // Добавляем сообщение в кастомный чат
                addMessageToChat(chat.id, text);

                // Если чат настроен на скрытие из основного, отмечаем это
                if (chat.hideFromDefault) {
                    shouldShowInDefault = false;
                }
            }
        } catch (e) {
            sendNotify(4, "Ошибка", `Ошибка в регулярном выражении чата "${chat.name}":`, e);
        }
    });

    if (shouldShowInDefault) {
        try {
            const defaultRegex = new RegExp(defaultChat.regex);
            if (defaultRegex.test(text)) {
                addMessageToChat(defaultChat.id, text);
            }
        } catch (e) {
            sendNotify(4, "Ошибка", "Ошибка в регулярном выражении дефолтного чата:", e)
            // Если regex сломан, добавляем сообщение как есть
            addMessageToChat(defaultChat.id, text);
        }
    }
}

// Функции escapeHtml, replaceMediaTags, colorify, replaceTextWithEmojis, HTMLstringify остаются без изменений
function escapeHtml(unsafe) {
    if (!unsafe) return unsafe;
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;");
}

function auto_layout_keyboard(str) {
    replacer = {
        "q": "й",
        "w": "ц",
        "e": "у",
        "r": "к",
        "t": "е",
        "y": "н",
        "u": "г",
        "i": "ш",
        "o": "щ",
        "p": "з",
        "[": "х",
        "]": "ъ",
        "a": "ф",
        "s": "ы",
        "d": "в",
        "f": "а",
        "g": "п",
        "h": "р",
        "j": "о",
        "k": "л",
        "l": "д",
        ";": "ж",
        "'": "э",
        "z": "я",
        "x": "ч",
        "c": "с",
        "v": "м",
        "b": "и",
        "n": "т",
        "m": "ь",
        ",": "б",
        ".": "ю",
        "/": "."
    };

    return str.replace(/[A-z/,.;\'\]\[]/g, function(x) {
        return x == x.toLowerCase() ? replacer[x] : replacer[x.toLowerCase()].toUpperCase();
    });
}

function auto_layout_keyboard_reverse(str) {
    replacer = {
        "й": "q",
        "ц": "w",
        "у": "e",
        "к": "r",
        "е": "t",
        "н": "y",
        "г": "u",
        "ш": "i",
        "щ": "o",
        "з": "p",
        "х": "[",
        "ъ": "]",
        "ф": "a",
        "ы": "s",
        "в": "d",
        "а": "f",
        "п": "g",
        "р": "h",
        "о": "j",
        "л": "k",
        "д": "l",
        "ж": ";",
        "э": "'",
        "я": "z",
        "ч": "x",
        "с": "c",
        "м": "v",
        "и": "b",
        "т": "n",
        "ь": "m",
        "б": ",",
        "ю": ".",
        ".": "/"
    };

    return str.replace(/[йцукенгшщзхъфывапролджэячсмитьбю.,\/]/g, function(x) {
        return x == x.toLowerCase() ? replacer[x] : replacer[x.toLowerCase()].toUpperCase();
    });
}

function showMediaModalElement(el) {
    const modal = document.getElementById('mediaModal');
    const container = document.getElementById('mediaContainer');

    // Очищаем, но НЕ пересоздаём сам элемент
    container.innerHTML = '';
    container.appendChild(el);
    modal.style.display = 'flex';
}

function closeMediaModal() {
    const modal = document.getElementById('mediaModal');
    modal.style.display = 'none';
    document.getElementById('mediaContainer').innerHTML = '';
}

function escapeHtmlAttr(str) {
    return str
        .replace(/&/g, "&amp;")
        .replace(/"/g, "&quot;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;");
}


function replaceMediaTags(text) {
    const isValidUrl = (url) => {
        const patternWithExt = /^https?:\/\/(?:[a-z0-9-]+\.)+[a-z]{2,6}(?:\/[^\s]+)*\.(gif|webp|png|jpg|jpeg|mp4|webm|mov|mp3|ogg|wav|m4a)(?:\?.*)?$/i;
        if (patternWithExt.test(url)) return true;

        // Допустим короткие ссылки без расширения (например, t.ly/abc)
        if (/^https?:\/\/[^\s]{10,30}$/.test(url)) return true;

        return false;
    };

    const esc = escapeHtmlAttr;

    // Восстанавливаем URL, если SAMP разбил строку на несколько с переносом и троеточием
    text = text.replace(/:(img|gif|vid|aud):([\s\S]*?):\1:/gi, (match, p1, middle) => {
        const fixed = middle
            .replace(/\s*\.\.\.\s*/g, '') // убираем троеточия
            .replace(/[\n\r]/g, '') // убираем переносы строк
            .replace(/\s+/g, ''); // убираем пробелы
        return `:${p1}:${fixed}:${p1}:`;
    });

    text = text.replace(/:gif:(.*?):gif:/gi, (match, url) => {
        if (!isValidUrl(url)) return sendNotify(4, "Ошибка ссылки", `Неправильная ссылка, убедитесь что она в формате https://example.gif"`);
        sendNotify(2, "Внимание", `Гифка была отправлена в чат. Убедитесь что на вашем сервере разрешено отправлять ссылки!"`);
        return `<button id="media-button" class="media-btn" data-type="gif" data-url="${esc(url)}">🎞 GIF</button>`;
    });

    text = text.replace(/:img:(.*?):img:/gi, (match, url) => {
        if (!isValidUrl(url)) return sendNotify(4, "Ошибка ссылки", `Неправильная ссылка, убедитесь что она в формате https://example (.jpg, .jpeg, .png, .webp)"`);
        sendNotify(2, "Внимание", `Изображение было отправлено в чат. Убедитесь что на вашем сервере разрешено отправлять ссылки!"`);
        return `<button id="media-button" class="media-btn" data-type="img" data-url="${esc(url)}">🖼 IMG</button>`;
    });

    text = text.replace(/:vid:(.*?):vid:/gi, (match, url) => {
        if (!isValidUrl(url)) return sendNotify(4, "Ошибка ссылки", `Неправильная ссылка, убедитесь что она в формате https://example (.mp4, .mov, .webm)"`);
        sendNotify(2, "Внимание", `Видео было отправлено в чат. Убедитесь что на вашем сервере разрешено отправлять ссылки!"`);
        return `<button id="media-button" class="media-btn" data-type="vid" data-url="${esc(url)}">🎥 VIDEO</button>`;
    });

    text = text.replace(/:aud:(.*?):aud:/gi, (match, url) => {
        if (!isValidUrl(url)) return sendNotify(4, "Ошибка ссылки", `Неправильная ссылка, убедитесь что она в формате https://example (.mp3, .ogg, .wav, .m4a)"`);
        sendNotify(2, "Внимание", `Аудио было отправлено в чат. Убедитесь что на вашем сервере разрешено отправлять ссылки!"`);
        return `<button id="media-button" class="media-btn" data-type="aud" data-url="${esc(url)}">🎧 AUDIO</button>`;
    });

    text = text.replace(/\*\*(.*?)\*\*/g, (match, text) => {
        return `<span style="font-weight: bolder;">${text}</span>`;
    });
    text = text.replace(/__(.*?)__/g, (match, text) => {
        return `<span style="font-style: italic;">${text}</span>`;
    });
    text = text.replace(/__\*\*(.*?)\*\*__/g, (match, text) => {
        return `<span style="font-style: italic; font-weight: bolder;">${text}</span>`;
    });
    text = text.replace(/\*\*__(.*?)__\*\*/g, (match, text) => {
        return `<span style="font-style: italic; font-weight: bolder;">${text}</span>`;
    });
    text = text.replace(/\*\*__(.*?)\*\*__/g, (match, text) => {
        return `<span style="font-style: italic; font-weight: bolder;">${text}</span>`;
    });
    text = text.replace(/__\*\*(.*?)__\*\*/g, (match, text) => {
        return `<span style="font-style: italic; font-weight: bolder;">${text}</span>`;
    });

    return text;
}

function isMentions1Enabled() {
    return uvedChat;
}

function isMentions2Enabled() {
    return uvedSound;
}

function isMentions3Enabled() {
    return uvedWindows;
}

function isCustomEmojiEnabled() {
    return toggleCustomEmoji;
}

let domUpdateQueue = [];
let rafScheduled = false;
const audioCache = new Map();

function playSound(url) {
    if (!audioCache.has(url)) {
        audioCache.set(url, new Audio(url));
    }
    
    const audio = audioCache.get(url);
    audio.currentTime = 0;
    audio.play().catch(e => console.error("Звук не воспроизведен:", e));
}

function highlightMentions(text) {
    if (!isMentions1Enabled() || !window.myPlayerData) return text;

    const { id, nick } = window.myPlayerData;
    const regex = getMentionPattern(nick, id);
    
    let hasPersonalMention = false;
    let hasGlobalMention = false;
    
    const result = text.replace(regex, (match) => {
        const lowerMatch = match.toLowerCase();
        const lowerNick = nick.toLowerCase();
        
        if (match.includes(id) || lowerMatch.includes(lowerNick)) {
            hasPersonalMention = true;
            
            if (match.startsWith('@')) {
                return `<span class="personal-mention">@${match.substring(1)}</span>`;
            } else if (match.endsWith(',')) {
                const word = match.slice(0, -1);
                const symbol = match.slice(-1);
                return `<span class="personal-mention">${word}</span>${symbol}`;
            }
        }
        
        if (lowerMatch.includes('all') || lowerMatch.includes('everyone')) {
            hasGlobalMention = true;
            
            if (match.startsWith('@')) {
                return `<span class="global-mention">@${match.substring(1)}</span>`;
            } else if (lowerMatch.endsWith(',') || lowerMatch.endsWith(':')) {
                const word = match.slice(0, -1);
                const symbol = match.slice(-1);
                return `<span class="global-mention">${word}</span>${symbol}`;
            }
        }
        
        return match;
    });
    
    if (hasPersonalMention || hasGlobalMention) {
        sendNotify(2, "Уведомление", "Вас упомянули в чате!");
        
        if (isMentions2Enabled()) {
            const soundUrl = hasPersonalMention 
                ? 'https://free-sounds-lib.ru/sounds/zvuki-uvedomleniy-o-novyih-soobscheniyah/zvuk-dostavlennogo-soobscheniya/85284.mp3'
                : 'https://free-sounds-lib.ru/sounds/zvuki-uvedomleniy-o-novyih-soobscheniyah/zvonkoe-uvedomlenie-ob-sms/85289.mp3';
            
            playSound(soundUrl);
        }
    }
    
    return result;
}

function addMessageToChat(chatId, message, color = currentColor) {
    domUpdateQueue.push({ chatId, message, color });
    if (!rafScheduled) {
        rafScheduled = true;
        requestAnimationFrame(() => {
            processDomUpdates();
            rafScheduled = false;
        });
    }
}

function processDomUpdates() {
    const updates = domUpdateQueue.splice(0, domUpdateQueue.length);
    const fragment = document.createDocumentFragment();
    const logsByChat = new Map();
    
    // Группируем сообщения по чатам
    updates.forEach(({ chatId, message, color }) => {
        if (!logsByChat.has(chatId)) {
            const log = document.querySelector(`.chatlog[data-chat-id="${chatId}"]`);
            if (!log) return;
            logsByChat.set(chatId, { log, messages: [] });
        }

        const safe = escapeHtml(message);
        const withColor = colorify(safe);
        const withMedia = replaceMediaTags(withColor);
        const withEmojis = replaceTextWithEmojis(withMedia);
        const withMentions = highlightMentions(withEmojis);
        const withReply = formatReply(withMentions, chatId);
        const formattedMessage = HTMLstringify(withReply);
        logsByChat.get(chatId).messages.push(formattedMessage);
    });
    
    // Добавляем все сообщения одним batch'ем
    logsByChat.forEach(({ log, messages }, chatId) => {
        const fragment = document.createDocumentFragment();
        
        messages.forEach(msg => {
            const p = document.createElement('p');
            p.innerHTML = msg;
            fragment.appendChild(p);
        });
        
        log.appendChild(fragment);
        
        if (autoScrollEnabled[chatId] !== false) {
            log.scrollTop = log.scrollHeight;
        }
        
        // Обновляем историю
        const history = loadChatHistory(chatId);
        history.push(...messages);
        saveChatHistory(chatId, history);
        
        // Уведомление о новом сообщении
        if (chatId !== activeChatId) {
            const btn = document.querySelector(`.btn-chat[data-id="${chatId}"]`);
            if (btn && !btn.textContent.includes('🔔')) {
                btn.textContent += ' 🔔';
            }
        }
    });
}

function colorify(message) {
    const regex = /#([0-9A-Fa-f]{6})([\s\S]*?)(?=(?:#(?:[0-9A-Fa-f]{6}))|$)/g;

    return message.replace(regex, function(match, hex, text) {
        const hexUp = hex.toUpperCase();
        return `<span style="color:#${hexUp}">${text}</span>`;
    });
}

function HTMLstringify(line) {
    return `<p>${line}</p>`;
}

function addMessageToSAMP(message) {

    // Если сообщение начинается с точки (.)
    if (message.startsWith(".")) {
        const parts = message.slice(1).split(" ");
        const command = parts[0];
        const args = parts.slice(1).join(" ");
        const convertedCommand = auto_layout_keyboard_reverse(command);
        const fullMessage = `/${convertedCommand} ${args}`;
        cef.sendMessage(fullMessage);
    }
    // Если сообщение содержит эмодзи (проверяем по emojiReverseMap)
    else if (Object.keys(emojiReverseMap).some(emoji => message.includes(emoji))) {
        // Заменяем все эмодзи на их текстовые версии
        let processedMessage = message;
        Object.entries(emojiReverseMap).forEach(([emoji, text]) => {
            processedMessage = processedMessage.replaceAll(emoji, text);
        });
        cef.sendMessage(processedMessage);
    }
    // Если сообщение начинается с пробела
    else if (message.startsWith(" ")) {
        console.log("Пробел найден");
        const msgWithInvisibleSpace = " " + message.slice(1);
        cef.sendMessage(msgWithInvisibleSpace);
    }
    // Обычный текст (без эмодзи, точки и пробела в начале)
    else {
        cef.sendMessage(message);
    }
}


class ChatContextMenu {
    constructor() {
        this.contextMenu = document.getElementById('contextMenu');
        this.chatlog = document.querySelector('.chatlog');
        this.currentLine = null;
        this.selectedText = '';
        this.savedSelection = null;
        this.init();
    }

    init() {
        const copyColorBtn = document.getElementById('copyColor');

        this.chatlog.addEventListener('contextmenu', (e) => {
            e.preventDefault();

            const line = e.target.closest('p');
            if (!line) return;

            const selection = window.getSelection();
            if (selection.rangeCount > 0) {
                this.savedSelection = selection.getRangeAt(0).cloneRange();
                this.selectedText = selection.toString();
            } else {
                this.savedSelection = null;
                this.selectedText = '';
            }

            this.currentLine = line;
            this.showMenu(e.clientX, e.clientY);
            this.updateMenuItems();
        });

        document.addEventListener('click', (e) => {
            if (!this.contextMenu.contains(e.target)) {
                this.hideMenu();
            }
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.hideMenu();
            }
        });

        document.getElementById('copySelected').addEventListener('click', () => {
            this.copySelected();
            this.hideMenu();
        });

        document.getElementById('replyToMessage').addEventListener('click', () => {
            this.replyToMessage();
        });

        document.getElementById('copyLine').addEventListener('click', () => {
            this.copyLine();
            this.hideMenu();
        });
        if (copyColorBtn) {
            copyColorBtn.addEventListener('click', () => this.copyColor());
        }
        if (copyTextWithColorBtn) {
            copyTextWithColorBtn.addEventListener('click', () => this.copyTextWithColor());
        }
    }

    showMenu(x, y) {
        const menu = this.contextMenu;
        menu.style.display = 'block';
        menu.style.left = x + 'px';
        menu.style.top = y + 'px';

        const rect = menu.getBoundingClientRect();
        if (rect.right > window.innerWidth) {
            menu.style.left = (x - rect.width) + 'px';
        }
        if (rect.bottom > window.innerHeight) {
            menu.style.top = (y - rect.height) + 'px';
        }
    }

    hideMenu() {
        this.contextMenu.style.display = 'none';
        this.currentLine = null;
        this.selectedText = '';
    }

    replyToMessage() {
        if (!this.currentLine) {
            sendNotify(4, "Ошибка", "Не выбрано сообщение");
            return;
        }
        const originalText = this.getCleanText(this.currentLine);
        if (!originalText) {
            sendNotify(2, "Инфо", "Не удалось получить текст сообщения");
            return;
        }
        const time = this.getMessageTime(this.currentLine);
        if (!time) {
            sendNotify(2, "Инфо", "Не удалось определить время сообщения для ответа");
            return;
        }
        
        const input = document.getElementById('chat-input');
        if (!input) return;
        const prefix = `[R]${time}[R][A]`;
        input.value = prefix;
        input.focus();
        input.setSelectionRange(prefix.length, prefix.length);
        if (input.style.display === 'none') input.style.display = 'block';
    }

    getMessageTime(line) {
        if (!line) return null;
        const text = this.getCleanText(line);
        // Ищем время в начале строки (до символа "-" или "↩")
        const match = text.match(/^\[?(\d{2}:\d{2}:\d{2})\]?/);
        if (match) {
            // Если время в скобках, убираем их
            return toMSK(match[1]);
        }
        return null;
    }

    updateMenuItems() {
        const copySelectedBtn = document.getElementById('copySelected');
        const copyColorBtn = document.getElementById('copyColor');

        const hasSelection = this.selectedText && this.selectedText.length > 0;

        copySelectedBtn.style.opacity = hasSelection ? '1' : '0.5';
        copySelectedBtn.textContent = hasSelection
            ? `Копировать "${this.selectedText.substring(0, 20)}${this.selectedText.length > 20 ? '...' : ''}"`
            : 'Копировать выделенное';

        if (copyColorBtn) {
            copyColorBtn.style.opacity = hasSelection ? '1' : '0.5';
        }

        if (this.replyBtn) {
            const hasTime = this.currentLine && this.getMessageTime(this.currentLine) !== null;
            this.replyBtn.style.opacity = hasTime ? '1' : '0.5';
            this.replyBtn.style.pointerEvents = hasTime ? 'auto' : 'none';
        }
    }

    copySelected() {
        if (this.selectedText) {
            this.copyToClipboard(this.selectedText);
            this.showNotification('Выделенный текст скопирован');
        }
    }

    copyLine() {
        if (this.currentLine) {
            const lineText = this.getCleanText(this.currentLine);
            this.copyToClipboard(lineText);
            this.showNotification('Строка скопирована целиком');
        }
    }

    getSelectedTextColor() {
        if (!this.savedSelection) return null;

        let node = this.savedSelection.startContainer;

        if (node.nodeType === Node.TEXT_NODE) {
            node = node.parentElement;
        }

        if (!(node instanceof HTMLElement)) return null;

        return window.getComputedStyle(node).color || null;
    }

    copyColor() {
        if (!this.selectedText || !this.savedSelection) return;

        const cssColor = this.getSelectedTextColor();
        if (!cssColor) {
            this.showNotification('Не удалось определить цвет текста');
            return;
        }

        const hexColor = this.rgbToHex(cssColor);
        if (!hexColor) {
            this.showNotification('Ошибка преобразования цвета');
            return;
        }

        this.copyToClipboard(hexColor);
        this.showNotification(`Цвет скопирован: ${hexColor}`);
        this.hideMenu();
    }

    getCleanText(element) {
        const temp = document.createElement('div');
        temp.innerHTML = element.innerHTML;
        return temp.textContent || temp.innerText || '';
    }
    rgbToHex(color) {
        if (!color) return null;

        if (color.startsWith('#')) {
            return color.toLowerCase();
        }

        const match = color.match(/rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i);
        if (!match) return null;

        const r = parseInt(match[1], 10);
        const g = parseInt(match[2], 10);
        const b = parseInt(match[3], 10);

        return (
            '#' +
            [r, g, b]
                .map(v => v.toString(16).padStart(2, '0'))
                .join('')
        );
    }

    async copyToClipboard(text) {
        try {
            await navigator.clipboard.writeText(text);
        } catch (err) {
            console.error('Ошибка navigator.clipboard:', err);
            const textArea = document.createElement('textarea');
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-999999px';
            textArea.style.top = '-999999px';
            document.body.appendChild(textArea);
            textArea.select();
            try {
                document.execCommand('copy');
            } catch (err) {
                console.error('Не удалось скопировать текст:', err);
            }
            document.body.removeChild(textArea);
        }
    }

    showNotification(message) {
        const notification = document.createElement('div');
        notification.textContent = message;
        notification.style.backgroundColor ="rgba(0,0,0,0.5)";
        notification.style.color = "white";
        notification.style.minWidth = "250px";
        notification.style.maxWidth = "280px";
        notification.style.borderRadius = "8px";
        notification.style.fontSize = "16px";
        notification.style.fontFamily = "Arial";
        notification.style.fontWeight = "bold";
        notification.style.textAlign = "center";
        document.body.appendChild(notification);
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 500);
    }
}

const emojiReverseMap = {
    "😀": ":D",
    "😁": ":U-2:",
    "😄": ":U-3:",
    "😆": ":U-4:",
    "😂": "xd",
    "🤣": "xdd",
    "😉": ":U-7:",
    "😊": ":U-8:",
    "😋": ":U-9:",
    "😎": ":U-10:",
    "😍": ":U-11:",
    "🥰": ":U-12:",
    "😘": ":U-13:",
    "🙂": ":)",
    "😙": ":U-15:",
    "🤗": ":U-16:",
    "🤩": ":U-17:",
    "🤔": ":U-18:",
    "🤨": ":U-19:",
    "😐": ":U-20:",
    "😑": ":U-21:",
    "😶": ":U-22:",
    "🙄": ":U-23:",
    "😏": ":U-24:",
    "😣": ":U-25:",
    "😮": ":U-26:",
    "😥": ":U-27:",
    "🤐": ":U-28:",
    "😪": ":U-29:",
    "🥱": ":U-30:",
    "😴": ":U-31:",
    "😛": ":U-32:",
    "😒": ":(",
    "🙃": ":U-34:",
    "🤑": ":U-35:",
    "😖": ":U-36:",
    "😤": ":U-37:",
    "😢": ":U-38:",
    "😭": ":U-39:",
    "🤯": ":U-40:",
    "😱": ":U-41:",
    "🥵": ":U-42:",
    "🥶": ":U-43:",
    "🤪": ":U-44:",
    "😵": ":U-45:",
    "😠": ":U-46:",
    "🤬": ":U-47:",
    "🤢": ":U-48:",
    "🤮": ":U-49:",
    "😇": ":U-50:",
    "🥳": ":U-51:",
    "🥺": ":U-52:",
    "🤠": ":U-53:",
    "🤡": ":U-54:",
    "🧐": ":U-55:",
    "🤓": ":U-56:",
    "😈": ":U-57:",
    "👿": ":U-58:",
    "💀": ":U-59:",
    "☠️": ":U-60:",
    "🌚": ":U-61:",
    "🌞": ":U-62:",
    "💩": ":U-63:",
    "👽": ":U-64:",
    "🐵": ":U-65:",
    "🐹": ":U-66:",
    "🐔": ":U-67:",
    "🐷": ":U-68:",
    "🐘": ":U-69:",
    "🐓": ":U-70:",
    "🐞": ":U-71:",
    "🖕": ":U-72:",
    "👍": ":U-73:",
    "👎": ":U-74:",
    "🤘": ":U-75:",
    "🤙": ":U-76:",
    "👋": ":U-77:",
    "👌": ":U-78:",
    "👉": ":U-79:",
    "👈": ":U-80:",
    "❤️": ":U-81:",
    "🔥": ":U-82:",
    "✅": ":U-83:",
    "❌": ":U-84:",
    "⚡": ":U-85:",
    "💥": ":U-86:",
    "♿": ":U-87:",
    "0️⃣": ":U-88:",
    "1️⃣": ":U-89:",
    "2️⃣": ":U-90:",
    "3️⃣": ":U-91:",
    "4️⃣": ":U-92:",
    "5️⃣": ":U-93:",
    "6️⃣": ":U-94:",
    "7️⃣": ":U-95:",
    "8️⃣": ":U-96:",
    "9️⃣": ":U-97:",
    "🔟": ":U-98:",
    "⭐": ":U-99:",
    "🌟": ":U-100:",
    "✨": ":U-101:",
    "🎉": ":U-102:",
    "🎊": ":U-103:",
    "🎈": ":U-104:",
    "🎁": ":U-105:",
    "💫": ":U-106:",
    "💥": ":U-107:",
    "🍕": ":U-108:",
    "🍔": ":U-109:",
    "🍟": ":U-110:",
    "🌭": ":U-111:",
    "🍿": ":U-112:",
    "🍩": ":U-113:",
    "🍪": ":U-114:",
    "🎂": ":U-115:",
    "☕": ":U-116:",
    "🍺": ":U-117:",
    "🍻": ":U-118:",
    "🍷": ":U-119:",
    "🥂": ":U-120:",
    "🍾": ":U-121:",
    "⚽": ":U-122:",
    "🏀": ":U-123:",
    "🏈": ":U-124:",
    "⚾": ":U-125:",
    "🎾": ":U-126:",
    "🏐": ":U-127:",
    "🏓": ":U-128:",
    "🎮": ":U-129:",
    "🕹️": ":U-130:",
    "🎲": ":U-131:",
    "🚗": ":U-132:",
    "🚕": ":U-133:",
    "🚓": ":U-134:",
    "🚑": ":U-135:",
    "🚒": ":U-136:",
    "🚜": ":U-137:",
    "🏍️": ":U-138:",
    "✈️": ":U-139:",
    "🚀": ":U-140:",
    "🛸": ":U-141:",
    "🏠": ":U-142:",
    "🏢": ":U-143:",
    "🏦": ":U-144:",
    "🏥": ":U-145:",
    "🏪": ":U-146:",
    "🏫": ":U-147:",
    "🏭": ":U-148:",
    "📱": ":U-149:",
    "💻": ":U-150:",
    "🖥️": ":U-151:",
    "⌨️": ":U-152:",
    "🖱️": ":U-153:",
    "💾": ":U-154:",
    "💿": ":U-155:",
    "📀": ":U-156:",
    "🔒": ":U-157:",
    "🔓": ":U-158:",
    "🔑": ":U-159:",
    "🗝️": ":U-160:",
    "⚙️": ":U-161:",
    "🛠️": ":U-162:",
    "🔧": ":U-163:",
    "🔨": ":U-164:",
    "📌": ":U-165:",
    "📎": ":U-166:",
    "✂️": ":U-167:",
    "📏": ":U-168:",
    "📝": ":U-169:",
    "📖": ":U-170:",
    "📚": ":U-171:",
    "💡": ":U-172:",
    "🔔": ":U-173:",
    "📢": ":U-174:",
    "📣": ":U-175:",
    "🔊": ":U-176:",
    "🔇": ":U-177:",
    "⏰": ":U-178:",
    "⏳": ":U-179:",
    "⌛": ":U-180:",
    "📅": ":U-181:",
    "📆": ":U-182:",
    "🟢": ":U-183:",
    "🔴": ":U-184:",
    "🟡": ":U-185:",
    "🔵": ":U-186:",
    "⚫": ":U-187:",
    "⚪": ":U-188:",
    "🟣": ":U-189:",
    "🟠": ":U-190:",
    "🟤": ":U-191:",
    "<img src='https://openmoji.org/data/color/svg/E068.svg' style='height: 30px; position: relative; top: 7px;'>": ":js:", // javascript emoji
    "<img src='https://openmoji.org/data/color/svg/E062.svg' style='height: 30px; position: relative; top: 7px;'>": ":C-code:", // C emoji
    "<img src='https://openmoji.org/data/color/svg/E063.svg' style='height: 30px; position: relative; top: 7px;'>": ":C++:", // C++ emoji
    "<img src='https://openmoji.org/data/color/svg/E064.svg' style='height: 30px; position: relative; top: 7px;'>": ":C#:", // C# emoji
    "<img src='https://openmoji.org/data/color/svg/E0FF.svg' style='height: 30px; position: relative; top: 7px;'>": ":ubuntu:", // Ubuntu emoji
    "<img src='https://openmoji.org/data/color/svg/F000.svg' style='height: 30px; position: relative; top: 7px;'>": ":windows:", // Windows emoji
    "<img src='https://openmoji.org/data/color/svg/E061.svg' style='height: 35px; position: relative; top: 7px;'>": ":discord:", // discord emoji
    "<img src='https://cdn-icons-png.flaticon.com/128/2111/2111646.png' style='height: 25px; position: relative; top: 3px;'>": ":telegram:", // telegram emoji
    "<img src='https://cdn-icons-png.flaticon.com/128/5968/5968835.png' style='height: 25px; position: relative; top: 3px;'>": ":vk:", // vk emoji
    "<img src='https://openmoji.org/data/color/svg/E040.svg' style='height: 30px; position: relative; top: 7px;'>": ":twitter:", // Twitter emoji
    "<img src='https://openmoji.org/data/color/svg/E042.svg' style='height: 30px; position: relative; top: 7px;'>": ":facebook:", // Facebook emoji
    "<img src='https://openmoji.org/data/color/svg/E044.svg' style='height: 30px; position: relative; top: 7px;'>": ":youtube:", // Youtube emoji
    "<img src='https://cdn-icons-png.flaticon.com/128/3046/3046121.png' style='height: 30px; position: relative; top: 3px;'>": ":TikTok:", // TikTok emoji
    "<img src='https://openmoji.org/data/color/svg/E045.svg' style='height: 30px; position: relative; top: 7px;'>": ":github:", // Github emoji
    "<img src='https://openmoji.org/data/color/svg/E054.svg' style='height: 30px; position: relative; top: 7px;'>": ":chrome:", // Chrome emoji
    "<img src='https://www.blast.hk/styles/io_dark/images/blasthack/logo_b_new.png' style='height: 30px; position: relative; top: 3px;'>": ":blasthack:", // blasthack emoji
    "<img src='https://cdn-icons-png.flaticon.com/128/588/588314.png' style='height: 30px; position: relative; top: 3px;'>": ":GTA:", // GTA emoji
    "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_001.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":deagle:", // Deagle emoji
    "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_002.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":AK47:", // AK47 emoji
    "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_027.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":M4:", // M4 emoji
    "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_004.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":ShotGun:", // ShotGun emoji
    "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_029.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":MiniGun:", // MiniGun emoji
    "<img src='https://cdn3.emoji.gg/emojis/65458-minecraft.png' style='height: 30px; position: relative; top: 3px;'>": ":minecraft:", // MinecraftHeart emoji
    "<img src='https://cdn3.emoji.gg/emojis/85500-minecraftheart.png' style='height: 30px; position: relative; top: 3px;'>": ":mineheart:", // MinecraftHeart emoji
    "<img src='https://cdn3.emoji.gg/emojis/16469-diamond.png' style='height: 30px; position: relative; top: 3px;'>": ":diamond:", // MinecraftDiamond emoji
    "<img src='https://cdn3.emoji.gg/emojis/64587-jeb-spinning.gif' style='height: 30px; position: relative; top: 3px;'>": ":jeb-spinning:", // MinecraftJeb-Spinn emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/100997/emodzi-mcbeespin.gif' style='height: 30px; position: relative; top: 3px;'>": ":mcbeespin:", // Minecraftmcbeespin emoji
    "<img src='https://cdn3.emoji.gg/emojis/21980-dance.gif' style='height: 30px; position: relative; top: 3px;'>": ":parrot-dance:", // MinecraftParrot-Dance emoji
    "<img src='https://cdn3.emoji.gg/emojis/77742-pet-the-frog.gif' style='height: 30px; position: relative; top: 3px;'>": ":pet-the-frog:", // MinecraftPet-The-Frog emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/105091/emodzi-banned_sign_ban_hammer_bean.gif' style='height: 50px; position: relative; top: 3px;'>": ":ban:", // ban emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106775/emodzi-poopparrot.gif' style='height: 50px; position: relative; top: 3px;'>": ":pparrot:", // poopparrot emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106775/emodzi-middleparrot.gif' style='height: 50px; position: relative; top: 3px;'>": ":mparrot:", // middleparrot emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106022/emodzi-peepo-toxic.gif' style='height: 50px; position: relative; top: 3px;'>": ":pepetoxic:", // pepetoxic emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/100526/emodzi-fingerme.gif' style='height: 50px; position: relative; top: 3px;'>": ":fingerme:", // fingerme emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106261/emodzi-pepe-nopes.gif' style='height: 50px; position: relative; top: 3px;'>": ":pepe-nopes:", // pepe-nopes emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106261/emodzi-peepocoffeehiss.gif' style='height: 50px; position: relative; top: 3px;'>": ":pcoffee:", // peepocoffeehiss emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/104874/emodzi-pixel-void.gif' style='height: 50px; position: relative; top: 3px;'>": ":pixel-void:", // peepocoffeehiss emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/105903/emodzi-bonk.webp' style='height: 50px; position: relative; top: 3px;'>": ":bonk:", // peepocoffeehiss emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/107067/emodzi-verified_blue.gif' style='height: 30px; position: relative; top: 3px;'>": ":verify:", // peepocoffeehiss emoji
    "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/101461/emodzi-yb-angry2.webp' style='height: 50px; position: relative; top: 3px;'>": ":ya-te-blya:", // peepocoffeehiss emoji

};

const emojiGroups = {
    "default": {},
    "custom": {},
    "animated": {},
    "you": {}
};

const textToEmojiMap = {};
for (const emoji in emojiReverseMap) {
    textToEmojiMap[emojiReverseMap[emoji]] = emoji;
}

function replaceEmojisWithText(text) {
    text = text.normalize('NFC');
    for (const emoji in emojiReverseMap) {
        const regex = new RegExp(emoji.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, '\\$1'), 'g');
        text = text.replace(regex, emojiReverseMap[emoji]);
    }
    return text;
}

const sortedEmojiKeys = Object.keys(textToEmojiMap).sort((a, b) => b.length - a.length);
const emojiRegexPattern = sortedEmojiKeys
    .map(k => k.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'))
    .join('|');
const emojiRegex = new RegExp(emojiRegexPattern, 'g');

function replaceTextWithEmojis(text) {
    if (isCustomEmojiEnabled()) {
        const customEmojiRegex = /:([A-Za-z0-9_-]{10,}):/g;
        text = text.replace(customEmojiRegex, (match, base64Code) => {
            const fullCode = `:${base64Code}:`;
            const emojiData = decodeEmojiData(fullCode);
            if (emojiData && emojiData.u) {
                return `<img src="${emojiData.u}" style="height: ${emojiData.s}; position: relative; top: 3px;">`;
            }
            return textToEmojiMap[fullCode] || match;
        });
    }

    // 2. Используем ОДИН regex для всех эмодзи вместо цикла
    return text.replace(emojiRegex, match =>
        `<span class="unicode-emoji">${textToEmojiMap[match]}</span>`
    );
}

function loadCustomEmojis() {
    const savedEmojis = localStorage.getItem('customEmojis');
    if (savedEmojis) {
        return JSON.parse(savedEmojis);
    }
    return {};
}

function saveCustomEmojis(emojis) {
    localStorage.setItem('customEmojis', JSON.stringify(emojis));
}

function addCustomEmoji(url, size = '70px') {
    const emojiId = encodeEmojiData(url, size);
    const emojiHtml = `<img src="${url}" style="height: ${size};">`;
    
    // Сохраняем в локальное хранилище для быстрого доступа
    const customEmojis = loadCustomEmojis();
    customEmojis[emojiId] = {
        html: emojiHtml,
        url: url,
        size: size
    };
    saveCustomEmojis(customEmojis);
    
    return emojiId;
}

function encodeEmojiData(url, size) {
    // Максимальное сжатие
    const cleanUrl = url
        .replace(/^https?:\/\//, '')
        .replace(/^www\./, '');
    const cleanSize = size.replace('px', '');
    
    // Формат: размер:url (самый компактный разделитель)
    const dataString = `${cleanSize}:${cleanUrl}`;
    
    // Самый короткий Base64
    return `:${btoa(dataString)
        .replace(/\+/g, '')
        .replace(/\//g, '')
        .replace(/=/g, '')}:`;
}

function decodeEmojiData(emojiId) {
    try {
        const base64 = emojiId.slice(1, -1);
        const paddedBase64 = base64 + '='.repeat((4 - base64.length % 4) % 4);
        const dataString = atob(paddedBase64);
        
        const colonIndex = dataString.indexOf(':');
        const size = dataString.substring(0, colonIndex);
        const url = dataString.substring(colonIndex + 1);
        
        return {
            u: 'https://' + url,
            s: size + 'px'
        };
    } catch (e) {
        return null;
    }
}

document.addEventListener("DOMContentLoaded", () => {
    const chatInput = document.getElementById('chat-input');
    const chatLog = document.querySelector('.chatlog');
    const emojiMenu = document.getElementById('emoji-menu');
    const langElement = document.getElementById('lang');
    const contextmenu = document.getElementById('contextMenu')
    const contextMenuText = document.getElementById('contextMenuText');
    const boldBtn = document.getElementById('bold');
    const italicBtn = document.getElementById('italic');
    const calculationResult = document.getElementById('calculation-result');

    createChatLog("default");
    openCloseChat(chatActive);
    loadChats();

    let currentLang = 'RU';

    const updateLang = () => {
        langElement.textContent = currentLang;
        langElement.title = `Сменить язык (${currentLang === 'RU' ? 'EN' : 'RU'})`;
    };


    document.getElementById('chat-logs-container').addEventListener('click', (e) => {
        const btn = e.target.closest('.media-btn');
        if (!btn) return;

        const type = btn.dataset.type;
        const url = decodeURIComponent(btn.dataset.url);

        // Ключ для кеша
        const key = `${type}:${url}`;

        // Если элемент ещё не создан — создаём и кэшируем
        if (!mediaElementCache[key]) {
            let el;
            if (type === 'img' || type === 'gif') {
                el = document.createElement('img');
                el.src = url;
                el.className = type === 'gif' ? 'chat-gif' : 'chat-img';
            } else if (type === 'vid') {
                el = document.createElement('video');
                el.controls = true;
                el.muted = false;
                el.className = 'chat-vid';

                const source = document.createElement('source');
                source.src = url;
                source.type = 'video/mp4';
                el.appendChild(source);
            } else if (type === 'aud') {
                el = document.createElement('audio');
                el.controls = true;
                el.className = 'chat-audio';

                const source = document.createElement('source');
                source.src = url;
                source.type = 'audio/mpeg';
                el.appendChild(source);
            }

            mediaElementCache[key] = el;
        }

        // Клонируем (важно для повтора показа)
        const elementClone = mediaElementCache[key].cloneNode(true);
        showMediaModalElement(elementClone);
    });

    document.addEventListener('keydown', (e) => {
        if (e.altKey && e.shiftKey) {
            currentLang = currentLang === 'RU' ? 'EN' : 'RU';
            updateLang();
        }
        if (e.key === 'F7') {
            e.preventDefault();
            e.stopPropagation();
            document.getElementById('chat-input').style.display = 'none';
            document.querySelector('.chatlog[data-chat-id]').style.display = 'none';
            document.getElementById('lang').style.display = 'none';
            document.querySelector('.chatlog[data-chat-id]').scrollTop = document.querySelector('.chatlog').scrollHeight
        }
    });

    const emojis = Object.keys(emojiReverseMap);
    const customEmojis = loadCustomEmojis();

    Object.entries(emojiReverseMap).forEach(([emoji, text]) => {
        if (emoji.startsWith('<img') && emoji.includes('.gif') || emoji.includes('.mp4')) {
            emojiGroups.animated[emoji] = text;
        } else if (emoji.startsWith('<img')) {
            emojiGroups.custom[emoji] = text;
        } else {
            emojiGroups.default[emoji] = text;
        }
    });

    Object.entries(customEmojis).forEach(([text, data]) => {
        emojiGroups.you[data.html] = text;
    });

    const tabsContainer = document.querySelector('.tabs-container')
    const contentContainer = document.querySelector('.content-container')
    
    function createTabs() {
        tabsContainer.innerHTML = '';
        
        Object.keys(emojiGroups).forEach((groupName, index) => {
            // Пропускаем вкладку "you", если кастомные эмодзи отключены
            if (groupName === 'you' && !isCustomEmojiEnabled) {
                return;
            }
            
            const tab = document.createElement('button');
            tab.textContent = groupName.charAt(0).toUpperCase() + groupName.slice(1);
            tab.dataset.group = groupName;
            tab.className = 'emoji-tab';
            
            // Первая вкладка активна по умолчанию
            if (index === 0) {
                tab.classList.add('active');
            }
            
            tab.addEventListener('click', () => {
                // Убираем активный класс у всех вкладок
                document.querySelectorAll('.emoji-tab').forEach(btn => {
                    btn.classList.remove('active');
                });
                
                // Добавляем активный класс текущей вкладке
                tab.classList.add('active');
                
                // Показываем эмодзи выбранной группы
                showEmojiGroup(groupName);
            });
            
            tabsContainer.appendChild(tab);
        });
    }
    
    // Функция показа эмодзи группы
    function showEmojiGroup(groupName) {
        contentContainer.innerHTML = '';
        const defaultText = "Выберите пак эмодзи:";

        if (groupName === 'you') {
            // Показываем форму добавления и список кастомных эмодзи
            showCustomEmojiForm();
        }
        
        const emojiContainer = document.createElement('div');
        const emojiHeader = document.querySelector('.emoji-header');
        emojiContainer.className = 'emoji-group';
        

        Object.entries(emojiGroups[groupName]).forEach(([emoji, text]) => {
            const emojiItem = document.createElement('div');
            emojiItem.innerHTML = emoji;
            emojiItem.dataset.tooltip = text;
            emojiItem.title = text;
            
            emojiItem.addEventListener('mouseenter', () => {
                emojiHeader.innerHTML = emojiItem.innerHTML;

                // Если img внутри, увеличиваем через height
                const img = emojiHeader.querySelector('img');
                if (img) {
                    img.style.height = "159px";
                } else {
                    emojiHeader.style.fontSize = "114px";
                }
            });

            emojiItem.addEventListener('mouseleave', () => {
                emojiHeader.innerHTML = defaultText;

                const img = emojiHeader.querySelector('img');
                if (img) {
                    img.style.height = "32px"; // или дефолт
                } else {
                    emojiHeader.style.fontSize = "14px";
                }
            });


            // Определяем класс размера
            const isBigSticker = text.match(/:cat([1-9]|10):/);
            emojiItem.className = isBigSticker ? 'emoji-item large' : 'emoji-item standard';
            
            emojiItem.addEventListener('click', () => {
                emojiItem.style.background = 'rgba(74, 144, 226, 0.3)';
                emojiItem.style.borderColor = 'rgba(74, 144, 226, 1)';
                
                setTimeout(() => {
                    chatInput.value += text;
                    chatInput.focus();
                    emojiMenu.style.display = 'none';
                }, 100);
            });
            
            emojiContainer.appendChild(emojiItem);
        });
        
        contentContainer.appendChild(emojiContainer);
    }

    function showDeleteEmojiModal() {
        const customEmojis = loadCustomEmojis();
        
        if (Object.keys(customEmojis).length === 0) {
            alert('У вас нет кастомных эмодзи для удаления');
            return;
        }
        
        const modal = document.createElement('div');
        modal.className = 'delete-emoji-modal';
        
        const modalContent = document.createElement('div');
        modalContent.className = 'modalContentEmoji';
        
        modalContent.innerHTML = `
            <h3>Удаление эмодзи</h3>
            <div class="delete-emoji-list"></div>
            <div class="modal-buttons">
                <button class="cancel-delete-btn">Отмена</button>
                <button class="delete-all-btn">Удалить все</button>
            </div>
        `;
        
        const deleteList = modalContent.querySelector('.delete-emoji-list');


        // Заполняем список эмодзи для удаления
        Object.entries(customEmojis).forEach(([emojiCode, emojiData]) => {
            const item = document.createElement('div');
            item.className = 'emoji-delete-item';

            item.innerHTML = `
                <div class="emoji-delete-preview">
                    ${emojiData.html}
                    <span class="emoji-code">${emojiCode}</span>
                </div>
                <div class="emoji-url-container">
                    <input type="text" class="emoji-url-input" value="${emojiData.url}" readonly>
                    <button class="copyBtn-emoji" title="Копировать ссылку">📋</button>
                </div>
                <button class="deleteBtn-emoji">Удалить</button>
            `;

            const deleteBtn = item.querySelector('.deleteBtn-emoji');
            const copyBtn = item.querySelector('.copyBtn-emoji');
            const urlInput = item.querySelector('.emoji-url-input');

            deleteBtn.addEventListener('mouseenter', () => {
                deleteBtn.style.background = 'rgba(231, 76, 60, 0.9)';
            });
            
            deleteBtn.addEventListener('mouseleave', () => {
                deleteBtn.style.background = 'rgba(231, 76, 60, 0.7)';
            });
            
            deleteBtn.addEventListener('click', () => {
                deleteCustomEmoji(emojiCode);
                item.remove();
                
                // Если список пуст, закрываем модальное окно
                if (deleteList.children.length === 0) {
                    modal.remove();
                    showEmojiGroup('you'); // Обновляем основную вкладку
                }
            });

            // Обработчик копирования ссылки
            copyBtn.addEventListener('click', async () => {
                try {
                    await navigator.clipboard.writeText(emojiData.url);
                    copyBtn.textContent = '✅';
                    copyBtn.style.background = 'rgba(46, 204, 113, 0.7)';
                    
                    setTimeout(() => {
                        copyBtn.textContent = '📋';
                        copyBtn.style.background = '';
                    }, 1500);
                } catch (err) {
                    console.error('Ошибка копирования:', err);
                    // Fallback метод
                    urlInput.select();
                    document.execCommand('copy');
                    copyBtn.textContent = '✅';
                    setTimeout(() => {
                        copyBtn.textContent = '📋';
                    }, 1500);
                }
            });

            // Клик по input для выделения всего текста
            urlInput.addEventListener('click', () => {
                urlInput.select();
            });

            deleteList.appendChild(item);
        });
        
        // Обработчики кнопок модального окна
        const cancelBtn = modalContent.querySelector('.cancel-delete-btn');
        const deleteAllBtn = modalContent.querySelector('.delete-all-btn');
        
        cancelBtn.addEventListener('click', () => {
            modal.remove();
        });
        
        deleteAllBtn.addEventListener('click', () => {
                deleteAllCustomEmojis();
                modal.remove();
                showEmojiGroup('you'); // Обновляем основную вкладку
        });
        
        // Закрытие модального окна при клике вне его
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.remove();
            }
        });
        
        modal.appendChild(modalContent);
        document.body.appendChild(modal);
    }

    function deleteCustomEmoji(emojiCode) {
        const customEmojis = loadCustomEmojis();
        delete customEmojis[emojiCode];
        saveCustomEmojis(customEmojis);
        
        // Обновляем группы эмодзи
        emojiGroups.you = {};
        Object.entries(customEmojis).forEach(([text, data]) => {
            emojiGroups.you[data.html] = text;
        });
    }

    // Функция удаления всех кастомных эмодзи
    function deleteAllCustomEmojis() {
        saveCustomEmojis({});
        emojiGroups.you = {};
    }

    function showCustomEmojiForm() {
        const formContainer = document.createElement('div');
        formContainer.className = 'custom-emoji-form';
        
        formContainer.innerHTML = `
            <div class="form-group">
                <label for="emoji-url">Ссылка на изображение:</label>
                <input type="url" id="emoji-url" placeholder="https://example.com/emoji.png">
            </div>
            <div class="form-group">
                <label for="emoji-size">Размер (px):</label>
                <input type="number" id="emoji-size" min="50" max="80" placeholder="70" value="70">
            </div>
            <button class="add-emoji-btn">Добавить эмодзи</button>
            <button class="delete-emoji-btn">Удалить эмодзи</button>
            
        `;
        
        contentContainer.appendChild(formContainer);
        
        // Обработчик добавления эмодзи
        const urlInput = document.getElementById('emoji-url');
        const sizeInput = document.getElementById('emoji-size');
        const addButton = formContainer.querySelector('.add-emoji-btn');
        const delButton = formContainer.querySelector('.delete-emoji-btn')

        sizeInput.addEventListener("change", () =>{
            sizeInput.value = Math.max(30, Math.min(80, parseInt(sizeInput.value, 10) || 30));
        });

        addButton.addEventListener('click', function() {

            const url = urlInput.value.trim();
            let size = sizeInput.value.trim() || '70px';

            if (size && !isNaN(size) && !size.endsWith('px') && !size.endsWith('em') && !size.endsWith('%')) {
            size = size + 'px';
            } else if (!size) {
                size = '70px'; // значение по умолчанию
            }
            
            if (url) {
                const emojiId = addCustomEmoji(url, size);
                
                // Обновляем группы эмодзи
                const customEmojis = loadCustomEmojis();
                emojiGroups.you = {};
                Object.entries(customEmojis).forEach(([text, data]) => {
                    emojiGroups.you[data.html] = text;
                });
                
                // Показываем обновленный список
                showEmojiGroup('you');
                
                // Очищаем поля
                urlInput.value = '';
                sizeInput.value = '32';
            }
        });
        delButton.addEventListener('click', function() {
            showDeleteEmojiModal();
        });
    }

    createTabs();
    
    // Показываем первую группу по умолчанию
    showEmojiGroup('default');

    boldBtn.addEventListener('click', () => {
        const startPos = chatInput.selectionStart;
        const endPos = chatInput.selectionEnd;
        const selectedText = chatInput.value.substring(startPos, endPos);

        if (selectedText) {
            let newText;
            // Если текст уже жирный (в любом варианте)
            if ((selectedText.startsWith('**') && selectedText.endsWith('**')) ||
                (selectedText.startsWith('__**') && selectedText.endsWith('**__')) ||
                (selectedText.startsWith('**__') && selectedText.endsWith('__**'))) {
                // Удаляем **
                newText = selectedText.replace(/\*\*/g, '');
                // Если был курсив, сохраняем __
                if (selectedText.includes('__')) {
                    newText = newText.replace(/__/g, '');
                    newText = '__' + newText + '__';
                }
            } else {
                // Добавляем **
                newText = '**' + selectedText + '**';
                // Если был курсив, делаем __**text**__
                if (selectedText.startsWith('__') && selectedText.endsWith('__')) {
                    newText = '__**' + selectedText.slice(2, -2) + '**__';
                }
            }

            chatInput.value = chatInput.value.substring(0, startPos) + newText + chatInput.value.substring(endPos);
            // Корректируем позицию выделения
            const lengthDiff = newText.length - selectedText.length;
            chatInput.setSelectionRange(startPos, endPos + lengthDiff);
        }
        contextMenuText.style.display = 'none';
        chatInput.focus();
    });

    italicBtn.addEventListener('click', () => {
        const startPos = chatInput.selectionStart;
        const endPos = chatInput.selectionEnd;
        const selectedText = chatInput.value.substring(startPos, endPos);

        if (selectedText) {
            let newText;
            // Если текст уже курсивный (в любом варианте)
            if ((selectedText.startsWith('__') && selectedText.endsWith('__')) ||
                (selectedText.startsWith('**__') && selectedText.endsWith('__**')) ||
                (selectedText.startsWith('__**') && selectedText.endsWith('**__'))) {
                // Удаляем __
                newText = selectedText.replace(/__/g, '');
                // Если был жирный, сохраняем **
                if (selectedText.includes('**')) {
                    newText = newText.replace(/\*\*/g, '');
                    newText = '**' + newText + '**';
                }
            } else {
                // Добавляем __
                newText = '__' + selectedText + '__';
                // Если был жирный, делаем **__text__**
                if (selectedText.startsWith('**') && selectedText.endsWith('**')) {
                    newText = '**__' + selectedText.slice(2, -2) + '__**';
                }
            }

            chatInput.value = chatInput.value.substring(0, startPos) + newText + chatInput.value.substring(endPos);
            // Корректируем позицию выделения
            const lengthDiff = newText.length - selectedText.length;
            chatInput.setSelectionRange(startPos, endPos + lengthDiff);
        }
        contextMenuText.style.display = 'none';
        chatInput.focus();
    });


    function evaluateMathExpression(expr) {
        // Удаляем все пробелы
        expr = expr.replace(/\s+/g, '');

        // Проверяем на наличие только разрешенных символов
        if (!/^[\d+\-*/().]+$/.test(expr)) {
            throw new Error('Недопустимые символы в выражении');
        }

        // Проверяем сбалансированность скобок
        const stack = [];
        for (const char of expr) {
            if (char === '(') stack.push(char);
            if (char === ')') {
                if (stack.length === 0) throw new Error('Несбалансированные скобки');
                stack.pop();
            }
        }
        if (stack.length > 0) throw new Error('Несбалансированные скобки');

        // Вычисляем выражение
        try {
            // Используем Function для безопасного вычисления
            return new Function(`return ${expr}`)();
        } catch (e) {
            throw new Error('Некорректное математическое выражение');
        }
    }

    chatInput.addEventListener('input', function() {
        const inputText = chatInput.value.trim();

        // Проверяем, содержит ли ввод математическое выражение
        if (/[+\-*/]/.test(inputText) && inputText.length > 2) {
            try {
                // Безопасное вычисление выражения
                const result = evaluateMathExpression(inputText);
                calculationResult.textContent = `Результат: ${result}`;
                calculationResult.style.display = 'block';
            } catch (e) {
                calculationResult.style.display = 'none';
            }
        } else {
            calculationResult.style.display = 'none';
        }
    });

    chatInput.addEventListener('mouseup', () => {
        const selectedText = chatInput.value.substring(
            chatInput.selectionStart,
            chatInput.selectionEnd
        );

        // Проверяем, есть ли ** и __ в выделенном тексте (в любом порядке)
        const isBold =
            (selectedText.startsWith('**') && selectedText.endsWith('**')) ||
            (selectedText.startsWith('__**') && selectedText.endsWith('**__')) ||
            (selectedText.startsWith('**__') && selectedText.endsWith('__**'));

        const isItalic =
            (selectedText.startsWith('__') && selectedText.endsWith('__')) ||
            (selectedText.startsWith('**__') && selectedText.endsWith('__**')) ||
            (selectedText.startsWith('__**') && selectedText.endsWith('**__'));

        // Обновляем стиль кнопок
        boldBtn.style.color = isBold ? "#00ff00" : '#ffffff';
        italicBtn.style.color = isItalic ? "#00ff00" : '#ffffff';

        chatInput.focus()
    });


    chatInput.addEventListener('contextmenu', (e) => {
        const selectedText = chatInput.value.substring(
            chatInput.selectionStart,
            chatInput.selectionEnd
        );

        if (!selectedText.trim()) {
            e.preventDefault();
            const rect = chatInput.getBoundingClientRect();
            emojiMenu.style.top = `${rect.bottom + window.scrollY}px`;
            emojiMenu.style.left = `${rect.left + window.scrollX}px`;
            emojiMenu.style.display = 'flex';
        } else {
            e.preventDefault();
            contextMenuText.style.display = 'flex';
            contextMenuText.style.top = `${e.clientY}px`;
            contextMenuText.style.left = `${e.clientX}px`;
        }
    });

    document.addEventListener('click', (e) => {
        if (!emojiMenu.contains(e.target) && e.target !== chatInput) {
            emojiMenu.style.display = 'none';
        }
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && emojiMenu.style.display !== 'none') {
            emojiMenu.style.display = 'none';
        }
    });


    chatInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            let value = chatInput.value;
            if (value.replace(/\s+/g, '').length > 0) {
                messageHistory.unshift(value);
                historyIndex = -1;
                chatInput.disabled = true;
                chatInput.placeholder = "Отправка...";

                setTimeout(() => {
                    try {
                        value = replaceEmojisWithText(value);
                        const currentChat = chats.find(c => c.id === activeChatId);

                        // Если это кастомный чат с командой /s $1
                        if (currentChat && currentChat.cmd) {
                            // Подставляем ВЕСЬ текст как $1, даже если нет совпадения с регуляркой
                            let cmd = currentChat.cmd.replace(/\$1/g, value);
                            addMessageToSAMP(cmd);
                        } else {
                            // Обычный чат (дефолтный или без команды)
                            addMessageToSAMP(value);
                        }
                    } catch (err) {
                        console.error("Ошибка отправки:", err);
                        sendNotify(4, "Ошибка", "Ошибка загрузки CEF! Перезагрузите скрипт, нажатием клавиш CTRL+R")
                    }
                    chatInput.disabled = false;
                    chatInput.placeholder = "Напишите сообщение...";
                    chatInput.value = '';
                }, 50);
            }
            calculationResult.style.display = 'none';
        }

        if (e.key === 'Escape') {
            chatInput.value = '';
            chatInput.style.display = 'none';
            calculationResult.style.display = 'none';
            chatLog.scrollTop = chatLog.scrollHeight;
            historyIndex = -1;
            console.log("Press ESC")
        }

        if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (historyIndex < messageHistory.length - 1) {
                historyIndex++;
                chatInput.value = messageHistory[historyIndex];
            }
        }

        if (e.key === 'ArrowDown') {
            e.preventDefault();
            if (historyIndex > -1) {
                historyIndex--;
                chatInput.value = historyIndex >= 0 ? messageHistory[historyIndex] : '';
            }
        }
    });

    new ChatContextMenu();
});
