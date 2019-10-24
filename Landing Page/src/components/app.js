import React from 'react';
import {
  BrowserRouter as Router,
  Route, Switch, NavLink,
} from 'react-router-dom';
import Counter from '../containers/counter';
import Controls from '../containers/controls';

const App = () => {
  const About = () => {
    return (
      <div>
        All there is to know about me
        <Counter />
        <Controls />
      </div>
    );
  };

  const Welcome = () => {
    return (
      <div>
        Welcome
        <Counter />
        <Controls />
      </div>

    );
  };

  const Test = (props) => {
    return (
      <div>
        ID: {props.match.params.id};
        <Counter />
        <Controls />
      </div>
    );
  };

  const FallBack = () => {
    return (
      <div>
        URL Not Found
        <Counter />
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
          <Route component={FallBack} />
        </Switch>
      </div>
    </Router>
  );
};

export default App;
