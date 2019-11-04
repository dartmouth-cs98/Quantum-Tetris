// the starting point for your redux store
// this defines what your store state will look like
import { combineReducers } from 'redux';
import CountReducer from './count-reducer';

const rootReducer = combineReducers({
  count: CountReducer,
});

export default rootReducer;
