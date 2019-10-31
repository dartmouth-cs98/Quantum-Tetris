// the starting point for your redux store
// this defines what your store state will look like
import { combineReducers } from 'redux';
import PlayerReducer from './playerReducer';

const rootReducer = combineReducers({
  player: PlayerReducer,
});

export default rootReducer;
