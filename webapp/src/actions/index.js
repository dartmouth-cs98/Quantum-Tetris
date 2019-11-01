import axios from 'axios';

// keys for actiontypes


const ROOT_URL = 'http://localhost:5000/api';

export const ActionTypes = {
  INCREMENT: 'INCREMENT',
  DECREMENT: 'DECREMENT',
  CREATE_PLAYER: 'CREATE_PLAYER',
  FETCH_PLAYER: 'FETCH_PLAYER',
  DELETE_PLAYER: 'DELETE_PLAYER',
  ERROR_ACTION: 'ERROR_ACTION',
};

// create player
export function createPlayer(newPlayer) {
  return (dispatch) => {
    axios.post(`${ROOT_URL}/createPlayer`, newPlayer)
      .then((response) => {
        dispatch({ type: ActionTypes.CREATE_PLAYER, payload: response.data });
      })
      .catch((error) => {
        dispatch({ type: ActionTypes.ERROR_ACTION, error });
      });
  };
}
// fetch player
export function fetchPlayer(username) {
  return (dispatch) => {
    axios.get(`${ROOT_URL}/fetchPlayer/?username=${username}`)
      .then((response) => {
        dispatch({ type: ActionTypes.FETCH_PLAYER, payload: response.data });
      })
      .catch((error) => {
        dispatch({ type: ActionTypes.ERROR_ACTION, error });
      });
  };
}

// delete player
export function deletePlayer(username) {
  return (dispatch) => {
    axios.delete(`${ROOT_URL}/deletePlayer`, username)
      .then((response) => {
        dispatch({ type: ActionTypes.DELETE_PLAYER, payload: response.data });
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
