## npm install

If `package-lock.json` satisfies `package.json`, then `package-lock.json` won't
change. `npm install` won't update dependency version. For CI environment, you
can use `npm ci` to install dependencies.

## NPM taobao mirrors

```
npm set registry https://registry.npm.taobao.org
npm set disturl https://npm.taobao.org/dist

# Optional
npm set sass_binary_site https://npm.taobao.org/mirrors/node-sass
npm set electron_mirror https://npm.taobao.org/mirrors/electron/
npm set puppeteer_download_host https://npm.taobao.org/mirrors
npm set chromedriver_cdnurl https://npm.taobao.org/mirrors/chromedriver
npm set operadriver_cdnurl https://npm.taobao.org/mirrors/operadriver
npm set phantomjs_cdnurl https://npm.taobao.org/mirrors/phantomjs
npm set selenium_cdnurl https://npm.taobao.org/mirrors/selenium
npm set node_inspector_cdnurl https://npm.taobao.org/mirrors/node-inspector
```
