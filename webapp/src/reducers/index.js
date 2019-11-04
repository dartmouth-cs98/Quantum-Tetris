// the starting point for your redux store
// this defines what your store state will look like
import { combineReducers } from 'redux';
import PlayerReducer from './playerReducer';
import QuantumReducer from './quantumReducer';

const rootReducer = combineReducers({
  player: PlayerReducer,
  quantum: QuantumReducer,
});

export default rootReducer;
