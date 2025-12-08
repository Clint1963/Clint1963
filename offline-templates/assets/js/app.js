/**
 * מערכת תבניות מקומית - Offline Template System
 * JavaScript ראשי לטעינת והצגת תבניות
 *
 * המערכת טוענת תבניות מקובץ JSON מקומי ומציגה אותן ב-Grid
 * תומכת בחיפוש, סינון והורדת קבצים
 *
 * כל הכתובות יחסיות - מתאים לסביבה ללא אינטרנט
 */

// === קונפיגורציה ===
const CONFIG = {
    templatesJsonPath: 'config/templates.json',
    templatesFolder: 'templates/',
    previewsFolder: 'previews/',
    defaultPreview: 'assets/icons/default-preview.svg'
};

// === משתנים גלובליים ===
let allTemplates = [];
let filteredTemplates = [];

// === אלמנטים מה-DOM ===
const elements = {
    templatesGrid: null,
    searchInput: null,
    totalCount: null,
    loadingState: null
};

// === פונקציות עזר ===

/**
 * יוצר אלמנט HTML עם תכונות
 * @param {string} tag - סוג האלמנט
 * @param {object} attrs - תכונות האלמנט
 * @param {string|HTMLElement|Array} children - תוכן האלמנט
 * @returns {HTMLElement}
 */
function createElement(tag, attrs = {}, children = null) {
    const element = document.createElement(tag);

    Object.entries(attrs).forEach(([key, value]) => {
        if (key === 'className') {
            element.className = value;
        } else if (key === 'onclick' || key === 'oninput') {
            element[key] = value;
        } else if (key.startsWith('data-')) {
            element.setAttribute(key, value);
        } else {
            element.setAttribute(key, value);
        }
    });

    if (children) {
        if (Array.isArray(children)) {
            children.forEach(child => {
                if (typeof child === 'string') {
                    element.appendChild(document.createTextNode(child));
                } else if (child instanceof HTMLElement) {
                    element.appendChild(child);
                }
            });
        } else if (typeof children === 'string') {
            element.innerHTML = children;
        } else if (children instanceof HTMLElement) {
            element.appendChild(children);
        }
    }

    return element;
}

/**
 * מחזיר את סיומת הקובץ
 * @param {string} filename - שם הקובץ
 * @returns {string}
 */
function getFileExtension(filename) {
    return filename.split('.').pop().toLowerCase();
}

/**
 * מחזיר אייקון לפי סוג הקובץ
 * @param {string} format - סוג הקובץ
 * @returns {string} - SVG HTML
 */
