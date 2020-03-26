import { MiniApp } from './miniapp.js';

let instance = new MiniApp.MiniAppImpl();
console.log(`Unique Id: ${instance.getUniqueId()}`)
