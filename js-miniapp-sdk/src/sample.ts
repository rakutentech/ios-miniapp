// tslint:disable-next-line:variable-name
const MiniApp = require('./miniapp.js');

let miniAppInstance = new MiniApp();

function printUniqueId() {
  miniAppInstance
    .getUniqueId()
    .then(value => {
      document.getElementById('uniqueId').textContent = 'Unique ID: ' + value;
    })
    .catch(error => {
      console.log('ERROR:', error.message);
    });
}

let btnPrintUniqueId = document.getElementById('btnPrintUniqueId');
btnPrintUniqueId.addEventListener('click', (e: Event) => printUniqueId());
