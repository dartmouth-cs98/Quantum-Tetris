import { ActionTypes } from '../actions';

const PlayerReducer = (state = {
  user: {
    username: 'Oliver',
    hiscore: 7,
  },
  error: '',
}, action) => {
  switch (action.type) {
    case ActionTypes.CREATE_PLAYER:
      return Object.assign({}, state, { user: action.payload, error: '' });
    case ActionTypes.FETCH_PLAYER:
      return Object.assign({}, state, { user: action.payload, error: '' });
    case ActionTypes.DELETE_PLAYER:
      return Object.assign({}, state, { user: '', error: '' });
    case ActionTypes.ERROR:
      return Object.assign({}, state, { error: action.error.response ? action.error.response.data : action.error.message });
    default:
      return state;
  }
};

export default PlayerReducer;
