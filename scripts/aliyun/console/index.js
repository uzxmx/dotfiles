#!/usr/bin/env node

'use strict';

let puppeteer, totpGenerate;
try {
  puppeteer = require('puppeteer-core');
  ({ generate: totpGenerate } = require('otplib'));
} catch (e) {
  console.error(`Missing dependency: ${e.message}`);
  console.error('Run: npm install -g puppeteer-core otplib');
  process.exit(1);
}

const LOGIN_URL = process.env.CONSOLE_URL;
const USERNAME  = process.env.ALI_USERNAME;
const PASSWORD  = process.env.ALI_PASSWORD;
const TOTP_SEED = process.env.ALI_TOTP_SEED;

if (!LOGIN_URL || !USERNAME || !PASSWORD) {
  console.error('Missing required env vars: CONSOLE_URL, ALI_USERNAME, ALI_PASSWORD');
  process.exit(1);
}

async function fill(page, selector, value) {
  const el = await page.waitForSelector(selector, { timeout: 10000 });
  await el.click({ clickCount: 3 });
  await el.type(value, { delay: 30 });
}

async function main() {
  const browser = await puppeteer.launch({
    executablePath: process.env.CHROME_PATH || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    headless: false,
    defaultViewport: null,
    args: ['--start-maximized'],
  });

  const pages = await browser.pages();
  const page = pages.length > 0 ? pages[0] : await browser.newPage();

  try {
    await page.goto(LOGIN_URL, { waitUntil: 'networkidle2', timeout: 30000 });

    // Step 1: username
    await fill(page, '#loginName', USERNAME);
    await page.keyboard.press('Enter');

    // Step 2: password (appears after username step)
    await page.waitForSelector('#loginPassword', { visible: true, timeout: 10000 });
    await fill(page, '#loginPassword', PASSWORD);
    await page.keyboard.press('Enter');

    // console.log('Wait for networkidle2');
    // await page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 20000 }).catch(() => {});

    // MFA
    console.log('Wait for MFA');
    const mfaInput = await page.waitForSelector(
      [
        'input[name="mfaCode"]',
        'input[name="code"]',
        'input[name="answer"]',
        'input[name="mfa"]',
        'input[placeholder*="安全码"]',
        'input[placeholder*="MFA"]',
        'input[placeholder*="验证码"]',
      ].join(', '),
      { timeout: 8000 }
    ).catch(() => null);

    if (mfaInput) {
      if (!TOTP_SEED) {
        console.error('MFA required but ALI_TOTP_SEED is not set');
        // process.exit(1);
        return;
      }
      console.log('Wait for MFA');
      const totp = await totpGenerate({ secret: TOTP_SEED, algorithm: 'sha1', digits: 6, period: 30 });
      console.log('Input MFA');
      await mfaInput.type(totp, { delay: 3 });
      await Promise.all([
        page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 20000 }).catch(() => {}),
        page.keyboard.press('Enter'),
      ]);
    }

    console.log('Login complete');
  } catch (err) {
    const screenshot = `/tmp/aliyun-console-error.png`;
    await page.screenshot({ path: screenshot, fullPage: true });
    console.error('Login failed:', err.message);
    console.error('Screenshot saved to', screenshot);
    // process.exit(1);
    return;
  }
}

main();
