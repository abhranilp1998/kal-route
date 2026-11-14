// Runs a Flutter integration test compiled as a web app
// (`flutter build web -t integration_test/<file>.dart --profile`) in headless
// Chrome via playwright-core, streams the test log, and exits non-zero unless
// the test reports "All tests passed!".
//
// Usage: node run_it_web.js <port> [timeoutSeconds]
// Env:   CHROME_PATH (default /usr/bin/google-chrome), IT_SCREENSHOT_DIR (optional)
const {chromium} = require('playwright-core');

const port = process.argv[2] || '8111';
const timeoutMs = (Number(process.argv[3]) || 600) * 1000;
const chromePath = process.env.CHROME_PATH || '/usr/bin/google-chrome';
const shotDir = process.env.IT_SCREENSHOT_DIR;

(async () => {
  let passed = false;
  let failed = false;
  const browser = await chromium.launch({executablePath: chromePath, args: ['--no-sandbox']});
  const ctx = await browser.newContext({viewport: {width: 390, height: 844}, deviceScaleFactor: 1});
  const page = await ctx.newPage();
  page.on('console', (m) => {
    const t = m.text();
    if (t.includes('GL Driver Message')) return;
    console.log('[console]', t.slice(0, 2000));
    if (t.includes('All tests passed!')) passed = true;
    if (t.includes('Some tests failed') || t.includes('Test failed.') || /\[E\]\s*$/.test(t)) failed = true;
  });
  page.on('pageerror', (e) => {
    console.log('[pageerror]', e.message);
  });

  await page.goto(`http://localhost:${port}/`);
  const t0 = Date.now();
  while (!passed && !failed && Date.now() - t0 < timeoutMs) {
    try {
      await page.waitForTimeout(1000);
    } catch (_) {
      break; // page closed by the test harness after finishing
    }
  }
  if (shotDir) await page.screenshot({path: `${shotDir}/it_final.png`}).catch(() => {});
  await browser.close().catch(() => {});

  if (passed && !failed) {
    console.log('RESULT: PASS');
    process.exit(0);
  }
  console.log(failed ? 'RESULT: FAIL' : `RESULT: TIMEOUT after ${timeoutMs / 1000}s`);
  process.exit(1);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
