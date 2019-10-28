import React, { Component } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';


import { createPlayer } from '../actions';

class Controls extends Component {
  constructor(props) {
    super(props);
    this.state = {
      username: '',
    };
  }

  onUserChange = (event) => {
    event.preventDefault();
    this.setState({ username: event.target.value });
  }

  onUserCreate = (event) => {
    event.preventDefault();
    this.props.createPlayer({
      username: this.state.username,
      hiscore: 0,
    });
  }

  render() {
    return (
      <div>
        <input type="input" onChange={this.onUserChange} value={this.state.username} />
        <button type="button" onClick={this.onUserCreate}>New Player</button>
        <h1>Current User</h1>
        <p>Name: {this.props.currUser.username}</p>
        <p>High Score: {this.props.currUser.hiscore}</p>
      </div>
    );
  }
}

const mapStateToProps = state => (
  {
    currUser: state.count.user,
  }
);

export default withRouter(connect(mapStateToProps, { createPlayer })(Controls));
