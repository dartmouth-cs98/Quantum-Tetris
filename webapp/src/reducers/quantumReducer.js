import { ActionTypes } from '../actions';

const QuantumReducer = (state = {
  randomNumber: 0,
  error: '',
}, action) => {
  switch (action.type) {
    case ActionTypes.RANDOM_NUMBER:
      return Object.assign({}, state, { randomNumber: action.payload.randomInt, error: '' });
    case ActionTypes.ERROR:
      return Object.assign({}, state, { error: action.error.response ? action.error.response.data : action.error.message });
    default:
      return state;
  }
};

export default QuantumReducer;
