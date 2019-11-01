import React, { Component } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';


import { createPlayer, fetchPlayer, deletePlayer } from '../actions';

class Controls extends Component {
  constructor(props) {
    super(props);
    this.state = {
      newUsername: '',
      newHiscore: 0,
      fetchUsername: '',
      deleteUsername: '',
    };
  }

  onNewUserChange = (event) => {
    event.preventDefault();
    this.setState({ newUsername: event.target.value });
  }

  onNewHiscoreChange = (event) => {
    event.preventDefault();
    this.setState({ newHiscore: event.target.value });
  }

  onFetchUserChange = (event) => {
    event.preventDefault();
    this.setState({ fetchUsername: event.target.value });
  }

  onDeleteUserChange = (event) => {
    event.preventDefault();
    this.setState({ deleteUsername: event.target.value });
  }

  onUserCreate = (event) => {
    event.preventDefault();
    this.props.createPlayer({
      username: this.state.newUsername,
      hiscore: this.state.newHiscore,
    });
  }

  onUserFetch = (event) => {
    event.preventDefault();
    this.props.fetchPlayer(this.state.fetchUsername);
  }

  onUserDelete = (event) => {
    event.preventDefault();
    this.props.deletePlayer({
      username: this.state.deleteUsername,
    });
  }

  render() {
    return (
      <div>
        <h1>Current User</h1>
        <p>Name: {this.props.currUser.username}</p>
        <p>High Score: {this.props.currUser.hiscore}</p>
        <input type="input" onChange={this.onNewUserChange} value={this.state.newUsername} />
        <input type="input" onChange={this.onNewHiscoreChange} value={this.state.newHiscore} />
        <button type="button" onClick={this.onUserCreate}>New Player</button>
        <input type="input" onChange={this.onFetchUserChange} value={this.state.fetchUsername} />
        <button type="button" onClick={this.onUserFetch}>Fetch Player</button>
        <input type="input" onChange={this.onDeleteUserChange} value={this.state.deleteUsername} />
        <button type="button" onClick={this.onUserDelete}>Delete Player</button>
      </div>
    );
  }
}

const mapStateToProps = state => (
  {
    currUser: state.player.user,
  }
);

export default withRouter(connect(mapStateToProps, { createPlayer, fetchPlayer, deletePlayer })(Controls));
