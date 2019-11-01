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
    case ActionTypes.GET_PLAYER:
      return Object.assign({}, state, { user: action.payload, error: '' });
    case ActionTypes.ERROR:
      return Object.assign({}, state, { error: action.error.response.data });
    default:
      return state;
  }
};

export default PlayerReducer;
