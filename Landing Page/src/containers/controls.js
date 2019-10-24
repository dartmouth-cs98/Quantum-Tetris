import React from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';


import { increment, decrement } from '../actions';

const Controls = (props) => {
  return (
    <div>
      <button type="button" onClick={props.increment}>+</button>
      <button type="button" onClick={props.decrement}>-</button>
    </div>
  );
};

export default withRouter(connect(null, { increment, decrement })(Controls));
