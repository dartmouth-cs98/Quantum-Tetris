import React, { Component } from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';


import {
  createPlayer, fetchPlayer, deletePlayer, generateRandomNumber, determineSuperposition,
} from '../actions';

class Controls extends Component {
  constructor(props) {
    super(props);
    this.state = {
      newUsername: '',
      newHiscore: 0,
      fetchUsername: '',
      deleteUsername: '',
      randInt: 0,
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

  onRandIntChange = (event) => {
    event.preventDefault();
    this.setState({ randInt: event.target.value });
  }

  onUserCreate = (event) => {
    event.preventDefault();
    this.props.createPlayer({
      username: this.state.newUsername,
      hiscore: this.state.newHiscore,
    });
  }

  onUserUpdate = (event) => {
    event.preventDefault();
    this.props.updatePlayer({
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
    this.props.deletePlayer(this.state.deleteUsername);
  }

  onGenRandInt = (event) => {
    event.preventDefault();
    this.props.generateRandomNumber(this.state.randInt);
  }

  onSuperposition = (event) => {
    event.preventDefault();
    this.props.determineSuperposition({
      piece1: {
        name: 'Red',
        blocks: 5,
      },
      piece2: {
        name: 'Blue',
        blocks: 4,
      },
    });
  }

  render() {
    return (
      <div>
        <div>
          <h1>Current User</h1>
          <p>Name: {this.props.currUser.username}</p>
          <p>High Score: {this.props.currUser.hiscore}</p>
        </div>
        <div>
          <input type="input" onChange={this.onNewUserChange} value={this.state.newUsername} />
          <input type="input" onChange={this.onNewHiscoreChange} value={this.state.newHiscore} />
          <button type="button" onClick={this.onUserCreate}>New Player</button>
        </div>
        <div>
          <input type="input" onChange={this.onFetchUserChange} value={this.state.fetchUsername} />
          <button type="button" onClick={this.onUserFetch}>Fetch Player</button>
        </div>
        <div>
          <input type="input" onChange={this.onNewUserChange} value={this.state.newUsername} />
          <input type="input" onChange={this.onNewHiscoreChange} value={this.state.newHiscore} />
          <button type="button" onClick={this.onUserUpdate}>Update Player</button>
        </div>
        <div>
          <input type="input" onChange={this.onDeleteUserChange} value={this.state.deleteUsername} />
          <button type="button" onClick={this.onUserDelete}>Delete Player</button>
        </div>
        <div>
          <input type="input" onChange={this.onRandIntChange} value={this.state.randInt} />
          <button type="button" onClick={this.onGenRandInt}>Generate Random Int</button>
          <p>{this.props.randNum}</p>
        </div>
        <div>
          <button type="button" onClick={this.onSuperposition}>Pick State</button>
          <p>{this.props.piece ? this.props.piece.name : 'No Piece Selected'}</p>
        </div>
        <div>
          <h4>Errors:{this.props.error} </h4>
        </div>
      </div>
    );
  }
}

const mapStateToProps = state => (
  {
    currUser: state.player.user,
    randNum: state.quantum.randomNumber,
    piece: state.quantum.superposition,
    error: state.player.error,
  }
);

export default withRouter(connect(mapStateToProps, {
  createPlayer, fetchPlayer, deletePlayer, generateRandomNumber, determineSuperposition,
})(Controls));
