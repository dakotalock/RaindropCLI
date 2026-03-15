const { app, BrowserWindow, ipcMain } = require('electron');
const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');

const visorApp = express();
visorApp.use(bodyParser.json());

let mainWindow;

app.commandLine.appendSwitch('no-sandbox');
app.commandLine.appendSwitch('disable-gpu');
app.commandLine.appendSwitch('disable-software-rasterizer');

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      offscreen: false
    },
    title: "Raindrop Visor | Autonomous Browsing Shell",
    backgroundColor: '#000000'
  });

  mainWindow.loadURL('https://google.com'); // Initial landing
}

app.whenReady().then(createWindow);

// API COMMANDS
visorApp.post('/goto', (req, res) => {
  const { url } = req.body;
  if (mainWindow) {
    mainWindow.loadURL(url);
    res.json({ status: "Navigating to " + url });
  } else {
    res.status(500).json({ error: "Visor Window not ready." });
  }
});

visorApp.post('/eval', async (req, res) => {
  const { code } = req.body;
  try {
    const result = await mainWindow.webContents.executeJavaScript(code);
    res.json({ result });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

visorApp.get('/snapshot', async (req, res) => {
    try {
        const image = await mainWindow.capturePage();
        const screenshotPath = path.join(process.env.HOME, '.raindrop/visor/snapshot.png');
        const fs = require('fs');
        fs.writeFileSync(screenshotPath, image.toPNG());
        res.json({ path: screenshotPath });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

visorApp.listen(7777, () => {
  console.log('Visor Control Server active on Port 7777');
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
