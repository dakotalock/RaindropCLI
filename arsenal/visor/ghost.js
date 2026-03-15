const express = require('express');
const { chromium } = require('playwright-core');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
app.use(bodyParser.json());

let browser;
let context;
let page;

async function launchVisor() {
    console.log("Launching Stealth Raindrop Visor (Grail-Spec)...");
    browser = await chromium.launch({ 
        headless: true,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-blink-features=AutomationControlled',
            '--disable-dev-shm-usage',
            '--no-first-run',
            '--no-default-browser-check',
            '--disable-default-apps',
            '--disable-features=TranslateUI',
            '--disable-ipc-flooding-protection'
        ] 
    });
    
    context = await browser.newContext({
        viewport: { width: 1920, height: 1080 },
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    });

    // Inject the Holy Grail Stealth Script
    await context.addInitScript(() => {
        Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
        Object.defineProperty(navigator, 'languages', { get: () => ['en-US', 'en'] });
        Object.defineProperty(navigator, 'plugins', { get: () => [1, 2, 3, 4, 5] });
        window.chrome = { runtime: {} };
    });

    page = await context.newPage();
    console.log("Stealth Visor Active on Port 7777");
}

app.post('/goto', async (req, res) => {
    const { url } = req.body;
    try {
        console.log(`Navigating to ${url}...`);
        await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 30000 });
        res.json({ status: "Stealth Visor navigated to " + url });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.post('/eval', async (req, res) => {
    const { code } = req.body;
    try {
        const result = await page.evaluate(code);
        res.json({ result });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.get('/snapshot', async (req, res) => {
    try {
        const screenshotPath = path.join(process.env.HOME, '.raindrop/visor/snapshot.png');
        await page.screenshot({ path: screenshotPath });
        res.json({ path: screenshotPath });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

launchVisor();
app.listen(7777);
