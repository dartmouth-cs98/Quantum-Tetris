/* eslint-disable no-mixed-operators */
/* eslint-disable no-bitwise */
// Generate UUID for each user
// Found at https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
const uuidv4 = require('uuid/v4');

function getUserId() {
  let userId = localStorage.getItem('userId');
  if (!userId) {
    userId = uuidv4();
    localStorage.setItem('userId', userId);
  }
  return userId;
}

window.onload = function WindowLoad(event) {
  console.log('userid:', getUserId());
  // We will then use the ID here to retrieve the user's highscore
};
