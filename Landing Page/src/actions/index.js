import axios from 'axios';

// keys for actiontypes


const ROOT_URL = 'http://127.0.0.1:5000/';

export const ActionTypes = {
  INCREMENT: 'INCREMENT',
  DECREMENT: 'DECREMENT',
  CREATE_PLAYER: 'CREATE_PLAYER',
  GET_PLAYER: 'GET_PLAYER',
  ERROR_ACTION: 'ERROR_ACTION',
};

// create player
export function createPlayer(newPlayer) {
  return (dispatch) => {
    axios.post(`${ROOT_URL}/createPlayer`, newPlayer)
      .then((response) => {
        dispatch({ type: ActionTypes.CREATE_PLAYER });
      })
      .catch((error) => {
        dispatch({ type: ActionTypes.ERROR_ACTION, error });
      });
  };
}
// get player
export function getPlayer(username) {
  return (dispatch) => {
    axios.get(`${ROOT_URL}/${username}/createPlayer`)
      .then((response) => {
        dispatch({ type: ActionTypes.GET_PLAYER, payload: response.data });
      })
      .catch((error) => {
        dispatch({ type: ActionTypes.ERROR_ACTION, error });
      });
  };
}


export function increment() {
  return {
    type: ActionTypes.INCREMENT,
    payload: null,
  };
}

export function decrement() {
  return {
    type: ActionTypes.DECREMENT,
    payload: null,
  };
}
