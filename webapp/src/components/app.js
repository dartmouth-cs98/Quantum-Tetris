import React from 'react';
import {
  BrowserRouter as Router,
  Route, Switch, NavLink,
} from 'react-router-dom';
import Controls from '../containers/controls';

import Game from '../containers/game';

const App = () => {
  const About = () => {
    return (
      <div>
        All there is to know about me
        <Controls />
      </div>
    );
  };

  const Welcome = () => {
    return (
      <div>
        Welcome
        <Controls />
      </div>

    );
  };

  const Test = (props) => {
    return (
      <div>
        ID: {props.match.params.id};
        <Controls />
      </div>
    );
  };

  // THE GAME
  const theGame = () => {
    return (
      // GAME HTML
      <div>
        <Game />
      </div>
    );
  };

  const FallBack = () => {
    return (
      <div>
        URL Not Found
        <Controls />
      </div>
    );
  };

  const Nav = () => {
    return (
      <nav>
        <ul>
          <li><NavLink to="/" exact>Home</NavLink></li>
          <li><NavLink to="/about" exact>About</NavLink></li>
          <li><NavLink to="/test/id1">test id1</NavLink></li>
          <li><NavLink to="/test/id2">test id2</NavLink></li>
          <li><NavLink to="/game">Game</NavLink></li>
        </ul>
      </nav>
    );
  };
  return (
    <Router>
      <div>
        <Nav />
        <Switch>
          <Route exact path="/" component={Welcome} />
          <Route path="/about" component={About} />
          <Route exact path="/test/:id" component={Test} />
          <Route path="/game" component={theGame} />
          <Route component={FallBack} />
        </Switch>
      </div>
    </Router>
  );
};

export default App;