function getFormatIcon(format) {
    const icons = {
        pptx: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path>
            <polyline points="13 2 13 9 20 9"></polyline>
            <rect x="8" y="13" width="8" height="4" rx="1"></rect>
        </svg>`,
        pdf: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
            <line x1="16" y1="13" x2="8" y2="13"></line>
            <line x1="16" y1="17" x2="8" y2="17"></line>
            <polyline points="10 9 9 9 8 9"></polyline>
        </svg>`,
        default: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path>
            <polyline points="13 2 13 9 20 9"></polyline>
        </svg>`
    };

    return icons[format] || icons.default;
}

/**
 * מחזיר את אייקון ההורדה
 * @returns {string} - SVG HTML
 */
function getDownloadIcon() {
    return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
        <polyline points="7 10 12 15 17 10"></polyline>
        <line x1="12" y1="15" x2="12" y2="3"></line>
    </svg>`;
}

/**
 * מחזיר את אייקון התצוגה המקדימה
 * @returns {string} - SVG HTML
 */
function getPreviewIcon() {
    return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="11" cy="11" r="8"></circle>
        <path d="m21 21-4.35-4.35"></path>
        <path d="M11 8v6"></path>
        <path d="M8 11h6"></path>
    </svg>`;
}

// === פונקציות לניהול התבניות ===

/**
 * טוען את קובץ ה-JSON עם רשימת התבניות
 * @returns {Promise<Array>}
 */
async function loadTemplatesFromJson() {
    try {
        const response = await fetch(CONFIG.templatesJsonPath);

        if (!response.ok) {
            throw new Error(`שגיאה בטעינת קובץ התבניות: ${response.status}`);
        }

        const data = await response.json();
        return data.templates || [];
    } catch (error) {
        console.error('שגיאה בטעינת התבניות:', error);

        // אם יש שגיאה, מחזירים רשימה ריקה עם הודעה
        showErrorMessage('לא ניתן לטעון את רשימת התבניות. אנא וודא שקובץ config/templates.json קיים.');
        return [];
    }
}

/**
 * מציג הודעת שגיאה
 * @param {string} message - הודעת השגיאה
 */
function showErrorMessage(message) {
    const grid = elements.templatesGrid;
    if (!grid) return;

    grid.innerHTML = `
        <div class="no-results" style="grid-column: 1/-1;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"></circle>
                <line x1="12" y1="8" x2="12" y2="12"></line>
                <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
            <h3>שגיאה בטעינה</h3>
            <p>${message}</p>
        </div>
    `;
}

/**
 * יוצר כרטיס תבנית
 * @param {object} template - אובייקט התבנית
 * @returns {HTMLElement}
 */
function createTemplateCard(template) {
    const format = getFileExtension(template.file);
    const previewPath = CONFIG.previewsFolder + template.preview;
    const filePath = CONFIG.templatesFolder + template.file;

    const card = createElement('article', { className: 'template-card' });

    // תצוגה מקדימה
    const preview = createElement('div', { className: 'template-preview' });

    const img = createElement('img', {
        src: previewPath,
        alt: template.name,
        loading: 'lazy'
    });

    // טיפול בשגיאת טעינת תמונה
    img.onerror = function() {
        this.src = CONFIG.defaultPreview;
        this.alt = 'תצוגה מקדימה לא זמינה';
    };

    preview.appendChild(img);

    // תגית (אם קיימת)
    if (template.badge) {
        const badge = createElement('span', { className: 'template-badge' }, template.badge);
        preview.appendChild(badge);
    }

    // שכבת hover עם כפתור תצוגה מקדימה
    const overlay = createElement('div', { className: 'template-overlay' });
    const previewBtn = createElement('button', {
        className: 'preview-btn',
        onclick: () => openPreview(previewPath, template.name)
    }, `${getPreviewIcon()} הגדל תמונה`);
    overlay.appendChild(previewBtn);
    preview.appendChild(overlay);

    card.appendChild(preview);

    // מידע על התבנית
    const info = createElement('div', { className: 'template-info' });

    const name = createElement('h3', { className: 'template-name' }, template.name);
    info.appendChild(name);

    if (template.description) {
        const desc = createElement('p', { className: 'template-description' }, template.description);
        info.appendChild(desc);
    }

    // מטא-דאטה ולחצן הורדה
    const meta = createElement('div', { className: 'template-meta' });

    const formatInfo = createElement('span', { className: 'template-format' });
    formatInfo.innerHTML = `${getFormatIcon(format)} ${format.toUpperCase()}`;
    meta.appendChild(formatInfo);

    const downloadLink = createElement('a', {
        href: filePath,
        className: 'download-btn',
        download: template.file,
        title: `הורד ${template.name}`
    });
    downloadLink.innerHTML = `${getDownloadIcon()} הורד`;
    meta.appendChild(downloadLink);

    info.appendChild(meta);
    card.appendChild(info);

    return card;
}

/**
 * פותח תצוגה מקדימה של תמונה
 * @param {string} imageSrc - נתיב התמונה
 * @param {string} title - כותרת
 */
function openPreview(imageSrc, title) {
    // יצירת מודאל לתצוגה מקדימה
    const modal = createElement('div', {
        className: 'preview-modal',
        onclick: (e) => {
            if (e.target.classList.contains('preview-modal')) {
                modal.remove();
            }
        }
    });

    // הוספת סטייל למודאל
    modal.style.cssText = `
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.9);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
        padding: 2rem;
        cursor: pointer;
    `;

    const img = createElement('img', {
        src: imageSrc,
        alt: title
    });

    img.style.cssText = `
        max-width: 90%;
        max-height: 90%;
        object-fit: contain;
        border-radius: 8px;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        cursor: default;
    `;

    const closeBtn = createElement('button', {
        onclick: () => modal.remove()
    });
    closeBtn.innerHTML = `
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width: 24px; height: 24px;">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
    `;
    closeBtn.style.cssText = `
        position: absolute;
        top: 1rem;
        left: 1rem;
        background: rgba(255, 255, 255, 0.1);
        border: none;
        color: white;
        width: 48px;
        height: 48px;
        border-radius: 50%;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.2s;
    `;
    closeBtn.onmouseover = () => closeBtn.style.background = 'rgba(255, 255, 255, 0.2)';
    closeBtn.onmouseout = () => closeBtn.style.background = 'rgba(255, 255, 255, 0.1)';

    modal.appendChild(img);
    modal.appendChild(closeBtn);
    document.body.appendChild(modal);

    // סגירה עם Escape
    const handleEscape = (e) => {
        if (e.key === 'Escape') {
            modal.remove();
            document.removeEventListener('keydown', handleEscape);
        }
    };
    document.addEventListener('keydown', handleEscape);
}

/**
 * מרנדר את התבניות ל-Grid
 * @param {Array} templates - מערך התבניות
 */
function renderTemplates(templates) {
    const grid = elements.templatesGrid;
    if (!grid) return;

    grid.innerHTML = '';

    if (templates.length === 0) {
        grid.innerHTML = `
            <div class="no-results" style="grid-column: 1/-1;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="11" cy="11" r="8"></circle>
                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
                <h3>לא נמצאו תבניות</h3>
                <p>נסה לחפש מונח אחר או הסר את הסינון</p>
            </div>
        `;
        return;
    }

    templates.forEach(template => {
        const card = createTemplateCard(template);
        grid.appendChild(card);
    });
}

/**
 * מעדכן את מונה התבניות
 * @param {number} count - מספר התבניות
 */
function updateCount(count) {
    if (elements.totalCount) {
        elements.totalCount.textContent = count;
    }
}

/**
 * מסנן תבניות לפי מחרוזת חיפוש
 * @param {string} query - מחרוזת החיפוש
 */
function filterTemplates(query) {
    const searchTerm = query.trim().toLowerCase();

    if (!searchTerm) {
        filteredTemplates = [...allTemplates];
    } else {
        filteredTemplates = allTemplates.filter(template => {
            return (
                template.name.toLowerCase().includes(searchTerm) ||
                (template.description && template.description.toLowerCase().includes(searchTerm)) ||
                (template.tags && template.tags.some(tag => tag.toLowerCase().includes(searchTerm)))
            );
        });
    }

    renderTemplates(filteredTemplates);
    updateCount(filteredTemplates.length);
}

/**
 * מציג מצב טעינה
 */
function showLoading() {
    const grid = elements.templatesGrid;
    if (!grid) return;

    grid.innerHTML = `
        <div class="loading" style="grid-column: 1/-1;">
            <div class="loading-spinner"></div>
            <p>טוען תבניות...</p>
        </div>
    `;
}

/**
 * מסתיר מצב טעינה
 */
function hideLoading() {
    const loading = document.querySelector('.loading');
    if (loading) {
        loading.remove();
    }
}

// === אתחול המערכת ===

/**
 * אתחול האפליקציה
 */
async function initApp() {
    // קישור לאלמנטים
    elements.templatesGrid = document.getElementById('templates-grid');
    elements.searchInput = document.getElementById('search-input');
    elements.totalCount = document.getElementById('total-count');

    // הצגת מצב טעינה
    showLoading();

    // טעינת התבניות
    allTemplates = await loadTemplatesFromJson();
    filteredTemplates = [...allTemplates];

    // רינדור התבניות
    renderTemplates(filteredTemplates);
    updateCount(filteredTemplates.length);

    // הגדרת מאזין לחיפוש
    if (elements.searchInput) {
        elements.searchInput.addEventListener('input', (e) => {
            filterTemplates(e.target.value);
        });

        // ניקוי החיפוש עם Escape
        elements.searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                elements.searchInput.value = '';
                filterTemplates('');
            }
        });
    }

    console.log('מערכת התבניות נטענה בהצלחה!');
    console.log(`נטענו ${allTemplates.length} תבניות`);
}

// הפעלת האפליקציה כשה-DOM מוכן
document.addEventListener('DOMContentLoaded', initApp);

// ייצוא פונקציות לשימוש חיצוני (אופציונלי)
window.TemplateSystem = {
    reload: async () => {
        allTemplates = await loadTemplatesFromJson();
        filteredTemplates = [...allTemplates];
        renderTemplates(filteredTemplates);
        updateCount(filteredTemplates.length);
    },
    getTemplates: () => allTemplates,
    search: filterTemplates
};
