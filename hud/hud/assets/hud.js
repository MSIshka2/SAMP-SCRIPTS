window.cef = {
    emit: function(event, data) {
        if (window.cef && window.cef.js_event) {
            window.cef.js_event(event, JSON.stringify(data));
        }
    }
};

function numberWithSpaces(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
}

function updateHealth(health) {
    const healthBar = document.getElementById('hp_bar');
    if (healthBar) {
        healthBar.style.width = Math.max(0, Math.min(100, health)) + '%';
    }
}

function updateArm(armor) {
    const armorBar = document.getElementById('arm_bar');
    if (armorBar) {
        armorBar.style.width = Math.max(0, Math.min(100, armor)) + '%';
    }
}

function updateOxy(oxygen) {
    const oxyBar = document.getElementById('oxy_bar');
    const oxyContainer = document.getElementById('oxygen-bar-container');
    if (oxyBar && oxyContainer) {
        oxyContainer.style.display = 'flex';
        oxyBar.style.width = Math.max(0, Math.min(100, oxygen)) + '%';
    }
}

function updateStam(stamina) {
    const stamBar = document.getElementById('stam_bar');
    if (stamBar) {
        stamBar.style.width = Math.max(0, Math.min(100, stamina)) + '%';
    }
}

function updateWeapon(weaponId) {
    const weaponIcon = document.getElementById('bullets');
    if (weaponIcon) {
        weaponIcon.src = 'assets/weapons/' + weaponId + '.png';
    }
}

function updateAmmo(ammoCount) {
    const ammoElement = document.getElementById('bc_wpc');
    if (ammoElement) {
        if (ammoCount < 1) {
            ammoElement.style.display = 'none';
        } else {
            ammoElement.style.display = 'block';
            ammoElement.textContent = ammoCount;
        }
    }
}

function updateMoney(money) {
    const moneyElement = document.getElementById('money_count');
    if (moneyElement) {
        moneyElement.textContent = '$ ' + numberWithSpaces(money);
    }
}

function updateREP(rep) {
    const repElement = document.getElementById('rep_count');
    if (repElement) {
        repElement.style.display = 'block';
        repElement.textContent = 'R ' + numberWithSpaces(rep);
    }
}

(function initSpeedometer() {
    const speedMarks = document.getElementById('speedMarks');
    if (!speedMarks) return;
    
    const totalMarks = 36;
    
    for (let i = 0; i < totalMarks; i++) {
        const mark = document.createElement('div');
        const angle = -135 + (i * 270 / (totalMarks - 1));
        mark.className = i % 4 === 0 ? 'speed-mark major' : 'speed-mark';
        mark.style.transform = `translateX(-50%) rotate(${angle}deg)`;
        mark.setAttribute('data-index', i);
        speedMarks.appendChild(mark);
    }
})();

function updateCar(status, speed, fuel, health, engine) {
    const speedometer = document.getElementById('speedbody');
    const speedValue = document.getElementById('speed');
    const needle = document.getElementById('rpm');
    const marks = document.querySelectorAll('.speed-mark');
    
    if (status == 1) {
        speedometer.style.display = 'flex';
        
        if (speedValue) {
            speedValue.textContent = Math.round(speed);
        }
        
        if (needle) {
            const maxSpeed = 200;
            const rotation = -135 + (Math.min(speed, maxSpeed) / maxSpeed) * 270;
            needle.style.transform = 'translateX(-50%) rotate(' + rotation + 'deg)';
        }
        
        const totalMarks = 36;
        const activeMarks = Math.floor((Math.min(speed, 200) / 200) * totalMarks);
        marks.forEach((mark, index) => {
            if (index < activeMarks) {
                mark.classList.add('active');
            } else {
                mark.classList.remove('active');
            }
        });
        
    } else {
        speedometer.style.display = 'none';
        
        marks.forEach(mark => {
            mark.classList.remove('active');
        });
    }
}

function updateClock() {
    const now = new Date();
    
    const localHours = String(now.getHours()).padStart(2, '0');
    const localMinutes = String(now.getMinutes()).padStart(2, '0');
    const localSeconds = String(now.getSeconds()).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const year = now.getFullYear();
    
    const mskOffset = 3 * 60 * 60 * 1000;
    const mskTime = new Date(now.getTime() + mskOffset + now.getTimezoneOffset() * 60000);
    const mskHours = String(mskTime.getHours()).padStart(2, '0');
    const mskMinutes = String(mskTime.getMinutes()).padStart(2, '0');
    const mskSeconds = String(mskTime.getSeconds()).padStart(2, '0');
    
    const timeString = localHours + ':' + localMinutes + ':' + localSeconds + '\n' +
                        mskHours + ':' + mskMinutes + ':' + mskSeconds + '\n' +
                        day + '.' + month + '.' + year;
    
    const timeElement = document.getElementById('time');
    if (timeElement) {
        timeElement.textContent = timeString;
    }
}

function sendNotify(type, text) {
    const notification = document.getElementById('notf_1');
    const notifIcon = document.getElementById('notf-icon');
    const notifImg = document.getElementById('notf_img');
    const notifHead = document.getElementById('notf_head');
    const notifBody = document.getElementById('notf_body');
    
    if (!notification) return;
    
    notification.classList.add('show');
    
    if (type == 1) {
        notifIcon.className = 'notification-icon info';
        notifImg.src = 'assets/info.png';
        notifHead.textContent = 'Информация';
    } else if (type == 2) {
        notifIcon.className = 'notification-icon error';
        notifImg.src = 'assets/cross.png';
        notifHead.textContent = 'Ошибка';
    } else if (type == 3) {
        notifIcon.className = 'notification-icon success';
        notifImg.src = 'assets/check.png';
        notifHead.textContent = 'Успех';
    }
    
    notifBody.textContent = text;
    
    setTimeout(function() {
        notification.classList.remove('show');
    }, 3000);
}

function hideOxygenBar() {
    const oxyContainer = document.getElementById('oxygen-bar-container');
    if (oxyContainer) {
        oxyContainer.style.display = 'none';
    }
}

updateClock();
setInterval(updateClock, 1000);

console.log('HUD initialized successfully!')