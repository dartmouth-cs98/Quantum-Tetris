/* eslint-disable max-len */
/* eslint-disable react/no-danger */
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import gameHTML from '../games/tetris.html';

// this can be dumb or smart component - connect works with either
class Game extends Component {
  constructor(props) {
    super(props);
    this.state = {
    };
  }

  static getHTML() {
    return ({ __html: '<div>Hello</div>' });
  }

  componentDidMount() {
    const script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'http://127.0.0.1:8887/games/Tetris.js';
    script.async = true;
    document.body.appendChild(script);
  }

  render() {
    return (
      <div>
        The Game
        <div dangerouslySetInnerHTML={{ __html: gameHTML }} />
      </div>
    );
  }
}

// <div dangerouslySetInnerHTML={{ __html: gameHTML }} />


// react-redux glue -- outputs Container that know state in props
// also with an optional HOC withRouter
export default withRouter(connect(null, null)(Game));
