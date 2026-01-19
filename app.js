// Design Canvas Simulator - Shared Logic
// Can be used by both heavy_canva_fonts.html and heavy_canva_fonts_no_sw.html

const images = [
    'imgs/1.png', 'imgs/2.png', 'imgs/3.png', 'imgs/4.png', 'imgs/5.png',
    'imgs/6.png', 'imgs/7.png', 'imgs/8.png', 'imgs/9.png', 'imgs/10.png', 'imgs/11.png'
];

const fonts = [
    { name: 'Canva Sans', class: 'font-canva-sans' },
    { name: 'Canva Sans Extra', class: 'font-canva-extra' },
    { name: 'HelloFont ChuYuan 65', class: 'font-chuyuan-65' },
    { name: 'HelloFont CangLan', class: 'font-canglan' },
    { name: 'MaShanZheng', class: 'font-mashanzheng' },
    { name: 'HelloFont MoQu', class: 'font-moqu' },
    { name: 'LongCang', class: 'font-longcang' },
    { name: 'SourceHanSerif SC', class: 'font-sourcehan' },
    { name: 'ZCOOLXiaoWei', class: 'font-zcool' },
    { name: 'LiuJianMaoCao', class: 'font-liujian' },
    { name: 'ZhiMangXing', class: 'font-zhimang' },
    { name: 'Bold Regular', class: 'font-bold-regular' },
    { name: 'Heavy Regular', class: 'font-heavy-regular' },
    { name: 'HelloFont ChuYuan 75', class: 'font-chuyuan-75' },
    { name: 'HelloFont ChuYuan 45', class: 'font-chuyuan-45' },
    { name: 'HelloFont FangZhuan 35', class: 'font-fangzhuan-35' },
    { name: 'HelloFont LieHei 65', class: 'font-liehei-65' },
    { name: 'HelloFont LingLong', class: 'font-linglong' },
    { name: 'IwaTxt Eb', class: 'font-iwatxt-eb' },
    { name: 'IwaTxt Bd', class: 'font-iwatxt-bd' }
];

const textSamples = [
    '设计让生活更美好',
    'Empower the world to design',
    'デザインで世界を変える',
    '创意无限可能',
    'Unlimited creativity',
    '简单易用的设计工具',
    'Professional Design',
    '赋能世界去设计',
    'Design made simple',
    '视觉设计的力量',
    'Create amazing content',
    '打造精彩内容',
    'Typography Excellence',
    '书法艺术',
    'Visual Impact'
];

let elements = [];
let elementCounter = 0;

function addImageToCanvas() {
    const canvas = document.getElementById('designCanvas');
    const img = document.createElement('img');
    const randomImage = images[Math.floor(Math.random() * images.length)];

    img.src = randomImage;
    img.className = 'canvas-image';

    const wrapper = document.createElement('div');
    wrapper.className = 'canvas-element';
    wrapper.style.left = Math.random() * 70 + '%';
    wrapper.style.top = Math.random() * 70 + '%';
    wrapper.style.width = (150 + Math.random() * 200) + 'px';
    wrapper.style.zIndex = Math.floor(Math.random() * 50);

    wrapper.appendChild(img);
    canvas.appendChild(wrapper);
    elements.push(wrapper);
    elementCounter++;
    updateStats();
}

function addTextToCanvas() {
    const canvas = document.getElementById('designCanvas');
    const randomFont = fonts[Math.floor(Math.random() * fonts.length)];
    const randomText = textSamples[Math.floor(Math.random() * textSamples.length)];

    const textDiv = document.createElement('div');
    textDiv.className = 'canvas-element canvas-text ' + randomFont.class;
    textDiv.textContent = randomText;
    textDiv.style.left = Math.random() * 70 + '%';
    textDiv.style.top = Math.random() * 70 + '%';
    textDiv.style.fontSize = (16 + Math.random() * 24) + 'px';
    textDiv.style.zIndex = Math.floor(Math.random() * 50);
    textDiv.style.color = '#' + Math.floor(Math.random()*16777215).toString(16);

    canvas.appendChild(textDiv);
    elements.push(textDiv);
    elementCounter++;
    updateStats();
}

function addMultipleElements() {
    for (let i = 0; i < 5; i++) {
        if (Math.random() > 0.5) {
            addImageToCanvas();
        } else {
            addTextToCanvas();
        }
    }
}

function clearCanvas() {
    const canvas = document.getElementById('designCanvas');
    canvas.innerHTML = '';
    elements = [];
    elementCounter = 0;
    updateStats();
}

function updateStats() {
    const elementCountEl = document.getElementById('elementCount');

    if (elementCountEl) {
        elementCountEl.textContent = elementCounter;
    }
}

// Initialize canvas with some elements
function initializeCanvas() {
    console.log('Initializing design canvas...');

    // Get target count from localStorage or use default
    const ELEMENT_COUNT_KEY = 'target-element-count';
    const targetCount = parseInt(localStorage.getItem(ELEMENT_COUNT_KEY) || '100');

    // Add elements upfront to simulate a busy design
    for (let i = 0; i < targetCount; i++) {
        setTimeout(() => {
            if (Math.random() > 0.4) {
                addImageToCanvas();
            } else {
                addTextToCanvas();
            }
        }, i * 50);
    }
}

// Adjust elements to match target count
function adjustElementsToTarget(targetCount) {
    const currentCount = elementCounter;

    if (targetCount > currentCount) {
        // Add more elements
        const toAdd = targetCount - currentCount;
        console.log(`Adding ${toAdd} elements to reach target of ${targetCount}`);

        for (let i = 0; i < toAdd; i++) {
            setTimeout(() => {
                if (Math.random() > 0.4) {
                    addImageToCanvas();
                } else {
                    addTextToCanvas();
                }
            }, i * 30);
        }
    } else if (targetCount < currentCount) {
        // Remove elements
        const toRemove = currentCount - targetCount;
        console.log(`Removing ${toRemove} elements to reach target of ${targetCount}`);

        for (let i = 0; i < toRemove; i++) {
            if (elements.length > 0) {
                const elementToRemove = elements.pop();
                if (elementToRemove && elementToRemove.parentNode) {
                    elementToRemove.parentNode.removeChild(elementToRemove);
                }
                elementCounter--;
            }
        }
        updateStats();
    }
}

// Expose function globally for use by HTML
window.adjustElementsToTarget = adjustElementsToTarget;

// Make elements draggable
function setupDraggableElements() {
    document.addEventListener('mousedown', function(e) {
        if (e.target.closest('.canvas-element')) {
            const element = e.target.closest('.canvas-element');
            let offsetX = e.clientX - element.offsetLeft;
            let offsetY = e.clientY - element.offsetTop;

            function moveElement(e) {
                element.style.left = (e.clientX - offsetX) + 'px';
                element.style.top = (e.clientY - offsetY) + 'px';
            }

            function stopMoving() {
                document.removeEventListener('mousemove', moveElement);
                document.removeEventListener('mouseup', stopMoving);
            }

            document.addEventListener('mousemove', moveElement);
            document.addEventListener('mouseup', stopMoving);
        }
    });
}

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
        initializeCanvas();
        setupDraggableElements();
    });
} else {
    // DOM is already ready
    initializeCanvas();
    setupDraggableElements();
}
