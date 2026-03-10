const { JSDOM } = require('jsdom');
const dom = new JSDOM('<!DOCTYPE html><p>Hello world</p>', { url: "http://localhost/test" });
const window = dom.window;

console.log(window.location.pathname);
window.history.pushState({}, '', '/login');
console.log(window.location.pathname);
