import React from 'react';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

// this can be dumb or smart component - connect works with either
const Game = React.createClass({
    render: function() {
      return (
        <div>
          <meta charSet="utf-8" />
          <meta name="viewport" content="width=device-width, user-scalable=no" />
          <title />
          <style type="text/css" dangerouslySetInnerHTML={{__html: "\n\n\t\tbody {\n\t\t\ttouch-action: none;\n\t\t\tmargin: 0;\n\t\t\tborder: 0 none;\n\t\t\tpadding: 0;\n\t\t\ttext-align: center;\n\t\t\tbackground-color: black;\n\t\t}\n\n\t\t#canvas {\n\t\t\tdisplay: block;\n\t\t\tmargin: 0;\n\t\t\tcolor: white;\n\t\t}\n\n\t\t#canvas:focus {\n\t\t\toutline: none;\n\t\t}\n\n\t\t.godot {\n\t\t\tfont-family: 'Noto Sans', 'Droid Sans', Arial, sans-serif;\n\t\t\tcolor: #e0e0e0;\n\t\t\tbackground-color: #3b3943;\n\t\t\tbackground-image: linear-gradient(to bottom, #403e48, #35333c);\n\t\t\tborder: 1px solid #45434e;\n\t\t\tbox-shadow: 0 0 1px 1px #2f2d35;\n\t\t}\n\n\n\t\t/* Status display\n\t\t * ============== */\n\n\t\t#status {\n\t\t\tposition: absolute;\n\t\t\tleft: 0;\n\t\t\ttop: 0;\n\t\t\tright: 0;\n\t\t\tbottom: 0;\n\t\t\tdisplay: flex;\n\t\t\tjustify-content: center;\n\t\t\talign-items: center;\n\t\t\t/* don't consume click events - make children visible explicitly */\n\t\t\tvisibility: hidden;\n\t\t}\n\n\t\t#status-progress {\n\t\t\twidth: 366px;\n\t\t\theight: 7px;\n\t\t\tbackground-color: #38363A;\n\t\t\tborder: 1px solid #444246;\n\t\t\tpadding: 1px;\n\t\t\tbox-shadow: 0 0 2px 1px #1B1C22;\n\t\t\tborder-radius: 2px;\n\t\t\tvisibility: visible;\n\t\t}\n\n\t\t@media only screen and (orientation:portrait) {\n\t\t\t#status-progress {\n\t\t\t\twidth: 61.8%;\n\t\t\t}\n\t\t}\n\n\t\t#status-progress-inner {\n\t\t\theight: 100%;\n\t\t\twidth: 0;\n\t\t\tbox-sizing: border-box;\n\t\t\ttransition: width 0.5s linear;\n\t\t\tbackground-color: #202020;\n\t\t\tborder: 1px solid #222223;\n\t\t\tbox-shadow: 0 0 1px 1px #27282E;\n\t\t\tborder-radius: 3px;\n\t\t}\n\n\t\t#status-indeterminate {\n\t\t\tvisibility: visible;\n\t\t\tposition: relative;\n\t\t}\n\n\t\t#status-indeterminate > div {\n\t\t\twidth: 4.5px;\n\t\t\theight: 0;\n\t\t\tborder-style: solid;\n\t\t\tborder-width: 9px 3px 0 3px;\n\t\t\tborder-color: #2b2b2b transparent transparent transparent;\n\t\t\ttransform-origin: center 21px;\n\t\t\tposition: absolute;\n\t\t}\n\n\t\t#status-indeterminate > div:nth-child(1) { transform: rotate( 22.5deg); }\n\t\t#status-indeterminate > div:nth-child(2) { transform: rotate( 67.5deg); }\n\t\t#status-indeterminate > div:nth-child(3) { transform: rotate(112.5deg); }\n\t\t#status-indeterminate > div:nth-child(4) { transform: rotate(157.5deg); }\n\t\t#status-indeterminate > div:nth-child(5) { transform: rotate(202.5deg); }\n\t\t#status-indeterminate > div:nth-child(6) { transform: rotate(247.5deg); }\n\t\t#status-indeterminate > div:nth-child(7) { transform: rotate(292.5deg); }\n\t\t#status-indeterminate > div:nth-child(8) { transform: rotate(337.5deg); }\n\n\t\t#status-notice {\n\t\t\tmargin: 0 100px;\n\t\t\tline-height: 1.3;\n\t\t\tvisibility: visible;\n\t\t\tpadding: 4px 6px;\n\t\t\tvisibility: visible;\n\t\t}\n\t" }} />
          <canvas id="canvas">
            HTML5 canvas appears to be unsupported in the current browser.<br />
            Please try updating or use a different browser.
          </canvas>
          <div id="status">
            <div id="status-progress" style={{display: 'none'}} oncontextmenu="event.preventDefault();"><div id="status-progress-inner" /></div>
            <div id="status-indeterminate" style={{display: 'none'}} oncontextmenu="event.preventDefault();">
              <div />
              <div />
              <div />
              <div />
              <div />
              <div />
              <div />
              <div />
            </div>
            <div id="status-notice" className="godot" style={{display: 'none'}} />
          </div>
        </div>
      );
    }
  });

// react-redux glue -- outputs Container that know state in props
// also with an optional HOC withRouter
export default withRouter(connect(null)(Game));
