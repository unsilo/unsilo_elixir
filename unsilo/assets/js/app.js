// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import $ from 'jquery';
import Cookies from 'js-cookie';
window.jQuery = $;
window.$ = $;
window.Cookies = Cookies;

import "phoenix_html"
import "bootstrap";
import "jquery-ui";
import "jquery.form";
import "action_btns";
import "utils";
import "jquery-ui/ui/widgets/sortable";
import "jquery-ui/ui/disable-selection";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

