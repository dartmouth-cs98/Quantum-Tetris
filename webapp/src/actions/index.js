import axios from 'axios';

// keys for actiontypes
const ROOT_URL = 'http://localhost:5000/api';

export const ActionTypes = {
  INCREMENT: 'INCREMENT',
  DECREMENT: 'DECREMENT',
  CREATE_PLAYER: 'CREATE_PLAYER',
  FETCH_PLAYER: 'FETCH_PLAYER',
  UPDATE_PLAYER: 'UPDATE_PLAYER',
  DELETE_PLAYER: 'DELETE_PLAYER',
  RANDOM_NUMBER: 'RANDOM_NUMBER',
  ERROR: 'ERROR',
};

/* *************** PLAYER ENDPOINTS ****************** */
// create player
export function createPlayer(newPlayer) {
  return (dispatch) => {
    axios.post(`${ROOT_URL}/createPlayer`, newPlayer)
      .then((response) => {
        dispatch({ type: ActionTypes.CREATE_PLAYER, payload: response.data });
      })
      .catch((error) => {
        dispatch({ type: ActionTypes.ERROR, error });
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
        dispatch({ type: ActionTypes.ERROR, error });
      });
  };
}

// update player
export function updatePlayer(newPlayer) {
  return (dispatch) => {
    axios.put(`${ROOT_URL}/updatePlayer`, newPlayer)
      .then((response) => {
        dispatch({ type: ActionTypes.UPDATE_PLAYER, payload: response.data });
      })
      .catch((error) => {
        dispatch({ type: ActionTypes.ERROR, error });
      });
  };
}

// delete player
export function deletePlayer(username) {
  return (dispatch) => {
    axios.delete(`${ROOT_URL}/deletePlayer/?username=${username}`)
      .then((response) => {
        dispatch({ type: ActionTypes.DELETE_PLAYER, payload: response.data });
      })
      .catch((error) => {
        dispatch({ type: ActionTypes.ERROR, error });
      });
  };
}
/* *************** QUANTUM ENDPOINTS ****************** */

// Get a random number NOTE: at the moment does not produce an actual random number
export function generateRandomNumber(randInt) {
  return (dispatch) => {
    axios.get(`${ROOT_URL}/generateRandomNumber/?randInt=${randInt}`)
      .then((response) => {
        dispatch({ type: ActionTypes.RANDOM_NUMBER, payload: response.data });
      })
      .catch((error) => {
        dispatch({ type: ActionTypes.ERROR, error });
      });
  };
}
